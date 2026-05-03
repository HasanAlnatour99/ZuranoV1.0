import '../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import '../data/models/et_attendance_settings.dart';
import 'attendance_work_punch_limits.dart';

class AttendanceResolution {
  const AttendanceResolution({
    required this.allowedTypes,
    required this.nextType,
    this.blockMessage,
  });

  final Set<AttendancePunchType> allowedTypes;
  final AttendancePunchType? nextType;
  final String? blockMessage;
}

class AttendanceValidationResult {
  const AttendanceValidationResult({
    required this.allowed,
    this.message,
    this.expectedNextAction,
  });

  final bool allowed;
  final String? message;
  final AttendancePunchType? expectedNextAction;
}

/// Central source of truth for punch sequence transitions.
class AttendanceStateResolver {
  const AttendanceStateResolver();

  /// Upper bound on punch documents read per day (includes break in/out rows).
  static const int maxPunchesPerDayAbsoluteCap = 20;

  AttendanceResolution resolve({
    required EtAttendanceSettings settings,
    required List<String> punchSequence,
    required bool isInsideZone,
    required bool attendanceRequired,
  }) {
    if (!settings.attendanceEnabled) {
      return const AttendanceResolution(
        allowedTypes: {},
        nextType: null,
        blockMessage: 'Attendance is not enabled for this salon.',
      );
    }
    if (attendanceRequired &&
        settings.gpsRequired &&
        !settings.hasSalonLocationConfigured) {
      return const AttendanceResolution(
        allowedTypes: {},
        nextType: null,
        blockMessage:
            'Salon attendance location is not configured. Please contact the owner.',
      );
    }
    final lastForZone =
        punchSequence.isNotEmpty ? punchSequence.last : null;
    final midOpenBreak = lastForZone == AttendancePunchType.breakOut.name;
    if (attendanceRequired &&
        settings.gpsRequired &&
        !isInsideZone &&
        !midOpenBreak) {
      return const AttendanceResolution(
        allowedTypes: {},
        nextType: null,
        blockMessage: 'You are outside the allowed salon zone.',
      );
    }

    if (punchSequence.isEmpty) {
      return const AttendanceResolution(
        allowedTypes: {AttendancePunchType.punchIn},
        nextType: AttendancePunchType.punchIn,
      );
    }

    final last = punchSequence.last;
    if (last == AttendancePunchType.breakOut.name) {
      return const AttendanceResolution(
        allowedTypes: {AttendancePunchType.breakIn},
        nextType: AttendancePunchType.breakIn,
      );
    }

    if (last == AttendancePunchType.punchOut.name) {
      return const AttendanceResolution(
        allowedTypes: {},
        nextType: null,
        blockMessage: 'You already completed your attendance for today.',
      );
    }

    final workPunches = workPunchCountInSequenceNames(punchSequence);
    if (workPunches >= kMaxWorkPunchesPerDay) {
      return const AttendanceResolution(
        allowedTypes: {},
        nextType: null,
        blockMessage: 'You already completed your attendance for today.',
      );
    }

    final allowed = <AttendancePunchType>{AttendancePunchType.punchOut};
    if (settings.breaksEnabled) {
      allowed.add(AttendancePunchType.breakOut);
    }
    final breakOutCount = punchSequence
        .where((e) => e == AttendancePunchType.breakOut.name)
        .length;
    if (breakOutCount >= settings.maxBreakCyclesPerDay) {
      allowed.remove(AttendancePunchType.breakOut);
    }
    final next = allowed.contains(AttendancePunchType.punchOut)
        ? AttendancePunchType.punchOut
        : (allowed.isEmpty ? null : allowed.first);
    return AttendanceResolution(allowedTypes: allowed, nextType: next);
  }

  AttendanceValidationResult validateRequestedPunch({
    required EtAttendanceSettings settings,
    required List<String> punchSequence,
    required AttendancePunchType requestedType,
    required bool isInsideZone,
    required bool attendanceRequired,
  }) {
    final resolution = resolve(
      settings: settings,
      punchSequence: punchSequence,
      isInsideZone: isInsideZone,
      attendanceRequired: attendanceRequired,
    );
    if (resolution.allowedTypes.contains(requestedType)) {
      return const AttendanceValidationResult(allowed: true);
    }
    return AttendanceValidationResult(
      allowed: false,
      message: resolution.blockMessage ?? 'This punch sequence is not valid.',
      expectedNextAction: resolution.nextType,
    );
  }
}
