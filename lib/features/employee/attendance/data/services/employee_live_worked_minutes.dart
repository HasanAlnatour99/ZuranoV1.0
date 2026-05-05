import '../../../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import '../../../../employee_today/data/models/et_attendance_day.dart';
import '../../../../employee_today/data/models/et_attendance_punch.dart';

/// Live “worked so far today” minutes (matches employee attendance screen logic).
int computeEmployeeLiveWorkedMinutes({
  required EtAttendanceDay? day,
  required List<EtAttendancePunch> punches,
  required DateTime now,
}) {
  if (day == null || punches.isEmpty) {
    return day?.workedMinutes ?? 0;
  }
  if (day.status == 'checkedOut') {
    return day.workedMinutes;
  }
  final sorted = List<EtAttendancePunch>.from(punches)
    ..sort((a, b) => a.punchTime.compareTo(b.punchTime));
  final last = sorted.last;
  var base = day.workedMinutes;
  if (last.type == AttendancePunchType.punchIn ||
      last.type == AttendancePunchType.breakIn) {
    base += now.difference(last.punchTime).inMinutes;
  }
  return base;
}
