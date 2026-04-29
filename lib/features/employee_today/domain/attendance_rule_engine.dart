import '../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import '../data/models/et_attendance_settings.dart';
import 'attendance_state_resolver.dart';

/// Client-side punch validation (mirror server-side rules in production).
class AttendanceRuleEngine {
  const AttendanceRuleEngine({AttendanceStateResolver? resolver})
    : _resolver = resolver ?? const AttendanceStateResolver();

  final AttendanceStateResolver _resolver;

  static int _breakOutCount(List<String> seq) =>
      seq.where((e) => e == AttendancePunchType.breakOut.name).length;

  AttendanceValidationResult validateNextPunch({
    required EtAttendanceSettings settings,
    required List<String> punchSequence,
    required AttendancePunchType requestedType,
    required bool isInsideZone,
    required bool attendanceRequired,
  }) {
    return _resolver.validateRequestedPunch(
      settings: settings,
      punchSequence: punchSequence,
      requestedType: requestedType,
      isInsideZone: isInsideZone,
      attendanceRequired: attendanceRequired,
    );
  }

  /// Which punch types are valid right now (for showing all four actions).
  Set<AttendancePunchType> allowedPunchTypes({
    required EtAttendanceSettings settings,
    required List<String> punchSequence,
    required bool isInsideZone,
    required bool attendanceRequired,
  }) {
    return _resolver
        .resolve(
          settings: settings,
          punchSequence: punchSequence,
          isInsideZone: isInsideZone,
          attendanceRequired: attendanceRequired,
        )
        .allowedTypes;
  }

  /// Validates inserting [requestedType] into [punchSequence] (e.g. correction).
  AttendanceValidationResult validateSequenceAfterInsert({
    required EtAttendanceSettings settings,
    required List<String> punchSequence,
    required AttendancePunchType requestedType,
  }) {
    final mergedTypes = List<String>.from(punchSequence)
      ..add(requestedType.name);
    final configuredMax = settings.maxPunchesPerDay;
    final effectiveMax = configuredMax <= 0
        ? AttendanceStateResolver.maxPunchesPerDayDefault
        : (configuredMax > AttendanceStateResolver.maxPunchesPerDayAbsoluteCap
              ? AttendanceStateResolver.maxPunchesPerDayAbsoluteCap
              : configuredMax);
    if (mergedTypes.length > effectiveMax) {
      return const AttendanceValidationResult(
        allowed: false,
        message: 'This punch would exceed the daily punch limit.',
      );
    }
    if (requestedType == AttendancePunchType.breakOut &&
        _breakOutCount(mergedTypes) > settings.maxBreakCyclesPerDay) {
      return const AttendanceValidationResult(
        allowed: false,
        message: 'This break would exceed the daily break limit.',
      );
    }
    return _resolver.validateRequestedPunch(
      settings: settings,
      punchSequence: punchSequence,
      requestedType: requestedType,
      isInsideZone: true,
      attendanceRequired: false,
    );
  }
}
