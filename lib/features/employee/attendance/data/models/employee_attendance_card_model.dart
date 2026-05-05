import 'attendance_ui_status.dart';

/// Read-only snapshot for the premium attendance card (backed by Today attendance + week rollup).
class EmployeeAttendanceCardModel {
  const EmployeeAttendanceCardModel({
    required this.salonId,
    required this.employeeId,
    required this.dateKey,
    required this.uiStatus,
    required this.dayStatusKey,
    required this.gpsLocating,
    required this.gpsVerified,
    required this.isOutsideZone,
    required this.lastActionAt,
    required this.todayWorkedMinutes,
    required this.totalBreakMinutes,
    required this.breakCount,
    required this.weeklyWorkedMinutes,
    required this.weeklyWorkingDays,
    required this.canPunchIn,
    required this.canLeaveBreak,
    required this.canReturnBreak,
    required this.canPunchOut,
  });

  final String salonId;
  final String employeeId;
  final String dateKey;
  final AttendanceUiStatus uiStatus;

  /// Raw Firestore/UI key from [EmployeeTodayAttendanceVm.dayStatusKey].
  final String dayStatusKey;
  final bool gpsLocating;
  final bool gpsVerified;
  final bool isOutsideZone;
  final DateTime? lastActionAt;
  final int todayWorkedMinutes;
  final int totalBreakMinutes;
  final int breakCount;
  final int weeklyWorkedMinutes;
  final int weeklyWorkingDays;
  final bool canPunchIn;
  final bool canLeaveBreak;
  final bool canReturnBreak;
  final bool canPunchOut;

  double get todayHours => todayWorkedMinutes / 60.0;

  double get weeklyHours => weeklyWorkedMinutes / 60.0;

  static EmployeeAttendanceCardModel empty() => const EmployeeAttendanceCardModel(
        salonId: '',
        employeeId: '',
        dateKey: '',
        uiStatus: AttendanceUiStatus.notStarted,
        dayStatusKey: 'notStarted',
        gpsLocating: true,
        gpsVerified: false,
        isOutsideZone: false,
        lastActionAt: null,
        todayWorkedMinutes: 0,
        totalBreakMinutes: 0,
        breakCount: 0,
        weeklyWorkedMinutes: 0,
        weeklyWorkingDays: 0,
        canPunchIn: false,
        canLeaveBreak: false,
        canReturnBreak: false,
        canPunchOut: false,
      );
}
