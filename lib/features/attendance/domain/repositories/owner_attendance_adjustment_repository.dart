import '../../../employees/data/models/employee.dart';
import '../../../owner/settings/attendance/domain/models/attendance_settings_model.dart';
import '../../../owner_settings/shifts/data/models/employee_schedule_model.dart';

class OwnerAttendanceAdjustmentLoad {
  const OwnerAttendanceAdjustmentLoad({
    required this.employee,
    required this.branchName,
    required this.schedule,
    required this.attendancePayload,
    required this.settings,
  });

  final Employee employee;
  final String branchName;
  final EmployeeScheduleModel? schedule;
  final Map<String, dynamic>? attendancePayload;
  final AttendanceSettingsModel settings;
}

class OwnerAttendanceAdjustmentSaveResult {
  const OwnerAttendanceAdjustmentSaveResult({
    required this.attendanceId,
    required this.lateMinutes,
    required this.earlyExitMinutes,
    required this.missingCheckoutMinutes,
    required this.workedMinutes,
    required this.breakMinutes,
    required this.overtimeMinutes,
    required this.missingCheckout,
    required this.storageStatus,
  });

  final String attendanceId;
  final int lateMinutes;
  final int earlyExitMinutes;
  final int missingCheckoutMinutes;
  final int workedMinutes;
  final int breakMinutes;
  final int overtimeMinutes;
  final bool missingCheckout;
  final String storageStatus;
}

abstract class OwnerAttendanceAdjustmentRepository {
  Future<OwnerAttendanceAdjustmentLoad> loadContext({
    required String salonId,
    required String employeeId,
    required DateTime attendanceDate,
  });

  Future<OwnerAttendanceAdjustmentSaveResult> saveViaCloudFunction({
    required String salonId,
    required String employeeId,
    required DateTime attendanceDate,
    String? shiftId,
    required String statusApiValue,
    required DateTime? punchInAt,
    required DateTime? breakOutAt,
    required DateTime? breakInAt,
    required DateTime? punchOutAt,
    required String reason,
    String? managerNote,
  });
}
