import '../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import '../data/models/et_attendance_punch.dart';

enum AttendanceStatus {
  notStarted,
  checkedIn,
  onBreak,
  backFromBreak,
  checkedOut,
  missingPunch,
  invalidSequence,
  pendingCorrection,
  correctionApproved,
  correctionRejected;

  String get firestoreValue => name;

  static AttendanceStatus fromFirestore(String value) {
    return AttendanceStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AttendanceStatus.notStarted,
    );
  }
}

AttendanceStatus calculateTodayStatus({
  required List<EtAttendancePunch> punches,
  required DateTime now,
  required DateTime? shiftEndAt,
  required int maxBreakMinutesPerDay,
  required int maxPunchesPerDay,
}) {
  if (punches.isEmpty) {
    return AttendanceStatus.notStarted;
  }

  if (punches.length > maxPunchesPerDay) {
    return AttendanceStatus.invalidSequence;
  }

  if (!_isValidSequence(punches.map((e) => e.type).toList(growable: false))) {
    return AttendanceStatus.invalidSequence;
  }

  final last = punches.last.type;

  if (last == AttendancePunchType.punchIn) {
    if (shiftEndAt != null && now.isAfter(shiftEndAt)) {
      return AttendanceStatus.missingPunch;
    }
    return AttendanceStatus.checkedIn;
  }

  if (last == AttendancePunchType.breakOut) {
    final breakStartedAt = punches.last.punchTime;
    final breakMinutes = now.difference(breakStartedAt).inMinutes;
    if (breakMinutes > maxBreakMinutesPerDay) {
      return AttendanceStatus.missingPunch;
    }
    return AttendanceStatus.onBreak;
  }

  if (last == AttendancePunchType.breakIn) {
    return AttendanceStatus.backFromBreak;
  }

  if (last == AttendancePunchType.punchOut) {
    return AttendanceStatus.checkedOut;
  }

  return AttendanceStatus.invalidSequence;
}

bool _isValidSequence(List<AttendancePunchType> types) {
  if (types.isEmpty || types.first != AttendancePunchType.punchIn) {
    return false;
  }
  for (var i = 1; i < types.length; i++) {
    final previous = types[i - 1];
    final current = types[i];
    final allowed = switch (previous) {
      AttendancePunchType.punchIn => {
          AttendancePunchType.breakOut,
          AttendancePunchType.punchOut,
        },
      AttendancePunchType.breakOut => {AttendancePunchType.breakIn},
      AttendancePunchType.breakIn => {
          AttendancePunchType.breakOut,
          AttendancePunchType.punchOut,
        },
      AttendancePunchType.punchOut => <AttendancePunchType>{},
    };
    if (!allowed.contains(current)) {
      return false;
    }
  }
  return true;
}
