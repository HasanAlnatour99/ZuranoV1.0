import '../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import 'attendance_status.dart';

/// Maps [AttendanceStatus] to the four punch CTAs (state machine for buttons).
///
/// Resolver output (GPS, max punches, salon settings) is still applied in the VM;
/// this type documents the intended machine and can be extended for tests.
class AttendanceActionsState {
  const AttendanceActionsState({
    required this.canCheckIn,
    required this.canBreakOut,
    required this.canBreakIn,
    required this.canCheckOut,
  });

  final bool canCheckIn;
  final bool canBreakOut;
  final bool canBreakIn;
  final bool canCheckOut;

  factory AttendanceActionsState.fromAttendanceStatus(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.notStarted:
        return const AttendanceActionsState(
          canCheckIn: true,
          canBreakOut: false,
          canBreakIn: false,
          canCheckOut: false,
        );
      case AttendanceStatus.checkedIn:
      case AttendanceStatus.backFromBreak:
      case AttendanceStatus.pendingCorrection:
      case AttendanceStatus.correctionApproved:
      case AttendanceStatus.correctionRejected:
        return const AttendanceActionsState(
          canCheckIn: false,
          canBreakOut: true,
          canBreakIn: false,
          canCheckOut: true,
        );
      case AttendanceStatus.onBreak:
        return const AttendanceActionsState(
          canCheckIn: false,
          canBreakOut: false,
          canBreakIn: true,
          canCheckOut: false,
        );
      case AttendanceStatus.checkedOut:
        return const AttendanceActionsState(
          canCheckIn: false,
          canBreakOut: false,
          canBreakIn: false,
          canCheckOut: false,
        );
      case AttendanceStatus.missingPunch:
      case AttendanceStatus.invalidSequence:
        return const AttendanceActionsState(
          canCheckIn: false,
          canBreakOut: false,
          canBreakIn: false,
          canCheckOut: false,
        );
    }
  }

  bool allows(AttendancePunchType type) {
    return switch (type) {
      AttendancePunchType.punchIn => canCheckIn,
      AttendancePunchType.breakOut => canBreakOut,
      AttendancePunchType.breakIn => canBreakIn,
      AttendancePunchType.punchOut => canCheckOut,
    };
  }
}
