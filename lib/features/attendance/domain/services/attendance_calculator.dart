import '../models/adjustment_attendance_status.dart';
import '../models/attendance_calculation_result.dart';

/// Preview-only calculator (Cloud Function remains source of truth on save).
class AttendanceCalculator {
  const AttendanceCalculator._();

  static AttendanceCalculationResult compute({
    required AdjustmentAttendanceStatus selectedStatus,
    required DateTime? punchInAt,
    required DateTime? breakOutAt,
    required DateTime? breakInAt,
    required DateTime? punchOutAt,
    required DateTime? scheduledStart,
    required DateTime? scheduledEnd,
    required int scheduledMinutesFallback,
    required int lateGraceMinutes,
    required int earlyExitGraceMinutes,
    required int missingCheckoutPenaltyMinutes,
  }) {
    if (selectedStatus == AdjustmentAttendanceStatus.absent ||
        selectedStatus == AdjustmentAttendanceStatus.dayOff) {
      return AttendanceCalculationResult(
        effectiveStatus: selectedStatus,
        lateMinutes: 0,
        earlyExitMinutes: 0,
        missingCheckoutMinutes: 0,
        workedMinutes: 0,
        breakMinutes: 0,
        overtimeMinutes: 0,
        missingCheckout: false,
      );
    }

    final pi = punchInAt;
    final po = punchOutAt;

    var breakMinutes = 0;
    if (breakOutAt != null && breakInAt != null) {
      final diff = breakInAt.difference(breakOutAt).inMinutes;
      if (diff > 0) {
        breakMinutes = diff;
      }
    }

    var lateMinutes = 0;
    if (pi != null && scheduledStart != null && pi.isAfter(scheduledStart)) {
      final raw = pi.difference(scheduledStart).inMinutes;
      lateMinutes = (raw - lateGraceMinutes).clamp(0, 24 * 60);
    }

    var earlyExitMinutes = 0;
    if (po != null && scheduledEnd != null && po.isBefore(scheduledEnd)) {
      final raw = scheduledEnd.difference(po).inMinutes;
      earlyExitMinutes = (raw - earlyExitGraceMinutes).clamp(0, 24 * 60);
    }

    final missingCheckout =
        pi != null && po == null && (selectedStatus == AdjustmentAttendanceStatus.present || selectedStatus == AdjustmentAttendanceStatus.late);

    final missingCheckoutMinutes =
        missingCheckout ? missingCheckoutPenaltyMinutes.clamp(0, 24 * 60) : 0;

    var workedMinutes = 0;
    if (pi != null && po != null && !po.isBefore(pi)) {
      workedMinutes =
          (po.difference(pi).inMinutes - breakMinutes).clamp(0, 24 * 60);
    }

    var scheduledMinutes = scheduledMinutesFallback;
    if (scheduledStart != null && scheduledEnd != null && scheduledEnd.isAfter(scheduledStart)) {
      scheduledMinutes = scheduledEnd.difference(scheduledStart).inMinutes;
    }

    final overtimeMinutes = scheduledMinutes > 0 ? (workedMinutes - scheduledMinutes).clamp(0, 24 * 60) : 0;

    var effectiveStatus = selectedStatus == AdjustmentAttendanceStatus.late ? AdjustmentAttendanceStatus.late : AdjustmentAttendanceStatus.present;
    if (lateMinutes > 0 && effectiveStatus == AdjustmentAttendanceStatus.present) {
      effectiveStatus = AdjustmentAttendanceStatus.late;
    }

    return AttendanceCalculationResult(
      effectiveStatus: effectiveStatus,
      lateMinutes: lateMinutes,
      earlyExitMinutes: earlyExitMinutes,
      missingCheckoutMinutes: missingCheckoutMinutes,
      workedMinutes: workedMinutes,
      breakMinutes: breakMinutes,
      overtimeMinutes: overtimeMinutes,
      missingCheckout: missingCheckout,
    );
  }

  /// Combine [date] calendar day with time-of-day from [instant] (timezone-safe local).
  static DateTime? composeDateAndTime(DateTime date, DateTime? instant) {
    if (instant == null) {
      return null;
    }
    final local = instant.toLocal();
    return DateTime(date.year, date.month, date.day, local.hour, local.minute);
  }
}
