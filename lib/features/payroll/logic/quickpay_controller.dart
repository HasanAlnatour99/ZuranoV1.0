import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/payroll_period_constants.dart';
import '../../../core/time/iso_week.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/app_settings_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';
import '../data/payroll_calculation_service.dart';
import '../data/payroll_constants.dart';
import '../domain/effective_payroll_period.dart';
import 'payroll_dashboard_providers.dart';
import 'payroll_failure_messages.dart';

class QuickPayState {
  const QuickPayState({
    this.selectedEmployeeId,
    this.selectedEmployeePayrollPeriodOverride,
    required this.period,
    this.isoWeekYear = 0,
    this.isoWeekNumber = 0,
    this.bundle,
    this.savedRunId,
    this.isBusy = false,
    this.error,
  });

  final String? selectedEmployeeId;
  /// Mirrors `Employee.payrollPeriodOverride` for the selected staff; null = inherit salon.
  final String? selectedEmployeePayrollPeriodOverride;
  final DateTime period;
  final int isoWeekYear;
  final int isoWeekNumber;
  final PayrollCalculationBundle? bundle;
  final String? savedRunId;
  final bool isBusy;
  final String? error;

  QuickPayState copyWith({
    Object? selectedEmployeeId = _sentinel,
    Object? selectedEmployeePayrollPeriodOverride = _sentinel,
    DateTime? period,
    int? isoWeekYear,
    int? isoWeekNumber,
    Object? bundle = _sentinel,
    Object? savedRunId = _sentinel,
    bool? isBusy,
    Object? error = _sentinel,
  }) {
    return QuickPayState(
      selectedEmployeeId: identical(selectedEmployeeId, _sentinel)
          ? this.selectedEmployeeId
          : selectedEmployeeId as String?,
      selectedEmployeePayrollPeriodOverride:
          identical(selectedEmployeePayrollPeriodOverride, _sentinel)
              ? this.selectedEmployeePayrollPeriodOverride
              : selectedEmployeePayrollPeriodOverride as String?,
      period: period ?? this.period,
      isoWeekYear: isoWeekYear ?? this.isoWeekYear,
      isoWeekNumber: isoWeekNumber ?? this.isoWeekNumber,
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

final quickPayControllerProvider =
    NotifierProvider.autoDispose<QuickPayController, QuickPayState>(
      QuickPayController.new,
    );

class QuickPayController extends Notifier<QuickPayState> {
  @override
  QuickPayState build() {
    final dashboardMonth = ref.read(payrollDashboardMonthProvider);
    final w = ref.read(payrollDashboardIsoWeekProvider);
    return QuickPayState(
      period: DateTime(dashboardMonth.year, dashboardMonth.month),
      isoWeekYear: w.y,
      isoWeekNumber: w.n,
    );
  }

  void selectEmployee(String? employeeId, {String? payrollPeriodOverride}) {
    final id = employeeId?.trim();
    final cleared = id == null || id.isEmpty;
    final override = cleared ? null : payrollPeriodOverride;

    var wy = state.isoWeekYear;
    var wn = state.isoWeekNumber;

    final effective = effectivePayrollPeriodFor(
      salonDefaultPayrollPeriod: ref.read(payrollHubSalonCadenceProvider),
      employeePayrollPeriodOverride: override,
    );
    if (!cleared && effective == SalonPayrollPeriods.weekly) {
      final p = state.period;
      final spec = isoWeekSpecForUtcDate(
        DateTime.utc(p.year, p.month, 15),
      );
      wy = spec.weekYear;
      wn = spec.weekNumber;
      ref.read(payrollDashboardIsoWeekProvider.notifier).selectWeek(wy, wn);
    }

    state = state.copyWith(
      selectedEmployeeId: cleared ? null : id,
      selectedEmployeePayrollPeriodOverride: override,
      isoWeekYear: wy,
      isoWeekNumber: wn,
      error: null,
      bundle: null,
      savedRunId: null,
    );
  }

  String _effectiveQuickPayCadence() {
    return effectivePayrollPeriodFor(
      salonDefaultPayrollPeriod: ref.read(payrollHubSalonCadenceProvider),
      employeePayrollPeriodOverride:
          state.selectedEmployeeId == null
              ? null
              : state.selectedEmployeePayrollPeriodOverride,
    );
  }

  void selectPeriod(DateTime period) {
    final normalized = DateTime(period.year, period.month);
    ref.read(payrollDashboardMonthProvider.notifier).selectMonth(normalized);
    var wy = state.isoWeekYear;
    var wn = state.isoWeekNumber;
    if (_effectiveQuickPayCadence() == SalonPayrollPeriods.weekly) {
      final spec = isoWeekSpecForUtcDate(
        DateTime.utc(normalized.year, normalized.month, 1),
      );
      wy = spec.weekYear;
      wn = spec.weekNumber;
      ref.read(payrollDashboardIsoWeekProvider.notifier).selectWeek(wy, wn);
    }
    state = state.copyWith(
      period: normalized,
      isoWeekYear: wy,
      isoWeekNumber: wn,
      error: null,
      bundle: null,
      savedRunId: null,
    );
  }

  void selectIsoWeek(int weekYear, int weekNumber) {
    ref
        .read(payrollDashboardIsoWeekProvider.notifier)
        .selectWeek(weekYear, weekNumber);
    state = state.copyWith(
      isoWeekYear: weekYear,
      isoWeekNumber: weekNumber,
      error: null,
      bundle: null,
      savedRunId: null,
    );
  }

  Future<void> calculate() async {
    final employeeId = state.selectedEmployeeId?.trim();
    final session = ref.read(sessionUserProvider).asData?.value;
    final salonId = session?.salonId?.trim();
    if (employeeId == null ||
        employeeId.isEmpty ||
        salonId == null ||
        salonId.isEmpty ||
        session == null) {
      state = state.copyWith(error: 'missing');
      return;
    }

    state = state.copyWith(isBusy: true, error: null);
    final l10n = lookupAppLocalizations(ref.read(appLocalePreferenceProvider));
    final useWeeklyWindow =
        _effectiveQuickPayCadence() == SalonPayrollPeriods.weekly;
    final result = await ref
        .read(quickPayUseCaseProvider)
        .calculate(
          salonId: salonId,
          employeeId: employeeId,
          year: state.period.year,
          month: state.period.month,
          createdBy: session.uid,
          existingRunId: state.savedRunId,
          isoWeekYear: useWeeklyWindow ? state.isoWeekYear : null,
          isoWeekNumber: useWeeklyWindow ? state.isoWeekNumber : null,
        );
    result.match(
      (failure) => state = state.copyWith(
        isBusy: false,
        error: payrollFailureUserMessage(failure: failure, l10n: l10n),
      ),
      (bundle) =>
          state = state.copyWith(isBusy: false, bundle: bundle, error: null),
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
        .read(quickPayUseCaseProvider)
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
        .read(quickPayUseCaseProvider)
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
        .read(quickPayUseCaseProvider)
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
