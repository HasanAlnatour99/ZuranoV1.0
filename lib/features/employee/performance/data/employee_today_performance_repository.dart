import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/sale_reporting.dart';
import '../../../../core/firestore/firestore_paths.dart';
import '../../../../core/firestore/firestore_serializers.dart';
import '../../../../core/firestore/firestore_write_payload.dart';
import '../../../employees/data/models/employee.dart';
import '../../../employee_today/data/models/et_attendance_day.dart';
import '../../../employee_today/data/repositories/employee_today_attendance_repository.dart';
import '../../../sales/data/models/sale.dart';
import 'employee_performance_scoring.dart';
import 'employee_today_performance_model.dart';

/// Computes balanced performance, optionally mirrors to [employeeDailyPerformance].
class EmployeeTodayPerformanceRepository {
  EmployeeTodayPerformanceRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// Dedupe Firestore writes when recomputed snapshot unchanged.
  final Map<String, String> _lastPersistSignature = {};

  static ({DateTime start, DateTime endExclusive}) _localDayBounds(
    DateTime day,
  ) {
    final start = DateTime(day.year, day.month, day.day);
    final endExclusive = start.add(const Duration(days: 1));
    return (start: start, endExclusive: endExclusive);
  }

  /// Compact local calendar key `yyyyMMdd`.
  static String localDateKey(DateTime day) {
    final y = day.year.toString().padLeft(4, '0');
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  Stream<EmployeeTodayPerformanceModel> watchTodayPerformance({
    required String salonId,
    required String employeeId,
    required DateTime dayLocal,
  }) {
    FirestoreWritePayload.assertSalonId(salonId);
    final bounds = _localDayBounds(dayLocal);
    final dateKey = localDateKey(dayLocal);
    final docId = '${dateKey}_$employeeId';

    final salesQuery = _firestore
        .collection(FirestorePaths.salonSales(salonId))
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: SaleStatuses.completed)
        .where(
          'soldAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(bounds.start),
        )
        .where('soldAt', isLessThan: Timestamp.fromDate(bounds.endExclusive))
        .orderBy('soldAt', descending: true)
        .limit(500);

    final employeeRef = _firestore.doc(
      FirestorePaths.salonEmployee(salonId, employeeId),
    );

    final dayId = EmployeeTodayAttendanceRepository.attendanceDayId(
      employeeId,
      EmployeeTodayAttendanceRepository.compactDateKey(dayLocal),
    );
    final attendanceRef = _firestore.doc(
      FirestorePaths.salonAttendanceDay(salonId, dayId),
    );

    final violationsQuery = _firestore
        .collection(FirestorePaths.salonViolations(salonId))
        .where('employeeId', isEqualTo: employeeId)
        .where(
          'occurredAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(bounds.start),
        )
        .where('occurredAt', isLessThan: Timestamp.fromDate(bounds.endExclusive));

    final reviewsQuery = _firestore
        .collection(FirestorePaths.salonReviews(salonId))
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(bounds.start),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(bounds.endExclusive));

    final perfRef = _firestore.doc(
      FirestorePaths.salonEmployeeDailyPerformanceDoc(salonId, docId),
    );

    late final StreamController<EmployeeTodayPerformanceModel> controller;
    controller = StreamController<EmployeeTodayPerformanceModel>(
      onListen: () {
        QuerySnapshot<Map<String, dynamic>>? lastSales;
        DocumentSnapshot<Map<String, dynamic>>? lastEmployee;
        DocumentSnapshot<Map<String, dynamic>>? lastAttendance;
        QuerySnapshot<Map<String, dynamic>>? lastViolations;
        QuerySnapshot<Map<String, dynamic>>? lastReviews;
        var violationsQueryUnavailable = false;
        var reviewsQueryUnavailable = false;

        void emit() {
          if (lastSales == null ||
              lastEmployee == null ||
              lastAttendance == null) {
            return;
          }
          final rawEmp = lastEmployee!.data();
          final weights = EmployeePerformanceWeights.fromFirestore(
            rawEmp?['performanceWeights'],
          );

          final Employee emp;
          if (!lastEmployee!.exists || rawEmp == null) {
            emp = Employee(
              id: employeeId,
              salonId: salonId,
              name: '',
              email: '',
              role: 'barber',
            );
          } else {
            emp = Employee.fromJson({
              ...rawEmp,
              'id': employeeId,
              'salonId': salonId,
            });
          }

          final day = lastAttendance!.exists
              ? EtAttendanceDay.fromFirestore(lastAttendance!)
              : null;

          final violationsCount = violationsQueryUnavailable
              ? 0
              : (lastViolations?.docs.length ?? 0);

          final ratingsToday = _ratingsForEmployeeToday(
            docs: reviewsQueryUnavailable || lastReviews == null
                ? const []
                : lastReviews!.docs,
            employeeId: employeeId,
            start: bounds.start,
            endExclusive: bounds.endExclusive,
          );

          final model = _buildModel(
            salesSnapshot: lastSales!,
            employee: emp,
            employeeId: employeeId,
            dateKey: dateKey,
            attendanceDay: day,
            violationsCount: violationsCount,
            ratingsToday: ratingsToday,
            weights: weights,
          );

          controller.add(model);
          unawaited(
            _persistPerformance(
              ref: perfRef,
              salonId: salonId,
              docId: docId,
              model: model,
            ),
          );
        }

        final subSales = salesQuery.snapshots().listen(
          (s) {
            lastSales = s;
            emit();
          },
          onError: controller.addError,
        );
        final subEmp = employeeRef.snapshots().listen(
          (e) {
            lastEmployee = e;
            emit();
          },
          onError: controller.addError,
        );
        final subAtt = attendanceRef.snapshots().listen(
          (e) {
            lastAttendance = e;
            emit();
          },
          onError: controller.addError,
        );
        final subVio = violationsQuery.snapshots().listen(
          (s) {
            violationsQueryUnavailable = false;
            lastViolations = s;
            emit();
          },
          onError: (Object e, StackTrace st) {
            violationsQueryUnavailable = true;
            lastViolations = null;
            emit();
          },
        );
        final subRev = reviewsQuery.snapshots().listen(
          (s) {
            reviewsQueryUnavailable = false;
            lastReviews = s;
            emit();
          },
          onError: (Object e, StackTrace st) {
            reviewsQueryUnavailable = true;
            lastReviews = null;
            emit();
          },
        );

        controller.onCancel = () async {
          await subSales.cancel();
          await subEmp.cancel();
          await subAtt.cancel();
          await subVio.cancel();
          await subRev.cancel();
        };
      },
    );

    return controller.stream;
  }

  List<double> _ratingsForEmployeeToday({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    required String employeeId,
    required DateTime start,
    required DateTime endExclusive,
  }) {
    final out = <double>[];
    for (final doc in docs) {
      final d = doc.data();
      final barber =
          (d['barberId'] ?? d['employeeId'])?.toString().trim() ?? '';
      if (barber != employeeId) continue;
      final created = FirestoreSerializers.dateTime(d['createdAt']);
      if (created == null) continue;
      if (created.isBefore(start) || !created.isBefore(endExclusive)) {
        continue;
      }
      final r = FirestoreSerializers.doubleValue(d['rating']);
      if (r > 0) out.add(r.clamp(0, 5));
    }
    return out;
  }

  EmployeeTodayPerformanceModel _buildModel({
    required QuerySnapshot<Map<String, dynamic>> salesSnapshot,
    required Employee employee,
    required String employeeId,
    required String dateKey,
    required EtAttendanceDay? attendanceDay,
    required int violationsCount,
    required List<double> ratingsToday,
    required EmployeePerformanceWeights weights,
  }) {
    final pct = employee.salesCommissionPercentFallback;

    var servicesCount = 0;
    var revenue = 0.0;
    var commission = 0.0;

    for (final doc in salesSnapshot.docs) {
      final sale = Sale.fromJson(doc.data());
      revenue += sale.total;
      final stored = sale.commissionAmount;
      commission +=
          stored ??
          (pct > 0 ? sale.total * (pct > 100 ? 100 : pct) / 100 : 0);
      for (final line in sale.lineItems) {
        servicesCount += line.quantity;
      }
    }

    final dailyServicesTarget = employee.dailyTargetServices;
    final dailyRevenueTarget = employee.dailyTargetRevenue;

    final salesSc = salesScoreComponent(
      revenue: revenue,
      dailyRevenueTarget: dailyRevenueTarget,
    );
    final servicesSc = servicesScoreComponent(
      servicesCount: servicesCount,
      dailyServicesTarget: dailyServicesTarget,
    );
    final attendanceSc = attendanceScoreComponent(attendanceDay);
    final ratingSc = ratingScoreComponent(ratingsToday: ratingsToday);
    final disciplineSc = disciplineScoreComponent(violationsCount);

    final finalScore = weightedFinalScore(
      salesScore: salesSc,
      servicesScore: servicesSc,
      attendanceScore: attendanceSc,
      ratingScore: ratingSc,
      disciplineScore: disciplineSc,
      w: weights,
    );

    double? avgRating;
    if (ratingsToday.isNotEmpty) {
      avgRating =
          ratingsToday.fold<double>(0, (a, b) => a + b) / ratingsToday.length;
    }

    return EmployeeTodayPerformanceModel(
      employeeId: employeeId,
      dateKey: dateKey,
      servicesCount: servicesCount,
      revenue: revenue,
      commission: commission,
      dailyServicesTarget: dailyServicesTarget,
      dailyRevenueTarget: dailyRevenueTarget,
      salesScore: salesSc,
      servicesScore: servicesSc,
      attendanceScore: attendanceSc,
      ratingScore: ratingSc,
      disciplineScore: disciplineSc,
      finalScore: finalScore,
      level: levelFromFinalScore(finalScore),
      averageRatingToday: avgRating,
      violationsCount: violationsCount,
    );
  }

  Future<void> _persistPerformance({
    required DocumentReference<Map<String, dynamic>> ref,
    required String salonId,
    required String docId,
    required EmployeeTodayPerformanceModel model,
  }) async {
    final key = '$salonId|$docId';
    final sig =
        '${model.finalScore.toStringAsFixed(2)}|${model.revenue.toStringAsFixed(2)}|${model.servicesCount}|${model.attendanceScore.toStringAsFixed(2)}|${model.violationsCount}|${model.ratingScore.toStringAsFixed(2)}';
    if (_lastPersistSignature[key] == sig) return;
    _lastPersistSignature[key] = sig;

    try {
      await ref.set(
        {
          'salonId': salonId,
          'employeeId': model.employeeId,
          'dateKey': model.dateKey,
          'servicesCount': model.servicesCount,
          'revenue': model.revenue,
          'commission': model.commission,
          'dailyRevenueTarget': model.dailyRevenueTarget,
          'dailyServicesTarget': model.dailyServicesTarget,
          'salesScore': model.salesScore,
          'servicesScore': model.servicesScore,
          'attendanceScore': model.attendanceScore,
          'ratingScore': model.ratingScore,
          'disciplineScore': model.disciplineScore,
          'finalScore': model.finalScore,
          'level': model.level.name,
          'averageRating': model.averageRatingToday,
          'violationsCount': model.violationsCount,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on Object {
      // Ignore persist failures (rules / offline); UI still shows computed stream.
    }
  }
}
