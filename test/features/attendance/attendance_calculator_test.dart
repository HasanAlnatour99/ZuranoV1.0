import 'package:barber_shop_app/features/attendance/domain/models/adjustment_attendance_status.dart';
import 'package:barber_shop_app/features/attendance/domain/models/attendance_calculation_result.dart';
import 'package:barber_shop_app/features/attendance/domain/services/attendance_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final schedStart = DateTime(2026, 4, 30, 9, 0);
  final schedEnd = DateTime(2026, 4, 30, 17, 0);

  AttendanceCalculationResult run({
    required AdjustmentAttendanceStatus status,
    DateTime? punchIn,
    DateTime? breakOut,
    DateTime? breakIn,
    DateTime? punchOut,
    int scheduledMinutesFallback = 480,
    int lateGrace = 5,
    int earlyGrace = 5,
    int missingPenalty = 120,
  }) {
    return AttendanceCalculator.compute(
      selectedStatus: status,
      punchInAt: punchIn,
      breakOutAt: breakOut,
      breakInAt: breakIn,
      punchOutAt: punchOut,
      scheduledStart: schedStart,
      scheduledEnd: schedEnd,
      scheduledMinutesFallback: scheduledMinutesFallback,
      lateGraceMinutes: lateGrace,
      earlyExitGraceMinutes: earlyGrace,
      missingCheckoutPenaltyMinutes: missingPenalty,
    );
  }

  group('AttendanceCalculator', () {
    test('absent and day off yield zero metrics', () {
      final absent = run(
        status: AdjustmentAttendanceStatus.absent,
        punchIn: DateTime(2026, 4, 30, 9),
      );
      expect(absent.lateMinutes, 0);
      expect(absent.missingCheckout, false);

      final off = run(
        status: AdjustmentAttendanceStatus.dayOff,
        punchIn: DateTime(2026, 4, 30, 9),
        punchOut: DateTime(2026, 4, 30, 17),
      );
      expect(off.workedMinutes, 0);
      expect(off.missingCheckout, false);
    });

    test('full shift with break computes worked minutes', () {
      final r = run(
        status: AdjustmentAttendanceStatus.present,
        punchIn: DateTime(2026, 4, 30, 9, 0),
        breakOut: DateTime(2026, 4, 30, 12, 0),
        breakIn: DateTime(2026, 4, 30, 12, 30),
        punchOut: DateTime(2026, 4, 30, 17, 0),
      );
      expect(r.breakMinutes, 30);
      expect(r.workedMinutes, 450);
      expect(r.missingCheckout, false);
    });

    test('late beyond grace marks late and sets minutes', () {
      final r = run(
        status: AdjustmentAttendanceStatus.present,
        punchIn: DateTime(2026, 4, 30, 9, 20),
        punchOut: DateTime(2026, 4, 30, 17, 0),
        lateGrace: 5,
      );
      expect(r.lateMinutes, 15);
      expect(r.effectiveStatus, AdjustmentAttendanceStatus.late);
    });

    test('missing checkout applies penalty minutes', () {
      final r = run(
        status: AdjustmentAttendanceStatus.present,
        punchIn: DateTime(2026, 4, 30, 9, 0),
        missingPenalty: 90,
      );
      expect(r.missingCheckout, true);
      expect(r.missingCheckoutMinutes, 90);
    });
  });
}
