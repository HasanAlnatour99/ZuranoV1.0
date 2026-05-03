import 'package:flutter_test/flutter_test.dart';
import 'package:barber_shop_app/features/employee_dashboard/domain/enums/attendance_punch_type.dart';
import 'package:barber_shop_app/features/employee_today/data/models/et_attendance_punch.dart';
import 'package:barber_shop_app/features/employee_today/domain/attendance_status.dart';

EtAttendancePunch _punch({
  required String id,
  required AttendancePunchType type,
  required DateTime at,
}) {
  return EtAttendancePunch(
    id: id,
    salonId: 'salon_1',
    employeeId: 'emp_1',
    attendanceDayId: '20260428_emp_1',
    type: type,
    punchTime: at,
    source: 'mobile',
    insideZone: true,
    createdBy: 'uid_1',
  );
}

void main() {
  group('calculateTodayStatus', () {
    final now = DateTime(2026, 4, 28, 12);

    test('A: no punches returns notStarted', () {
      final status = calculateTodayStatus(
        punches: const [],
        now: now,
        shiftEndAt: DateTime(2026, 4, 28, 18),
        maxBreakMinutesPerDay: 30,
        maxWorkPunchesPerDay: 2,
      );
      expect(status, AttendanceStatus.notStarted);
    });

    test('B: punch in just now returns checkedIn', () {
      final status = calculateTodayStatus(
        punches: [_punch(id: '1', type: AttendancePunchType.punchIn, at: now)],
        now: now.add(const Duration(minutes: 1)),
        shiftEndAt: DateTime(2026, 4, 28, 18),
        maxBreakMinutesPerDay: 30,
        maxWorkPunchesPerDay: 2,
      );
      expect(status, AttendanceStatus.checkedIn);
    });

    test('C: shift end passed without punch out returns missingPunch', () {
      final status = calculateTodayStatus(
        punches: [
          _punch(
            id: '1',
            type: AttendancePunchType.punchIn,
            at: DateTime(2026, 4, 28, 9),
          ),
        ],
        now: DateTime(2026, 4, 28, 18, 30),
        shiftEndAt: DateTime(2026, 4, 28, 18),
        maxBreakMinutesPerDay: 30,
        maxWorkPunchesPerDay: 2,
      );
      expect(status, AttendanceStatus.missingPunch);
    });

    test('D: punch in then break out returns onBreak', () {
      final status = calculateTodayStatus(
        punches: [
          _punch(
            id: '1',
            type: AttendancePunchType.punchIn,
            at: DateTime(2026, 4, 28, 9),
          ),
          _punch(
            id: '2',
            type: AttendancePunchType.breakOut,
            at: DateTime(2026, 4, 28, 12),
          ),
        ],
        now: DateTime(2026, 4, 28, 12, 10),
        shiftEndAt: DateTime(2026, 4, 28, 18),
        maxBreakMinutesPerDay: 30,
        maxWorkPunchesPerDay: 2,
      );
      expect(status, AttendanceStatus.onBreak);
    });

    test('E: break exceeds max duration still returns onBreak', () {
      final status = calculateTodayStatus(
        punches: [
          _punch(
            id: '1',
            type: AttendancePunchType.punchIn,
            at: DateTime(2026, 4, 28, 9),
          ),
          _punch(
            id: '2',
            type: AttendancePunchType.breakOut,
            at: DateTime(2026, 4, 28, 12),
          ),
        ],
        now: DateTime(2026, 4, 28, 13),
        shiftEndAt: DateTime(2026, 4, 28, 18),
        maxBreakMinutesPerDay: 30,
        maxWorkPunchesPerDay: 2,
      );
      expect(status, AttendanceStatus.onBreak);
    });

    test('F: punch in then punch out returns checkedOut', () {
      final status = calculateTodayStatus(
        punches: [
          _punch(
            id: '1',
            type: AttendancePunchType.punchIn,
            at: DateTime(2026, 4, 28, 9),
          ),
          _punch(
            id: '2',
            type: AttendancePunchType.punchOut,
            at: DateTime(2026, 4, 28, 18),
          ),
        ],
        now: DateTime(2026, 4, 28, 18, 1),
        shiftEndAt: DateTime(2026, 4, 28, 18),
        maxBreakMinutesPerDay: 30,
        maxWorkPunchesPerDay: 2,
      );
      expect(status, AttendanceStatus.checkedOut);
    });

    test('invalid sequence returns invalidSequence', () {
      final status = calculateTodayStatus(
        punches: [
          _punch(
            id: '1',
            type: AttendancePunchType.breakOut,
            at: DateTime(2026, 4, 28, 12),
          ),
        ],
        now: now,
        shiftEndAt: DateTime(2026, 4, 28, 18),
        maxBreakMinutesPerDay: 30,
        maxWorkPunchesPerDay: 2,
      );
      expect(status, AttendanceStatus.invalidSequence);
    });

    test('G: multiple breaks do not trip work punch cap', () {
      final t0 = DateTime(2026, 4, 28, 9);
      final status = calculateTodayStatus(
        punches: [
          _punch(id: '1', type: AttendancePunchType.punchIn, at: t0),
          _punch(
            id: '2',
            type: AttendancePunchType.breakOut,
            at: t0.add(const Duration(hours: 1)),
          ),
          _punch(
            id: '3',
            type: AttendancePunchType.breakIn,
            at: t0.add(const Duration(hours: 1, minutes: 15)),
          ),
          _punch(
            id: '4',
            type: AttendancePunchType.breakOut,
            at: t0.add(const Duration(hours: 2)),
          ),
          _punch(
            id: '5',
            type: AttendancePunchType.breakIn,
            at: t0.add(const Duration(hours: 2, minutes: 10)),
          ),
          _punch(
            id: '6',
            type: AttendancePunchType.punchOut,
            at: t0.add(const Duration(hours: 8)),
          ),
        ],
        now: t0.add(const Duration(hours: 9)),
        shiftEndAt: DateTime(2026, 4, 28, 18),
        maxBreakMinutesPerDay: 120,
        maxWorkPunchesPerDay: 2,
      );
      expect(status, AttendanceStatus.checkedOut);
    });
  });
}
