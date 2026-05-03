import '../../../core/connectivity/connectivity_service.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/result/app_result.dart';
import '../../../core/result/app_result_guard.dart';
import '../../employees/data/employee_repository.dart';
import '../../employees/data/models/employee.dart';
import '../../salon/data/salon_repository.dart';
import '../data/default_payroll_elements.dart';
import '../data/models/payroll_result_model.dart';
import '../data/models/payroll_run_model.dart';
import '../data/repositories/payslip_repository.dart';
import '../data/payroll_calculation_service.dart';
import '../data/payroll_constants.dart';
import '../data/payroll_element_repository.dart';
import '../data/payroll_run_repository.dart';
import '../domain/payroll_run_totals.dart';
import '../../violations/data/violation_repository.dart';

class PayrollRunUseCase {
  PayrollRunUseCase({
    required PayrollCalculationService payrollCalculationService,
    required PayrollRunRepository payrollRunRepository,
    required PayrollElementRepository payrollElementRepository,
    required ViolationRepository violationRepository,
    required PayslipRepository payslipRepository,
    required SalonRepository salonRepository,
    required EmployeeRepository employeeRepository,
    required ConnectivityService connectivityService,
    required AppLogger logger,
  }) : _payrollCalculationService = payrollCalculationService,
       _payrollRunRepository = payrollRunRepository,
       _payrollElementRepository = payrollElementRepository,
       _violationRepository = violationRepository,
       _payslipRepository = payslipRepository,
       _salonRepository = salonRepository,
       _employeeRepository = employeeRepository,
       _connectivityService = connectivityService,
       _logger = logger;

  final PayrollCalculationService _payrollCalculationService;
  final PayrollRunRepository _payrollRunRepository;
  final PayrollElementRepository _payrollElementRepository;
  final ViolationRepository _violationRepository;
  final PayslipRepository _payslipRepository;
  final SalonRepository _salonRepository;
  final EmployeeRepository _employeeRepository;
  final ConnectivityService _connectivityService;
  final AppLogger _logger;

  Future<AppResult<PayrollCalculationBundle>> calculate({
    required String salonId,
    required int year,
    required int month,
    required String createdBy,
    required String runCadence,
    Iterable<String>? employeeIds,
    String? existingRunId,
    int? isoWeekYear,
    int? isoWeekNumber,
    DateTime? weeklyWindowStartUtc,
    DateTime? weeklyWindowEndUtc,
  }) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'calculatePayrollRun',
      run: () async {
        await _ensureDefaultsSeeded(salonId);
        return _payrollCalculationService.calculatePayrollRun(
          salonId: salonId,
          year: year,
          month: month,
          createdBy: createdBy,
          runCadence: runCadence,
          employeeIds: employeeIds,
          existingRunId: existingRunId,
          isoWeekYear: isoWeekYear,
          isoWeekNumber: isoWeekNumber,
          weeklyWindowStartUtc: weeklyWindowStartUtc,
          weeklyWindowEndUtc: weeklyWindowEndUtc,
        );
      },
    );
  }

  Future<AppResult<String>> approve(
    PayrollCalculationBundle bundle, {
    required String approvedBy,
  }) {
    return _persistBundle(
      bundle,
      status: PayrollRunStatuses.approved,
      approvedBy: approvedBy,
    );
  }

  Future<AppResult<String>> pay(
    PayrollCalculationBundle bundle, {
    required String paidBy,
    String? approvedBy,
  }) {
    return _persistBundle(
      bundle,
      status: PayrollRunStatuses.paid,
      approvedBy: approvedBy ?? paidBy,
      paidBy: paidBy,
    );
  }

  /// Marks an existing **approved** run as paid (e.g. from payroll history).
  Future<AppResult<String>> payApprovedRun({
    required String salonId,
    required String runId,
    required String paidBy,
  }) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'payApprovedPayrollRun',
      run: () async {
        final run = await _payrollRunRepository.getRun(salonId, runId);
        if (run == null) {
          throw ArgumentError.value(runId, 'runId', 'Payroll run not found.');
        }
        if (run.status != PayrollRunStatuses.approved) {
          throw StateError(
            'Only approved payroll runs can be marked paid.',
          );
        }
        final results = await _payrollRunRepository.getResults(salonId, runId);
        final bundle = PayrollCalculationBundle(
          run: run,
          results: results,
          employeeStatements: const [],
        );
        final outcome = await pay(bundle, paidBy: paidBy);
        return outcome.fold(
          (failure) => throw StateError(failure.userMessage),
          (id) => id,
        );
      },
    );
  }

  Future<AppResult<void>> rollback({
    required String salonId,
    required String runId,
  }) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'rollbackPayrollRun',
      run: () async {
        final run = await _payrollRunRepository.getRun(salonId, runId);
        if (run == null) {
          throw ArgumentError.value(runId, 'runId', 'Payroll run not found.');
        }
        if (!PayrollRunStatuses.canRollback(run.status)) {
          throw StateError(
            'Only draft, approved, or paid payroll runs can be rolled back.',
          );
        }

        final results = await _payrollRunRepository.getResults(salonId, runId);
        await _performFullRollback(
          salonId: salonId,
          runId: runId,
          run: run,
          results: results,
        );
      },
    );
  }

  Future<void> _performFullRollback({
    required String salonId,
    required String runId,
    required PayrollRunModel run,
    required List<PayrollResultModel> results,
  }) async {
    final violationIds = _violationIdsFromResults(results);
    final shouldUndoViolationsAndPayslips =
        run.status == PayrollRunStatuses.approved ||
        run.status == PayrollRunStatuses.paid;
    if (violationIds.isNotEmpty && shouldUndoViolationsAndPayslips) {
      await _violationRepository.rollbackPayrollRun(
        salonId,
        violationIds,
        payrollRunId: runId,
      );
    }

    await _payrollRunRepository.updateRun(
      salonId,
      run.copyWith(status: PayrollRunStatuses.rolledBack),
    );

    if (shouldUndoViolationsAndPayslips) {
      final employeeIds = results
          .map((r) => r.employeeId.trim())
          .where((id) => id.isNotEmpty)
          .toSet();
      if (employeeIds.isNotEmpty) {
        await _payslipRepository.deleteMonthlyPayslipsForEmployees(
          salonId: salonId,
          year: run.year,
          month: run.month,
          employeeIds: employeeIds,
        );
      }
    }
  }

  /// Removes one employee's result rows from a multi-employee run and updates
  /// run totals. For approved/paid, deletes that employee's payslip only and
  /// rolls back violations tied to removed rows. If no rows remain, performs
  /// a full [rollback] instead.
  Future<AppResult<void>> rollbackPartial({
    required String salonId,
    required String runId,
    required String employeeId,
  }) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'rollbackPayrollRunPartial',
      run: () async {
        final run = await _payrollRunRepository.getRun(salonId, runId);
        if (run == null) {
          throw ArgumentError.value(runId, 'runId', 'Payroll run not found.');
        }
        if (!PayrollRunStatuses.canRollback(run.status)) {
          throw StateError(
            'Only draft, approved, or paid payroll runs can be rolled back.',
          );
        }

        final target = employeeId.trim();
        if (target.isEmpty) {
          throw ArgumentError.value(employeeId, 'employeeId', 'Required.');
        }

        final results = await _payrollRunRepository.getResults(salonId, runId);
        final distinctIds = distinctEmployeeIdsForRun(results, run.employeeIds);
        if (distinctIds.length <= 1) {
          throw StateError(
            'Partial rollback requires a run with more than one employee.',
          );
        }

        final removed = results
            .where((r) => r.employeeId.trim() == target)
            .toList(growable: false);
        if (removed.isEmpty) {
          throw StateError('Employee not found on this payroll run.');
        }

        final remaining = results
            .where((r) => r.employeeId.trim() != target)
            .toList(growable: false);

        if (remaining.isEmpty) {
          await _performFullRollback(
            salonId: salonId,
            runId: runId,
            run: run,
            results: results,
          );
          return;
        }

        final violationIds = _violationIdsFromResults(removed);
        final shouldUndoViolationsAndPayslips =
            run.status == PayrollRunStatuses.approved ||
            run.status == PayrollRunStatuses.paid;

        if (violationIds.isNotEmpty && shouldUndoViolationsAndPayslips) {
          await _violationRepository.rollbackPayrollRun(
            salonId,
            violationIds,
            payrollRunId: runId,
          );
        }

        await _payrollRunRepository.replaceResults(
          salonId,
          runId,
          remaining,
        );

        final totals = aggregatePayrollRunTotalsFromResults(remaining);
        final newEmployeeIds = distinctEmployeeIdsForRun(remaining, run.employeeIds);
        final count = newEmployeeIds.length;

        PayrollRunModel updated = run.copyWith(
          totalEarnings: totals.totalEarnings,
          totalDeductions: totals.totalDeductions,
          netPay: totals.netPay,
          employeeIds: newEmployeeIds,
          employeeCount: count,
        );

        if (run.isQuickPay) {
          if (count == 1) {
            final only = newEmployeeIds.first;
            updated = updated.copyWith(
              employeeId: only,
              employeeName:
                  primaryEmployeeNameFromResults(remaining, only) ??
                  updated.employeeName,
            );
          } else {
            updated = updated.copyWith(
              employeeId: null,
              employeeName: null,
            );
          }
        }

        await _payrollRunRepository.updateRun(salonId, updated);

        if (shouldUndoViolationsAndPayslips) {
          await _payslipRepository.deleteMonthlyPayslipsForEmployees(
            salonId: salonId,
            year: run.year,
            month: run.month,
            employeeIds: {target},
          );
        }
      },
    );
  }

  Future<Map<String, Employee?>> _employeesLookupForPayslip({
    required String salonId,
    required List<PayrollResultModel> results,
  }) async {
    final ids = results
        .map((r) => r.employeeId.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    final out = <String, Employee?>{};
    for (final id in ids) {
      out[id] = await _employeeRepository.getEmployee(salonId, id);
    }
    return out;
  }

  Future<AppResult<String>> _persistBundle(
    PayrollCalculationBundle bundle, {
    required String status,
    String? approvedBy,
    String? paidBy,
  }) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'persistPayrollBundle',
      run: () async {
        await _ensureDefaultsSeeded(bundle.run.salonId);

        final now = DateTime.now();
        final run = bundle.run.copyWith(
          status: status,
          approvedBy:
              status == PayrollRunStatuses.approved ||
                  status == PayrollRunStatuses.paid
              ? approvedBy
              : null,
          approvedAt:
              status == PayrollRunStatuses.approved ||
                  status == PayrollRunStatuses.paid
              ? now
              : null,
          paidBy: status == PayrollRunStatuses.paid ? paidBy : null,
          paidAt: status == PayrollRunStatuses.paid ? now : null,
        );

        final runId = run.id.isEmpty
            ? await _payrollRunRepository.createRun(run.salonId, run)
            : run.id;

        if (run.id.isNotEmpty) {
          await _payrollRunRepository.updateRun(
            run.salonId,
            run.copyWith(id: runId),
          );
        }

        final persistedResults = bundle.results
            .map((result) => result.copyWith(payrollRunId: runId))
            .toList(growable: false);
        await _payrollRunRepository.replaceResults(
          run.salonId,
          runId,
          persistedResults,
        );

        if (status == PayrollRunStatuses.approved ||
            status == PayrollRunStatuses.paid) {
          final violationIds = _violationIdsFromResults(persistedResults);
          await _violationRepository.applyToPayrollRun(
            run.salonId,
            violationIds,
            payrollRunId: runId,
          );
        }

        if (status == PayrollRunStatuses.approved ||
            status == PayrollRunStatuses.paid) {
          final persistedForPayslip = run.copyWith(id: runId);
          final salon = await _salonRepository.getSalon(run.salonId);
          final currency =
              salon?.currencyCode.trim().isNotEmpty == true
                  ? salon!.currencyCode.trim()
                  : 'USD';
          await _payslipRepository.upsertFromPayrollRunSnapshot(
            persistedRun: persistedForPayslip,
            persistedResults: persistedResults,
            currencyCode: currency,
            employeesById: await _employeesLookupForPayslip(
              salonId: run.salonId,
              results: persistedResults,
            ),
          );
        }

        return runId;
      },
    );
  }

  Future<void> _ensureDefaultsSeeded(String salonId) async {
    final existing = await _payrollElementRepository.getElements(
      salonId,
      activeOnly: false,
    );
    if (existing.length >= buildDefaultPayrollElements().length) {
      return;
    }
    await _payrollElementRepository.seedDefaultElements(salonId);
  }

  List<String> _violationIdsFromResults(List<PayrollResultModel> results) {
    return results
        .where(
          (result) =>
              result.sourceType == PayrollResultSourceTypes.systemGenerated &&
              (result.elementCode == 'attendance_deduction' ||
                  result.elementCode == 'absence_deduction' ||
                  result.elementCode == 'late_penalty'),
        )
        .expand((result) => result.sourceRefIds)
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList(growable: false);
  }
}
