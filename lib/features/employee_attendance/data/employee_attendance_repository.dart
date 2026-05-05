import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/firestore/firestore_paths.dart';
import '../../../core/firestore/firestore_write_payload.dart';
import '../../../core/text/team_member_name.dart';
import '../../employee_dashboard/data/repositories/attendance_request_repository.dart';
import '../../employee_dashboard/data/repositories/employee_attendance_repository.dart'
    as legacy;
import '../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import '../../employee_dashboard/domain/enums/attendance_request_status.dart';
import '../../employee_dashboard/domain/enums/attendance_request_type.dart';
import '../../employee_today/data/models/et_attendance_day.dart';
import '../../employee_today/data/repositories/employee_today_attendance_repository.dart';
import 'employee_attendance_models.dart';
import 'employee_staff_request_models.dart';

/// Attendance tab: profile + [attendanceDays] streams + safe request creation.
class EmployeeAttendanceViewRepository {
  EmployeeAttendanceViewRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth,
       _et = EmployeeTodayAttendanceRepository(firestore: firestore);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final EmployeeTodayAttendanceRepository _et;

  /// Resolves `users/{uid}` then `salons/.../employees/{id}`; optional `employees` collectionGroup on `uid`.
  Stream<EmployeeAttendanceProfile> watchEmployeeProfile() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream<EmployeeAttendanceProfile>.error(
        StateError('NO_AUTH'),
      );
    }
    return _firestore.doc(FirestorePaths.user(uid)).snapshots().asyncExpand((
      userSnap,
    ) {
      if (!userSnap.exists) {
        return Stream<EmployeeAttendanceProfile>.error(
          StateError('USER_DOC_MISSING'),
        );
      }
      final u = userSnap.data() ?? {};
      var salonId = (u['salonId'] as String?)?.trim() ?? '';
      var employeeId = (u['employeeId'] as String?)?.trim() ?? '';
      if (salonId.isEmpty || employeeId.isEmpty) {
        return Stream.fromFuture(
              _tryResolveWorkspaceViaEmployees(uid: uid, userData: u),
            )
            .asyncExpand((resolved) {
              if (resolved == null) {
                return Stream<EmployeeAttendanceProfile>.error(
                  StateError('WORKSPACE_UNRESOLVED'),
                );
              }
              return _watchProfileForWorkspace(
                uid: uid,
                userData: u,
                salonId: resolved.salonId,
                employeeId: resolved.employeeId,
              );
            });
      }
      return _watchProfileForWorkspace(
        uid: uid,
        userData: u,
        salonId: salonId,
        employeeId: employeeId,
      );
    });
  }

  Stream<EmployeeAttendanceProfile> _watchProfileForWorkspace({
    required String uid,
    required Map<String, dynamic> userData,
    required String salonId,
    required String employeeId,
  }) {
    return _firestore
        .doc(FirestorePaths.salonEmployee(salonId, employeeId))
        .snapshots()
        .map((empSnap) {
          final role =
              (userData['role'] as String?)?.trim().isNotEmpty == true
              ? (userData['role'] as String).trim()
              : (empSnap.data()?['role'] as String?)?.trim() ?? '';
          final m = empSnap.data();
          final empName = m?['name']?.toString().trim() ?? '';
          final name = empName.isNotEmpty
              ? empName
              : (userData['name'] as String?)?.trim() ?? '';
          final photo =
              (userData['photoUrl'] as String?)?.trim().isNotEmpty == true
              ? userData['photoUrl'] as String
              : m?['avatarUrl']?.toString();
          final tierRaw =
              empSnap.data()?['membershipTier'] ??
              empSnap.data()?['tier'] ??
              userData['membershipTier'];
          final tier = tierRaw?.toString().trim().isNotEmpty == true
              ? tierRaw.toString().trim()
              : '';

          return EmployeeAttendanceProfile(
            salonId: salonId,
            employeeId: employeeId,
            name: name,
            role: role,
            membershipTier: tier,
            photoUrl: photo,
            userUid: uid,
          );
        });
  }

  Future<({String salonId, String employeeId})?> _tryResolveWorkspaceViaEmployees({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    final salonOnly = (userData['salonId'] as String?)?.trim() ?? '';
    if (salonOnly.isNotEmpty) {
      final q = await _firestore
          .collection(FirestorePaths.salonEmployees(salonOnly))
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
      if (q.docs.isNotEmpty) {
        return (
          salonId: salonOnly,
          employeeId: q.docs.first.id,
        );
      }
    }

    try {
      final g = await _firestore
          .collectionGroup('employees')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
      if (g.docs.isNotEmpty) {
        final path = g.docs.first.reference.path.split('/');
        if (path.length >= 4 && path[0] == 'salons') {
          return (salonId: path[1], employeeId: g.docs.first.id);
        }
      }
    } on FirebaseException catch (e) {
      debugPrint('employee workspace collectionGroup: ${e.code} ${e.message}');
    }
    return null;
  }

  Stream<EmployeeAttendanceDay?> watchTodayAttendance() {
    return watchEmployeeProfile().asyncExpand((profile) {
      return _et
          .watchTodayAttendanceDay(
            salonId: profile.salonId,
            employeeId: profile.employeeId,
          )
          .map(
            (d) =>
                d == null ? null : EmployeeAttendanceDayMapper.fromEtDay(d),
          );
    });
  }

  Stream<List<EmployeeAttendanceDay>> watchAttendanceHistory({
    required int limit,
  }) {
    return watchEmployeeProfile().asyncExpand((profile) {
      return _et
          .watchRecentAttendanceDays(
            salonId: profile.salonId,
            employeeId: profile.employeeId,
            limit: limit,
          )
          .map(
            (rows) => rows
                .map(EmployeeAttendanceDayMapper.fromEtDay)
                .toList(growable: false),
          );
    });
  }

  Stream<List<EmployeeAttendanceDay>> watchAttendanceHistoryInLocalDateRange({
    required DateTime fromLocalDay,
    required DateTime toLocalDay,
  }) {
    return watchEmployeeProfile().asyncExpand((profile) {
      return _et
          .watchAttendanceDaysInLocalDateRange(
            salonId: profile.salonId,
            employeeId: profile.employeeId,
            fromLocalDay: fromLocalDay,
            toLocalDay: toLocalDay,
          )
          .map(
            (rows) => rows
                .map(EmployeeAttendanceDayMapper.fromEtDay)
                .toList(growable: false),
          );
    });
  }

  Future<EmployeeAttendanceProfile> resolveEmployeeProfileOnce() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('NO_AUTH');
    }
    final u = await _firestore.doc(FirestorePaths.user(uid)).get();
    if (!u.exists) {
      throw StateError('USER_DOC_MISSING');
    }
    final data = u.data() ?? {};
    var salonId = (data['salonId'] as String?)?.trim() ?? '';
    var employeeId = (data['employeeId'] as String?)?.trim() ?? '';
    if (salonId.isEmpty || employeeId.isEmpty) {
      final r = await _tryResolveWorkspaceViaEmployees(
        uid: uid,
        userData: data,
      );
      if (r == null) {
        throw StateError('WORKSPACE_UNRESOLVED');
      }
      salonId = r.salonId;
      employeeId = r.employeeId;
    }
    final emp = await _firestore
        .doc(FirestorePaths.salonEmployee(salonId, employeeId))
        .get();
    final role =
        (data['role'] as String?)?.trim().isNotEmpty == true
            ? (data['role'] as String).trim()
            : (emp.data()?['role'] as String?)?.trim() ?? '';
    final empName = emp.data()?['name']?.toString().trim() ?? '';
    final name = empName.isNotEmpty
        ? empName
        : (data['name'] as String?)?.trim() ?? '';
    final photo =
        (data['photoUrl'] as String?)?.trim().isNotEmpty == true
            ? data['photoUrl'] as String
            : emp.data()?['avatarUrl']?.toString();
    final tierRaw =
        emp.data()?['membershipTier'] ??
        emp.data()?['tier'] ??
        data['membershipTier'];
    final tier = tierRaw?.toString().trim().isNotEmpty == true
        ? tierRaw.toString().trim()
        : '';

    return EmployeeAttendanceProfile(
      salonId: salonId,
      employeeId: employeeId,
      name: name,
      role: role,
      membershipTier: tier,
      photoUrl: photo,
      userUid: uid,
    );
  }

  /// Absent [EtAttendanceDay] rows for this employee (excludes days already
  /// covered by a pending `adjustAbsentDay` request).
  /// Uses the existing composite index (`salonId`, `employeeId`, `date`) so this
  /// works immediately; filters `status == absent` in memory. Avoids relying on
  /// a separate `status` composite index that may still be building in Firebase.
  Stream<List<EtAttendanceDay>> watchAbsentDaysForAdjustment({int limit = 30}) {
    return watchEmployeeProfile().asyncExpand((profile) {
      FirestoreWritePayload.assertSalonId(profile.salonId);
      const maxScan = 400;
      return _firestore
          .collection(FirestorePaths.salonAttendanceDays(profile.salonId))
          .where('salonId', isEqualTo: profile.salonId)
          .where('employeeId', isEqualTo: profile.employeeId)
          .orderBy('date', descending: true)
          .limit(maxScan)
          .snapshots()
          .asyncMap((snap) async {
            final pending = await _pendingAdjustAbsentIsoKeys(
              salonId: profile.salonId,
              employeeId: profile.employeeId,
            );
            final out = <EtAttendanceDay>[];
            for (final doc in snap.docs) {
              final d = EtAttendanceDay.fromFirestore(doc);
              if (d.status.trim().toLowerCase() != 'absent') {
                continue;
              }
              if (pending.contains(_isoCalendarKey(d.date))) {
                continue;
              }
              out.add(d);
              if (out.length >= limit) {
                break;
              }
            }
            return out;
          });
    });
  }

  Stream<List<EmployeeLeaveBalance>> watchLeaveBalances() {
    return watchEmployeeProfile().asyncExpand((profile) {
      FirestoreWritePayload.assertSalonId(profile.salonId);
      return _firestore
          .collection(
            FirestorePaths.salonEmployeeLeaveBalances(
              profile.salonId,
              profile.employeeId,
            ),
          )
          .snapshots()
          .map((s) {
            if (s.docs.isEmpty) {
              return const <EmployeeLeaveBalance>[];
            }
            return s.docs.map((d) {
              final m = d.data();
              return EmployeeLeaveBalance(
                leaveTypeId: d.id,
                leaveTypeName: m['leaveTypeName']?.toString().trim().isNotEmpty ==
                        true
                    ? m['leaveTypeName'].toString()
                    : d.id,
                remainingHours:
                    (m['remainingHours'] as num?)?.toDouble() ?? 0,
                remainingDays: (m['remainingDays'] as num?)?.toDouble(),
                updatedAt: (m['updatedAt'] as Timestamp?)?.toDate(),
              );
            }).toList(growable: false);
          });
    });
  }

  Future<void> submitAdjustAbsentDayRequest({
    required List<String> targetDateKeys,
    required String reason,
  }) async {
    final trimmed = reason.trim();
    if (trimmed.length < 5) {
      throw ArgumentError('REASON_TOO_SHORT');
    }
    if (targetDateKeys.isEmpty) {
      throw ArgumentError('NO_DAYS');
    }
    final profile = await resolveEmployeeProfileOnce();
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('NO_AUTH');
    }
    FirestoreWritePayload.assertSalonId(profile.salonId);
    await _assertNoDuplicateAdjustAbsent(
      salonId: profile.salonId,
      employeeId: profile.employeeId,
      keys: targetDateKeys,
    );

    final docRef = _firestore
        .collection(FirestorePaths.salonAttendanceRequests(profile.salonId))
        .doc();
    final firstKey = targetDateKeys.first.replaceAll('-', '');
    final compact =
        firstKey.length >= 8 ? firstKey.substring(0, 8) : firstKey;

    await docRef.set({
      'requestId': docRef.id,
      'type': 'adjustAbsentDay',
      'salonId': profile.salonId,
      'employeeId': profile.employeeId,
      'employeeUid': uid,
      'employeeName': formatTeamMemberName(profile.name),
      'targetDateKeys': targetDateKeys,
      'reason': trimmed,
      'status': AttendanceRequestStatuses.pending,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': uid,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': uid,
      // Legacy fields kept for admin/detail tooling that expects the older shape.
      'attendanceId': 'adjust_absent_${docRef.id}',
      'dateKey': compact,
      'requestType': AttendanceRequestTypes.other,
      'requestedPunchType': AttendancePunchType.punchIn.name,
      'requestedDateTime': FieldValue.serverTimestamp(),
      'reviewedByUid': null,
      'reviewedByName': null,
      'reviewedAt': null,
      'reviewNote': null,
    });
  }

  Future<void> submitAttendanceCorrectionRequest({
    required AttendanceCorrectionKind correctionKind,
    required DateTime requestedDateTime,
    required String reason,
  }) async {
    final trimmed = reason.trim();
    if (trimmed.length < 5) {
      throw ArgumentError('REASON_TOO_SHORT');
    }
    final now = DateTime.now();
    if (requestedDateTime.isAfter(now)) {
      throw StateError('FUTURE_CORRECTION');
    }
    final profile = await resolveEmployeeProfileOnce();
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('NO_AUTH');
    }
    FirestoreWritePayload.assertSalonId(profile.salonId);

    final day = DateTime(
      requestedDateTime.year,
      requestedDateTime.month,
      requestedDateTime.day,
    );
    final targetDateKey = _isoCalendarKey(day);
    final compactKey = AttendanceRequestRepository.compactDateKey(day);
    final attendanceId = legacy.EmployeeAttendanceRepository.attendanceDocumentId(
      profile.employeeId,
      compactKey,
    );
    final punch = correctionKind == AttendanceCorrectionKind.missingPunchIn
        ? AttendancePunchType.punchIn
        : AttendancePunchType.punchOut;

    await _assertNoDuplicateCorrection(
      salonId: profile.salonId,
      employeeId: profile.employeeId,
      targetDateKey: targetDateKey,
      kind: correctionKind,
    );

    final repo = AttendanceRequestRepository(firestore: _firestore);
    final dupLegacy = await repo.hasPendingDuplicate(
      salonId: profile.salonId,
      employeeId: profile.employeeId,
      dateKey: compactKey,
      requestedPunchType: punch,
    );
    if (dupLegacy) {
      throw StateError('DUPLICATE_PENDING');
    }

    final docRef = _firestore
        .collection(FirestorePaths.salonAttendanceRequests(profile.salonId))
        .doc();
    await docRef.set({
      'requestId': docRef.id,
      'type': 'attendanceCorrection',
      'correctionKind': correctionKind.name,
      'targetDateKey': targetDateKey,
      'salonId': profile.salonId,
      'employeeId': profile.employeeId,
      'employeeUid': uid,
      'employeeName': formatTeamMemberName(profile.name),
      'attendanceId': attendanceId,
      'dateKey': compactKey,
      'requestType': AttendanceRequestTypes.missingPunch,
      'requestedPunchType': punch.name,
      'requestedDateTime': Timestamp.fromDate(requestedDateTime),
      'reason': trimmed,
      'status': AttendanceRequestStatuses.pending,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': uid,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': uid,
      'reviewedByUid': null,
      'reviewedByName': null,
      'reviewedAt': null,
      'reviewNote': null,
    });
  }

  Future<void> submitLeaveRequest({
    required String leaveTypeId,
    required String leaveTypeName,
    required DateTime startAt,
    required DateTime endAt,
    required double requestedHours,
    required double remainingHoursAtRequest,
    required String reason,
  }) async {
    final trimmed = reason.trim();
    if (trimmed.length < 5) {
      throw ArgumentError('REASON_TOO_SHORT');
    }
    if (requestedHours <= 0) {
      throw StateError('LEAVE_HOURS_INVALID');
    }
    if (requestedHours > remainingHoursAtRequest) {
      throw StateError('LEAVE_EXCEEDS_BALANCE');
    }
    final profile = await resolveEmployeeProfileOnce();
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('NO_AUTH');
    }
    FirestoreWritePayload.assertSalonId(profile.salonId);

    await _assertLeaveNoOverlap(
      salonId: profile.salonId,
      employeeId: profile.employeeId,
      start: startAt,
      end: endAt,
    );

    final docRef = _firestore
        .collection(FirestorePaths.salonAttendanceRequests(profile.salonId))
        .doc();
    final dateKey = AttendanceRequestRepository.compactDateKey(startAt);

    await docRef.set({
      'requestId': docRef.id,
      'type': 'leaveRequest',
      'leaveTypeId': leaveTypeId,
      'leaveTypeName': leaveTypeName,
      'salonId': profile.salonId,
      'employeeId': profile.employeeId,
      'employeeUid': uid,
      'employeeName': formatTeamMemberName(profile.name),
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'requestedHours': requestedHours,
      'remainingHoursAtRequest': remainingHoursAtRequest,
      'reason': trimmed,
      'status': AttendanceRequestStatuses.pending,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': uid,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': uid,
      'attendanceId': 'leave_${docRef.id}',
      'dateKey': dateKey,
      'requestType': AttendanceRequestTypes.other,
      'requestedPunchType': AttendancePunchType.punchIn.name,
      'requestedDateTime': Timestamp.fromDate(startAt),
      'reviewedByUid': null,
      'reviewedByName': null,
      'reviewedAt': null,
      'reviewNote': null,
    });
  }

  Future<Set<String>> _pendingAdjustAbsentIsoKeys({
    required String salonId,
    required String employeeId,
  }) async {
    final q = await _firestore
        .collection(FirestorePaths.salonAttendanceRequests(salonId))
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: AttendanceRequestStatuses.pending)
        .limit(40)
        .get();
    final out = <String>{};
    for (final d in q.docs) {
      final m = d.data();
      if (m['type']?.toString() != 'adjustAbsentDay') {
        continue;
      }
      final keys = m['targetDateKeys'];
      if (keys is List) {
        for (final k in keys) {
          out.add(k.toString());
        }
      }
    }
    return out;
  }

  Future<void> _assertNoDuplicateAdjustAbsent({
    required String salonId,
    required String employeeId,
    required List<String> keys,
  }) async {
    final sel = keys.toSet();
    final pending = await _pendingAdjustAbsentIsoKeys(
      salonId: salonId,
      employeeId: employeeId,
    );
    for (final k in sel) {
      if (pending.contains(k)) {
        throw StateError('DUPLICATE_ADJUST_ABSENT');
      }
    }
  }

  Future<void> _assertNoDuplicateCorrection({
    required String salonId,
    required String employeeId,
    required String targetDateKey,
    required AttendanceCorrectionKind kind,
  }) async {
    final q = await _firestore
        .collection(FirestorePaths.salonAttendanceRequests(salonId))
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: AttendanceRequestStatuses.pending)
        .limit(40)
        .get();
    for (final d in q.docs) {
      final m = d.data();
      if (m['type']?.toString() != 'attendanceCorrection') {
        continue;
      }
      if (m['targetDateKey']?.toString() == targetDateKey &&
          m['correctionKind']?.toString() == kind.name) {
        throw StateError('DUPLICATE_CORRECTION');
      }
    }
  }

  Future<void> _assertLeaveNoOverlap({
    required String salonId,
    required String employeeId,
    required DateTime start,
    required DateTime end,
  }) async {
    final q = await _firestore
        .collection(FirestorePaths.salonAttendanceRequests(salonId))
        .where('employeeId', isEqualTo: employeeId)
        .limit(60)
        .get();
    for (final d in q.docs) {
      final m = d.data();
      if (m['type']?.toString() != 'leaveRequest') {
        continue;
      }
      final st = m['status']?.toString() ?? '';
      if (st != AttendanceRequestStatuses.pending &&
          st != AttendanceRequestStatuses.approved) {
        continue;
      }
      final sa = (m['startAt'] as Timestamp?)?.toDate();
      final ea = (m['endAt'] as Timestamp?)?.toDate();
      if (sa != null &&
          ea != null &&
          dateRangesOverlap(start, end, sa, ea)) {
        throw StateError('LEAVE_OVERLAP');
      }
    }
  }
}

String _isoCalendarKey(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}
