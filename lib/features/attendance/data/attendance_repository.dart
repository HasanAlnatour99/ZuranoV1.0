import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/attendance_approval.dart';
import '../../../core/firestore/firestore_paths.dart';
import '../../../core/firestore/firestore_write_payload.dart';
import 'models/attendance_record.dart';

class AttendanceRepository {
  AttendanceRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _attendance(String salonId) {
    FirestoreWritePayload.assertSalonId(salonId);
    return _firestore.collection(FirestorePaths.salonAttendance(salonId));
  }

  Future<String> createAttendanceRecord(
    String salonId,
    AttendanceRecord record,
  ) async {
    final collection = _attendance(salonId);
    final document = record.id.isEmpty
        ? collection.doc()
        : collection.doc(record.id);
    final payload = FirestoreWritePayload.withServerTimestampsForCreate({
      ...record.toJson(),
      'id': document.id,
    });

    await document.set(payload);
    return document.id;
  }

  Future<void> updateAttendanceRecord(String salonId, AttendanceRecord record) {
    return _attendance(salonId)
        .doc(record.id)
        .set(
          FirestoreWritePayload.withServerTimestampForUpdate(record.toJson()),
          SetOptions(merge: true),
        );
  }

  Future<AttendanceRecord?> getAttendanceRecord(
    String salonId,
    String attendanceId,
  ) async {
    if (attendanceId.isEmpty) {
      throw ArgumentError.value(
        attendanceId,
        'attendanceId',
        'Attendance ID is required.',
      );
    }

    final snap = await _attendance(salonId).doc(attendanceId).get();
    final data = snap.data();
    if (data == null) {
      return null;
    }
    return AttendanceRecord.fromJson(data);
  }

  /// Sets [AttendanceRecord.checkInAt] if the record exists and is not already checked in.
  Future<void> checkIn({
    required String salonId,
    required String attendanceId,
    DateTime? at,
  }) async {
    if (attendanceId.isEmpty) {
      throw ArgumentError.value(
        attendanceId,
        'attendanceId',
        'Attendance ID is required.',
      );
    }

    final ref = _attendance(salonId).doc(attendanceId);
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(ref);
      if (!snap.exists) {
        throw StateError('Attendance record not found.');
      }
      final data = snap.data();
      if (data == null) {
        throw StateError('Attendance record not found.');
      }
      if (data['checkInAt'] != null) {
        throw StateError('Already checked in.');
      }

      txn.update(ref, {
        'checkInAt': at != null
            ? Timestamp.fromDate(at)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Sets [AttendanceRecord.checkOutAt] after a check-in exists and before double check-out.
  Future<void> checkOut({
    required String salonId,
    required String attendanceId,
    DateTime? at,
  }) async {
    if (attendanceId.isEmpty) {
      throw ArgumentError.value(
        attendanceId,
        'attendanceId',
        'Attendance ID is required.',
      );
    }

    final ref = _attendance(salonId).doc(attendanceId);
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(ref);
      if (!snap.exists) {
        throw StateError('Attendance record not found.');
      }
      final data = snap.data();
      if (data == null) {
        throw StateError('Attendance record not found.');
      }
      if (data['checkInAt'] == null) {
        throw StateError('Cannot check out before checking in.');
      }
      if (data['checkOutAt'] != null) {
        throw StateError('Already checked out.');
      }

      txn.update(ref, {
        'checkOutAt': at != null
            ? Timestamp.fromDate(at)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Owner/admin approval workflow: sets [AttendanceRecord.approvalStatus],
  /// [AttendanceRecord.approvedByUid], and related approval metadata.
  Future<void> approveAttendance({
    required String salonId,
    required String attendanceId,
    required String approvedByUid,
    String? approvedByName,
    required String approvalStatus,
    String? rejectionReason,
  }) async {
    if (attendanceId.isEmpty) {
      throw ArgumentError.value(
        attendanceId,
        'attendanceId',
        'Attendance ID is required.',
      );
    }
    if (approvedByUid.isEmpty) {
      throw ArgumentError.value(
        approvedByUid,
        'approvedByUid',
        'Approver user id is required.',
      );
    }
    if (approvalStatus != AttendanceApprovalStatuses.approved &&
        approvalStatus != AttendanceApprovalStatuses.rejected) {
      throw ArgumentError.value(
        approvalStatus,
        'approvalStatus',
        'Must be "${AttendanceApprovalStatuses.approved}" or '
            '"${AttendanceApprovalStatuses.rejected}".',
      );
    }

    final ref = _attendance(salonId).doc(attendanceId);
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(ref);
      if (!snap.exists) {
        throw StateError('Attendance record not found.');
      }

      final patch = <String, dynamic>{
        'approvalStatus': approvalStatus,
        'approvedByUid': approvedByUid,
        'approvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (approvedByName != null && approvedByName.trim().isNotEmpty) {
        patch['approvedByName'] = approvedByName.trim();
      } else {
        patch['approvedByName'] = FieldValue.delete();
      }

      if (approvalStatus == AttendanceApprovalStatuses.approved) {
        patch['rejectionReason'] = FieldValue.delete();
      } else if (rejectionReason != null && rejectionReason.isNotEmpty) {
        patch['rejectionReason'] = rejectionReason;
      } else {
        patch['rejectionReason'] = FieldValue.delete();
      }

      txn.update(ref, patch);
    });
  }

  /// All attendance records awaiting owner/admin review, newest first.
  ///
  /// Bounded by [salonId] and `approvalStatus == pending`. The owner queue on
  /// the dashboard consumes this stream directly — keep [limit] small enough
  /// for a one-page review experience.
  Stream<List<AttendanceRecord>> watchPendingAttendanceRequests(
    String salonId, {
    int limit = 100,
  }) {
    FirestoreWritePayload.assertSalonId(salonId);
    final query = _attendance(salonId)
        .where('approvalStatus', isEqualTo: AttendanceApprovalStatuses.pending)
        .orderBy('workDate', descending: true)
        .limit(limit);
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => AttendanceRecord.fromJson(doc.data()))
          .toList(),
    );
  }

  Stream<List<AttendanceRecord>> watchAttendance(
    String salonId, {
    String? employeeId,
    DateTime? workDateFrom,
    DateTime? workDateTo,
    int limit = 90,
  }) {
    Query<Map<String, dynamic>> query = _attendance(
      salonId,
    ).orderBy('workDate', descending: true).limit(limit);

    if (employeeId != null && employeeId.isNotEmpty) {
      query = query.where('employeeId', isEqualTo: employeeId);
    }

    if (workDateFrom != null) {
      final d = workDateFrom;
      final fromDay = DateTime(d.year, d.month, d.day);
      query = query.where(
        'workDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(fromDay),
      );
    }

    if (workDateTo != null) {
      final d = workDateTo;
      final inclusiveEndDay = DateTime(d.year, d.month, d.day);
      final exclusiveNext = inclusiveEndDay.add(const Duration(days: 1));
      query = query.where(
        'workDate',
        isLessThan: Timestamp.fromDate(exclusiveNext),
      );
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => AttendanceRecord.fromJson(
              <String, dynamic>{...doc.data(), 'id': doc.id},
            ),
          )
          .toList(),
    );
  }

  Future<List<AttendanceRecord>> getAttendance(
    String salonId, {
    String? employeeId,
    DateTime? workDateFrom,
    DateTime? workDateTo,
    int limit = 120,
  }) async {
    Query<Map<String, dynamic>> query = _attendance(
      salonId,
    ).orderBy('workDate', descending: true).limit(limit);

    if (employeeId != null && employeeId.isNotEmpty) {
      query = query.where('employeeId', isEqualTo: employeeId);
    }

    if (workDateFrom != null) {
      final d = workDateFrom;
      final fromDay = DateTime(d.year, d.month, d.day);
      query = query.where(
        'workDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(fromDay),
      );
    }

    if (workDateTo != null) {
      final d = workDateTo;
      final inclusiveEndDay = DateTime(d.year, d.month, d.day);
      final exclusiveNext = inclusiveEndDay.add(const Duration(days: 1));
      query = query.where(
        'workDate',
        isLessThan: Timestamp.fromDate(exclusiveNext),
      );
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) => AttendanceRecord.fromJson(
            <String, dynamic>{...doc.data(), 'id': doc.id},
          ),
        )
        .toList(growable: false);
  }
}
