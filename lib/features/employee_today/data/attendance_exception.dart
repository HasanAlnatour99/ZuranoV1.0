/// Machine-readable punch validation codes (map to [AppLocalizations] in UI).
abstract final class AttendanceExceptionCodes {
  static const outsideShiftBreak = 'attendance_outside_shift_break';
}

/// Thrown when punch or correction validation fails (show [message] to user).
class AttendanceException implements Exception {
  AttendanceException(this.message);

  final String message;

  @override
  String toString() => message;
}
