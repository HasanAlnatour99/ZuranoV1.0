import '../../employee_today/data/models/et_attendance_day.dart';

enum AttendanceStatus {
  present,
  absent,
  checkedIn,
  checkedOut,
  onBreak,
  notStarted,
  unknown,
}

enum ShiftState {
  notStarted,
  working,
  breakTime,
  finished,
  unknown,
}

class EmployeeAttendanceProfile {
  const EmployeeAttendanceProfile({
    required this.salonId,
    required this.employeeId,
    required this.name,
    required this.role,
    required this.membershipTier,
    this.photoUrl,
    this.userUid,
  });

  final String salonId;
  final String employeeId;
  final String name;
  final String? photoUrl;
  final String role;

  /// Zurano tier label (defaults when absent in Firestore).
  final String membershipTier;
  final String? userUid;
}

class EmployeeAttendanceDay {
  const EmployeeAttendanceDay({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.dateKey,
    required this.status,
    required this.shiftState,
    this.checkedInAt,
    this.checkedOutAt,
    this.breakStartedAt,
    required this.totalWorkedMinutes,
    required this.totalBreakMinutes,
    required this.exceededBreakMinutes,
  });

  final String id;
  final String employeeId;
  final DateTime date;
  final String dateKey;
  final AttendanceStatus status;
  final ShiftState shiftState;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;
  final DateTime? breakStartedAt;
  final int totalWorkedMinutes;
  final int totalBreakMinutes;
  final int exceededBreakMinutes;
}

class EmployeeAttendanceDayMapper {
  const EmployeeAttendanceDayMapper._();

  static EmployeeAttendanceDay fromEtDay(EtAttendanceDay et) {
    final localDate = et.date.toLocal();
    final y = localDate.year.toString().padLeft(4, '0');
    final m = localDate.month.toString().padLeft(2, '0');
    final d = localDate.day.toString().padLeft(2, '0');
    final isoKey = '$y-$m-$d';

    final status = _statusFromEt(et);
    final shift = _shiftFromEt(et);

    return EmployeeAttendanceDay(
      id: et.id,
      employeeId: et.employeeId,
      date: localDate,
      dateKey: isoKey,
      status: status,
      shiftState: shift,
      checkedInAt: et.firstPunchInAt?.toLocal(),
      checkedOutAt: et.lastPunchOutAt?.toLocal(),
      breakStartedAt: null,
      totalWorkedMinutes: et.workedMinutes,
      totalBreakMinutes: et.breakMinutes,
      exceededBreakMinutes: et.exceededBreakMinutes ?? 0,
    );
  }

  static AttendanceStatus _statusFromEt(EtAttendanceDay et) {
    final s = et.status.trim().toLowerCase();
    switch (s) {
      case 'notstarted':
      case 'not_started':
        return AttendanceStatus.notStarted;
      case 'checkedin':
      case 'checked_in':
        return AttendanceStatus.checkedIn;
      case 'onbreak':
      case 'on_break':
        return AttendanceStatus.onBreak;
      case 'backfrombreak':
      case 'back_from_break':
        return AttendanceStatus.checkedIn;
      case 'checkedout':
      case 'checked_out':
        return AttendanceStatus.checkedOut;
      case 'absent':
        return AttendanceStatus.absent;
      case 'present':
        return AttendanceStatus.present;
      default:
        return AttendanceStatus.unknown;
    }
  }

  static ShiftState _shiftFromEt(EtAttendanceDay et) {
    final s = et.status.trim().toLowerCase();
    switch (s) {
      case 'notstarted':
      case 'not_started':
        return ShiftState.notStarted;
      case 'onbreak':
      case 'on_break':
        return ShiftState.breakTime;
      case 'checkedout':
      case 'checked_out':
        return ShiftState.finished;
      case 'checkedin':
      case 'checked_in':
      case 'backfrombreak':
      case 'back_from_break':
        return ShiftState.working;
      default:
        return ShiftState.unknown;
    }
  }
}
