/// Staff-facing attendance request categories (stored as `type` on
/// `salons/{salonId}/attendanceRequests/{id}`).
enum EmployeeRequestType {
  adjustAbsentDay,
  attendanceCorrection,
  leaveRequest,
}

/// Missing punch variants for [EmployeeRequestType.attendanceCorrection].
enum AttendanceCorrectionKind {
  missingPunchIn,
  missingPunchOut,
}

/// Leave balance row (`salons/{salonId}/employees/{employeeId}/leaveBalances/{id}`).
class EmployeeLeaveBalance {
  const EmployeeLeaveBalance({
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.remainingHours,
    this.remainingDays,
    this.updatedAt,
  });

  final String leaveTypeId;
  final String leaveTypeName;
  final double remainingHours;
  final double? remainingDays;
  final DateTime? updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeLeaveBalance &&
          runtimeType == other.runtimeType &&
          leaveTypeId == other.leaveTypeId;

  @override
  int get hashCode => leaveTypeId.hashCode;
}

double calculateRequestedLeaveHours({
  required DateTime start,
  required DateTime end,
}) {
  final minutes = end.difference(start).inMinutes;
  if (minutes <= 0) {
    return 0;
  }
  return minutes / 60.0;
}

bool dateRangesOverlap(
  DateTime aStart,
  DateTime aEnd,
  DateTime bStart,
  DateTime bEnd,
) {
  return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
}
