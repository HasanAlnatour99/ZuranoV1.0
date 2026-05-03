import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../../../../core/firestore/firestore_write_payload.dart';
import '../../../employee_today/data/models/et_attendance_day.dart';
import '../models/attendance_correction_request_model.dart';
import '../models/attendance_record_model.dart';
import '../models/attendance_summary_model.dart';
import '../../../owner_settings/shifts/data/models/employee_schedule_model.dart';

class TeamMemberAttendanceRepository {
  TeamMemberAttendanceRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _attendanceRef(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonAttendance(salonId));
  }

  /// Employee-submitted punch corrections (`attendanceCorrectionRequests`).
  CollectionReference<Map<String, dynamic>> _correctionRequestsRef(
    String salonId,
  ) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(
      FirestorePaths.salonAttendanceCorrectionRequests(salonId),
    );
  }

  CollectionReference<Map<String, dynamic>> _auditLogsRef(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonAuditLogs(salonId));
  }

  DocumentReference<Map<String, dynamic>> _scheduleRef(
    String salonId,
    String employeeId,
    DateTime date,
  ) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final scheduleId = '${employeeId}_$y$m$d';
    return _firestore.doc(
      FirestorePaths.salonEmployeeSchedule(salonId, scheduleId),
    );
  }

  String attendanceDocId({required String employeeId, required DateTime date}) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${employeeId}_$y$m$d';
  }

  int dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return int.parse('$y$m$d');
  }

  String monthKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$y-$m';
  }

  /// ISO week label `yyyy-'W'ww` based on the calendar day in local time.
  static String weekKey(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    final thursday = local.add(Duration(days: 4 - local.weekday));
    var y = thursday.year;
    var jan4 = DateTime(y, 1, 4);
    var week1Thursday = jan4.add(Duration(days: 4 - jan4.weekday));
    var diffDays = thursday.difference(week1Thursday).inDays;
    if (diffDays < 0) {
      y--;
      jan4 = DateTime(y, 1, 4);
      week1Thursday = jan4.add(Duration(days: 4 - jan4.weekday));
      diffDays = thursday.difference(week1Thursday).inDays;
    }
    final week = 1 + diffDays ~/ 7;
    return '$y-W${week.toString().padLeft(2, '0')}';
  }

  Stream<AttendanceRecordModel?> watchTodayAttendance({
    required String salonId,
    required String employeeId,
    required DateTime today,
  }) {
    final dayStart = DateTime(today.year, today.month, today.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final canonicalId = attendanceDocId(employeeId: employeeId, date: dayStart);
    final legacyRef = _attendanceRef(salonId).doc(canonicalId);
    final dayDocId = '${dateKey(dayStart)}_$employeeId';
    final dayRef = _firestore.doc(
      FirestorePaths.salonAttendanceDay(salonId, dayDocId),
    );
    final rangeQuery = _attendanceRef(salonId)
        .where('employeeId', isEqualTo: employeeId)
        .where('workDate', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('workDate', isLessThan: Timestamp.fromDate(dayEnd));

    DocumentSnapshot<Map<String, dynamic>>? lastLegacy;
    DocumentSnapshot<Map<String, dynamic>>? lastDay;
    QuerySnapshot<Map<String, dynamic>>? lastRange;

    void mergeInto(
      Map<String, AttendanceRecordModel> byId,
      AttendanceRecordModel record,
    ) {
      final existing = byId[record.id];
      if (existing == null) {
        byId[record.id] = record;
        return;
      }
      if (existing.checkInAt == null && record.checkInAt != null) {
        byId[record.id] = record;
      }
    }

    AttendanceRecordModel? emitMerged() {
      final byId = <String, AttendanceRecordModel>{};

      if (lastRange != null) {
        for (final d in lastRange!.docs) {
          mergeInto(byId, AttendanceRecordModel.fromDoc(d));
        }
      }
      if (lastLegacy != null && lastLegacy!.exists) {
        mergeInto(byId, AttendanceRecordModel.fromDoc(lastLegacy!));
      }
      final day = lastDay != null && lastDay!.exists
          ? EtAttendanceDay.fromFirestore(lastDay!)
          : null;
      if (day != null &&
          (day.firstPunchInAt != null || day.totalPunches > 0)) {
        mergeInto(
          byId,
          _attendanceRecordFromEmployeeDay(
            day: day,
            calendarDay: dayStart,
            canonicalDocId: canonicalId,
          ),
        );
      }

      return _pickBestTodayCandidate(byId, canonicalId);
    }

    final subs = <StreamSubscription<dynamic>>[];
    late final StreamController<AttendanceRecordModel?> controller;

    void emit() {
      if (!controller.isClosed) {
        controller.add(emitMerged());
      }
    }

    controller = StreamController<AttendanceRecordModel?>.broadcast(
      onListen: () {
        if (subs.isNotEmpty) {
          return;
        }
        subs.addAll([
          legacyRef.snapshots().listen(
            (snap) {
              lastLegacy = snap;
              emit();
            },
            onError: controller.addError,
          ),
          dayRef.snapshots().listen(
            (snap) {
              lastDay = snap;
              emit();
            },
            onError: controller.addError,
          ),
          rangeQuery.snapshots().listen(
            (snap) {
              lastRange = snap;
              emit();
            },
            onError: controller.addError,
          ),
        ]);
      },
      onCancel: () {
        for (final s in subs) {
          s.cancel();
        }
        subs.clear();
      },
    );
    return controller.stream;
  }

  static AttendanceRecordModel? _pickBestTodayCandidate(
    Map<String, AttendanceRecordModel> byId,
    String canonicalDocId,
  ) {
    if (byId.isEmpty) return null;
    final values = byId.values.toList();
    final withCheckIn = values.where((r) => r.checkInAt != null).toList();
    if (withCheckIn.isNotEmpty) {
      withCheckIn.sort((a, b) {
        final aCanon = a.id == canonicalDocId ? 0 : 1;
        final bCanon = b.id == canonicalDocId ? 0 : 1;
        return aCanon.compareTo(bCanon);
      });
      return withCheckIn.first;
    }
    final canonical = byId[canonicalDocId];
    if (canonical != null) return canonical;
    return values.first;
  }

  static String _mapEmployeeDayStatusToLegacyRow(String status) {
    if (status == 'checkedIn' ||
        status == 'backFromBreak' ||
        status == 'checkedOut') {
      return 'present';
    }
    return switch (status) {
      'onBreak' => 'onBreak',
      'missingPunch' => 'incomplete',
      'notStarted' => 'absent',
      'pendingCorrection' => 'incomplete',
      'invalidSequence' => 'incomplete',
      'correctionApproved' => 'present',
      'correctionRejected' => 'present',
      _ => status,
    };
  }

  static AttendanceRecordModel _attendanceRecordFromEmployeeDay({
    required EtAttendanceDay day,
    required DateTime calendarDay,
    required String canonicalDocId,
  }) {
    final y = calendarDay.year.toString().padLeft(4, '0');
    final m = calendarDay.month.toString().padLeft(2, '0');
    final d = calendarDay.day.toString().padLeft(2, '0');
    final iso = '$y-$m-$d';
    final dk = int.parse('$y$m$d');
    return AttendanceRecordModel(
      id: canonicalDocId,
      salonId: day.salonId,
      employeeId: day.employeeId,
      employeeName: day.employeeName,
      attendanceDate: iso,
      dateKey: dk,
      weekKey: weekKey(calendarDay),
      monthKey: '${calendarDay.year}-${calendarDay.month.toString().padLeft(2, '0')}',
      checkInAt: day.firstPunchInAt,
      checkOutAt: day.lastPunchOutAt,
      status: _mapEmployeeDayStatusToLegacyRow(day.status),
      source: 'employee_app',
      lateMinutes: day.lateMinutes,
      earlyExitMinutes: day.earlyExitMinutes,
      missingCheckout: day.hasMissingPunch,
      manualEdited: false,
      notes: '',
    );
  }

  Stream<EmployeeScheduleModel?> watchTodayAssignedSchedule({
    required String salonId,
    required String employeeId,
    required DateTime today,
  }) {
    return _scheduleRef(salonId, employeeId, today).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return EmployeeScheduleModel.fromFirestore(doc);
    });
  }

  Stream<List<AttendanceRecordModel>> watchRecentAttendance({
    required String salonId,
    required String employeeId,
    int limit = 10,
  }) {
    return _attendanceRef(salonId)
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('workDate', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(AttendanceRecordModel.fromDoc)
              .toList(growable: false),
        );
  }

  /// Inclusive calendar-day bounds in local time; [workDate] stored as start-of-day timestamps.
  Stream<List<AttendanceRecordModel>> watchEmployeeAttendanceWorkDateRange({
    required String salonId,
    required String employeeId,
    required DateTime fromInclusiveLocalDay,
    required DateTime toInclusiveLocalDay,
    int limit = 500,
  }) {
    final start = DateTime(
      fromInclusiveLocalDay.year,
      fromInclusiveLocalDay.month,
      fromInclusiveLocalDay.day,
    );
    final endExclusive = DateTime(
      toInclusiveLocalDay.year,
      toInclusiveLocalDay.month,
      toInclusiveLocalDay.day,
    ).add(const Duration(days: 1));

    return _attendanceRef(salonId)
        .where('employeeId', isEqualTo: employeeId)
        .where('workDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('workDate', isLessThan: Timestamp.fromDate(endExclusive))
        .orderBy('workDate', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(AttendanceRecordModel.fromDoc)
              .toList(growable: false),
        );
  }

  Stream<List<AttendanceCorrectionRequestModel>> watchCorrectionRequests({
    required String salonId,
    required String employeeId,
    int limit = 10,
  }) {
    return _correctionRequestsRef(salonId)
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(AttendanceCorrectionRequestModel.fromDoc)
              .toList(growable: false),
        );
  }

  Future<AttendanceSummaryModel> getSummary({
    required String salonId,
    required String employeeId,
    required DateTime now,
  }) async {
    final snapshot = await _attendanceRef(salonId)
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('workDate', descending: true)
        .limit(120)
        .get();

    final records = snapshot.docs.map(AttendanceRecordModel.fromDoc).toList();

    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - DateTime.monday));

    bool isInCurrentMonth(AttendanceRecordModel r) {
      final parsed = DateTime.tryParse(r.attendanceDate);
      if (parsed != null) {
        return parsed.year == now.year && parsed.month == now.month;
      }
      return r.monthKey == monthKey(now);
    }

    final monthRecords = records.where(isInCurrentMonth).toList();

    final lateCount = monthRecords
        .where((r) => r.lateMinutes > 0 || r.status == 'late')
        .length;
    final missingCheckoutCount = monthRecords
        .where((r) => r.missingCheckout)
        .length;

    final todayDay = DateTime(now.year, now.month, now.day);
    final weekPresentDates = <String>{};
    for (final r in records) {
      final recordDate = DateTime.tryParse(r.attendanceDate);
      if (recordDate == null) continue;
      final day = DateTime(recordDate.year, recordDate.month, recordDate.day);
      final inWeek = !day.isBefore(weekStart) && !day.isAfter(todayDay);
      if (!inWeek) continue;
      final eligible =
          r.status == 'present' ||
          r.status == 'late' ||
          r.status == 'manual' ||
          r.status == 'onBreak' ||
          (r.checkInAt != null && r.status != 'absent');
      if (eligible) {
        weekPresentDates.add(r.attendanceDate);
      }
    }
    final weeklyPresentDays = weekPresentDates.length;

    final requestsSnapshot = await _correctionRequestsRef(salonId)
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: 'pending')
        .get();

    return AttendanceSummaryModel(
      weeklyPresentDays: weeklyPresentDays,
      monthlyLateCount: lateCount,
      monthlyMissingCheckoutCount: missingCheckoutCount,
      pendingCorrectionRequests: requestsSnapshot.docs.length,
    );
  }

  Future<void> upsertManualAttendance({
    required String salonId,
    required String employeeId,
    required String employeeName,
    required DateTime attendanceDate,
    required DateTime? checkInAt,
    required DateTime? checkOutAt,
    required String status,
    required int lateMinutes,
    required int earlyExitMinutes,
    required bool missingCheckout,
    required String notes,
    required String performedBy,
    required String performedByRole,
  }) async {
    final id = attendanceDocId(employeeId: employeeId, date: attendanceDate);
    final docRef = _attendanceRef(salonId).doc(id);
    final day = DateTime(
      attendanceDate.year,
      attendanceDate.month,
      attendanceDate.day,
    );
    final attendanceDateIso = day.toIso8601String().substring(0, 10);

    await _firestore.runTransaction((transaction) async {
      final oldDoc = await transaction.get(docRef);
      final oldValue = oldDoc.data();

      final data = <String, dynamic>{
        'salonId': salonId,
        'employeeId': employeeId,
        'employeeName': employeeName,
        'attendanceDate': attendanceDateIso,
        'dateKey': dateKey(day),
        'weekKey': weekKey(day),
        'monthKey': monthKey(day),
        'workDate': Timestamp.fromDate(day),
        'checkInAt': checkInAt == null ? null : Timestamp.fromDate(checkInAt),
        'checkOutAt': checkOutAt == null
            ? null
            : Timestamp.fromDate(checkOutAt),
        'status': status,
        'source': 'admin_manual',
        'lateMinutes': lateMinutes,
        'minutesLate': lateMinutes,
        'earlyExitMinutes': earlyExitMinutes,
        'missingCheckout': missingCheckout,
        'needsCorrection': missingCheckout,
        'manualEdited': true,
        'notes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': performedBy,
      };

      if (!oldDoc.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['createdBy'] = performedBy;
      }

      transaction.set(docRef, data, SetOptions(merge: true));

      final auditRef = _auditLogsRef(salonId).doc();
      transaction.set(auditRef, {
        'salonId': salonId,
        'entityType': 'attendance',
        'entityId': id,
        'employeeId': employeeId,
        'action': oldDoc.exists
            ? 'manual_attendance_update'
            : 'manual_attendance_create',
        'performedBy': performedBy,
        'performedByRole': performedByRole,
        'oldValue': oldValue ?? {},
        'newValue': data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

}
