import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/payroll_period_constants.dart';
import '../../../core/constants/user_roles.dart';
import '../../../core/time/iso_week.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/salon_streams_provider.dart';
import '../../../providers/session_provider.dart';
import '../../employees/data/models/employee.dart';
import '../data/models/employee_element_entry_model.dart';
import '../data/models/payroll_element_model.dart';
import '../data/models/payroll_result_model.dart';
import '../data/models/payroll_run_model.dart';
import '../data/payroll_constants.dart';

class PayrollDashboardSummary {
  const PayrollDashboardSummary({
    required this.month,
    required this.totalNetPay,
    required this.totalEarnings,
    required this.totalDeductions,
    required this.monthPayrollRunCount,
    required this.recentRuns,
  });

  final DateTime month;
  final double totalNetPay;
  final double totalEarnings;
  final double totalDeductions;
  /// Number of payroll run documents in the selected month (any status).
  final int monthPayrollRunCount;
  final List<PayrollRunModel> recentRuns;
}

bool payrollRunMatchesDashboardSelection({
  required PayrollRunModel run,
  required DateTime selectedMonth,
  required int selectedIsoWeekYear,
  required int selectedIsoWeekNumber,
  required String salonPayrollPeriod,
}) {
  final hub = SalonPayrollPeriods.normalize(salonPayrollPeriod);
  if (hub == SalonPayrollPeriods.weekly) {
    if (run.periodGranularity == PayrollRunPeriodGranularities.weekly &&
        run.isoWeekYear > 0 &&
        run.isoWeekNumber > 0) {
      return run.isoWeekYear == selectedIsoWeekYear &&
          run.isoWeekNumber == selectedIsoWeekNumber;
    }
    return false;
  }
  if (run.periodGranularity == PayrollRunPeriodGranularities.weekly &&
      run.isoWeekYear > 0 &&
      run.isoWeekNumber > 0) {
    final mon = isoWeekMondayUtc(run.isoWeekYear, run.isoWeekNumber);
    return mon.year == selectedMonth.year && mon.month == selectedMonth.month;
  }
  return run.year == selectedMonth.year && run.month == selectedMonth.month;
}

final payrollRunsStreamProvider = StreamProvider<List<PayrollRunModel>>((ref) {
  final repo = ref.watch(payrollRunRepositoryProvider);
  return watchSessionSalonId(ref).asyncExpand((salonId) {
    if (salonId == null || salonId.isEmpty) {
      return Stream.value(const <PayrollRunModel>[]);
    }
    return repo.watchRuns(salonId, limit: 60);
  });
});

final payrollElementsStreamProvider = StreamProvider<List<PayrollElementModel>>(
  (ref) {
    final repo = ref.watch(payrollElementRepositoryProvider);
    return watchSessionSalonId(ref).asyncExpand((salonId) {
      if (salonId == null || salonId.isEmpty) {
        return Stream.value(const <PayrollElementModel>[]);
      }
      return repo.watchElements(salonId, activeOnly: false);
    });
  },
);

class PayrollDashboardMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void selectMonth(DateTime month) {
    state = DateTime(month.year, month.month);
  }
}

final payrollDashboardMonthProvider =
    NotifierProvider<PayrollDashboardMonthNotifier, DateTime>(
      PayrollDashboardMonthNotifier.new,
    );

class PayrollDashboardIsoWeekNotifier extends Notifier<({int y, int n})> {
  @override
  ({int y, int n}) build() {
    final now = DateTime.now();
    final spec = isoWeekSpecForUtcDate(DateTime.utc(now.year, now.month, now.day));
    return (y: spec.weekYear, n: spec.weekNumber);
  }

  void selectWeek(int weekYear, int weekNumber) {
    state = (y: weekYear, n: weekNumber);
  }
}

final payrollDashboardIsoWeekProvider =
    NotifierProvider<PayrollDashboardIsoWeekNotifier, ({int y, int n})>(
      PayrollDashboardIsoWeekNotifier.new,
    );

final payrollHubSalonCadenceProvider = Provider<String>((ref) {
  final salon = ref.watch(sessionSalonStreamProvider).asData?.value;
  return SalonPayrollPeriods.normalize(salon?.defaultPayrollPeriod);
});

final payrollDashboardSummaryProvider =
    Provider<AsyncValue<PayrollDashboardSummary>>((ref) {
      final selectedMonth = ref.watch(payrollDashboardMonthProvider);
      final selectedWeek = ref.watch(payrollDashboardIsoWeekProvider);
      final salonCadence = ref.watch(payrollHubSalonCadenceProvider);
      final runsAsync = ref.watch(payrollRunsStreamProvider);
      return runsAsync.whenData((runs) {
        final monthRuns = runs
            .where(
              (run) =>
                  run.status != PayrollRunStatuses.rolledBack &&
                  payrollRunMatchesDashboardSelection(
                    run: run,
                    selectedMonth: selectedMonth,
                    selectedIsoWeekYear: selectedWeek.y,
                    selectedIsoWeekNumber: selectedWeek.n,
                    salonPayrollPeriod: salonCadence,
                  ),
            )
            .toList(growable: false);
        final sortedMonthRuns = [...monthRuns]
          ..sort((a, b) {
            final ad = a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bd = b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bd.compareTo(ad);
          });

        return PayrollDashboardSummary(
          month: selectedMonth,
          totalNetPay: sortedMonthRuns.fold<double>(
            0,
            (sum, run) => sum + run.netPay,
          ),
          totalEarnings: sortedMonthRuns.fold<double>(
            0,
            (sum, run) => sum + run.totalEarnings,
          ),
          totalDeductions: sortedMonthRuns.fold<double>(
            0,
            (sum, run) => sum + run.totalDeductions,
          ),
          monthPayrollRunCount: sortedMonthRuns.length,
          recentRuns: sortedMonthRuns.take(6).toList(growable: false),
        );
      });
    });

final employeesMissingPayrollSetupProvider = FutureProvider<List<Employee>>((
  ref,
) async {
  final salonId = ref.watch(sessionUserProvider).asData?.value?.salonId?.trim();
  if (salonId == null || salonId.isEmpty) {
    return const <Employee>[];
  }
  final employeeRepository = ref.read(employeeRepositoryProvider);
  final entryRepository = ref.read(employeeElementEntryRepositoryProvider);

  final employees = await employeeRepository.getEmployees(
    salonId,
    onlyActive: true,
  );
  final eligibleEmployees = employees
      .where((employee) => employee.role != UserRoles.owner)
      .toList(growable: false);

  final missing = <Employee>[];
  for (final employee in eligibleEmployees) {
    final entries = await entryRepository.getEntriesForEmployee(
      salonId,
      employee.id,
      activeOnly: true,
    );
    final hasBasicSalary = entries.any(
      (entry) =>
          entry.elementCode == 'basic_salary' &&
          entry.recurrenceType == PayrollRecurrenceTypes.recurring,
    );
    if (!hasBasicSalary) {
      missing.add(employee);
    }
  }
  return missing;
});

final employeePayrollEntriesProvider =
    FutureProvider.family<List<EmployeeElementEntryModel>, String>((
      ref,
      employeeId,
    ) async {
      final salonId = ref
          .watch(sessionUserProvider)
          .asData
          ?.value
          ?.salonId
          ?.trim();
      if (salonId == null || salonId.isEmpty || employeeId.trim().isEmpty) {
        return const <EmployeeElementEntryModel>[];
      }
      return ref
          .read(employeeElementEntryRepositoryProvider)
          .getEntriesForEmployee(salonId, employeeId);
    });

final employeePayrollHistoryProvider =
    StreamProvider.family<List<PayrollRunModel>, String>((ref, employeeId) {
      final salonId = ref
          .watch(sessionUserProvider)
          .asData
          ?.value
          ?.salonId
          ?.trim();
      if (salonId == null || salonId.isEmpty || employeeId.trim().isEmpty) {
        return Stream.value(const <PayrollRunModel>[]);
      }
      return ref
          .read(payrollRunRepositoryProvider)
          .watchRunsForEmployee(salonId, employeeId);
    });

typedef PayslipQuery = ({String runId, String employeeId});

class PayslipData {
  const PayslipData({required this.run, required this.results});

  final PayrollRunModel? run;
  final List<PayrollResultModel> results;
}

final payslipDataProvider = FutureProvider.family<PayslipData, PayslipQuery>((
  ref,
  query,
) async {
  final salonId = ref.watch(sessionUserProvider).asData?.value?.salonId?.trim();
  if (salonId == null ||
      salonId.isEmpty ||
      query.runId.trim().isEmpty ||
      query.employeeId.trim().isEmpty) {
    return const PayslipData(run: null, results: <PayrollResultModel>[]);
  }

  final runRepository = ref.read(payrollRunRepositoryProvider);
  final run = await runRepository.getRun(salonId, query.runId);
  final results = await runRepository.getResults(
    salonId,
    query.runId,
    employeeId: query.employeeId,
  );
  return PayslipData(run: run, results: results);
});
