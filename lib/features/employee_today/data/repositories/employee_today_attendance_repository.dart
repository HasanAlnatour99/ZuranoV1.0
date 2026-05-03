import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/attendance_approval.dart';
import '../../../../core/constants/violation_types.dart';
import '../../../../core/firestore/firestore_paths.dart';
import '../../../../core/firestore/firestore_write_payload.dart';
import '../../../../core/firestore/report_period.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import '../attendance_exception.dart';
import '../../domain/break_allowance_math.dart';
import '../models/et_attendance_day.dart';
import '../models/et_attendance_punch.dart';
import '../models/et_attendance_settings.dart';
import '../models/et_correction_request.dart';
import '../../../owner_settings/shifts/data/models/employee_schedule_model.dart';
import '../../domain/attendance_analysis_service.dart';
import '../../domain/attendance_status.dart';
import '../../domain/attendance_state_resolver.dart';
import '../../domain/attendance_work_punch_limits.dart';

class EmployeeTodayAttendanceRepository {
  EmployeeTodayAttendanceRepository({
    required FirebaseFirestore firestore,
    AttendanceAnalysisService? analysis,
  }) : _firestore = firestore,
       _analysis = analysis ?? const AttendanceAnalysisService();

  final FirebaseFirestore _firestore;
  final AttendanceAnalysisService _analysis;
  static const _resolver = AttendanceStateResolver();
  static const _uuid = Uuid();

  static String compactDateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y$m$day';
  }

  static String attendanceDayId(String employeeId, String dateKey) =>
      '${dateKey}_$employeeId';

  /// Same id shape as owner `salons/{salonId}/attendance` daily rows
  /// (`employeeId_yyyyMMdd`) so Team + profile attendance streams update.
  static String legacySalonAttendanceDocId({
    required String employeeId,
    required DateTime date,
  }) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${employeeId}_$y$m$d';
  }

  static String _isoAttendanceDateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  DocumentReference<Map<String, dynamic>> _settingsRef(String salonId) =>
      _firestore.doc(FirestorePaths.salonAttendanceSettingsDoc(salonId));

  DocumentReference<Map<String, dynamic>> _dayRef(
    String salonId,
    String dayId,
  ) => _firestore.doc(FirestorePaths.salonAttendanceDay(salonId, dayId));

  CollectionReference<Map<String, dynamic>> _punchesCol(
    String salonId,
    String dayId,
  ) => _firestore.collection(
    FirestorePaths.salonAttendanceDayPunchesCollection(salonId, dayId),
  );

  CollectionReference<Map<String, dynamic>> _dayBreaksCol(
    String salonId,
    String dayId,
  ) => _firestore.collection(
    FirestorePaths.salonAttendanceDayBreaksCollection(salonId, dayId),
  );

  CollectionReference<Map<String, dynamic>> _correctionsCol(String salonId) =>
      _firestore.collection(
        FirestorePaths.salonAttendanceCorrectionRequests(salonId),
      );

  DocumentReference<Map<String, dynamic>> _scheduleRef(
    String salonId,
    String employeeId,
    DateTime date,
  ) {
    final dk = compactDateKey(date);
    final scheduleId = '${employeeId}_$dk';
    return _firestore.doc(
      FirestorePaths.salonEmployeeSchedule(salonId, scheduleId),
    );
  }

  Stream<EtAttendanceSettings> watchAttendanceSettings(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _settingsRef(salonId).snapshots().map((s) {
      if (!s.exists) {
        return EtAttendanceSettings.defaults(salonId);
      }
      return EtAttendanceSettings.fromFirestore(salonId, s);
    });
  }

  Future<EtAttendanceDay?> getAttendanceDay({
    required String salonId,
    required String dayId,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final s = await _dayRef(salonId, dayId).get();
    if (!s.exists) {
      return null;
    }
    return EtAttendanceDay.fromFirestore(s);
  }

  Stream<EtAttendanceDay?> watchTodayAttendanceDay({
    required String salonId,
    required String employeeId,
  }) {
    final now = DateTime.now();
    final dk = compactDateKey(now);
    final id = attendanceDayId(employeeId, dk);
    return watchAttendanceDay(salonId: salonId, dayId: id);
  }

  Stream<EtAttendanceDay?> watchAttendanceDay({
    required String salonId,
    required String dayId,
  }) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _dayRef(salonId, dayId).snapshots().map((s) {
      if (!s.exists) {
        return null;
      }
      return EtAttendanceDay.fromFirestore(s);
    });
  }

  Stream<List<EtAttendancePunch>> watchDayPunches({
    required String salonId,
    required String attendanceDayId,
  }) {
    return _punchesCol(salonId, attendanceDayId)
        .orderBy('punchTime', descending: false)
        .limit(32)
        .snapshots()
        .map(
          (s) => s.docs
              .map(EtAttendancePunch.fromFirestore)
              .toList(growable: false),
        );
  }

  Stream<List<EtAttendancePunch>> watchTodayPunches({
    required String salonId,
    required String attendanceDayId,
  }) {
    return watchDayPunches(salonId: salonId, attendanceDayId: attendanceDayId);
  }

  Stream<List<EtAttendanceDay>> watchRecentAttendanceDays({
    required String salonId,
    required String employeeId,
    int limit = 5,
  }) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore
        .collection(FirestorePaths.salonAttendanceDays(salonId))
        .where('salonId', isEqualTo: salonId)
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (s) =>
              s.docs.map(EtAttendanceDay.fromFirestore).toList(growable: false),
        );
  }

  Stream<EmployeeScheduleModel?> watchEmployeeScheduleForDate({
    required String salonId,
    required String employeeId,
    required DateTime date,
  }) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _scheduleRef(salonId, employeeId, date).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return EmployeeScheduleModel.fromFirestore(doc);
    });
  }

  Stream<List<EtCorrectionRequest>> watchEmployeeCorrectionRequests({
    required String salonId,
    required String employeeId,
    String? status,
    int limit = 20,
  }) {
    return _correctionsCol(salonId)
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) {
          final list = s.docs.map(EtCorrectionRequest.fromFirestore).toList();
          if (status != null && status.isNotEmpty) {
            return list.where((r) => r.status == status).toList();
          }
          return list;
        });
  }

  Future<List<EtAttendanceDay>> getEmployeeMonthAttendance({
    required String salonId,
    required String employeeId,
    required int year,
    required int month,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    final q = await _firestore
        .collection(FirestorePaths.salonAttendanceDays(salonId))
        .where('salonId', isEqualTo: salonId)
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .limit(62)
        .get();
    return q.docs.map(EtAttendanceDay.fromFirestore).toList(growable: false);
  }

  Future<void> submitPunch({
    required String uid,
    required String salonId,
    required String employeeId,
    required String employeeName,
    required bool employeeActive,
    required bool attendanceRequired,
    required AttendancePunchType type,
    required Position? position,
    required EtAttendanceSettings settings,
    String? shiftStartHhmm,
    String? shiftEndHhmm,
  }) async {
    if (uid.isEmpty) {
      throw AttendanceException('You must be signed in to submit a punch.');
    }
    if (!employeeActive) {
      throw AttendanceException('Your employee profile is inactive.');
    }
    if (!settings.attendanceEnabled) {
      throw AttendanceException('Attendance is not enabled for this salon.');
    }

    final now = DateTime.now();
    final calendarDay = DateTime(now.year, now.month, now.day);
    final shiftStartHm = shiftStartHhmm ?? settings.standardShiftStart;
    final shiftEndHm = shiftEndHhmm ?? settings.standardShiftEnd;
    final breakWindowStart = shiftBoundaryOnCalendarDay(
      calendarDay,
      shiftStartHm,
    );
    final breakWindowEnd = shiftBoundaryOnCalendarDay(calendarDay, shiftEndHm);

    if (type == AttendancePunchType.breakOut &&
        breakWindowStart != null &&
        breakWindowEnd != null &&
        breakWindowEnd.isAfter(breakWindowStart)) {
      if (now.isBefore(breakWindowStart) || now.isAfter(breakWindowEnd)) {
        throw AttendanceException(AttendanceExceptionCodes.outsideShiftBreak);
      }
    }

    final dk = compactDateKey(now);
    final dayId = attendanceDayId(employeeId, dk);
    final dayRef = _dayRef(salonId, dayId);
    final punchesCol = _punchesCol(salonId, dayId);

    double? distance;
    var inside = false;
    final zoneMandatory =
        attendanceRequired &&
        settings.gpsRequired &&
        (type == AttendancePunchType.punchIn ||
            type == AttendancePunchType.punchOut);

    if (zoneMandatory) {
      if (!settings.hasSalonLocationConfigured) {
        throw AttendanceException(
          'Salon attendance location is not configured. Please contact the owner.',
        );
      }
      if (position == null) {
        throw AttendanceException('You are outside the allowed salon zone.');
      }
      final lat = settings.salonLatitude!;
      final lng = settings.salonLongitude!;
      distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        lat,
        lng,
      );
      inside = distance <= settings.allowedRadiusMeters;
    } else {
      inside = true;
      if (position != null && settings.hasSalonLocationConfigured) {
        final lat = settings.salonLatitude!;
        final lng = settings.salonLongitude!;
        distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          lat,
          lng,
        );
        inside = distance <= settings.allowedRadiusMeters;
      }
    }

    final punchRef = punchesCol.doc();
    final punchTime = now;

    // Transaction.get() only accepts DocumentReference; read punch list first.
    final punchesSnapBeforeTx = await punchesCol
        .orderBy('punchTime', descending: false)
        .limit(AttendanceStateResolver.maxPunchesPerDayAbsoluteCap)
        .get();
    final sortedPunchesBeforeTx = punchesSnapBeforeTx.docs
        .map(EtAttendancePunch.fromFirestore)
        .toList(growable: false);

    await _firestore.runTransaction((tx) async {
      final daySnap = await tx.get(dayRef);
      final sortedPunches = sortedPunchesBeforeTx;
      final seqFromPunches =
          sortedPunches.map((p) => p.type.name).toList(growable: false);
      final idsFromPunches =
          sortedPunches.map((p) => p.id).toList(growable: false);
      final seq = seqFromPunches.isNotEmpty
          ? seqFromPunches
          : List<String>.from(
              daySnap.data()?['punchSequence'] as List? ?? const [],
            );
      final punchIds = idsFromPunches.isNotEmpty
          ? idsFromPunches
          : List<String>.from(
              daySnap.data()?['punchIds'] as List? ?? const [],
            );

      final v = _resolver.validateRequestedPunch(
        settings: settings,
        punchSequence: seq,
        requestedType: type,
        isInsideZone: inside,
        attendanceRequired: attendanceRequired,
      );
      if (!v.allowed) {
        throw AttendanceException(
          v.message ?? 'This punch sequence is not valid.',
        );
      }

      if (type == AttendancePunchType.punchIn ||
          type == AttendancePunchType.punchOut) {
        final workSoFar = workPunchCountInPunches(sortedPunches);
        if (workSoFar >= kMaxWorkPunchesPerDay) {
          throw AttendanceException('You reached today\'s maximum punches.');
        }
      }

      if (sortedPunches.isNotEmpty) {
        final last = sortedPunches.last;
        final duplicateWindowSeconds = punchTime
            .difference(last.punchTime)
            .inSeconds
            .abs();
        if (last.type == type && duplicateWindowSeconds < 60) {
          throw AttendanceException(
            'Duplicate punch blocked. Try again after one minute.',
          );
        }
      }

      DateTime? breakReturnStartedAt;
      var breakReturnAllowedMin = 0;
      var breakReturnActualMin = 0;
      var breakReturnExceededMin = 0;
      var breakInDailyCapSnapshot = 0;
      var breakInCompletedBeforeSnapshot = 0;
      String? breakSessionDocId;
      String? exceededViolationDocId;

      if (type == AttendancePunchType.breakIn) {
        if (sortedPunches.isEmpty ||
            sortedPunches.last.type != AttendancePunchType.breakOut) {
          throw AttendanceException('This punch sequence is not valid.');
        }
        breakReturnStartedAt = sortedPunches.last.punchTime;
        final dailyCap = settings.maxBreakMinutesPerDay <= 0
            ? 60
            : settings.maxBreakMinutesPerDay;
        final completedBefore = completedClosedBreakMinutesClamped(
          sortedPunches,
          breakWindowStart,
          breakWindowEnd,
        );
        breakInDailyCapSnapshot = dailyCap;
        breakInCompletedBeforeSnapshot = completedBefore;
        breakReturnAllowedMin = math.max(0, dailyCap - completedBefore);
        breakReturnActualMin = clampedIntervalMinutesCeil(
          breakReturnStartedAt,
          punchTime,
          breakWindowStart,
          breakWindowEnd,
        );
        breakReturnExceededMin = math.max(
          0,
          breakReturnActualMin - breakReturnAllowedMin,
        );
        breakSessionDocId = _dayBreaksCol(salonId, dayId).doc().id;
        if (breakReturnExceededMin > 0) {
          exceededViolationDocId = _firestore
              .collection(FirestorePaths.salonViolations(salonId))
              .doc()
              .id;
        }
      }

      final newSeq = [...seq, type.name];
      final newPunchIds = [...punchIds, punchRef.id];
      final workDate = DateTime(punchTime.year, punchTime.month, punchTime.day);
      final projectedPunches = <EtAttendancePunch>[
        ...sortedPunches,
        EtAttendancePunch(
          id: punchRef.id,
          salonId: salonId,
          employeeId: employeeId,
          attendanceDayId: dayId,
          type: type,
          punchTime: punchTime,
          source: 'mobile',
          insideZone: inside,
          latitude: position?.latitude,
          longitude: position?.longitude,
          distanceFromSalonMeters: distance,
          createdAt: null,
          createdBy: uid,
        ),
      ];
      final missingPunchShiftEnd = _shiftEndForDay(
        punchTime,
        settings.standardShiftEnd,
      );
      final calculatedStatus = calculateTodayStatus(
        punches: projectedPunches,
        now: now,
        shiftEndAt: missingPunchShiftEnd,
        maxBreakMinutesPerDay: settings.maxBreakMinutesPerDay,
        maxWorkPunchesPerDay: kMaxWorkPunchesPerDay,
      );
      final missingReason = _missingPunchReason(
        status: calculatedStatus,
        punches: projectedPunches,
        now: now,
        shiftEndAt: missingPunchShiftEnd,
        maxBreakMinutesPerDay: settings.maxBreakMinutesPerDay,
      );

      _logAttendanceDebug(
        employeeId: employeeId,
        dayId: dayId,
        currentPunchesCount: sortedPunches.length,
        lastPunchType: seq.isEmpty ? null : seq.last,
        requestedPunchType: type.name,
        calculatedStatusBefore: daySnap.data()?['status']?.toString(),
        calculatedStatusAfter: calculatedStatus.name,
        isInsideSalonZone: inside,
        distanceFromSalonMeters: distance,
      );
      tx.set(punchRef, {
        'id': punchRef.id,
        'salonId': salonId,
        'employeeId': employeeId,
        'attendanceDayId': dayId,
        'type': type.name,
        'punchTime': Timestamp.fromDate(punchTime),
        'punchedAt': Timestamp.fromDate(punchTime),
        'source': 'mobile',
        'insideZone': inside,
        'isInsideSalonZone': inside,
        'latitude': position?.latitude,
        'longitude': position?.longitude,
        'distanceFromSalonMeters': distance,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': uid,
      });

      final dayFields = <String, dynamic>{
        'id': dayId,
        'salonId': salonId,
        'employeeId': employeeId,
        'employeeName': formatTeamMemberName(employeeName),
        'workDate':
            '${punchTime.year.toString().padLeft(4, '0')}-${punchTime.month.toString().padLeft(2, '0')}-${punchTime.day.toString().padLeft(2, '0')}',
        'dateKey': dk,
        'date': Timestamp.fromDate(workDate),
        'punchSequence': newSeq,
        'punchIds': newPunchIds,
        'totalPunches': newSeq.length,
        'isInsideZone': inside,
        'lastLatitude': position?.latitude,
        'lastLongitude': position?.longitude,
        'lastDistanceFromSalon': distance,
        'status': calculatedStatus.firestoreValue,
        'lastPunchType': type.name,
        'lastPunchAt': Timestamp.fromDate(punchTime),
        'missingPunchReason': missingReason,
        'correctionRequestId': daySnap.data()?['correctionRequestId'],
        'updatedAt': FieldValue.serverTimestamp(),
        if (!daySnap.exists) 'createdAt': FieldValue.serverTimestamp(),
      };
      if (type == AttendancePunchType.breakIn) {
        if (breakReturnExceededMin > 0) {
          dayFields['exceededBreakMinutes'] = FieldValue.increment(
            breakReturnExceededMin,
          );
          dayFields['payrollImpactStatus'] = 'PENDING_PROCESSING';
        }
        dayFields['hasBreakViolation'] =
            (daySnap.data()?['hasBreakViolation'] == true) ||
            breakReturnExceededMin > 0;
      }
      tx.set(dayRef, dayFields, SetOptions(merge: true));

      if (type == AttendancePunchType.breakIn &&
          breakSessionDocId != null &&
          breakReturnStartedAt != null) {
        final breakRef = _dayBreaksCol(salonId, dayId).doc(breakSessionDocId);
        final breakPayload = <String, dynamic>{
          'breakId': breakSessionDocId,
          'salonId': salonId,
          'employeeId': employeeId,
          'attendanceDayId': dayId,
          'startedAt': Timestamp.fromDate(breakReturnStartedAt),
          'endedAt': FieldValue.serverTimestamp(),
          'allowedMinutes': breakReturnAllowedMin,
          'actualMinutes': breakReturnActualMin,
          'exceededMinutes': breakReturnExceededMin,
          'createdAt': FieldValue.serverTimestamp(),
        };
        final vid = exceededViolationDocId;
        if (vid != null) {
          breakPayload['createdViolationId'] = vid;
        }
        tx.set(breakRef, breakPayload);

        if (exceededViolationDocId != null && breakReturnExceededMin > 0) {
          final violationStatus = settings.autoCreateViolations
              ? ViolationStatuses.approved
              : ViolationStatuses.pending;
          final vRef = _firestore.doc(
            FirestorePaths.salonViolation(salonId, exceededViolationDocId),
          );
          final occurredAt = punchTime;
          final rp = ReportPeriod.denormalizedFieldsFor(occurredAt);
          const penaltyPerExceededMinute = 1.0;
          final penaltyAmount =
              breakReturnExceededMin * penaltyPerExceededMinute;
          tx.set(vRef, {
            'id': exceededViolationDocId,
            'salonId': salonId,
            'employeeId': employeeId,
            'employeeName': formatTeamMemberName(employeeName),
            'sourceType': ViolationSourceTypes.attendanceBreak,
            'violationType': ViolationTypes.exceededBreakTime,
            'status': violationStatus,
            'occurredAt': Timestamp.fromDate(occurredAt),
            'reportYear': rp['reportYear'],
            'reportMonth': rp['reportMonth'],
            'reportPeriodKey': rp['reportPeriodKey'],
            'minutesLate': breakReturnExceededMin,
            'amount': penaltyAmount,
            'ruleSnapshot': {
              'attendanceDayId': dayId,
              'allowedBreakMinutes': breakReturnAllowedMin,
              'actualBreakMinutes': breakReturnActualMin,
              'dailyBreakCapMinutes': breakInDailyCapSnapshot,
              'completedBreakMinutesBefore': breakInCompletedBeforeSnapshot,
            },
            'createdByUid': uid,
            'createdByRole': 'employee',
            if (violationStatus == ViolationStatuses.approved) ...<String, dynamic>{
              'approvedByUid': 'SYSTEM',
              'approvedAt': FieldValue.serverTimestamp(),
            },
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'payrollImpactStatus': 'PENDING_PROCESSING',
          });
        }
      }
    });

    if (kDebugMode &&
        (type == AttendancePunchType.breakIn ||
            type == AttendancePunchType.breakOut)) {
      debugPrint(
        'ATTENDANCE_TX_SUCCESS: employeeId=$employeeId dayId=$dayId '
        'punch=${type.name}',
      );
    }

    await _refreshDaySummary(
      salonId: salonId,
      dayId: dayId,
      calendarDay: DateTime(now.year, now.month, now.day),
      settings: settings,
      employeeId: employeeId,
      employeeName: formatTeamMemberName(employeeName),
      employeeAuthUid: uid,
    );
  }

  DateTime? _shiftEndForDay(DateTime day, String? shiftEnd) {
    if (shiftEnd == null || !shiftEnd.contains(':')) {
      return null;
    }
    final parts = shiftEnd.split(':');
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) {
      return null;
    }
    return DateTime(day.year, day.month, day.day, h, m);
  }

  String? _missingPunchReason({
    required AttendanceStatus status,
    required List<EtAttendancePunch> punches,
    required DateTime now,
    required DateTime? shiftEndAt,
    required int maxBreakMinutesPerDay,
  }) {
    if (status == AttendanceStatus.invalidSequence) {
      return 'invalidSequence';
    }
    if (status != AttendanceStatus.missingPunch || punches.isEmpty) {
      return null;
    }
    final last = punches.last;
    if (last.type == AttendancePunchType.punchIn &&
        shiftEndAt != null &&
        now.isAfter(shiftEndAt)) {
      return 'missingPunchOutAfterShiftEnd';
    }
    return 'missingPunch';
  }

  void _logAttendanceDebug({
    required String employeeId,
    required String dayId,
    required int currentPunchesCount,
    required String? lastPunchType,
    required String requestedPunchType,
    required String? calculatedStatusBefore,
    required String calculatedStatusAfter,
    required bool isInsideSalonZone,
    required double? distanceFromSalonMeters,
  }) {
    debugPrint(
      'ATTENDANCE_DEBUG: employeeId=$employeeId dayId=$dayId '
      'currentPunchesCount=$currentPunchesCount lastPunchType=${lastPunchType ?? 'none'} '
      'requestedPunchType=$requestedPunchType '
      'calculatedStatusBefore=${calculatedStatusBefore ?? 'none'} '
      'calculatedStatusAfter=$calculatedStatusAfter '
      'isInsideSalonZone=$isInsideSalonZone '
      'distanceFromSalonMeters=${distanceFromSalonMeters?.toStringAsFixed(2) ?? 'n/a'}',
    );
  }

  Future<void> _refreshDaySummary({
    required String salonId,
    required String dayId,
    required DateTime calendarDay,
    required EtAttendanceSettings settings,
    required String employeeId,
    required String employeeName,
    required String? employeeAuthUid,
  }) async {
    final snaps = await _punchesCol(
      salonId,
      dayId,
    ).orderBy('punchTime', descending: false).get();
    final punches = snaps.docs.map(EtAttendancePunch.fromFirestore).toList();
    final calc = _analysis.calculateDay(
      settings: settings,
      punchesSorted: punches,
      calendarDay: calendarDay,
    );
    final seq = punches.map((p) => p.type.name).toList();
    final shiftEndAt = _shiftEndForDay(calendarDay, settings.standardShiftEnd);
    final todayStatus = calculateTodayStatus(
      punches: punches,
      now: DateTime.now(),
      shiftEndAt: shiftEndAt,
      maxBreakMinutesPerDay: settings.maxBreakMinutesPerDay,
      maxWorkPunchesPerDay: kMaxWorkPunchesPerDay,
    );
    final missingReason = _missingPunchReason(
      status: todayStatus,
      punches: punches,
      now: DateTime.now(),
      shiftEndAt: shiftEndAt,
      maxBreakMinutesPerDay: settings.maxBreakMinutesPerDay,
    );
    final monthlyPolicy = await _computeMonthlyPolicySummary(
      salonId: salonId,
      employeeId: calc.firstPunchInAt == null && punches.isNotEmpty
          ? punches.first.employeeId
          : (punches.isNotEmpty ? punches.first.employeeId : null),
      calendarDay: calendarDay,
      isLateAfterGrace: calc.isLateAfterGrace,
      isEarlyExitAfterGrace: calc.isEarlyExitAfterGrace,
      missingReason: missingReason,
      settings: settings,
    );
    await _dayRef(salonId, dayId).set({
      'punchSequence': seq,
      'punchIds': punches.map((p) => p.id).toList(),
      'status': todayStatus.firestoreValue,
      'workedMinutes': calc.workedMinutes,
      'breakMinutes': calc.breakMinutes,
      'lateMinutes': calc.lateMinutes,
      'earlyExitMinutes': calc.earlyExitMinutes,
      'isLateAfterGrace': calc.isLateAfterGrace,
      'isEarlyExitAfterGrace': calc.isEarlyExitAfterGrace,
      'hasMissingPunch': todayStatus == AttendanceStatus.missingPunch,
      'missingPunchReason': missingReason,
      'monthlyLateAfterGraceCount': monthlyPolicy.lateCount,
      'monthlyEarlyExitAfterGraceCount': monthlyPolicy.earlyExitCount,
      'monthlyMissingCheckoutCount': monthlyPolicy.missingCheckoutCount,
      'remainingLateAllowance': monthlyPolicy.remainingLateAllowance,
      'remainingEarlyExitAllowance': monthlyPolicy.remainingEarlyAllowance,
      'remainingMissingCheckoutAllowance':
          monthlyPolicy.remainingMissingCheckoutAllowance,
      'lateAllowanceExceeded': monthlyPolicy.lateAllowanceExceeded,
      'earlyExitAllowanceExceeded': monthlyPolicy.earlyAllowanceExceeded,
      'missingCheckoutAllowanceExceeded':
          monthlyPolicy.missingCheckoutAllowanceExceeded,
      'applyLateDeduction': monthlyPolicy.applyLateDeduction,
      'applyEarlyExitDeduction': monthlyPolicy.applyEarlyExitDeduction,
      'applyMissingCheckoutDeduction':
          monthlyPolicy.applyMissingCheckoutDeduction,
      'lateDeductionPercent': settings.lateDeductionPercent,
      'earlyExitDeductionPercent': settings.earlyExitDeductionPercent,
      'missingCheckoutDeductionPercent':
          settings.missingCheckoutDeductionPercent,
      'totalBreaks': calc.totalBreaks,
      'firstPunchInAt': calc.firstPunchInAt != null
          ? Timestamp.fromDate(calc.firstPunchInAt!)
          : null,
      'lastPunchOutAt': calc.lastPunchOutAt != null
          ? Timestamp.fromDate(calc.lastPunchOutAt!)
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _syncSalonAttendanceLegacyMirror(
      salonId: salonId,
      employeeId: employeeId,
      employeeName: formatTeamMemberName(employeeName),
      employeeAuthUid: employeeAuthUid,
      calendarDay: calendarDay,
      punches: punches,
      calc: calc,
    );
  }

  /// Mirrors Employee Today punch state into `salons/{salonId}/attendance`
  /// so owner Team analytics and team-member attendance tabs (which listen on
  /// that collection) stay in sync in real time.
  Future<void> _syncSalonAttendanceLegacyMirror({
    required String salonId,
    required String employeeId,
    required String employeeName,
    required String? employeeAuthUid,
    required DateTime calendarDay,
    required List<EtAttendancePunch> punches,
    required AttendanceDayCalculation calc,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);
    final docId = legacySalonAttendanceDocId(
      employeeId: employeeId,
      date: calendarDay,
    );
    final ref = _firestore.doc(
      FirestorePaths.salonAttendanceRecord(salonId, docId),
    );

    final dayStart = DateTime(
      calendarDay.year,
      calendarDay.month,
      calendarDay.day,
    );
    final dateKeyStr = _isoAttendanceDateKey(dayStart);

    String? preservedEmployeeUid;
    if (employeeAuthUid == null || employeeAuthUid.isEmpty) {
      final existing = await ref.get();
      final u = existing.data()?['employeeUid']?.toString().trim();
      if (u != null && u.isNotEmpty) {
        preservedEmployeeUid = u;
      }
    }
    final uidToWrite = (employeeAuthUid != null && employeeAuthUid.isNotEmpty)
        ? employeeAuthUid
        : preservedEmployeeUid;

    if (punches.isEmpty) {
      await ref.set(<String, dynamic>{
        'id': docId,
        'salonId': salonId,
        'employeeId': employeeId,
        'employeeName': formatTeamMemberName(employeeName),
        'workDate': Timestamp.fromDate(dayStart),
        'dateKey': dateKeyStr,
        'status': 'absent',
        'checkInAt': FieldValue.delete(),
        'checkOutAt': FieldValue.delete(),
        'minutesLate': 0,
        'needsCorrection': false,
        'approvalStatus': AttendanceApprovalStatuses.approved,
        'updatedAt': FieldValue.serverTimestamp(),
        if (uidToWrite != null && uidToWrite.isNotEmpty) 'employeeUid': uidToWrite,
      }, SetOptions(merge: true));
      return;
    }

    DateTime? checkOutAt;
    if (punches.isNotEmpty) {
      final last = punches.last.type;
      final closedByPunchOut =
          last == AttendancePunchType.punchOut &&
          (calc.status == 'checkedOut' || calc.status == 'incomplete');
      if (closedByPunchOut) {
        checkOutAt = calc.lastPunchOutAt;
      }
    }

    String legacyStatus;
    if (calc.firstPunchInAt == null) {
      legacyStatus = 'absent';
    } else if (calc.isLateAfterGrace) {
      legacyStatus = 'late';
    } else if (calc.status == 'onBreak') {
      legacyStatus = 'onBreak';
    } else if (calc.status == 'incomplete') {
      legacyStatus = 'incomplete';
    } else {
      legacyStatus = 'present';
    }

    final payload = <String, dynamic>{
      'id': docId,
      'salonId': salonId,
      'employeeId': employeeId,
      'employeeName': formatTeamMemberName(employeeName),
      'workDate': Timestamp.fromDate(dayStart),
      'dateKey': dateKeyStr,
      'status': legacyStatus,
      'minutesLate': calc.lateMinutes,
      'needsCorrection': calc.hasMissingPunch,
      'approvalStatus': AttendanceApprovalStatuses.approved,
      'updatedAt': FieldValue.serverTimestamp(),
      if (calc.firstPunchInAt != null)
        'checkInAt': Timestamp.fromDate(calc.firstPunchInAt!)
      else
        'checkInAt': FieldValue.delete(),
      if (checkOutAt != null)
        'checkOutAt': Timestamp.fromDate(checkOutAt)
      else
        'checkOutAt': FieldValue.delete(),
      if (uidToWrite != null && uidToWrite.isNotEmpty) 'employeeUid': uidToWrite,
    };

    await ref.set(payload, SetOptions(merge: true));
  }

  Future<_MonthlyPolicySummary> _computeMonthlyPolicySummary({
    required String salonId,
    required String? employeeId,
    required DateTime calendarDay,
    required bool isLateAfterGrace,
    required bool isEarlyExitAfterGrace,
    required String? missingReason,
    required EtAttendanceSettings settings,
  }) async {
    if (employeeId == null || employeeId.isEmpty) {
      return _MonthlyPolicySummary.empty();
    }

    final monthStart = DateTime(calendarDay.year, calendarDay.month, 1);
    final monthEnd = DateTime(
      calendarDay.year,
      calendarDay.month + 1,
      0,
      23,
      59,
      59,
    );
    final days = await _firestore
        .collection(FirestorePaths.salonAttendanceDays(salonId))
        .where('employeeId', isEqualTo: employeeId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(monthEnd))
        .limit(62)
        .get();

    var lateCount = days.docs
        .where((d) => d.data()['isLateAfterGrace'] == true)
        .length;
    var earlyCount = days.docs
        .where((d) => d.data()['isEarlyExitAfterGrace'] == true)
        .length;
    var missingCheckoutCount = days.docs
        .where(
          (d) =>
              d.data()['missingPunchReason']?.toString() ==
              'missingPunchOutAfterShiftEnd',
        )
        .length;

    final dayKey = compactDateKey(calendarDay);
    final currentDayExists = days.docs.any(
      (d) => d.data()['dateKey']?.toString() == dayKey,
    );
    if (!currentDayExists) {
      if (isLateAfterGrace) {
        lateCount += 1;
      }
      if (isEarlyExitAfterGrace) {
        earlyCount += 1;
      }
      if (missingReason == 'missingPunchOutAfterShiftEnd') {
        missingCheckoutCount += 1;
      }
    }

    final remainingLate = (settings.allowedLateCountPerMonth - lateCount).clamp(
      0,
      1 << 30,
    );
    final remainingEarly = (settings.allowedEarlyExitCountPerMonth - earlyCount)
        .clamp(0, 1 << 30);
    final remainingMissing =
        (settings.allowedMissingCheckoutCountPerMonth - missingCheckoutCount)
            .clamp(0, 1 << 30);

    final lateExceeded = lateCount > settings.allowedLateCountPerMonth;
    final earlyExceeded = earlyCount > settings.allowedEarlyExitCountPerMonth;
    final missingExceeded =
        missingCheckoutCount > settings.allowedMissingCheckoutCountPerMonth;

    return _MonthlyPolicySummary(
      lateCount: lateCount,
      earlyExitCount: earlyCount,
      missingCheckoutCount: missingCheckoutCount,
      remainingLateAllowance: remainingLate,
      remainingEarlyAllowance: remainingEarly,
      remainingMissingCheckoutAllowance: remainingMissing,
      lateAllowanceExceeded: lateExceeded,
      earlyAllowanceExceeded: earlyExceeded,
      missingCheckoutAllowanceExceeded: missingExceeded,
      applyLateDeduction:
          settings.autoCreateViolations &&
          isLateAfterGrace &&
          lateExceeded &&
          settings.lateDeductionPercent > 0,
      applyEarlyExitDeduction:
          settings.autoCreateViolations &&
          isEarlyExitAfterGrace &&
          earlyExceeded &&
          settings.earlyExitDeductionPercent > 0,
      applyMissingCheckoutDeduction:
          settings.autoCreateViolations &&
          missingReason == 'missingPunchOutAfterShiftEnd' &&
          missingExceeded &&
          settings.missingCheckoutDeductionPercent > 0,
    );
  }

  Future<void> createCorrectionRequest({
    required String uid,
    required String salonId,
    required String employeeId,
    required String employeeName,
    required String attendanceDayId,
    required String dateKey,
    required AttendancePunchType requestedType,
    required DateTime requestedPunchTime,
    required String reason,
    required EtAttendanceSettings settings,
    required List<String> existingSequence,
  }) async {
    if (!settings.allowEmployeeCorrectionRequests) {
      throw AttendanceException(
        'Correction requests are disabled for this salon.',
      );
    }

    final pending = await _correctionsCol(salonId)
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: 'pending')
        .limit(40)
        .get();
    final reqMs = requestedPunchTime.millisecondsSinceEpoch;
    for (final d in pending.docs) {
      final r = EtCorrectionRequest.fromFirestore(d);
      if (r.status != 'pending') {
        continue;
      }
      if (r.dateKey == dateKey &&
          r.requestedPunchType == requestedType.name &&
          r.requestedPunchTime.millisecondsSinceEpoch == reqMs) {
        throw AttendanceException(
          'You already have a pending request for this punch.',
        );
      }
    }

    final merged = [...existingSequence, requestedType.name];
    if (workPunchCountInSequenceNames(merged) > kMaxWorkPunchesPerDay) {
      throw AttendanceException(
        'This punch would exceed the daily punch limit.',
      );
    }
    if (requestedType == AttendancePunchType.breakOut &&
        existingSequence
                .where((e) => e == AttendancePunchType.breakOut.name)
                .length >=
            settings.maxBreakCyclesPerDay) {
      throw AttendanceException(
        'This break would exceed the daily break limit.',
      );
    }

    final id = _uuid.v4();
    await _correctionsCol(salonId).doc(id).set({
      'id': id,
      'salonId': salonId,
      'employeeId': employeeId,
      'employeeUid': uid,
      'employeeName': formatTeamMemberName(employeeName),
      'attendanceDayId': attendanceDayId,
      'dateKey': dateKey,
      'requestedPunchType': requestedType.name,
      'requestedPunchTime': Timestamp.fromDate(requestedPunchTime),
      'reason': reason,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': uid,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': uid,
    });

    await _dayRef(
      salonId,
      attendanceDayId,
    ).set({'hasPendingCorrectionRequest': true}, SetOptions(merge: true));
  }

  Future<void> approveCorrectionRequest({
    required String salonId,
    required String requestId,
    required String reviewerId,
    required String reviewerName,
    String? reviewNote,
  }) async {
    final reqRef = _correctionsCol(salonId).doc(requestId);
    final reqSnap = await reqRef.get();
    if (!reqSnap.exists) {
      throw AttendanceException('Correction request not found.');
    }
    final request = EtCorrectionRequest.fromFirestore(reqSnap);
    if (request.status != 'pending') {
      throw AttendanceException('This correction request is already reviewed.');
    }
    final correctionEmployeeUid =
        reqSnap.data()?['employeeUid']?.toString().trim();

    final settingsSnap = await _settingsRef(salonId).get();
    final settings = settingsSnap.exists
        ? EtAttendanceSettings.fromFirestore(salonId, settingsSnap)
        : EtAttendanceSettings.defaults(salonId);

    final dayRef = _dayRef(salonId, request.attendanceDayId);
    final daySnap = await dayRef.get();
    final punchesSnap = await _punchesCol(salonId, request.attendanceDayId)
        .orderBy('punchTime', descending: false)
        .limit(AttendanceStateResolver.maxPunchesPerDayAbsoluteCap)
        .get();
    final existingPunches = punchesSnap.docs
        .map(EtAttendancePunch.fromFirestore)
        .toList(growable: false);

    final requestedType = AttendancePunchType.fromFirestoreString(
      request.requestedPunchType,
    );
    final correctedPunch = EtAttendancePunch(
      id: _punchesCol(salonId, request.attendanceDayId).doc().id,
      salonId: salonId,
      employeeId: request.employeeId,
      attendanceDayId: request.attendanceDayId,
      type: requestedType,
      punchTime: request.requestedPunchTime,
      source: 'correction_approved',
      insideZone: true,
      correctionRequestId: request.id,
      createdBy: reviewerId,
    );

    final projectedPunches = _insertPunchSorted(
      existingPunches,
      correctedPunch,
    );
    final projectedTypes = projectedPunches.map((e) => e.type).toList();
    if (!_isValidPunchOrder(projectedTypes)) {
      throw AttendanceException(
        'Approved correction creates an invalid punch sequence.',
      );
    }
    if (workPunchCountInPunches(projectedPunches) > kMaxWorkPunchesPerDay) {
      throw AttendanceException(
        'This correction exceeds the daily punch limit.',
      );
    }

    final breakCycles = projectedTypes
        .where((e) => e == AttendancePunchType.breakOut)
        .length;
    if (breakCycles > settings.maxBreakCyclesPerDay) {
      throw AttendanceException(
        'This correction exceeds the daily break limit.',
      );
    }

    final breakMinutes = _totalBreakMinutes(projectedPunches);
    if (breakMinutes > settings.maxBreakMinutesPerDay) {
      throw AttendanceException(
        'This correction exceeds the allowed daily break time.',
      );
    }

    final punchRef = _punchesCol(
      salonId,
      request.attendanceDayId,
    ).doc(correctedPunch.id);
    await _firestore.runTransaction((tx) async {
      final txReq = await tx.get(reqRef);
      if (!txReq.exists) {
        throw AttendanceException('Correction request not found.');
      }
      if (txReq.data()?['status']?.toString() != 'pending') {
        throw AttendanceException(
          'This correction request is already reviewed.',
        );
      }

      tx.set(punchRef, {
        'id': punchRef.id,
        'salonId': salonId,
        'employeeId': request.employeeId,
        'attendanceDayId': request.attendanceDayId,
        'type': requestedType.name,
        'punchTime': Timestamp.fromDate(request.requestedPunchTime),
        'punchedAt': Timestamp.fromDate(request.requestedPunchTime),
        'source': 'correction_approved',
        'insideZone': true,
        'isInsideSalonZone': true,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': reviewerId,
        'correctionRequestId': request.id,
      });

      tx.set(dayRef, {
        'id': request.attendanceDayId,
        'salonId': salonId,
        'employeeId': request.employeeId,
        'employeeName': formatTeamMemberName(request.employeeName),
        'dateKey': request.dateKey,
        'hasPendingCorrectionRequest': false,
        'updatedAt': FieldValue.serverTimestamp(),
        if (!daySnap.exists)
          'date': Timestamp.fromDate(
            DateTime(
              request.requestedPunchTime.year,
              request.requestedPunchTime.month,
              request.requestedPunchTime.day,
            ),
          ),
        if (!daySnap.exists) 'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      tx.set(reqRef, {
        'status': 'approved',
        'reviewedBy': reviewerId,
        'reviewedByName': reviewerName,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewNote': reviewNote?.trim(),
        'createdPunchId': punchRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': reviewerId,
      }, SetOptions(merge: true));
    });

    await _refreshDaySummary(
      salonId: salonId,
      dayId: request.attendanceDayId,
      calendarDay: DateTime(
        request.requestedPunchTime.year,
        request.requestedPunchTime.month,
        request.requestedPunchTime.day,
      ),
      settings: settings,
      employeeId: request.employeeId,
      employeeName: formatTeamMemberName(request.employeeName),
      employeeAuthUid:
          correctionEmployeeUid != null && correctionEmployeeUid.isNotEmpty
          ? correctionEmployeeUid
          : null,
    );

    await _syncDayPendingCorrectionFlag(
      salonId: salonId,
      attendanceDayId: request.attendanceDayId,
    );
  }

  Future<void> rejectCorrectionRequest({
    required String salonId,
    required String requestId,
    required String reviewerId,
    required String reviewerName,
    required String reason,
  }) async {
    final reqRef = _correctionsCol(salonId).doc(requestId);
    final reqSnap = await reqRef.get();
    if (!reqSnap.exists) {
      throw AttendanceException('Correction request not found.');
    }
    final request = EtCorrectionRequest.fromFirestore(reqSnap);
    if (request.status != 'pending') {
      throw AttendanceException('This correction request is already reviewed.');
    }

    await reqRef.set({
      'status': 'rejected',
      'reviewedBy': reviewerId,
      'reviewedByName': reviewerName,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewNote': reason.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': reviewerId,
    }, SetOptions(merge: true));

    await _syncDayPendingCorrectionFlag(
      salonId: salonId,
      attendanceDayId: request.attendanceDayId,
    );
  }

  List<EtAttendancePunch> _insertPunchSorted(
    List<EtAttendancePunch> punches,
    EtAttendancePunch newPunch,
  ) {
    final all = [...punches, newPunch];
    all.sort((a, b) => a.punchTime.compareTo(b.punchTime));
    return all;
  }

  bool _isValidPunchOrder(List<AttendancePunchType> types) {
    if (types.isEmpty || types.first != AttendancePunchType.punchIn) {
      return false;
    }
    for (var i = 1; i < types.length; i++) {
      final previous = types[i - 1];
      final current = types[i];
      final allowed = switch (previous) {
        AttendancePunchType.punchIn => {
          AttendancePunchType.breakOut,
          AttendancePunchType.punchOut,
        },
        AttendancePunchType.breakOut => {AttendancePunchType.breakIn},
        AttendancePunchType.breakIn => {
          AttendancePunchType.breakOut,
          AttendancePunchType.punchOut,
        },
        AttendancePunchType.punchOut => {AttendancePunchType.punchIn},
      };
      if (!allowed.contains(current)) {
        return false;
      }
    }
    return true;
  }

  int _totalBreakMinutes(List<EtAttendancePunch> punches) {
    var breakMs = 0;
    DateTime? breakOpen;
    for (final punch in punches) {
      if (punch.type == AttendancePunchType.breakOut) {
        breakOpen = punch.punchTime;
        continue;
      }
      if (punch.type == AttendancePunchType.breakIn && breakOpen != null) {
        breakMs += punch.punchTime.difference(breakOpen).inMilliseconds;
        breakOpen = null;
      }
    }
    return (breakMs / 60000).ceil();
  }

  Future<void> _syncDayPendingCorrectionFlag({
    required String salonId,
    required String attendanceDayId,
  }) async {
    final pending = await _correctionsCol(salonId)
        .where('attendanceDayId', isEqualTo: attendanceDayId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    await _dayRef(salonId, attendanceDayId).set({
      'hasPendingCorrectionRequest': pending.docs.isNotEmpty,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

class _MonthlyPolicySummary {
  const _MonthlyPolicySummary({
    required this.lateCount,
    required this.earlyExitCount,
    required this.missingCheckoutCount,
    required this.remainingLateAllowance,
    required this.remainingEarlyAllowance,
    required this.remainingMissingCheckoutAllowance,
    required this.lateAllowanceExceeded,
    required this.earlyAllowanceExceeded,
    required this.missingCheckoutAllowanceExceeded,
    required this.applyLateDeduction,
    required this.applyEarlyExitDeduction,
    required this.applyMissingCheckoutDeduction,
  });

  factory _MonthlyPolicySummary.empty() {
    return const _MonthlyPolicySummary(
      lateCount: 0,
      earlyExitCount: 0,
      missingCheckoutCount: 0,
      remainingLateAllowance: 0,
      remainingEarlyAllowance: 0,
      remainingMissingCheckoutAllowance: 0,
      lateAllowanceExceeded: false,
      earlyAllowanceExceeded: false,
      missingCheckoutAllowanceExceeded: false,
      applyLateDeduction: false,
      applyEarlyExitDeduction: false,
      applyMissingCheckoutDeduction: false,
    );
  }

  final int lateCount;
  final int earlyExitCount;
  final int missingCheckoutCount;
  final int remainingLateAllowance;
  final int remainingEarlyAllowance;
  final int remainingMissingCheckoutAllowance;
  final bool lateAllowanceExceeded;
  final bool earlyAllowanceExceeded;
  final bool missingCheckoutAllowanceExceeded;
  final bool applyLateDeduction;
  final bool applyEarlyExitDeduction;
  final bool applyMissingCheckoutDeduction;
}
