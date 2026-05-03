import 'dart:math' as math;

import '../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import '../data/models/et_attendance_punch.dart';

/// Parses `HH:mm` into a [DateTime] on [calendarDay] (local calendar fields).
DateTime? shiftBoundaryOnCalendarDay(DateTime calendarDay, String? hhmm) {
  if (hhmm == null || !hhmm.contains(':')) {
    return null;
  }
  final parts = hhmm.split(':');
  if (parts.length != 2) {
    return null;
  }
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) {
    return null;
  }
  if (h < 0 || h > 23 || m < 0 || m > 59) {
    return null;
  }
  return DateTime(calendarDay.year, calendarDay.month, calendarDay.day, h, m);
}

/// Minutes from [start] to [end], clamped to \[ [windowStart], [windowEnd] ]\, ceil.
///
/// When either window bound is null, no clamping on that side.
int clampedIntervalMinutesCeil(
  DateTime start,
  DateTime end,
  DateTime? windowStart,
  DateTime? windowEnd,
) {
  if (!end.isAfter(start)) {
    return 0;
  }
  var s = start;
  var e = end;
  if (windowEnd != null && s.isAfter(windowEnd)) {
    return 0;
  }
  if (windowStart != null && e.isBefore(windowStart)) {
    return 0;
  }
  if (windowStart != null && s.isBefore(windowStart)) {
    s = windowStart;
  }
  if (windowEnd != null && e.isAfter(windowEnd)) {
    e = windowEnd;
  }
  if (!e.isAfter(s)) {
    return 0;
  }
  final ms = e.difference(s).inMilliseconds;
  return math.max(1, (ms / 60000).ceil());
}

/// Sum of completed break sessions (each `breakOut` … `breakIn` pair), minutes
/// clamped to the shift window. Ignores a trailing open `breakOut`.
int completedClosedBreakMinutesClamped(
  List<EtAttendancePunch> sortedAscending,
  DateTime? shiftStart,
  DateTime? shiftEnd,
) {
  var total = 0;
  DateTime? openBreakOut;
  for (final p in sortedAscending) {
    if (p.type == AttendancePunchType.breakOut) {
      openBreakOut = p.punchTime;
    } else if (p.type == AttendancePunchType.breakIn) {
      if (openBreakOut != null) {
        total += clampedIntervalMinutesCeil(
          openBreakOut,
          p.punchTime,
          shiftStart,
          shiftEnd,
        );
        openBreakOut = null;
      }
    }
  }
  return total;
}

/// Elapsed seconds for an **open** break from [breakOutAt] to [now], clamped to shift.
int openBreakElapsedSecondsClamped(
  DateTime breakOutAt,
  DateTime now,
  DateTime? shiftStart,
  DateTime? shiftEnd,
) {
  var s = breakOutAt;
  var e = now;
  if (shiftEnd != null && s.isAfter(shiftEnd)) {
    return 0;
  }
  if (shiftStart != null && e.isBefore(shiftStart)) {
    return 0;
  }
  if (shiftStart != null && s.isBefore(shiftStart)) {
    s = shiftStart;
  }
  if (shiftEnd != null && e.isAfter(shiftEnd)) {
    e = shiftEnd;
  }
  if (!e.isAfter(s)) {
    return 0;
  }
  return e.difference(s).inSeconds;
}