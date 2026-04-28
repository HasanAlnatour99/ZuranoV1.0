import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/firestore/firestore_paths.dart';
import '../../../../core/firestore/firestore_write_payload.dart';
import '../../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import '../attendance_exception.dart';
import '../models/et_attendance_day.dart';
import '../models/et_attendance_punch.dart';
import '../models/et_attendance_settings.dart';
import '../models/et_correction_request.dart';
import '../../domain/attendance_analysis_service.dart';
import '../../domain/attendance_status.dart';
import '../../domain/attendance_state_resolver.dart';

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

  CollectionReference<Map<String, dynamic>> _correctionsCol(String salonId) =>
      _firestore.collection(
        FirestorePaths.salonAttendanceCorrectionRequests(salonId),
      );

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
        .limit(AttendanceStateResolver.maxPunchesPerDayHardLimit)
        .get();
    final sortedPunchesBeforeTx = punchesSnapBeforeTx.docs
        .map(EtAttendancePunch.fromFirestore)
        .toList(growable: false);

    await _firestore.runTransaction((tx) async {
      final daySnap = await tx.get(dayRef);
      final sortedPunches = sortedPunchesBeforeTx;
      final seq = List<String>.from(
        daySnap.data()?['punchSequence'] as List? ?? const [],
      );
      final punchIds = List<String>.from(
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

      if (sortedPunches.length >= settings.maxPunchesPerDay) {
        throw AttendanceException('You reached today\'s maximum punches.');
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

      if (type == AttendancePunchType.breakIn) {
        int breakMs = 0;
        DateTime? breakOpen;
        for (final p in sortedPunches) {
          if (p.type == AttendancePunchType.breakOut) {
            breakOpen = p.punchTime;
          } else if (p.type == AttendancePunchType.breakIn) {
            final open = breakOpen;
            if (open != null) {
              breakMs += p.punchTime.difference(open).inMilliseconds;
              breakOpen = null;
            }
          }
        }
        if (breakOpen != null) {
          breakMs += punchTime.difference(breakOpen).inMilliseconds;
        }
        final breakMin = (breakMs / 60000).ceil();
        if (breakMin > settings.maxBreakMinutesPerDay) {
          throw AttendanceException(
            'Your break time exceeded the allowed daily limit.',
          );
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
      final shiftEndAt = _shiftEndForDay(punchTime, settings.standardShiftEnd);
      final calculatedStatus = calculateTodayStatus(
        punches: projectedPunches,
        now: now,
        shiftEndAt: shiftEndAt,
        maxBreakMinutesPerDay: settings.maxBreakMinutesPerDay,
        maxPunchesPerDay: settings.maxPunchesPerDay,
      );
      final missingReason = _missingPunchReason(
        status: calculatedStatus,
        punches: projectedPunches,
        now: now,
        shiftEndAt: shiftEndAt,
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

      tx.set(dayRef, {
        'id': dayId,
        'salonId': salonId,
        'employeeId': employeeId,
        'employeeName': employeeName,
        'workDate': '${punchTime.year.toString().padLeft(4, '0')}-${punchTime.month.toString().padLeft(2, '0')}-${punchTime.day.toString().padLeft(2, '0')}',
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
      }, SetOptions(merge: true));
    });

    await _refreshDaySummary(
      salonId: salonId,
      dayId: dayId,
      calendarDay: DateTime(now.year, now.month, now.day),
      settings: settings,
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
    if (last.type == AttendancePunchType.breakOut &&
        now.difference(last.punchTime).inMinutes > maxBreakMinutesPerDay) {
      return 'missingBreakInAfterBreakOut';
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
      maxPunchesPerDay: settings.maxPunchesPerDay,
    );
    final missingReason = _missingPunchReason(
      status: todayStatus,
      punches: punches,
      now: DateTime.now(),
      shiftEndAt: shiftEndAt,
      maxBreakMinutesPerDay: settings.maxBreakMinutesPerDay,
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
      'totalBreaks': calc.totalBreaks,
      'firstPunchInAt': calc.firstPunchInAt != null
          ? Timestamp.fromDate(calc.firstPunchInAt!)
          : null,
      'lastPunchOutAt': calc.lastPunchOutAt != null
          ? Timestamp.fromDate(calc.lastPunchOutAt!)
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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
    if (merged.length > settings.maxPunchesPerDay) {
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
      'employeeName': employeeName,
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
    // Owner/admin app: implement in follow-up; placeholder keeps API surface.
    if (kDebugMode) {
      debugPrint('approveCorrectionRequest not yet wired: $requestId');
    }
  }

  Future<void> rejectCorrectionRequest({
    required String salonId,
    required String requestId,
    required String reviewerId,
    required String reviewerName,
    required String reason,
  }) async {
    if (kDebugMode) {
      debugPrint('rejectCorrectionRequest not yet wired: $requestId');
    }
  }
}
