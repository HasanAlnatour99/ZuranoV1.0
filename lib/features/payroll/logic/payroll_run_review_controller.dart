import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/payroll_period_constants.dart';
import '../../../core/time/iso_week.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/app_settings_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';
import '../data/models/payroll_run_model.dart';
import '../data/payroll_calculation_service.dart';
import '../data/payroll_constants.dart';
import 'payroll_dashboard_providers.dart';
import 'payroll_failure_messages.dart';

class PayrollRunReviewState {
  const PayrollRunReviewState({
    required this.period,
    required this.runCadence,
    required this.weeklyRangeStartUtc,
    required this.weeklyRangeEndUtc,
    this.isoWeekYear = 0,
    this.isoWeekNumber = 0,
    this.selectedEmployeeIds = const [],
    this.bundle,
    this.savedRunId,
    this.isBusy = false,
    this.error,
  });

  final DateTime period;
  /// Selected run mode: [SalonPayrollPeriods.monthly] or [SalonPayrollPeriods.weekly].
  final String runCadence;
  /// Inclusive UTC calendar start day (00:00) for weekly runs.
  final DateTime weeklyRangeStartUtc;
  /// Inclusive UTC calendar end day (date-only; service expands to end of day).
  final DateTime weeklyRangeEndUtc;
  final int isoWeekYear;
  final int isoWeekNumber;
  final List<String> selectedEmployeeIds;
  final PayrollCalculationBundle? bundle;
  final String? savedRunId;
  final bool isBusy;
  final String? error;

  PayrollRunReviewState copyWith({
    DateTime? period,
    String? runCadence,
    DateTime? weeklyRangeStartUtc,
    DateTime? weeklyRangeEndUtc,
    int? isoWeekYear,
    int? isoWeekNumber,
    List<String>? selectedEmployeeIds,
    Object? bundle = _sentinel,
    Object? savedRunId = _sentinel,
    bool? isBusy,
    Object? error = _sentinel,
  }) {
    return PayrollRunReviewState(
      period: period ?? this.period,
      runCadence: runCadence ?? this.runCadence,
      weeklyRangeStartUtc: weeklyRangeStartUtc ?? this.weeklyRangeStartUtc,
      weeklyRangeEndUtc: weeklyRangeEndUtc ?? this.weeklyRangeEndUtc,
      isoWeekYear: isoWeekYear ?? this.isoWeekYear,
      isoWeekNumber: isoWeekNumber ?? this.isoWeekNumber,
      selectedEmployeeIds: selectedEmployeeIds ?? this.selectedEmployeeIds,
      bundle: identical(bundle, _sentinel)
          ? this.bundle
          : bundle as PayrollCalculationBundle?,
      savedRunId: identical(savedRunId, _sentinel)
          ? this.savedRunId
          : savedRunId as String?,
      isBusy: isBusy ?? this.isBusy,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

({DateTime startUtc, DateTime endUtc}) defaultWeeklyUtcRangeFromLocalToday() {
  final now = DateTime.now();
  final d = DateTime(now.year, now.month, now.day);
  final wd = d.weekday;
  final mon = d.subtract(Duration(days: wd - 1));
  final sun = mon.add(const Duration(days: 6));
  return (
    startUtc: DateTime.utc(mon.year, mon.month, mon.day),
    endUtc: DateTime.utc(sun.year, sun.month, sun.day),
  );
}

final payrollRunReviewControllerProvider =
    NotifierProvider.autoDispose<
      PayrollRunReviewController,
      PayrollRunReviewState
    >(PayrollRunReviewController.new);

class PayrollRunReviewController extends Notifier<PayrollRunReviewState> {
  bool _draftRestoreAttempted = false;
  bool _restoreInFlight = false;

  void _resetDraftRestoreGate() {
    _draftRestoreAttempted = false;
  }

  @override
  PayrollRunReviewState build() {
    final hub = ref.read(payrollHubSalonCadenceProvider);
    final dashboardMonth = ref.read(payrollDashboardMonthProvider);
    final w = ref.read(payrollDashboardIsoWeekProvider);

    final period = DateTime(dashboardMonth.year, dashboardMonth.month);
    late final DateTime weeklyStart;
    late final DateTime weeklyEnd;
    late final int isoY;
    late final int isoN;

    if (hub == SalonPayrollPeriods.weekly) {
      final bounds = isoWeekUtcBounds(w.y, w.n);
      weeklyStart = DateTime.utc(
        bounds.$1.year,
        bounds.$1.month,
        bounds.$1.day,
      );
      weeklyEnd = DateTime.utc(
        bounds.$2.year,
        bounds.$2.month,
        bounds.$2.day,
      );
      final spec = isoWeekSpecForUtcDate(bounds.$1);
      isoY = spec.weekYear;
      isoN = spec.weekNumber;
    } else {
      final week = defaultWeeklyUtcRangeFromLocalToday();
      weeklyStart = week.startUtc;
      weeklyEnd = week.endUtc;
      final spec = isoWeekSpecForUtcDate(week.startUtc);
      isoY = spec.weekYear;
      isoN = spec.weekNumber;
    }

    return PayrollRunReviewState(
      period: period,
      runCadence: hub,
      weeklyRangeStartUtc: weeklyStart,
      weeklyRangeEndUtc: weeklyEnd,
      isoWeekYear: isoY,
      isoWeekNumber: isoN,
    );
  }

  /// Reloads a persisted draft for the current period when returning to this screen
  /// (in-memory state is cleared because this notifier is [autoDispose]).
  Future<void> maybeRestoreDraft(List<PayrollRunModel> runs) async {
    if (_draftRestoreAttempted ||
        _restoreInFlight ||
        state.bundle != null ||
        state.isBusy) {
      return;
    }

    final matches = _matchingDraftRuns(runs);
    if (matches.isEmpty) {
      return;
    }

    _draftRestoreAttempted = true;
    _restoreInFlight = true;
    final draft = matches.first;
    try {
      _applyDraftPeriodToState(draft);
      await calculate();
    } finally {
      _restoreInFlight = false;
    }
  }

  List<PayrollRunModel> _matchingDraftRuns(List<PayrollRunModel> runs) {
    // Must match [state.runCadence] (what the user picked on this screen), not only
    // the salon default — otherwise a monthly draft saved while the salon defaults
    // to weekly never matches restore filtering (and vice versa).
    final selectionCadence = SalonPayrollPeriods.normalize(state.runCadence);
    final filtered = runs.where((run) {
      if (run.status != PayrollRunStatuses.draft) {
        return false;
      }
      if (run.runType != PayrollRunTypes.payrollRun) {
        return false;
      }
      return payrollRunMatchesDashboardSelection(
        run: run,
        selectedMonth: state.period,
        selectedIsoWeekYear: state.isoWeekYear,
        selectedIsoWeekNumber: state.isoWeekNumber,
        salonPayrollPeriod: selectionCadence,
      );
    }).toList(growable: false);

    filtered.sort((a, b) {
      final ad =
          a.updatedAt ??
          a.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bd =
          b.updatedAt ??
          b.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
    return filtered;
  }

  void _applyDraftPeriodToState(PayrollRunModel draft) {
    if (draft.periodGranularity == PayrollRunPeriodGranularities.weekly) {
      final ws = draft.payrollWindowStartUtc;
      final we = draft.payrollWindowEndUtc;
      if (ws != null && we != null) {
        state = state.copyWith(
          weeklyRangeStartUtc: DateTime.utc(ws.year, ws.month, ws.day),
          weeklyRangeEndUtc: DateTime.utc(we.year, we.month, we.day),
          isoWeekYear: draft.isoWeekYear,
          isoWeekNumber: draft.isoWeekNumber,
          selectedEmployeeIds: draft.employeeIds.isNotEmpty
              ? List<String>.from(draft.employeeIds)
              : state.selectedEmployeeIds,
          savedRunId: draft.id,
          error: null,
        );
        return;
      }
      if (draft.isoWeekYear > 0 && draft.isoWeekNumber > 0) {
        final bounds = isoWeekUtcBounds(draft.isoWeekYear, draft.isoWeekNumber);
        state = state.copyWith(
          weeklyRangeStartUtc: DateTime.utc(
            bounds.$1.year,
            bounds.$1.month,
            bounds.$1.day,
          ),
          weeklyRangeEndUtc: DateTime.utc(
            bounds.$2.year,
            bounds.$2.month,
            bounds.$2.day,
          ),
          isoWeekYear: draft.isoWeekYear,
          isoWeekNumber: draft.isoWeekNumber,
          selectedEmployeeIds: draft.employeeIds.isNotEmpty
              ? List<String>.from(draft.employeeIds)
              : state.selectedEmployeeIds,
          savedRunId: draft.id,
          error: null,
        );
        return;
      }
    }

    state = state.copyWith(
      period: DateTime(draft.year, draft.month),
      selectedEmployeeIds: draft.employeeIds.isNotEmpty
          ? List<String>.from(draft.employeeIds)
          : state.selectedEmployeeIds,
      savedRunId: draft.id,
      error: null,
    );
  }

  void setRunCadence(String cadence) {
    final c = SalonPayrollPeriods.normalize(cadence);
    if (c == SalonPayrollPeriods.weekly) {
      final w = ref.read(payrollDashboardIsoWeekProvider);
      final bounds = isoWeekUtcBounds(w.y, w.n);
      final spec = isoWeekSpecForUtcDate(bounds.$1);
      _resetDraftRestoreGate();
      state = state.copyWith(
        runCadence: c,
        weeklyRangeStartUtc: DateTime.utc(
          bounds.$1.year,
          bounds.$1.month,
          bounds.$1.day,
        ),
        weeklyRangeEndUtc: DateTime.utc(
          bounds.$2.year,
          bounds.$2.month,
          bounds.$2.day,
        ),
        isoWeekYear: spec.weekYear,
        isoWeekNumber: spec.weekNumber,
        bundle: null,
        savedRunId: null,
        error: null,
      );
    } else {
      _resetDraftRestoreGate();
      state = state.copyWith(
        runCadence: c,
        bundle: null,
        savedRunId: null,
        error: null,
      );
    }
  }

  void selectPeriod(DateTime period) {
    final normalized = DateTime(period.year, period.month);
    _resetDraftRestoreGate();
    state = state.copyWith(
      period: normalized,
      bundle: null,
      savedRunId: null,
      error: null,
    );
  }

  void setWeeklyRangeStartUtc(DateTime pickedLocalOrUtc) {
    final s = DateTime.utc(
      pickedLocalOrUtc.year,
      pickedLocalOrUtc.month,
      pickedLocalOrUtc.day,
    );
    var e = DateTime.utc(
      state.weeklyRangeEndUtc.year,
      state.weeklyRangeEndUtc.month,
      state.weeklyRangeEndUtc.day,
    );
    if (e.isBefore(s)) {
      e = s;
    }
    final spec = isoWeekSpecForUtcDate(s);
    _resetDraftRestoreGate();
    state = state.copyWith(
      weeklyRangeStartUtc: s,
      weeklyRangeEndUtc: e,
      isoWeekYear: spec.weekYear,
      isoWeekNumber: spec.weekNumber,
      bundle: null,
      savedRunId: null,
      error: null,
    );
  }

  void setWeeklyRangeEndUtc(DateTime pickedLocalOrUtc) {
    var e = DateTime.utc(
      pickedLocalOrUtc.year,
      pickedLocalOrUtc.month,
      pickedLocalOrUtc.day,
    );
    final s = DateTime.utc(
      state.weeklyRangeStartUtc.year,
      state.weeklyRangeStartUtc.month,
      state.weeklyRangeStartUtc.day,
    );
    if (e.isBefore(s)) {
      e = s;
    }
    _resetDraftRestoreGate();
    state = state.copyWith(
      weeklyRangeEndUtc: e,
      bundle: null,
      savedRunId: null,
      error: null,
    );
  }

  void toggleEmployee(String employeeId) {
    final current = state.selectedEmployeeIds.toSet();
    if (current.contains(employeeId)) {
      current.remove(employeeId);
    } else {
      current.add(employeeId);
    }
    _resetDraftRestoreGate();
    state = state.copyWith(
      selectedEmployeeIds: current.toList(growable: false),
      bundle: null,
      savedRunId: null,
      error: null,
    );
  }

  void clearEmployeeFilter() {
    _resetDraftRestoreGate();
    state = state.copyWith(
      selectedEmployeeIds: const [],
      bundle: null,
      savedRunId: null,
      error: null,
    );
  }

  Future<void> calculate() async {
    final session = ref.read(sessionUserProvider).asData?.value;
    final salonId = session?.salonId?.trim();
    if (session == null || salonId == null || salonId.isEmpty) {
      state = state.copyWith(error: 'missing');
      return;
    }

    if (state.runCadence == SalonPayrollPeriods.weekly) {
      final s = DateTime.utc(
        state.weeklyRangeStartUtc.year,
        state.weeklyRangeStartUtc.month,
        state.weeklyRangeStartUtc.day,
      );
      final e = DateTime.utc(
        state.weeklyRangeEndUtc.year,
        state.weeklyRangeEndUtc.month,
        state.weeklyRangeEndUtc.day,
      );
      final spanDays = e.difference(s).inDays + 1;
      if (spanDays < 1 || spanDays > 31) {
        state = state.copyWith(error: 'week_range');
        return;
      }
    }

    state = state.copyWith(isBusy: true, error: null);
    final l10n = lookupAppLocalizations(ref.read(appLocalePreferenceProvider));
    final weekly = state.runCadence == SalonPayrollPeriods.weekly;
    final result = await ref
        .read(payrollRunUseCaseProvider)
        .calculate(
          salonId: salonId,
          year: state.period.year,
          month: state.period.month,
          createdBy: session.uid,
          runCadence: state.runCadence,
          employeeIds: state.selectedEmployeeIds.isEmpty
              ? null
              : state.selectedEmployeeIds,
          existingRunId: state.savedRunId,
          isoWeekYear: weekly ? state.isoWeekYear : null,
          isoWeekNumber: weekly ? state.isoWeekNumber : null,
          weeklyWindowStartUtc: weekly ? state.weeklyRangeStartUtc : null,
          weeklyWindowEndUtc: weekly ? state.weeklyRangeEndUtc : null,
        );
    result.match(
      (failure) => state = state.copyWith(
        isBusy: false,
        error: payrollFailureUserMessage(failure: failure, l10n: l10n),
      ),
      (bundle) => state = state.copyWith(isBusy: false, bundle: bundle),
    );
  }

  Future<String?> approve() async {
    final bundle = state.bundle;
    final session = ref.read(sessionUserProvider).asData?.value;
    if (bundle == null || session == null) {
      return null;
    }
    state = state.copyWith(isBusy: true, error: null);
    final l10n = lookupAppLocalizations(ref.read(appLocalePreferenceProvider));
    final result = await ref
        .read(payrollRunUseCaseProvider)
        .approve(bundle, approvedBy: session.uid);
    return result.match(
      (failure) {
        state = state.copyWith(
          isBusy: false,
          error: payrollFailureUserMessage(failure: failure, l10n: l10n),
        );
        return null;
      },
      (runId) {
        state = state.copyWith(
          isBusy: false,
          savedRunId: runId,
          bundle: PayrollCalculationBundle(
            run: bundle.run.copyWith(
              id: runId,
              status: PayrollRunStatuses.approved,
            ),
            results: bundle.results,
            employeeStatements: bundle.employeeStatements,
          ),
        );
        return runId;
      },
    );
  }

  Future<String?> pay() async {
    final bundle = state.bundle;
    final session = ref.read(sessionUserProvider).asData?.value;
    if (bundle == null || session == null) {
      return null;
    }
    state = state.copyWith(isBusy: true, error: null);
    final l10n = lookupAppLocalizations(ref.read(appLocalePreferenceProvider));
    final result = await ref
        .read(payrollRunUseCaseProvider)
        .pay(bundle, paidBy: session.uid);
    return result.match(
      (failure) {
        state = state.copyWith(
          isBusy: false,
          error: payrollFailureUserMessage(failure: failure, l10n: l10n),
        );
        return null;
      },
      (runId) {
        state = state.copyWith(
          isBusy: false,
          savedRunId: runId,
          bundle: PayrollCalculationBundle(
            run: bundle.run.copyWith(
              id: runId,
              status: PayrollRunStatuses.paid,
            ),
            results: bundle.results,
            employeeStatements: bundle.employeeStatements,
          ),
        );
        return runId;
      },
    );
  }

  Future<bool> rollback() async {
    final session = ref.read(sessionUserProvider).asData?.value;
    final salonId = session?.salonId?.trim();
    final runId = state.savedRunId?.trim();
    if (salonId == null || salonId.isEmpty || runId == null || runId.isEmpty) {
      return false;
    }
    state = state.copyWith(isBusy: true, error: null);
    final l10n = lookupAppLocalizations(ref.read(appLocalePreferenceProvider));
    final result = await ref
        .read(payrollRunUseCaseProvider)
        .rollback(salonId: salonId, runId: runId);
    return result.match(
      (failure) {
        state = state.copyWith(
          isBusy: false,
          error: payrollFailureUserMessage(failure: failure, l10n: l10n),
        );
        return false;
      },
      (_) {
        final bundle = state.bundle;
        state = state.copyWith(
          isBusy: false,
          bundle: bundle == null
              ? null
              : PayrollCalculationBundle(
                  run: bundle.run.copyWith(
                    id: runId,
                    status: PayrollRunStatuses.rolledBack,
                  ),
                  results: bundle.results,
                  employeeStatements: bundle.employeeStatements,
                ),
        );
        return true;
      },
    );
  }
}

const Object _sentinel = Object();
