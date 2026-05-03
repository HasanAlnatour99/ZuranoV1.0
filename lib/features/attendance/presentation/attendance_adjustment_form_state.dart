import 'package:cloud_firestore/cloud_firestore.dart';

import '../../employees/domain/employee_role.dart';
import '../../owner/settings/attendance/domain/models/attendance_settings_model.dart';
import '../../owner_settings/shifts/data/models/employee_schedule_model.dart';
import '../domain/models/adjustment_attendance_status.dart';
import '../domain/models/attendance_calculation_result.dart';
import '../domain/services/attendance_calculator.dart';
import '../domain/repositories/owner_attendance_adjustment_repository.dart';

class AttendanceAdjustmentParams {
  const AttendanceAdjustmentParams({
    required this.salonId,
    required this.employeeId,
    required this.attendanceDate,
    required this.employeeDisplayName,
  });

  final String salonId;
  final String employeeId;
  /// Calendar day being edited (time components ignored).
  final DateTime attendanceDate;
  final String employeeDisplayName;

  DateTime get day => DateTime(
    attendanceDate.year,
    attendanceDate.month,
    attendanceDate.day,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is AttendanceAdjustmentParams &&
        other.salonId == salonId &&
        other.employeeId == employeeId &&
        other.attendanceDate.year == attendanceDate.year &&
        other.attendanceDate.month == attendanceDate.month &&
        other.attendanceDate.day == attendanceDate.day &&
        other.employeeDisplayName == employeeDisplayName;
  }

  @override
  int get hashCode => Object.hash(
    salonId,
    employeeId,
    attendanceDate.year,
    attendanceDate.month,
    attendanceDate.day,
    employeeDisplayName,
  );
}

class AttendanceAdjustmentFormState {
  const AttendanceAdjustmentFormState({
    required this.load,
    required this.attendanceDay,
    required this.selectedShiftId,
    required this.selectedStatus,
    required this.punchInAt,
    required this.breakOutAt,
    required this.breakInAt,
    required this.punchOutAt,
    required this.calculation,
    required this.selectedReasonCode,
    required this.managerNote,
    required this.isSaving,
    required this.initialDocIdHint,
    this.lastErrorCode,
  });

  final OwnerAttendanceAdjustmentLoad load;
  final DateTime attendanceDay;
  final String? selectedShiftId;
  final AdjustmentAttendanceStatus selectedStatus;
  final DateTime? punchInAt;
  final DateTime? breakOutAt;
  final DateTime? breakInAt;
  final DateTime? punchOutAt;
  final AttendanceCalculationResult calculation;
  final String? selectedReasonCode;
  final String managerNote;
  final bool isSaving;
  final String initialDocIdHint;
  final String? lastErrorCode;

  EmployeeScheduleModel? get shift => load.schedule;

  EmployeeRole resolvedEmployeeRole() {
    try {
      return employeeRoleFromString(load.employee.role);
    } catch (_) {
      return EmployeeRole.barber;
    }
  }

  AttendanceAdjustmentFormState withPunches({
    AdjustmentAttendanceStatus? status,
    DateTime? punchInAt,
    bool wipePunchIn = false,
    DateTime? breakOutAt,
    bool wipeBreakOut = false,
    DateTime? breakInAt,
    bool wipeBreakIn = false,
    DateTime? punchOutAt,
    bool wipePunchOut = false,
  }) {
    final st = status ?? selectedStatus;
    var pi = wipePunchIn ? null : (punchInAt ?? this.punchInAt);
    var bo = wipeBreakOut ? null : (breakOutAt ?? this.breakOutAt);
    var bi = wipeBreakIn ? null : (breakInAt ?? this.breakInAt);
    var po = wipePunchOut ? null : (punchOutAt ?? this.punchOutAt);

    final absentLike =
        st == AdjustmentAttendanceStatus.absent ||
        st == AdjustmentAttendanceStatus.dayOff;

    if (absentLike) {
      final calc = AttendanceFirestoreParsers.recalculatePreview(
        day: attendanceDay,
        status: st,
        punchIn: null,
        breakOut: null,
        breakIn: null,
        punchOut: null,
        schedule: shift,
        settings: load.settings,
      );
      return AttendanceAdjustmentFormState(
        load: load,
        attendanceDay: attendanceDay,
        selectedShiftId: selectedShiftId,
        selectedStatus: st,
        punchInAt: null,
        breakOutAt: null,
        breakInAt: null,
        punchOutAt: null,
        calculation: calc,
        selectedReasonCode: selectedReasonCode,
        managerNote: managerNote,
        isSaving: isSaving,
        initialDocIdHint: initialDocIdHint,
        lastErrorCode: null,
      );
    }

    if (pi == null) {
      bo = null;
      bi = null;
    }

    if (pi != null && po != null && po.isBefore(pi)) {
      po = null;
    }

    if (bo != null && bi != null && bi.isBefore(bo)) {
      bi = null;
    }

    final calc = AttendanceFirestoreParsers.recalculatePreview(
      day: attendanceDay,
      status: st,
      punchIn: pi,
      breakOut: bo,
      breakIn: bi,
      punchOut: po,
      schedule: shift,
      settings: load.settings,
    );

    return AttendanceAdjustmentFormState(
      load: load,
      attendanceDay: attendanceDay,
      selectedShiftId: selectedShiftId,
      selectedStatus: st,
      punchInAt: pi,
      breakOutAt: bo,
      breakInAt: bi,
      punchOutAt: po,
      calculation: calc,
      selectedReasonCode: selectedReasonCode,
      managerNote: managerNote,
      isSaving: isSaving,
      initialDocIdHint: initialDocIdHint,
      lastErrorCode: null,
    );
  }

  AttendanceAdjustmentFormState copyWith({
    OwnerAttendanceAdjustmentLoad? load,
    DateTime? attendanceDay,
    String? selectedShiftId,
    bool clearShiftId = false,
    AdjustmentAttendanceStatus? selectedStatus,
    DateTime? punchInAt,
    bool clearPunchIn = false,
    DateTime? breakOutAt,
    bool clearBreakOut = false,
    DateTime? breakInAt,
    bool clearBreakIn = false,
    DateTime? punchOutAt,
    bool clearPunchOut = false,
    AttendanceCalculationResult? calculation,
    String? selectedReasonCode,
    bool clearReason = false,
    String? managerNote,
    bool? isSaving,
    String? lastErrorCode,
    bool clearError = false,
  }) {
    return AttendanceAdjustmentFormState(
      load: load ?? this.load,
      attendanceDay: attendanceDay ?? this.attendanceDay,
      selectedShiftId: clearShiftId
          ? null
          : (selectedShiftId ?? this.selectedShiftId),
      selectedStatus: selectedStatus ?? this.selectedStatus,
      punchInAt: clearPunchIn ? null : (punchInAt ?? this.punchInAt),
      breakOutAt: clearBreakOut ? null : (breakOutAt ?? this.breakOutAt),
      breakInAt: clearBreakIn ? null : (breakInAt ?? this.breakInAt),
      punchOutAt: clearPunchOut ? null : (punchOutAt ?? this.punchOutAt),
      calculation: calculation ?? this.calculation,
      selectedReasonCode: clearReason
          ? null
          : (selectedReasonCode ?? this.selectedReasonCode),
      managerNote: managerNote ?? this.managerNote,
      isSaving: isSaving ?? this.isSaving,
      initialDocIdHint: initialDocIdHint,
      lastErrorCode: clearError ? null : (lastErrorCode ?? this.lastErrorCode),
    );
  }

  factory AttendanceAdjustmentFormState.fromLoad({
    required OwnerAttendanceAdjustmentLoad load,
    required DateTime attendanceDay,
    required Map<String, dynamic>? attendancePayload,
    required String initialDocIdHint,
  }) {
    final m = attendancePayload;
    final punches = AttendanceFirestoreParsers.initialPunches(
      attendanceDay,
      m,
    );
    final sched = load.schedule;
    final shiftId = sched?.shiftTemplateId?.trim().isNotEmpty == true
        ? sched!.shiftTemplateId
        : null;

    final status =
        adjustmentAttendanceStatusFromApi(m?['status'] as String?) ??
        AdjustmentAttendanceStatus.present;

    final calc = AttendanceFirestoreParsers.recalculatePreview(
      day: attendanceDay,
      status: status,
      punchIn: punches.$1,
      breakOut: punches.$2,
      breakIn: punches.$3,
      punchOut: punches.$4,
      schedule: sched,
      settings: load.settings,
    );

    return AttendanceAdjustmentFormState(
      load: load,
      attendanceDay: attendanceDay,
      selectedShiftId: shiftId,
      selectedStatus: status,
      punchInAt: punches.$1,
      breakOutAt: punches.$2,
      breakInAt: punches.$3,
      punchOutAt: punches.$4,
      calculation: calc,
      selectedReasonCode: null,
      managerNote:
          (m?['notes'] ?? m?['managerNote'])?.toString() ?? '',
      isSaving: false,
      initialDocIdHint: initialDocIdHint,
      lastErrorCode: null,
    );
  }
}

class AttendanceFirestoreParsers {
  const AttendanceFirestoreParsers._();

  static AttendanceCalculationResult recalculatePreview({
    required DateTime day,
    required AdjustmentAttendanceStatus status,
    required DateTime? punchIn,
    required DateTime? breakOut,
    required DateTime? breakIn,
    required DateTime? punchOut,
    required EmployeeScheduleModel? schedule,
    required AttendanceSettingsModel settings,
  }) {
    final schedStart =
        TimesOnDay.scheduleStart(day, schedule, settings.standardShiftStart);
    final schedEnd = TimesOnDay.scheduleEnd(day, schedule, settings.standardShiftEnd);
    final schedMinutesFallback = schedule?.scheduledMinutes ?? 0;

    return AttendanceCalculator.compute(
      selectedStatus: status,
      punchInAt: punchIn,
      breakOutAt: breakOut,
      breakInAt: breakIn,
      punchOutAt: punchOut,
      scheduledStart: schedStart,
      scheduledEnd: schedEnd,
      scheduledMinutesFallback: schedMinutesFallback,
      lateGraceMinutes: settings.lateGraceMinutes,
      earlyExitGraceMinutes: settings.earlyExitGraceMinutes,
      missingCheckoutPenaltyMinutes: settings.missingCheckoutPenaltyMinutes,
    );
  }

  static (DateTime?, DateTime?, DateTime?, DateTime?) initialPunches(
    DateTime day,
    Map<String, dynamic>? m,
  ) {
    if (m == null) {
      return (null, null, null, null);
    }
    DateTime? readTs(String a, String b) {
      final v = m[a] ?? m[b];
      if (v is Timestamp) {
        return TimesOnDay.combineOnAttendanceDay(day, v.toDate());
      }
      return null;
    }

    final pi = readTs('checkInAt', 'punchInAt');
    final po = readTs('checkOutAt', 'punchOutAt');
    final bo = readTs('breakOutAt', 'lastBreakOutAt');
    final bi = readTs('breakInAt', 'lastBreakInAt');
    return (pi, bo, bi, po);
  }
}

class TimesOnDay {
  const TimesOnDay._();

  static DateTime? combineOnAttendanceDay(DateTime day, DateTime instant) {
    final l = instant.toLocal();
    return DateTime(day.year, day.month, day.day, l.hour, l.minute);
  }

  static DateTime? scheduleStart(
    DateTime day,
    EmployeeScheduleModel? schedule,
    String? standardStart,
  ) {
    final dt = schedule?.startDateTime;
    if (dt != null) {
      return combineOnAttendanceDay(day, dt);
    }
    return parseHhMmOn(day, schedule?.startTime) ??
        parseHhMmOn(day, standardStart);
  }

  static DateTime? scheduleEnd(
    DateTime day,
    EmployeeScheduleModel? schedule,
    String? standardEnd,
  ) {
    final dt = schedule?.endDateTime;
    if (dt != null) {
      return combineOnAttendanceDay(day, dt);
    }
    return parseHhMmOn(day, schedule?.endTime) ??
        parseHhMmOn(day, standardEnd);
  }

  static DateTime? parseHhMmOn(DateTime day, String? hhmm) {
    if (hhmm == null || !hhmm.contains(':')) {
      return null;
    }
    final p = hhmm.split(':');
    if (p.length < 2) {
      return null;
    }
    final h = int.tryParse(p[0]);
    final mi = int.tryParse(p[1]);
    if (h == null || mi == null) {
      return null;
    }
    return DateTime(day.year, day.month, day.day, h, mi);
  }
}

String attendanceDocId(String employeeId, DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${employeeId}_$y$m$d';
}
