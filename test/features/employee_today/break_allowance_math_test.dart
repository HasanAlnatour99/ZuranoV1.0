import 'package:barber_shop_app/features/employee_dashboard/domain/enums/attendance_punch_type.dart';
import 'package:barber_shop_app/features/employee_today/data/models/et_attendance_punch.dart';
import 'package:barber_shop_app/features/employee_today/domain/break_allowance_math.dart';
import 'package:flutter_test/flutter_test.dart';

EtAttendancePunch _p({
  required AttendancePunchType type,
  required DateTime at,
}) {
  return EtAttendancePunch(
    id: '${at.millisecondsSinceEpoch}_$type',
    salonId: 's',
    employeeId: 'e',
    attendanceDayId: 'd',
    type: type,
    punchTime: at,
    source: 't',
    insideZone: true,
    createdBy: 'u',
  );
}

void main() {
  group('completedClosedBreakMinutesClamped', () {
    test('second break allowance uses daily pool minus first break', () {
      final day = DateTime(2026, 5, 2, 0, 0);
      final shiftStart = DateTime(day.year, day.month, day.day, 9);
      final shiftEnd = DateTime(day.year, day.month, day.day, 18);
      final punches = [
        _p(type: AttendancePunchType.punchIn, at: shiftStart),
        _p(
          type: AttendancePunchType.breakOut,
          at: DateTime(day.year, day.month, day.day, 10),
        ),
        _p(
          type: AttendancePunchType.breakIn,
          at: DateTime(day.year, day.month, day.day, 10, 10),
        ),
      ];
      final used = completedClosedBreakMinutesClamped(
        punches,
        shiftStart,
        shiftEnd,
      );
      expect(used, 10);
      const cap = 15;
      final remaining = (cap - used).clamp(0, cap);
      expect(remaining, 5);
    });
  });

  group('clampedIntervalMinutesCeil', () {
    test('clips to shift window', () {
      final day = DateTime(2026, 5, 2);
      final ws = DateTime(day.year, day.month, day.day, 9);
      final we = DateTime(day.year, day.month, day.day, 12);
      final m = clampedIntervalMinutesCeil(
        DateTime(day.year, day.month, day.day, 8, 30),
        DateTime(day.year, day.month, day.day, 12, 30),
        ws,
        we,
      );
      expect(m, 180);
    });
  });
}
