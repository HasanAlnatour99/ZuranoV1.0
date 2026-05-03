import 'adjustment_attendance_status.dart';

class AttendanceCalculationResult {
  const AttendanceCalculationResult({
    required this.effectiveStatus,
    required this.lateMinutes,
    required this.earlyExitMinutes,
    required this.missingCheckoutMinutes,
    required this.workedMinutes,
    required this.breakMinutes,
    required this.overtimeMinutes,
    required this.missingCheckout,
  });

  final AdjustmentAttendanceStatus effectiveStatus;
  final int lateMinutes;
  final int earlyExitMinutes;
  final int missingCheckoutMinutes;
  final int workedMinutes;
  final int breakMinutes;
  final int overtimeMinutes;
  final bool missingCheckout;
}
