import '../../../core/connectivity/connectivity_service.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/result/app_result.dart';
import '../../../core/result/app_result_guard.dart';
import '../data/payroll_calculation_service.dart';
import '../data/payroll_element_repository.dart';
import 'payroll_run_usecase.dart';

class QuickPayUseCase {
  QuickPayUseCase({
    required PayrollCalculationService payrollCalculationService,
    required PayrollRunUseCase payrollRunUseCase,
    required PayrollElementRepository payrollElementRepository,
    required ConnectivityService connectivityService,
    required AppLogger logger,
  }) : _payrollCalculationService = payrollCalculationService,
       _payrollRunUseCase = payrollRunUseCase,
       _payrollElementRepository = payrollElementRepository,
       _connectivityService = connectivityService,
       _logger = logger;

  final PayrollCalculationService _payrollCalculationService;
  final PayrollRunUseCase _payrollRunUseCase;
  final PayrollElementRepository _payrollElementRepository;
  final ConnectivityService _connectivityService;
  final AppLogger _logger;

  Future<AppResult<PayrollCalculationBundle>> calculate({
    required String salonId,
    required String employeeId,
    required int year,
    required int month,
    required String createdBy,
    String? existingRunId,
    int? isoWeekYear,
    int? isoWeekNumber,
  }) {
    return guardResult(
      connectivityService: _connectivityService,
      logger: _logger,
      operation: 'calculateQuickPay',
      run: () async {
        await _ensureDefaultsSeeded(salonId);
        return _payrollCalculationService.calculateQuickPay(
          salonId: salonId,
          employeeId: employeeId,
          year: year,
          month: month,
          createdBy: createdBy,
          existingRunId: existingRunId,
          isoWeekYear: isoWeekYear,
          isoWeekNumber: isoWeekNumber,
        );
      },
    );
  }

  Future<AppResult<String>> approve(
    PayrollCalculationBundle bundle, {
    required String approvedBy,
  }) => _payrollRunUseCase.approve(bundle, approvedBy: approvedBy);

  Future<AppResult<String>> pay(
    PayrollCalculationBundle bundle, {
    required String paidBy,
    String? approvedBy,
  }) => _payrollRunUseCase.pay(bundle, paidBy: paidBy, approvedBy: approvedBy);

  Future<AppResult<void>> rollback({
    required String salonId,
    required String runId,
  }) => _payrollRunUseCase.rollback(salonId: salonId, runId: runId);

  Future<void> _ensureDefaultsSeeded(String salonId) async {
    final existing = await _payrollElementRepository.getElements(
      salonId,
      activeOnly: false,
    );
    if (existing.isNotEmpty) {
      return;
    }
    await _payrollElementRepository.seedDefaultElements(salonId);
  }
}
