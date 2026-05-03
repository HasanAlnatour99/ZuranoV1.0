import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/auth/auth_guard.dart';
import '../../../../core/firestore/firestore_paths.dart';
import '../../../../core/firestore/firestore_write_payload.dart';
import '../../../employees/data/models/employee.dart';
import '../../../owner/settings/attendance/domain/models/attendance_settings_model.dart';
import '../../../owner_settings/shifts/data/models/employee_schedule_model.dart';
import '../../../salon/data/models/salon.dart';
import '../../domain/repositories/owner_attendance_adjustment_repository.dart';

/// Reads Firestore + invokes [reprocessAttendanceForEmployeeDate] callable.
class AttendanceAdjustmentRemoteDataSource {
  AttendanceAdjustmentRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseFunctions functions,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _fn = functions,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _fn;
  final FirebaseAuth _auth;

  String _attendanceDocId(String employeeId, DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${employeeId}_$y$m$d';
  }

  String _scheduleDocId(String employeeId, DateTime date) {
    return _attendanceDocId(employeeId, date);
  }

  Future<OwnerAttendanceAdjustmentLoad> load({
    required String salonId,
    required String employeeId,
    required DateTime attendanceDate,
  }) async {
    FirestoreWritePayload.assertSalonId(salonId);

    final day = DateTime(
      attendanceDate.year,
      attendanceDate.month,
      attendanceDate.day,
    );

    final employeeSnap =
        await _firestore.doc(FirestorePaths.salonEmployee(salonId, employeeId)).get();

    final employeeJson = employeeSnap.data();
    if (employeeJson == null) {
      throw StateError('Employee not found.');
    }
    final employee = Employee.fromJson(employeeJson);

    final salonSnap = await _firestore.doc(FirestorePaths.salon(salonId)).get();
    final sm = salonSnap.data();
    final branchName = sm != null
        ? Salon.fromJson(Map<String, dynamic>.from({...sm, 'id': salonId})).name
              .trim()
        : salonId.trim();

    final settingsSnap =
        await _firestore.doc(FirestorePaths.salonAttendanceSettingsDoc(salonId)).get();
    final settings =
        AttendanceSettingsModel.fromFirestore(salonId, settingsSnap);

    final scheduleSnap = await _firestore
        .doc(FirestorePaths.salonEmployeeSchedule(
          salonId,
          _scheduleDocId(employeeId, day),
        ))
        .get();

    final schedule = scheduleSnap.exists && scheduleSnap.data() != null
        ? EmployeeScheduleModel.fromFirestore(scheduleSnap)
        : null;

    final attendanceId = _attendanceDocId(employeeId, day);
    final attendanceSnap = await _firestore
        .doc(FirestorePaths.salonAttendanceRecord(salonId, attendanceId))
        .get();

    return OwnerAttendanceAdjustmentLoad(
      employee: employee,
      branchName: branchName.isNotEmpty ? branchName : salonId,
      schedule: schedule,
      attendancePayload: attendanceSnap.exists ? attendanceSnap.data() : null,
      settings: settings,
    );
  }

  Future<OwnerAttendanceAdjustmentSaveResult> reprocessAttendance({
    required String salonId,
    required String employeeId,
    required DateTime attendanceDate,
    String? shiftId,
    required String status,
    DateTime? punchInAt,
    DateTime? breakOutAt,
    DateTime? breakInAt,
    DateTime? punchOutAt,
    required String reason,
    String? managerNote,
  }) async {
    final day = DateTime(
      attendanceDate.year,
      attendanceDate.month,
      attendanceDate.day,
    );

    await requireFirebaseUser(_auth);

    final callable = _fn.httpsCallable('reprocessAttendanceForEmployeeDate');

    final result = await callable.call({
      'salonId': salonId,
      'employeeId': employeeId,
      'attendanceDate': '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
      if (shiftId != null && shiftId.trim().isNotEmpty) 'shiftId': shiftId.trim(),
      'status': status,
      'punchInAt': punchInAt?.toUtc().toIso8601String(),
      'breakOutAt': breakOutAt?.toUtc().toIso8601String(),
      'breakInAt': breakInAt?.toUtc().toIso8601String(),
      'punchOutAt': punchOutAt?.toUtc().toIso8601String(),
      'reason': reason,
      if (managerNote != null && managerNote.trim().isNotEmpty)
        'managerNote': managerNote.trim(),
    });

    final raw = result.data;
    final data = switch (raw) {
      final Map m => Map<String, dynamic>.from(m),
      _ => null,
    };
    if (data == null || data['success'] != true) {
      throw StateError('Unexpected response from reprocessAttendance.');
    }

    final rec = (data['recalculated'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    return OwnerAttendanceAdjustmentSaveResult(
      attendanceId: data['attendanceId'] as String? ?? '',
      lateMinutes: (rec['lateMinutes'] as num?)?.toInt() ?? 0,
      earlyExitMinutes: (rec['earlyExitMinutes'] as num?)?.toInt() ?? 0,
      missingCheckoutMinutes:
          (rec['missingCheckoutMinutes'] as num?)?.toInt() ?? 0,
      workedMinutes: (rec['workedMinutes'] as num?)?.toInt() ?? 0,
      breakMinutes: (rec['breakMinutes'] as num?)?.toInt() ?? 0,
      overtimeMinutes: (rec['overtimeMinutes'] as num?)?.toInt() ?? 0,
      missingCheckout: rec['missingCheckout'] == true,
      storageStatus: rec['status'] as String? ?? status,
    );
  }
}
