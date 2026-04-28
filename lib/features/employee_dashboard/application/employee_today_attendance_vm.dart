import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../employee_today/data/models/et_attendance_day.dart';
import '../../employee_today/data/models/et_attendance_punch.dart';
import '../../employee_today/data/models/employee_workplace_location_snapshot.dart';
import '../../employee_today/domain/attendance_status.dart';
import '../../employee_today/domain/attendance_state_resolver.dart';
import '../../employee_today/domain/employee_attendance_today_chips.dart';
import '../../employees/data/models/employee.dart';
import '../../owner/settings/attendance/domain/models/attendance_settings_model.dart';
import '../domain/enums/attendance_punch_type.dart';

/// Why the primary punch CTA is disabled (maps to localized copy in the UI).
enum EmployeeTodayPrimaryBlock {
  none,
  attendanceDisabled,
  salonLocationMissing,
  outsideZone,
  shiftComplete,
  generic,
}

enum EmployeePunchActionType { punchIn, punchOut, breakIn, breakOut, none }

@immutable
class SplitPunchActionsVm {
  const SplitPunchActionsVm({
    required this.primaryAction,
    required this.primaryEnabled,
    required this.showCorrectionAction,
    required this.validationMessage,
  });

  final EmployeePunchActionType primaryAction;
  final bool primaryEnabled;
  final bool showCorrectionAction;
  final String? validationMessage;
}

/// View-model for employee Today attendance card + quick punch actions.
@immutable
class EmployeeTodayAttendanceVm {
  const EmployeeTodayAttendanceVm({
    required this.salonId,
    required this.employeeId,
    required this.salonName,
    required this.todayAttendanceId,
    this.lastPunchAt,
    this.lastPunchType,
    required this.isCheckedIn,
    required this.isCheckedOut,
    required this.isOnBreak,
    required this.hasMissingPunch,
    required this.isInsideSalonZone,
    this.distanceFromSalonCenterMeters,
    this.nextPunchType,
    required this.canPunchAny,
    required this.punchSequence,
    required this.locationResolved,
    this.shiftStartRaw,
    this.shiftEndRaw,
    required this.primaryBlock,
    required this.showOutsideZoneChip,
    required this.showMissingPunchChip,
    required this.locationRowShowsOutside,
    required this.dayStatusKey,
    required this.splitActions,
  });

  factory EmployeeTodayAttendanceVm.noWorkspace() {
    return const EmployeeTodayAttendanceVm(
      salonId: '',
      employeeId: '',
      salonName: '',
      todayAttendanceId: '',
      isCheckedIn: false,
      isCheckedOut: false,
      isOnBreak: false,
      hasMissingPunch: false,
      isInsideSalonZone: true,
      canPunchAny: false,
      punchSequence: <String>[],
      locationResolved: false,
      primaryBlock: EmployeeTodayPrimaryBlock.generic,
      showOutsideZoneChip: false,
      showMissingPunchChip: false,
      locationRowShowsOutside: false,
      dayStatusKey: 'notStarted',
      splitActions: SplitPunchActionsVm(
        primaryAction: EmployeePunchActionType.none,
        primaryEnabled: false,
        showCorrectionAction: true,
        validationMessage: null,
      ),
    );
  }

  factory EmployeeTodayAttendanceVm.fromInputs({
    required String salonId,
    required String employeeId,
    required String salonName,
    required String todayAttendanceId,
    required AttendanceSettingsModel settings,
    required EtAttendanceDay? day,
    required List<EtAttendancePunch> punches,
    required Employee? employee,
    required EmployeeWorkplaceLocationSnapshot location,
  }) {
    final attendanceReq = employeeAttendanceRequired(employee);
    final seq = day?.punchSequence ?? const <String>[];
    final effectiveInside = _effectiveInsideZone(
      attendanceRequired: attendanceReq,
      settings: settings,
      location: location,
    );

    final showOutside = shouldShowOutsideSalonZoneChip(
      day: day,
      punches: punches,
      settings: settings,
      employeeAttendanceRequired: attendanceReq,
      location: location,
    );
    final completedDay = _completedForDay(day);
    final locationRowShowsOutside =
        showOutside && (completedDay || location.insideZone != true);

    EtAttendancePunch? lastPunch;
    for (final p in punches) {
      if (lastPunch == null || p.punchTime.isAfter(lastPunch.punchTime)) {
        lastPunch = p;
      }
    }

    final dayStatus = AttendanceStatus.fromFirestore(
      day?.status ?? AttendanceStatus.notStarted.name,
    );
    final dayStatusKey = dayStatus.name;
    final isCheckedIn = dayStatus == AttendanceStatus.checkedIn;
    final isCheckedOut = dayStatus == AttendanceStatus.checkedOut;
    final isOnBreak = dayStatus == AttendanceStatus.onBreak;
    final hasMissing = dayStatus == AttendanceStatus.missingPunch;
    final hasInvalid = dayStatus == AttendanceStatus.invalidSequence;

    final dist = location.distanceMeters ?? day?.lastDistanceFromSalon;

    const resolver = AttendanceStateResolver();
    final resolution = resolver.resolve(
      settings: settings,
      punchSequence: seq,
      isInsideZone: effectiveInside,
      attendanceRequired: attendanceReq,
    );
    final next = resolution.nextType;
    final canPunch =
        next != null &&
        resolution.allowedTypes.contains(next) &&
        !hasMissing &&
        !hasInvalid &&
        !isCheckedOut;
    final block = _resolvePrimaryBlockFromMessage(resolution.blockMessage);
    final validation = hasMissing || hasInvalid
        ? 'missingPunch'
        : (_validationMessageForBlock(block));
    final showCorrectionAction = hasMissing || hasInvalid;
    final splitActions = buildSplitPunchActions(
      nextPunchType: next,
      canPunch: canPunch && !hasMissing,
      showCorrectionAction: showCorrectionAction,
      validationMessage: isCheckedOut && validation == null
          ? 'shiftComplete'
          : validation,
    );

    return EmployeeTodayAttendanceVm(
      salonId: salonId,
      employeeId: employeeId,
      salonName: salonName,
      todayAttendanceId: todayAttendanceId,
      lastPunchAt: lastPunch?.punchTime,
      lastPunchType: lastPunch?.type,
      isCheckedIn: isCheckedIn,
      isCheckedOut: isCheckedOut,
      isOnBreak: isOnBreak,
      hasMissingPunch: hasMissing,
      isInsideSalonZone: !locationRowShowsOutside,
      distanceFromSalonCenterMeters: dist,
      nextPunchType: next,
      canPunchAny: canPunch,
      punchSequence: seq,
      locationResolved: location.resolved,
      shiftStartRaw: settings.standardShiftStart,
      shiftEndRaw: settings.standardShiftEnd,
      primaryBlock: block,
      showOutsideZoneChip: showOutside,
      showMissingPunchChip:
          dayStatus == AttendanceStatus.missingPunch ||
          dayStatus == AttendanceStatus.invalidSequence,
      locationRowShowsOutside: locationRowShowsOutside,
      dayStatusKey: dayStatusKey,
      splitActions: splitActions,
    );
  }

  final String salonId;
  final String employeeId;
  final String salonName;
  final String todayAttendanceId;
  final DateTime? lastPunchAt;
  final AttendancePunchType? lastPunchType;
  final bool isCheckedIn;
  final bool isCheckedOut;
  final bool isOnBreak;
  final bool hasMissingPunch;
  final bool isInsideSalonZone;
  final double? distanceFromSalonCenterMeters;
  final AttendancePunchType? nextPunchType;
  final bool canPunchAny;
  final List<String> punchSequence;
  final bool locationResolved;
  final String? shiftStartRaw;
  final String? shiftEndRaw;
  final EmployeeTodayPrimaryBlock primaryBlock;
  final bool showOutsideZoneChip;
  final bool showMissingPunchChip;
  final bool locationRowShowsOutside;
  final String dayStatusKey;
  final SplitPunchActionsVm splitActions;

  String primaryStatusTitle(AppLocalizations l10n) {
    switch (dayStatusKey) {
      case 'missingPunch':
        return l10n.employeeTodayStatusMissingPunch;
      case 'invalidSequence':
        return l10n.employeeTodayStatusInvalidSequence;
      case 'backFromBreak':
        return l10n.employeeTodayStatusBackFromBreak;
      case 'checkedOut':
        return l10n.employeeTodayStatusCheckedOut;
      case 'onBreak':
        return l10n.employeeTodayStatusOnBreak;
      case 'notStarted':
        return l10n.employeeTodayStatusNotCheckedIn;
      case 'checkedIn':
      default:
        return l10n.employeeTodayStatusCheckedIn;
    }
  }

  String primaryStatusSubtitle(AppLocalizations l10n) {
    switch (dayStatusKey) {
      case 'checkedIn':
        return l10n.employeeTodayStatusCheckedInSubtitle;
      case 'onBreak':
        return l10n.employeeTodayStatusOnBreakSubtitle;
      case 'backFromBreak':
        return l10n.employeeTodayStatusBackFromBreakSubtitle;
      case 'checkedOut':
        return l10n.employeeTodayStatusCheckedOutSubtitle;
      case 'missingPunch':
        return l10n.employeeTodayStatusMissingPunchSubtitle;
      case 'invalidSequence':
        return l10n.employeeTodayStatusInvalidSequenceSubtitle;
      default:
        return '';
    }
  }

  IconData get primaryActionIcon {
    final t = nextPunchType;
    if (t == null) {
      return Icons.touch_app_rounded;
    }
    switch (t) {
      case AttendancePunchType.punchIn:
        return Icons.login_rounded;
      case AttendancePunchType.punchOut:
        return Icons.logout_rounded;
      case AttendancePunchType.breakOut:
        return Icons.free_breakfast_outlined;
      case AttendancePunchType.breakIn:
        return Icons.coffee_rounded;
    }
  }

  String primaryActionLabel(AppLocalizations l10n) {
    final t = nextPunchType;
    if (t == null) {
      return l10n.employeeTodayPunchUnavailableGeneric;
    }
    return _punchLabel(l10n, t);
  }

  String primaryActionSubtitle(AppLocalizations l10n) {
    final t = splitActions.primaryAction.toAttendancePunchType();
    if (t == null) {
      return validationMessage(l10n) ?? '';
    }
    if (!splitActions.primaryEnabled) {
      return validationMessage(l10n) ??
          l10n.employeeTodayPunchUnavailableGeneric;
    }
    switch (t) {
      case AttendancePunchType.punchIn:
        return l10n.employeeTodayPrimaryPunchInSubtitle;
      case AttendancePunchType.punchOut:
        return l10n.employeeTodayPrimaryPunchOutSubtitle;
      case AttendancePunchType.breakOut:
        return l10n.employeeTodayPrimaryBreakOutSubtitle;
      case AttendancePunchType.breakIn:
        return l10n.employeeTodayPrimaryBreakInSubtitle;
    }
  }

  Color locationStatusColor(Color successColor, Color warningColor) {
    if (locationRowShowsOutside) {
      return warningColor;
    }
    return successColor;
  }

  String locationStatusText(AppLocalizations l10n) {
    if (locationRowShowsOutside) {
      return l10n.employeeTodayZoneOutside;
    }
    return l10n.employeeTodayZoneInside;
  }

  bool canPunch(AttendancePunchType type) {
    if (hasMissingPunch || dayStatusKey == 'invalidSequence') {
      return false;
    }
    if (dayStatusKey == 'checkedOut') {
      return false;
    }

    if (punchSequence.isEmpty) {
      return type == AttendancePunchType.punchIn;
    }

    final last = punchSequence.last;
    if (last == AttendancePunchType.punchIn.name) {
      return type == AttendancePunchType.breakOut ||
          type == AttendancePunchType.punchOut;
    }
    if (last == AttendancePunchType.breakOut.name) {
      return type == AttendancePunchType.breakIn;
    }
    if (last == AttendancePunchType.breakIn.name) {
      return type == AttendancePunchType.breakOut ||
          type == AttendancePunchType.punchOut;
    }
    if (last == AttendancePunchType.punchOut.name) {
      return false;
    }
    return false;
  }

  String shiftLabel(AppLocalizations l10n, Locale locale) {
    final start = _parseShiftTime(shiftStartRaw);
    final end = _parseShiftTime(shiftEndRaw);
    if (start == null || end == null) {
      return '${l10n.employeeTodayShiftLabel}: —';
    }
    final day = DateTime.now();
    final startAt = DateTime(day.year, day.month, day.day, start.$1, start.$2);
    final endAt = DateTime(day.year, day.month, day.day, end.$1, end.$2);
    final fmt = DateFormat.jm(locale.toString());
    return '${l10n.employeeTodayShiftLabel}: ${fmt.format(startAt)} - ${fmt.format(endAt)}';
  }

  bool get isGpsVerified => locationResolved && isInsideSalonZone;

  String? validationMessage(AppLocalizations l10n) {
    if (splitActions.validationMessage == 'missingPunch') {
      return l10n.employeeTodayPunchUnavailableMissingPunch;
    }
    switch (primaryBlock) {
      case EmployeeTodayPrimaryBlock.none:
        return null;
      case EmployeeTodayPrimaryBlock.attendanceDisabled:
        return l10n.employeeTodayPunchUnavailableAttendanceDisabled;
      case EmployeeTodayPrimaryBlock.salonLocationMissing:
        return l10n.employeeTodaySalonLocationMissing;
      case EmployeeTodayPrimaryBlock.outsideZone:
        return l10n.employeeTodayPunchUnavailableMoveToZone;
      case EmployeeTodayPrimaryBlock.shiftComplete:
        return l10n.employeeTodayPunchUnavailableShiftComplete;
      case EmployeeTodayPrimaryBlock.generic:
        return l10n.employeeTodayPunchUnavailableGeneric;
    }
  }

  static bool _completedForDay(EtAttendanceDay? day) {
    if (day == null) {
      return false;
    }
    if (day.status == 'checkedOut') {
      return true;
    }
    final s = day.punchSequence;
    return s.isNotEmpty && s.last == 'punchOut';
  }

  static bool _effectiveInsideZone({
    required bool attendanceRequired,
    required AttendanceSettingsModel settings,
    required EmployeeWorkplaceLocationSnapshot location,
  }) {
    if (!attendanceRequired || !settings.gpsRequired) {
      return true;
    }
    return location.insideZone == true;
  }

  static String _punchLabel(AppLocalizations l10n, AttendancePunchType t) {
    switch (t) {
      case AttendancePunchType.punchIn:
        return l10n.employeeTodayPunchIn;
      case AttendancePunchType.punchOut:
        return l10n.employeeTodayPunchOut;
      case AttendancePunchType.breakOut:
        return l10n.employeeTodayBreakOut;
      case AttendancePunchType.breakIn:
        return l10n.employeeTodayBreakIn;
    }
  }

  static (int, int)? _parseShiftTime(String? hhmm) {
    if (hhmm == null || !hhmm.contains(':')) {
      return null;
    }
    final parts = hhmm.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return (hour, minute);
  }

  static SplitPunchActionsVm buildSplitPunchActions({
    required AttendancePunchType? nextPunchType,
    required bool canPunch,
    required bool showCorrectionAction,
    String? validationMessage,
  }) {
    if (!canPunch) {
      return SplitPunchActionsVm(
        primaryAction: EmployeePunchActionType.none,
        primaryEnabled: false,
        showCorrectionAction: showCorrectionAction,
        validationMessage: validationMessage,
      );
    }
    final action = switch (nextPunchType) {
      AttendancePunchType.punchIn => EmployeePunchActionType.punchIn,
      AttendancePunchType.breakOut => EmployeePunchActionType.breakOut,
      AttendancePunchType.breakIn => EmployeePunchActionType.breakIn,
      AttendancePunchType.punchOut => EmployeePunchActionType.punchOut,
      null => EmployeePunchActionType.none,
    };
    return SplitPunchActionsVm(
      primaryAction: action,
      primaryEnabled: action != EmployeePunchActionType.none,
      showCorrectionAction: showCorrectionAction,
      validationMessage: null,
    );
  }

  static EmployeeTodayPrimaryBlock _resolvePrimaryBlockFromMessage(
    String? message,
  ) {
    if (message == null) {
      return EmployeeTodayPrimaryBlock.none;
    }
    if (message.contains('not enabled')) {
      return EmployeeTodayPrimaryBlock.attendanceDisabled;
    }
    if (message.contains('not configured')) {
      return EmployeeTodayPrimaryBlock.salonLocationMissing;
    }
    if (message.contains('outside')) {
      return EmployeeTodayPrimaryBlock.outsideZone;
    }
    if (message.contains('completed')) {
      return EmployeeTodayPrimaryBlock.shiftComplete;
    }
    return EmployeeTodayPrimaryBlock.generic;
  }

  static String? _validationMessageForBlock(EmployeeTodayPrimaryBlock block) {
    switch (block) {
      case EmployeeTodayPrimaryBlock.none:
        return null;
      case EmployeeTodayPrimaryBlock.attendanceDisabled:
        return 'attendanceDisabled';
      case EmployeeTodayPrimaryBlock.salonLocationMissing:
        return 'salonLocationMissing';
      case EmployeeTodayPrimaryBlock.outsideZone:
        return 'outsideZone';
      case EmployeeTodayPrimaryBlock.shiftComplete:
        return 'shiftComplete';
      case EmployeeTodayPrimaryBlock.generic:
        return 'generic';
    }
  }
}

extension EmployeePunchActionTypeX on EmployeePunchActionType {
  AttendancePunchType? toAttendancePunchType() {
    switch (this) {
      case EmployeePunchActionType.punchIn:
        return AttendancePunchType.punchIn;
      case EmployeePunchActionType.punchOut:
        return AttendancePunchType.punchOut;
      case EmployeePunchActionType.breakIn:
        return AttendancePunchType.breakIn;
      case EmployeePunchActionType.breakOut:
        return AttendancePunchType.breakOut;
      case EmployeePunchActionType.none:
        return null;
    }
  }
}
