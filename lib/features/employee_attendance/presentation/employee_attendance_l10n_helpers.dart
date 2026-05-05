import '../../../l10n/app_localizations.dart';
import '../data/employee_attendance_models.dart';

String formatAttendanceWorkedL10n(AppLocalizations l10n, int minutes) {
  if (minutes <= 0) {
    return l10n.employeeAttendanceTabDurationZero;
  }
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (hours == 0) {
    return l10n.employeeAttendanceTabDurationMinutes(mins);
  }
  if (mins == 0) {
    return l10n.employeeAttendanceTabDurationHours(hours);
  }
  return l10n.employeeAttendanceTabDurationHoursMinutes(hours, mins);
}

String attendanceStatusLabel(AppLocalizations l10n, AttendanceStatus s) {
  switch (s) {
    case AttendanceStatus.notStarted:
      return l10n.employeeAttendanceTabStatusNotStarted;
    case AttendanceStatus.checkedIn:
      return l10n.employeeAttendanceTabStatusCheckedIn;
    case AttendanceStatus.checkedOut:
      return l10n.employeeAttendanceTabStatusCheckedOut;
    case AttendanceStatus.onBreak:
      return l10n.employeeAttendanceTabStatusOnBreak;
    case AttendanceStatus.absent:
      return l10n.employeeAttendanceTabStatusAbsent;
    case AttendanceStatus.present:
      return l10n.employeeAttendanceTabStatusPresent;
    case AttendanceStatus.unknown:
      return l10n.employeeAttendanceTabStatusUnknown;
  }
}

String shiftStateLabel(AppLocalizations l10n, ShiftState s) {
  switch (s) {
    case ShiftState.working:
      return l10n.employeeAttendanceTabShiftWorking;
    case ShiftState.breakTime:
      return l10n.employeeAttendanceTabShiftBreak;
    case ShiftState.finished:
      return l10n.employeeAttendanceTabShiftFinished;
    case ShiftState.notStarted:
      return l10n.employeeAttendanceTabShiftNotStarted;
    case ShiftState.unknown:
      return l10n.employeeAttendanceTabShiftUnknown;
  }
}
