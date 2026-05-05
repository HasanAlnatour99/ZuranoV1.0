import '../../../../employee_dashboard/application/employee_today_attendance_vm.dart';
import '../../../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import '../../../../employee_today/data/models/et_attendance_day.dart';
import '../../../../employee_today/data/models/et_attendance_punch.dart';
import '../models/attendance_ui_status.dart';
import '../models/employee_attendance_card_model.dart';
import 'employee_live_worked_minutes.dart';

AttendanceUiStatus _mapUiStatus(EmployeeTodayAttendanceVm vm) {
  if (vm.hasMissingPunch || vm.dayStatusKey == 'invalidSequence') {
    return AttendanceUiStatus.needsAttention;
  }
  switch (vm.dayStatusKey) {
    case 'checkedIn':
    case 'backFromBreak':
      return AttendanceUiStatus.working;
    case 'onBreak':
      return AttendanceUiStatus.onBreak;
    case 'checkedOut':
      return AttendanceUiStatus.checkedOut;
    case 'notStarted':
    default:
      return AttendanceUiStatus.notStarted;
  }
}

/// Builds the premium card model from the existing Today attendance VM + day docs.
EmployeeAttendanceCardModel buildEmployeeAttendanceCardModel({
  required EmployeeTodayAttendanceVm vm,
  required EtAttendanceDay? day,
  required List<EtAttendancePunch> punches,
  required int weeklyWorkedMinutes,
  required int weeklyWorkingDays,
  required DateTime now,
}) {
  if (vm.salonId.isEmpty) {
    return EmployeeAttendanceCardModel.empty();
  }

  final dk = day?.dateKey ?? '';
  final locating = !vm.locationResolved;
  final verified = vm.isGpsVerified;
  final outside = vm.locationRowShowsOutside;

  final live = computeEmployeeLiveWorkedMinutes(
    day: day,
    punches: punches,
    now: now,
  );

  return EmployeeAttendanceCardModel(
    salonId: vm.salonId,
    employeeId: vm.employeeId,
    dateKey: dk,
    uiStatus: _mapUiStatus(vm),
    dayStatusKey: vm.dayStatusKey,
    gpsLocating: locating,
    gpsVerified: verified,
    isOutsideZone: outside,
    lastActionAt: vm.lastPunchAt,
    todayWorkedMinutes: live,
    totalBreakMinutes: day?.breakMinutes ?? 0,
    breakCount: day?.totalBreaks ?? 0,
    weeklyWorkedMinutes: weeklyWorkedMinutes,
    weeklyWorkingDays: weeklyWorkingDays,
    canPunchIn: vm.canPunch(AttendancePunchType.punchIn),
    canLeaveBreak: vm.canPunch(AttendancePunchType.breakOut),
    canReturnBreak: vm.canPunch(AttendancePunchType.breakIn),
    canPunchOut: vm.canPunch(AttendancePunchType.punchOut),
  );
}
