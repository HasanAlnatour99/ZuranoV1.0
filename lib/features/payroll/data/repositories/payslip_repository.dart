import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/payroll_statuses.dart';
import '../../../../core/firestore/firestore_json_helpers.dart';
import '../../../../core/firestore/firestore_paths.dart';
import '../../../../core/firestore/firestore_write_payload.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../employees/data/models/employee.dart';
import '../models/payroll_ai_summary_model.dart';
import '../models/payroll_result_model.dart';
import '../models/payroll_run_model.dart';
import '../models/payslip_line_model.dart';
import '../models/payslip_model.dart';
import '../payroll_constants.dart';

class PayslipRepository {
  PayslipRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _payslips(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonPayslips(salonId));
  }

  /// Visible approved/paid payslip for [year]/[month], with ordered lines.
  Stream<PayslipModel?> watchEmployeePayslip({
    required String salonId,
    required String employeeId,
    required int year,
    required int month,
  }) {
    final sid = salonId.trim();
    final eid = employeeId.trim();
    if (sid.isEmpty || eid.isEmpty) {
      return Stream<PayslipModel?>.value(null);
    }

    return _payslips(sid)
        .where('employeeId', isEqualTo: eid)
        .where('employeeVisible', isEqualTo: true)
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .limit(1)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) {
            return null;
          }
          final doc = snapshot.docs.first;
          final linesSnap = await doc.reference
              .collection(FirestorePaths.payslipLines)
              .orderBy('displayOrder')
              .get();
          final lines = linesSnap.docs
              .map(PayslipLineModel.fromFirestore)
              .toList(growable: false);
          return PayslipModel.fromFirestore(doc, lines);
        });
  }

  /// All payslips for a calendar month (owner finance / reporting). No line subcollection reads.
  Stream<List<PayslipModel>> watchPayslipsForSalonCalendarMonth({
    required String salonId,
    required int year,
    required int month,
    int limit = 500,
  }) {
    final sid = salonId.trim();
    if (sid.isEmpty || year <= 0 || month <= 0 || month > 12) {
      return Stream<List<PayslipModel>>.value(const []);
    }
    return _payslips(sid)
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PayslipModel.fromFirestore(doc, const []))
              .toList(growable: false),
        );
  }

  Stream<List<PayslipModel>> watchRecentEmployeePayslips({
    required String salonId,
    required String employeeId,
    int limit = 6,
  }) {
    final sid = salonId.trim();
    final eid = employeeId.trim();
    if (sid.isEmpty || eid.isEmpty) {
      return Stream<List<PayslipModel>>.value(const []);
    }

    return _payslips(sid)
        .where('employeeId', isEqualTo: eid)
        .where('employeeVisible', isEqualTo: true)
        .orderBy('periodStart', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
          final out = <PayslipModel>[];
          for (final doc in snapshot.docs) {
            final linesSnap = await doc.reference
                .collection(FirestorePaths.payslipLines)
                .orderBy('displayOrder')
                .get();
            final lines = linesSnap.docs
                .map(PayslipLineModel.fromFirestore)
                .toList(growable: false);
            out.add(PayslipModel.fromFirestore(doc, lines));
          }
          return out;
        });
  }

  Future<PayslipModel?> getPayslipForEmployee({
    required String salonId,
    required String employeeId,
    required String payslipId,
  }) async {
    final sid = salonId.trim();
    final eid = employeeId.trim();
    final pid = payslipId.trim();
    if (sid.isEmpty || eid.isEmpty || pid.isEmpty) {
      return null;
    }
    final doc = await _payslips(sid).doc(pid).get();
    if (!doc.exists) {
      return null;
    }
    final data = doc.data();
    if (data == null) {
      return null;
    }
    if (looseStringFromJson(data['employeeId']) != eid) {
      return null;
    }
    if (trueBoolFromJson(data['employeeVisible']) != true) {
      return null;
    }
    final linesSnap = await doc.reference
        .collection(FirestorePaths.payslipLines)
        .orderBy('displayOrder')
        .get();
    final lines = linesSnap.docs
        .map(PayslipLineModel.fromFirestore)
        .toList(growable: false);
    return PayslipModel.fromFirestore(doc, lines);
  }

  Stream<PayrollAiSummaryModel?> watchSalaryNotes({
    required String salonId,
    required String payslipId,
  }) {
    final sid = salonId.trim();
    final pid = payslipId.trim();
    if (sid.isEmpty || pid.isEmpty) {
      return Stream<PayrollAiSummaryModel?>.value(null);
    }
    return _firestore
        .doc(
          '${FirestorePaths.salonPayslip(sid, pid)}/${FirestorePaths.payslipAiAnalysis}/main',
        )
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            return null;
          }
          return PayrollAiSummaryModel.fromFirestore(doc);
        });
  }

  /// Same id convention as [`payslipIdFor`] in Functions (`payrollShared.ts`).
  static String payslipDocumentId(String employeeId, int year, int month) {
    final trimmed = employeeId.trim();
    final mm = month.clamp(1, 12);
    return '${trimmed}_${year.toString()}${mm.toString().padLeft(2, '0')}';
  }

  /// Deletes payslip docs and their `lines` for the given employees in [year]/[month].
  Future<void> deleteMonthlyPayslipsForEmployees({
    required String salonId,
    required int year,
    required int month,
    required Set<String> employeeIds,
  }) async {
    final sid = salonId.trim();
    if (sid.isEmpty || employeeIds.isEmpty) return;

    for (final rawId in employeeIds) {
      final employeeId = rawId.trim();
      if (employeeId.isEmpty) continue;
      final ref = _payslips(sid).doc(payslipDocumentId(employeeId, year, month));
      await _deleteLinesSubcollection(ref);
      final snap = await ref.get();
      if (snap.exists) {
        await ref.delete();
      }
    }
  }

  /// Mirrors owner `payroll_runs` totals into salon `payslips` for employee apps.
  Future<void> upsertFromPayrollRunSnapshot({
    required PayrollRunModel persistedRun,
    required List<PayrollResultModel> persistedResults,
    required String currencyCode,
    Map<String, Employee?> employeesById = const {},
  }) async {
    final sid = persistedRun.salonId.trim();
    final y = persistedRun.year;
    final m = persistedRun.month;
    if (sid.isEmpty ||
        persistedResults.isEmpty ||
        y <= 0 ||
        (m <= 0 || m > 12)) {
      return;
    }

    final st = persistedRun.status;
    if (st != PayrollRunStatuses.approved && st != PayrollRunStatuses.paid) {
      return;
    }

    final payslipStatus =
        st == PayrollRunStatuses.paid ? PayrollStatuses.paid : PayrollStatuses.approved;
    final employeeVisible = payslipStatus == PayrollStatuses.paid;

    final byEmployee = <String, List<PayrollResultModel>>{};
    for (final row in persistedResults) {
      final id = row.employeeId.trim();
      if (id.isEmpty) continue;
      byEmployee.putIfAbsent(id, () => []).add(row);
    }

    final periodStart = DateTime(y, m, 1);
    final periodEnd = DateTime(y, m + 1, 0, 23, 59, 59);

    for (final entry in byEmployee.entries) {
      await _upsertEmployeePayslipFromResults(
        salonId: sid,
        employeeId: entry.key,
        rows: entry.value,
        employee: employeesById[entry.key],
        year: y,
        month: m,
        periodStart: periodStart,
        periodEnd: periodEnd,
        currencyCode: currencyCode,
        persistedRun: persistedRun,
        payslipStatus: payslipStatus,
        employeeVisible: employeeVisible,
      );
    }
  }

  Future<void> _deleteLinesSubcollection(
    DocumentReference<Map<String, dynamic>> payslipRef,
  ) async {
    const chunk = 420;
    while (true) {
      final snap = await payslipRef
          .collection(FirestorePaths.payslipLines)
          .limit(chunk)
          .get();
      if (snap.docs.isEmpty) return;
      var batch = _firestore.batch();
      var n = 0;
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
        n++;
        if (n >= chunk) {
          await batch.commit();
          batch = _firestore.batch();
          n = 0;
        }
      }
      if (n > 0) await batch.commit();
    }
  }

  Future<void> _upsertEmployeePayslipFromResults({
    required String salonId,
    required String employeeId,
    required List<PayrollResultModel> rows,
    required Employee? employee,
    required int year,
    required int month,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String currencyCode,
    required PayrollRunModel persistedRun,
    required String payslipStatus,
    required bool employeeVisible,
  }) async {
    final payslipId = payslipDocumentId(employeeId, year, month);
    final payslipRef = _payslips(salonId).doc(payslipId);

    double totalEarnings = 0;
    double totalDeductions = 0;
    for (final row in rows) {
      if (row.classification == PayrollElementClassifications.earning) {
        totalEarnings += row.amount;
      } else if (row.classification == PayrollElementClassifications.deduction) {
        totalDeductions += row.amount;
      }
    }
    final netPay = totalEarnings - totalDeductions;

    var baseSalary = 0.0;
    var commissionAmount = 0.0;
    var commissionPct = 0.0;
    for (final row in rows) {
      if (row.elementCode == 'basic_salary') {
        baseSalary += row.amount;
      } else if (row.elementCode == 'commission') {
        commissionAmount += row.amount;
        final r = row.rate;
        if (r != null && r > commissionPct) {
          commissionPct = r;
        }
      }
    }

    final nameFromEmp = employee?.name.trim();
    var employeeName = (nameFromEmp != null && nameFromEmp.isNotEmpty)
        ? nameFromEmp
        : '';
    if (employeeName.isEmpty) {
      for (final r in rows) {
        final n = r.employeeName.trim();
        if (n.isNotEmpty) {
          employeeName = n;
          break;
        }
      }
    }
    if (employeeName.isEmpty) {
      employeeName = 'Employee';
    }
    employeeName = formatTeamMemberName(employeeName);

    final role = employee?.role.trim().isNotEmpty == true
        ? employee!.role.trim()
        : 'barber';

    final visibleRows = rows
        .where(
          (r) =>
              r.visibleOnPayslip &&
              (r.classification == PayrollElementClassifications.earning ||
                  r.classification == PayrollElementClassifications.deduction),
        )
        .toList(growable: false)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    await _deleteLinesSubcollection(payslipRef);

    final snap = await payslipRef.get();
    final existed = snap.exists;
    final hadCreated = snap.data()?['createdAt'];

    final cur = currencyCode.trim().isEmpty ? 'USD' : currencyCode.trim();

    final payload = <String, dynamic>{
      'id': payslipId,
      'salonId': salonId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'employeeRole': role,
      'employeePhotoUrl': employee?.avatarUrl?.trim(),
      'year': year,
      'month': month,
      'periodStart': Timestamp.fromDate(periodStart),
      'periodEnd': Timestamp.fromDate(periodEnd),
      'currency': cur,
      'status': payslipStatus,
      'employeeVisible': employeeVisible,
      'payrollRunId': persistedRun.id,
      'baseSalary': baseSalary,
      'serviceRevenue': 0,
      'commissionPercent': commissionPct,
      'commissionAmount': commissionAmount,
      'totalEarnings': totalEarnings,
      'totalDeductions': totalDeductions,
      'netPay': netPay,
      'servicesCount': 0,
      'attendanceDaysPresent': 0,
      'attendanceRequiredDays': 0,
      'lateCount': 0,
      'absenceCount': 0,
      'missingCheckoutCount': 0,
      'generatedBy': persistedRun.createdBy ?? '',
      'approvedBy': persistedRun.approvedBy ?? '',
      'paidBy': persistedRun.paidBy ?? '',
    };

    final genAt = persistedRun.createdAt != null
        ? Timestamp.fromDate(persistedRun.createdAt!)
        : null;
    if (genAt != null) {
      payload['generatedAt'] = genAt;
    } else if (!existed || hadCreated == null) {
      payload['generatedAt'] = FieldValue.serverTimestamp();
    }

    payload['approvedAt'] = persistedRun.approvedAt != null
        ? Timestamp.fromDate(persistedRun.approvedAt!)
        : null;
    payload['paidAt'] = persistedRun.paidAt != null
        ? Timestamp.fromDate(persistedRun.paidAt!)
        : null;

    if (!existed || hadCreated == null) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    }
    payload['updatedAt'] = FieldValue.serverTimestamp();

    await payslipRef.set(payload, SetOptions(merge: true));

    if (visibleRows.isEmpty) return;

    var batch = _firestore.batch();
    var ops = 0;
    const maxOps = 450;

    Future<void> commitBatch() async {
      await batch.commit();
      batch = _firestore.batch();
      ops = 0;
    }

    for (var i = 0; i < visibleRows.length; i++) {
      final row = visibleRows[i];
      var lineDocId =
          '${i}_${row.elementCode}_${row.displayOrder}'
              .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      if (lineDocId.length > 100) lineDocId = lineDocId.substring(0, 100);

      final lineRef =
          payslipRef.collection(FirestorePaths.payslipLines).doc(lineDocId);
      final earning = PayrollElementClassifications.earning;

      batch.set(lineRef, {
        'id': lineDocId,
        'salonId': salonId,
        'payslipId': payslipId,
        'employeeId': employeeId,
        'elementCode': row.elementCode,
        'elementName': row.elementName,
        'type': row.classification == earning ? 'earning' : 'deduction',
        'amount': row.amount,
        'sourceType': row.sourceType,
        'sourceRef': row.sourceRefIds.isNotEmpty
            ? row.sourceRefIds.first
            : (row.calculationSource ?? ''),
        'displayOrder': row.displayOrder != 0 ? row.displayOrder : i,
        'createdAt': FieldValue.serverTimestamp(),
      });
      ops++;
      if (ops >= maxOps) await commitBatch();
    }
    if (ops > 0) await commitBatch();
  }
}
