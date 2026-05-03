import 'package:flutter/foundation.dart';

/// Attendance bucket for the team deck “Attend today” chip.
enum TeamAttendanceState { working, completed, absent, dayOff, notCheckedIn }

/// View model for owner team deck cards (Firestore-backed).
@immutable
class TeamMemberCardVm {
  const TeamMemberCardVm({
    required this.employeeId,
    required this.name,
    required this.roleFirestore,
    required this.profileImageUrl,
    required this.isActive,
    required this.attendanceState,
    required this.rating,
    required this.hasPerformanceData,
  });

  final String employeeId;
  final String name;

  /// Firestore `role` string for localized role line.
  final String roleFirestore;
  final String? profileImageUrl;
  final bool isActive;
  final TeamAttendanceState attendanceState;

  /// Monthly performance doc exists for the current period (Firestore).
  final bool hasPerformanceData;

  /// 0–5 from performance doc when [hasPerformanceData] is true; otherwise 0.
  final double rating;

  bool get isWorkingNow => attendanceState == TeamAttendanceState.working;
}
