import '../../../core/constants/attendance_approval.dart';
import '../../../core/constants/payroll_period_constants.dart';
import '../../../core/constants/sale_reporting.dart';
import '../../../core/constants/user_roles.dart';
import '../../../core/constants/violation_types.dart';
import '../../../core/firestore/report_period.dart';
import '../../../core/time/iso_week.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../attendance/data/models/attendance_record.dart';
import '../../employees/data/employee_repository.dart';
import '../../employees/data/models/employee.dart';
import '../../sales/data/models/sale.dart';
import '../../sales/data/sales_repository.dart';
import '../../salon/data/salon_repository.dart';
import '../../violations/data/models/violation.dart';
import '../../violations/data/violation_repository.dart';
import '../domain/effective_payroll_period.dart'
    show effectivePayrollPeriodFor;
import 'employee_element_entry_repository.dart';
import 'models/employee_element_entry_model.dart';
import 'models/payroll_element_model.dart';
import 'models/payroll_result_model.dart';
import 'models/payroll_run_model.dart';
import 'payroll_constants.dart';
import 'payroll_element_repository.dart';
import 'payroll_run_repository.dart';

class PayrollCalculationBundle {
  const PayrollCalculationBundle({
    required this.run,
    required this.results,
    required this.employeeStatements,
  });

  final PayrollRunModel run;
  final List<PayrollResultModel> results;
  final List<PayrollEmployeeStatement> employeeStatements;
}

class PayrollEmployeeStatement {
  const PayrollEmployeeStatement({
    required this.employee,
    required this.results,
    required this.totalEarnings,
    required this.totalDeductions,
    required this.netPay,
  });

  final Employee employee;
  final List<PayrollResultModel> results;
  final double totalEarnings;
  final double totalDeductions;
  final double netPay;
}

class PayrollCommissionComputation {
  const PayrollCommissionComputation({
    required this.amount,
    required this.calculationSource,
    required this.sourceRefIds,
    required this.quantity,
    this.rate,
  });

  final double amount;
  final String calculationSource;
  final List<String> sourceRefIds;
  final double quantity;
  final double? rate;
}

class PayrollCalculationService {
  PayrollCalculationService({
    required PayrollElementRepository payrollElementRepository,
    required EmployeeElementEntryRepository employeeElementEntryRepository,
    required EmployeeRepository employeeRepository,
    required SalesRepository salesRepository,
    required AttendanceRepository attendanceRepository,
    required ViolationRepository violationRepository,
    required SalonRepository salonRepository,
    required PayrollRunRepository payrollRunRepository,
  }) : _payrollElementRepository = payrollElementRepository,
       _employeeElementEntryRepository = employeeElementEntryRepository,
       _employeeRepository = employeeRepository,
       _salesRepository = salesRepository,
       _attendanceRepository = attendanceRepository,
       _violationRepository = violationRepository,
       _salonRepository = salonRepository,
       _payrollRunRepository = payrollRunRepository;

  final PayrollElementRepository _payrollElementRepository;
  final EmployeeElementEntryRepository _employeeElementEntryRepository;
  final EmployeeRepository _employeeRepository;
  final SalesRepository _salesRepository;
  final AttendanceRepository _attendanceRepository;
  final ViolationRepository _violationRepository;
  final SalonRepository _salonRepository;
  final PayrollRunRepository _payrollRunRepository;

  static DateTime periodStartUtc(int year, int month) =>
      DateTime.utc(year, month, 1);

  static DateTime periodEndInclusiveUtc(int year, int month) =>
      DateTime.utc(year, month + 1, 0, 23, 59, 59, 999);

  static double roundMoney(double value) =>
      double.parse(value.toStringAsFixed(2));

  static PayrollCommissionComputation calculateCommissionFromSales({
    required List<Sale> sales,
    required double fallbackRate,
  }) {
    final completedSales = sales
        .where((sale) => sale.status == SaleStatuses.completed)
        .toList(growable: false);

    var amount = 0.0;
    var usedFallback = false;

    for (final sale in completedSales) {
      if (sale.commissionAmount != null) {
        amount += sale.commissionAmount!;
        continue;
      }

      if (sale.commissionRateUsed != null) {
        amount +=
            Sale.computeCommissionAmount(
              total: sale.total,
              ratePercent: sale.commissionRateUsed,
            ) ??
            0;
        continue;
      }

      usedFallback = true;
      amount +=
          Sale.computeCommissionAmount(
            total: sale.total,
            ratePercent: fallbackRate,
          ) ??
          0;
    }

    return PayrollCommissionComputation(
      amount: roundMoney(amount),
      calculationSource: usedFallback
          ? PayrollCalculationSources.fallback
          : PayrollCalculationSources.snapshot,
      sourceRefIds: completedSales
          .map((sale) => sale.id)
          .toList(growable: false),
      quantity: completedSales.length.toDouble(),
      rate: fallbackRate > 0 ? fallbackRate : null,
    );
  }

  Future<PayrollCalculationBundle> calculateQuickPay({
    required String salonId,
    required String employeeId,
    required int year,
    required int month,
    required String createdBy,
    String? existingRunId,
    int? isoWeekYear,
    int? isoWeekNumber,
  }) async {
    final employee = await _employeeRepository.getEmployee(salonId, employeeId);
    if (employee == null ||
        !employee.isActive ||
        employee.role == UserRoles.owner) {
      throw ArgumentError.value(
        employeeId,
        'employeeId',
        'Eligible employee not found for payroll.',
      );
    }

    final salon = await _salonRepository.getSalon(salonId);
    final effectivePeriod = effectivePayrollPeriodFor(
      salonDefaultPayrollPeriod:
          salon?.defaultPayrollPeriod ?? SalonPayrollPeriods.monthly,
      employeePayrollPeriodOverride: employee.payrollPeriodOverride,
    );
    var wy = isoWeekYear ?? 0;
    var wn = isoWeekNumber ?? 0;
    if (effectivePeriod == SalonPayrollPeriods.weekly &&
        (wy <= 0 || wn <= 0)) {
      final spec = isoWeekSpecForUtcDate(DateTime.utc(year, month, 15));
      wy = spec.weekYear;
      wn = spec.weekNumber;
    }

    var runYear = year;
    var runMonth = month;
    var periodGranularity = PayrollRunPeriodGranularities.monthly;
    var runIsoY = 0;
    var runIsoN = 0;
    if (effectivePeriod == SalonPayrollPeriods.weekly && wy > 0 && wn > 0) {
      periodGranularity = PayrollRunPeriodGranularities.weekly;
      runIsoY = wy;
      runIsoN = wn;
      final mon = isoWeekMondayUtc(wy, wn);
      runYear = mon.year;
      runMonth = mon.month;
    }

    final periodKeyRun = PayrollRunModel(
      id: '',
      runType: PayrollRunTypes.quickPay,
      salonId: salonId,
      employeeId: employee.id,
      employeeName: employee.name,
      year: runYear,
      month: runMonth,
      periodGranularity: periodGranularity,
      isoWeekYear: runIsoY,
      isoWeekNumber: runIsoN,
      employeeIds: [employee.id],
    );
    final excludeRun = existingRunId?.trim();
    final alreadyPaid = await _payrollRunRepository
        .employeeIdsWithPaidRunForReportPeriod(
          salonId,
          reportPeriodKey: periodKeyRun.reportPeriodKey,
          excludeRunId:
              excludeRun != null && excludeRun.isNotEmpty ? excludeRun : null,
        );
    if (alreadyPaid.contains(employee.id)) {
      throw ArgumentError.value(
        employee.id,
        'payrollEmployeeAlreadyPaidForPeriod',
        'This team member already has a paid payroll for this period.',
      );
    }

    final elements = await _loadElementsMap(salonId);
    final statement = await _buildEmployeeStatement(
      salonId: salonId,
      employee: employee,
      year: year,
      month: month,
      elements: elements,
      existingRunId: existingRunId,
      runId: existingRunId ?? '',
      accrualGranularity: effectivePeriod,
      isoWeekYear: wy,
      isoWeekNumber: wn,
    );

    final run = PayrollRunModel(
      id: existingRunId ?? '',
      runType: PayrollRunTypes.quickPay,
      salonId: salonId,
      employeeId: employee.id,
      employeeName: employee.name,
      year: runYear,
      month: runMonth,
      periodGranularity: periodGranularity,
      isoWeekYear: runIsoY,
      isoWeekNumber: runIsoN,
      status: PayrollRunStatuses.draft,
      totalEarnings: statement.totalEarnings,
      totalDeductions: statement.totalDeductions,
      netPay: statement.netPay,
      employeeIds: [employee.id],
      employeeCount: 1,
      createdBy: createdBy,
    );

    return PayrollCalculationBundle(
      run: run,
      results: statement.results,
      employeeStatements: [statement],
    );
  }

  Future<PayrollCalculationBundle> calculatePayrollRun({
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
  }) async {
    final salon = await _salonRepository.getSalon(salonId);
    final salonDefault = salon?.defaultPayrollPeriod;
    final bulkGranularity = SalonPayrollPeriods.normalize(runCadence);

    var wy = isoWeekYear ?? 0;
    var wn = isoWeekNumber ?? 0;
    DateTime? windowStart;
    DateTime? windowEnd;

    if (bulkGranularity == SalonPayrollPeriods.weekly) {
      final customStart = weeklyWindowStartUtc;
      final customEndDay = weeklyWindowEndUtc;
      if (customStart != null && customEndDay != null) {
        windowStart = DateTime.utc(
          customStart.year,
          customStart.month,
          customStart.day,
        );
        windowEnd = DateTime.utc(
          customEndDay.year,
          customEndDay.month,
          customEndDay.day,
          23,
          59,
          59,
          999,
        );
        if (windowStart.isAfter(windowEnd)) {
          final d0 = customStart;
          final d1 = customEndDay;
          windowStart = DateTime.utc(d1.year, d1.month, d1.day);
          windowEnd = DateTime.utc(
            d0.year,
            d0.month,
            d0.day,
            23,
            59,
            59,
            999,
          );
        }
        final spec = isoWeekSpecForUtcDate(windowStart);
        wy = spec.weekYear;
        wn = spec.weekNumber;
      } else if (wy <= 0 || wn <= 0) {
        final spec = isoWeekSpecForUtcDate(DateTime.utc(year, month, 15));
        wy = spec.weekYear;
        wn = spec.weekNumber;
        final bounds = isoWeekUtcBounds(wy, wn);
        windowStart = bounds.$1;
        windowEnd = bounds.$2;
      } else {
        final bounds = isoWeekUtcBounds(wy, wn);
        windowStart = bounds.$1;
        windowEnd = bounds.$2;
      }
    }

    var runYear = year;
    var runMonth = month;
    var periodGranularity = PayrollRunPeriodGranularities.monthly;
    var runIsoY = 0;
    var runIsoN = 0;
    DateTime? persistedWinStart;
    DateTime? persistedWinEnd;
    if (bulkGranularity == SalonPayrollPeriods.weekly &&
        windowStart != null &&
        windowEnd != null) {
      periodGranularity = PayrollRunPeriodGranularities.weekly;
      runIsoY = wy;
      runIsoN = wn;
      runYear = windowStart.year;
      runMonth = windowStart.month;
      persistedWinStart = windowStart;
      persistedWinEnd = windowEnd;
    }

    final periodKeyRun = PayrollRunModel(
      id: '',
      runType: PayrollRunTypes.payrollRun,
      salonId: salonId,
      year: runYear,
      month: runMonth,
      periodGranularity: periodGranularity,
      isoWeekYear: runIsoY,
      isoWeekNumber: runIsoN,
      payrollWindowStartUtc: persistedWinStart,
      payrollWindowEndUtc: persistedWinEnd,
    );
    final excludeRun = existingRunId?.trim();
    final alreadyPaidIds = await _payrollRunRepository
        .employeeIdsWithPaidRunForReportPeriod(
          salonId,
          reportPeriodKey: periodKeyRun.reportPeriodKey,
          excludeRunId:
              excludeRun != null && excludeRun.isNotEmpty ? excludeRun : null,
        );

    var employees = await _loadEligibleEmployeesForRun(
      salonId,
      salonDefaultPayrollPeriod: salonDefault,
      runCadence: bulkGranularity,
      employeeIds: employeeIds,
    );
    employees = employees
        .where((e) => !alreadyPaidIds.contains(e.id))
        .toList(growable: false);

    if (employees.isEmpty) {
      throw ArgumentError.value(
        null,
        'payrollAllStaffAlreadyPaidForPeriod',
        'Everyone on your list already has a paid payroll for this period.',
      );
    }

    final elements = await _loadElementsMap(salonId);
    final statements = <PayrollEmployeeStatement>[];

    for (final employee in employees) {
      final statement = await _buildEmployeeStatement(
        salonId: salonId,
        employee: employee,
        year: year,
        month: month,
        elements: elements,
        existingRunId: existingRunId,
        runId: existingRunId ?? '',
        accrualGranularity: bulkGranularity,
        isoWeekYear: wy,
        isoWeekNumber: wn,
        periodWindowStartUtc: windowStart,
        periodWindowEndUtc: windowEnd,
      );
      statements.add(statement);
    }

    final results = statements
        .expand((statement) => statement.results)
        .toList(growable: false);

    final run = PayrollRunModel(
      id: existingRunId ?? '',
      runType: PayrollRunTypes.payrollRun,
      salonId: salonId,
      year: runYear,
      month: runMonth,
      periodGranularity: periodGranularity,
      isoWeekYear: runIsoY,
      isoWeekNumber: runIsoN,
      status: PayrollRunStatuses.draft,
      totalEarnings: roundMoney(
        statements.fold<double>(
          0,
          (sum, statement) => sum + statement.totalEarnings,
        ),
      ),
      totalDeductions: roundMoney(
        statements.fold<double>(
          0,
          (sum, statement) => sum + statement.totalDeductions,
        ),
      ),
      netPay: roundMoney(
        statements.fold<double>(0, (sum, statement) => sum + statement.netPay),
      ),
      employeeIds: statements
          .map((statement) => statement.employee.id)
          .toList(growable: false),
      employeeCount: statements.length,
      createdBy: createdBy,
      payrollWindowStartUtc: persistedWinStart,
      payrollWindowEndUtc: persistedWinEnd,
    );

    return PayrollCalculationBundle(
      run: run,
      results: results,
      employeeStatements: statements,
    );
  }

  Future<List<Employee>> _loadEligibleEmployeesForRun(
    String salonId, {
    required String? salonDefaultPayrollPeriod,
    required String runCadence,
    Iterable<String>? employeeIds,
  }) async {
    final employees = await _employeeRepository.getEmployees(
      salonId,
      onlyActive: true,
    );
    final idSet = employeeIds
        ?.map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    final normalizedSalonDefault =
        SalonPayrollPeriods.normalize(salonDefaultPayrollPeriod);
    final wantCadence = SalonPayrollPeriods.normalize(runCadence);

    return employees
        .where((employee) => employee.role != UserRoles.owner)
        .where((employee) => employee.isPayrollEnabled)
        .where(
          (employee) =>
              effectivePayrollPeriodFor(
                salonDefaultPayrollPeriod: normalizedSalonDefault,
                employeePayrollPeriodOverride: employee.payrollPeriodOverride,
              ) ==
              wantCadence,
        )
        .where((employee) => idSet == null || idSet.contains(employee.id))
        .toList(growable: false);
  }

  Future<Map<String, PayrollElementModel>> _loadElementsMap(
    String salonId,
  ) async {
    final elements = await _payrollElementRepository.getElements(
      salonId,
      activeOnly: false,
    );
    return {for (final element in elements) element.code: element};
  }

  Future<List<Violation>> _violationsForPayrollWindow({
    required String salonId,
    required String employeeId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String accrualGranularity,
    required int year,
    required int month,
    String? existingRunId,
  }) async {
    if (accrualGranularity == SalonPayrollPeriods.weekly) {
      final monthKeys = <String, (int, int)>{};
      var cursor = periodStart;
      while (!cursor.isAfter(periodEnd)) {
        final k = ReportPeriod.periodKey(cursor.year, cursor.month);
        monthKeys[k] = (cursor.year, cursor.month);
        cursor = cursor.add(const Duration(days: 1));
      }
      final byId = <String, Violation>{};
      for (final ym in monthKeys.values) {
        final chunk = await _violationRepository.getPayrollEligibleForEmployeeMonth(
          salonId,
          employeeId,
          ym.$1,
          ym.$2,
          includeRunId: existingRunId,
        );
        for (final v in chunk) {
          if (!v.occurredAt.isBefore(periodStart) &&
              !v.occurredAt.isAfter(periodEnd)) {
            byId[v.id] = v;
          }
        }
      }
      return byId.values.toList(growable: false);
    }
    return _violationRepository.getPayrollEligibleForEmployeeMonth(
      salonId,
      employeeId,
      year,
      month,
      includeRunId: existingRunId,
    );
  }

  Future<PayrollEmployeeStatement> _buildEmployeeStatement({
    required String salonId,
    required Employee employee,
    required int year,
    required int month,
    required Map<String, PayrollElementModel> elements,
    required String runId,
    String? existingRunId,
    required String accrualGranularity,
    int isoWeekYear = 0,
    int isoWeekNumber = 0,
    DateTime? periodWindowStartUtc,
    DateTime? periodWindowEndUtc,
  }) async {
    late DateTime periodStart;
    late DateTime periodEnd;
    if (periodWindowStartUtc != null && periodWindowEndUtc != null) {
      periodStart = periodWindowStartUtc;
      periodEnd = periodWindowEndUtc;
    } else if (accrualGranularity == SalonPayrollPeriods.weekly &&
        isoWeekYear > 0 &&
        isoWeekNumber > 0) {
      final bounds = isoWeekUtcBounds(isoWeekYear, isoWeekNumber);
      periodStart = bounds.$1;
      periodEnd = bounds.$2;
    } else {
      periodStart = periodStartUtc(year, month);
      periodEnd = periodEndInclusiveUtc(year, month);
    }

    final nonRecurringYear = accrualGranularity == SalonPayrollPeriods.weekly
        ? periodStart.year
        : year;
    final nonRecurringMonth = accrualGranularity == SalonPayrollPeriods.weekly
        ? periodStart.month
        : month;

    final recurringEntries = await _employeeElementEntryRepository
        .getActiveRecurringEntriesForPeriod(
          salonId,
          employee.id,
          periodStart: periodStart,
          periodEnd: periodEnd,
        );
    final nonRecurringEntries = await _employeeElementEntryRepository
        .getCurrentPeriodNonRecurringEntries(
          salonId,
          employee.id,
          year: nonRecurringYear,
          month: nonRecurringMonth,
        );
    final sales = accrualGranularity == SalonPayrollPeriods.weekly
        ? await _salesRepository.getSalesByEmployee(
            salonId,
            employee.id,
            soldFrom: periodStart,
            soldTo: periodEnd,
            limit: 2000,
          )
        : await _salesRepository.getSalesByEmployee(
            salonId,
            employee.id,
            reportYear: year,
            reportMonth: month,
            limit: 2000,
          );
    final attendance = await _attendanceRepository.getAttendance(
      salonId,
      employeeId: employee.id,
      workDateFrom: periodStart,
      workDateTo: periodEnd,
      limit: 120,
    );
    final violations = await _violationsForPayrollWindow(
      salonId: salonId,
      employeeId: employee.id,
      periodStart: periodStart,
      periodEnd: periodEnd,
      accrualGranularity: accrualGranularity,
      year: year,
      month: month,
      existingRunId: existingRunId,
    );

    final basicSalaryAmount = recurringEntries
        .where((entry) => entry.elementCode == 'basic_salary')
        .fold<double>(0, (sum, entry) => sum + entry.amount);

    final results = <PayrollResultModel>[
      ...recurringEntries.map(
        (entry) => _resultFromEntry(
          entry: entry,
          employee: employee,
          elements: elements,
          basicSalaryAmount: basicSalaryAmount,
          sourceType: PayrollResultSourceTypes.recurringEntry,
          runId: runId,
        ),
      ),
      ...nonRecurringEntries.map(
        (entry) => _resultFromEntry(
          entry: entry,
          employee: employee,
          elements: elements,
          basicSalaryAmount: basicSalaryAmount,
          sourceType: PayrollResultSourceTypes.nonrecurringEntry,
          runId: runId,
        ),
      ),
    ];

    final commissionLine = _buildCommissionLine(
      employee: employee,
      sales: sales,
      elements: elements,
      runId: runId,
    );
    if (commissionLine != null) {
      results.add(commissionLine);
    }

    final grossEarnings = roundMoney(
      results
          .where(
            (result) =>
                result.classification == PayrollElementClassifications.earning,
          )
          .fold<double>(0, (sum, result) => sum + result.amount),
    );

    results.addAll(
      _buildAttendanceInformationLines(
        attendance: attendance,
        violations: violations,
        employee: employee,
        elements: elements,
        runId: runId,
      ),
    );
    results.addAll(
      _buildViolationLines(
        violations: violations,
        employee: employee,
        elements: elements,
        grossEarnings: grossEarnings,
        runId: runId,
      ),
    );

    results.sort((a, b) {
      final displayCompare = a.displayOrder.compareTo(b.displayOrder);
      if (displayCompare != 0) {
        return displayCompare;
      }
      return a.elementName.toLowerCase().compareTo(b.elementName.toLowerCase());
    });

    final totalEarnings = roundMoney(
      results
          .where(
            (result) =>
                result.classification == PayrollElementClassifications.earning,
          )
          .fold<double>(0, (sum, result) => sum + result.amount),
    );
    final totalDeductions = roundMoney(
      results
          .where(
            (result) =>
                result.classification ==
                PayrollElementClassifications.deduction,
          )
          .fold<double>(0, (sum, result) => sum + result.amount),
    );
    final netPay = roundMoney(totalEarnings - totalDeductions);

    return PayrollEmployeeStatement(
      employee: employee,
      results: results,
      totalEarnings: totalEarnings,
      totalDeductions: totalDeductions,
      netPay: netPay,
    );
  }

  PayrollResultModel _resultFromEntry({
    required EmployeeElementEntryModel entry,
    required Employee employee,
    required Map<String, PayrollElementModel> elements,
    required double basicSalaryAmount,
    required String sourceType,
    required String runId,
  }) {
    final element = elements[entry.elementCode];
    final calculationMethod =
        element?.calculationMethod ??
        (entry.percentage != null && entry.percentage! > 0
            ? PayrollCalculationMethods.percentage
            : PayrollCalculationMethods.fixed);

    final resolved = _resolveEntryAmount(
      entry,
      calculationMethod: calculationMethod,
      basicSalaryAmount: basicSalaryAmount,
    );

    return PayrollResultModel(
      id: '',
      payrollRunId: runId,
      employeeId: employee.id,
      employeeName: employee.name,
      elementCode: entry.elementCode,
      elementName: entry.elementName,
      classification: entry.classification,
      recurrenceType: entry.recurrenceType,
      amount: resolved.amount,
      quantity: resolved.quantity,
      rate: resolved.rate,
      sourceType: sourceType,
      sourceRefIds: [entry.id],
      visibleOnPayslip: element?.visibleOnPayslip ?? true,
      displayOrder: element?.displayOrder ?? 999,
      calculationSource:
          calculationMethod == PayrollCalculationMethods.percentage
          ? PayrollCalculationSources.derived
          : PayrollCalculationSources.manual,
    );
  }

  ({double amount, double? quantity, double? rate}) _resolveEntryAmount(
    EmployeeElementEntryModel entry, {
    required String calculationMethod,
    required double basicSalaryAmount,
  }) {
    final formula = entry.formulaConfig ?? const <String, dynamic>{};
    final formulaQuantity = _asDouble(formula['quantity']);
    final formulaRate = _asDouble(formula['rate']);
    final formulaBase = _asDouble(formula['baseAmount']);

    return switch (calculationMethod) {
      PayrollCalculationMethods.percentage => (
        amount: roundMoney(
          (formulaBase ?? basicSalaryAmount) * ((entry.percentage ?? 0) / 100),
        ),
        quantity: formulaQuantity,
        rate: entry.percentage,
      ),
      PayrollCalculationMethods.derived => (
        amount: roundMoney(
          formulaQuantity != null && formulaRate != null
              ? formulaQuantity * formulaRate
              : entry.amount,
        ),
        quantity: formulaQuantity,
        rate: formulaRate,
      ),
      _ => (
        amount: roundMoney(entry.amount),
        quantity: formulaQuantity,
        rate: formulaRate,
      ),
    };
  }

  PayrollResultModel? _buildCommissionLine({
    required Employee employee,
    required List<Sale> sales,
    required Map<String, PayrollElementModel> elements,
    required String runId,
  }) {
    final completedSales = sales
        .where((sale) => sale.status == SaleStatuses.completed)
        .toList(growable: false);
    final element = elements['commission'];

    if (completedSales.isEmpty) {
      final fixedOnly =
          employee.commissionType == EmployeeCommissionTypes.fixed &&
          employee.resolvedCommissionFixedAmount > 0;
      final plusFixedNoSales =
          employee.commissionType ==
              EmployeeCommissionTypes.percentagePlusFixed &&
          employee.resolvedCommissionFixedAmount > 0;
      if (fixedOnly || plusFixedNoSales) {
        final amt = roundMoney(employee.resolvedCommissionFixedAmount);
        return PayrollResultModel(
          id: '',
          payrollRunId: runId,
          employeeId: employee.id,
          employeeName: employee.name,
          elementCode: 'commission',
          elementName: element?.name ?? 'Commission',
          classification:
              element?.classification ?? PayrollElementClassifications.earning,
          recurrenceType:
              element?.recurrenceType ?? PayrollRecurrenceTypes.nonrecurring,
          amount: amt,
          quantity: 0,
          rate: null,
          sourceType: PayrollResultSourceTypes.systemGenerated,
          sourceRefIds: const [],
          visibleOnPayslip: element?.visibleOnPayslip ?? true,
          displayOrder: element?.displayOrder ?? 20,
          calculationSource: PayrollCalculationSources.manual,
        );
      }
      return null;
    }

    final fallbackRate = employee.salesCommissionPercentFallback;
    final computation = calculateCommissionFromSales(
      sales: completedSales,
      fallbackRate: fallbackRate,
    );

    final fixedAddon = employee.resolvedCommissionFixedAmount;
    var commissionTotal = computation.amount;
    if (employee.commissionType == EmployeeCommissionTypes.fixed) {
      commissionTotal = roundMoney(fixedAddon);
    } else if (employee.commissionType ==
        EmployeeCommissionTypes.percentagePlusFixed) {
      commissionTotal = roundMoney(computation.amount + fixedAddon);
    }

    return PayrollResultModel(
      id: '',
      payrollRunId: runId,
      employeeId: employee.id,
      employeeName: employee.name,
      elementCode: 'commission',
      elementName: element?.name ?? 'Commission',
      classification:
          element?.classification ?? PayrollElementClassifications.earning,
      recurrenceType:
          element?.recurrenceType ?? PayrollRecurrenceTypes.nonrecurring,
      amount: commissionTotal,
      quantity: computation.quantity,
      rate: computation.rate,
      sourceType: PayrollResultSourceTypes.systemGenerated,
      sourceRefIds: computation.sourceRefIds,
      visibleOnPayslip: element?.visibleOnPayslip ?? true,
      displayOrder: element?.displayOrder ?? 20,
      calculationSource: computation.calculationSource,
    );
  }

  List<PayrollResultModel> _buildAttendanceInformationLines({
    required List<AttendanceRecord> attendance,
    required List<Violation> violations,
    required Employee employee,
    required Map<String, PayrollElementModel> elements,
    required String runId,
  }) {
    final approvedAttendance = attendance
        .where(
          (record) =>
              record.approvalStatus == AttendanceApprovalStatuses.approved,
        )
        .toList(growable: false);

    final workedDays = approvedAttendance
        .where((record) => record.status.toLowerCase() != 'absent')
        .length
        .toDouble();
    final lateMinutes = approvedAttendance.fold<int>(
      0,
      (sum, record) => sum + record.minutesLate,
    );
    final violationCount = violations.length.toDouble();

    final results = <PayrollResultModel>[];
    void addInfoLine({
      required String code,
      required double amount,
      required List<String> sourceRefIds,
    }) {
      if (amount <= 0) {
        return;
      }
      final element = elements[code];
      results.add(
        PayrollResultModel(
          id: '',
          payrollRunId: runId,
          employeeId: employee.id,
          employeeName: employee.name,
          elementCode: code,
          elementName: element?.name ?? code,
          classification:
              element?.classification ??
              PayrollElementClassifications.information,
          recurrenceType:
              element?.recurrenceType ?? PayrollRecurrenceTypes.nonrecurring,
          amount: roundMoney(amount),
          quantity: amount,
          sourceType: PayrollResultSourceTypes.systemGenerated,
          sourceRefIds: sourceRefIds,
          visibleOnPayslip: element?.visibleOnPayslip ?? true,
          displayOrder: element?.displayOrder ?? 900,
          calculationSource: PayrollCalculationSources.derived,
        ),
      );
    }

    addInfoLine(
      code: 'worked_days',
      amount: workedDays,
      sourceRefIds: approvedAttendance.map((record) => record.id).toList(),
    );
    addInfoLine(
      code: 'late_minutes',
      amount: lateMinutes.toDouble(),
      sourceRefIds: approvedAttendance
          .where((record) => record.minutesLate > 0)
          .map((record) => record.id)
          .toList(),
    );
    addInfoLine(
      code: 'violation_count',
      amount: violationCount,
      sourceRefIds: violations.map((violation) => violation.id).toList(),
    );

    return results;
  }

  List<PayrollResultModel> _buildViolationLines({
    required List<Violation> violations,
    required Employee employee,
    required Map<String, PayrollElementModel> elements,
    required double grossEarnings,
    required String runId,
  }) {
    final groups = <String, _ViolationAccumulator>{};

    for (final violation in violations) {
      final elementCode = switch (violation.violationType) {
        ViolationTypes.barberLate => 'late_penalty',
        ViolationTypes.barberNoShow => 'absence_deduction',
        _ => 'attendance_deduction',
      };

      final amount = violation.amount > 0
          ? violation.amount
          : ((violation.percent ?? 0) > 0
                ? grossEarnings * (violation.percent! / 100)
                : 0);
      if (amount <= 0) {
        continue;
      }

      final bucket = groups.putIfAbsent(
        elementCode,
        () => _ViolationAccumulator(elementCode: elementCode),
      );
      bucket.totalAmount += amount;
      bucket.sourceRefIds.add(violation.id);
    }

    return groups.values
        .map((bucket) {
          final element = elements[bucket.elementCode];
          return PayrollResultModel(
            id: '',
            payrollRunId: runId,
            employeeId: employee.id,
            employeeName: employee.name,
            elementCode: bucket.elementCode,
            elementName: element?.name ?? bucket.elementCode,
            classification:
                element?.classification ??
                PayrollElementClassifications.deduction,
            recurrenceType:
                element?.recurrenceType ?? PayrollRecurrenceTypes.nonrecurring,
            amount: roundMoney(bucket.totalAmount),
            quantity: bucket.sourceRefIds.length.toDouble(),
            sourceType: PayrollResultSourceTypes.systemGenerated,
            sourceRefIds: bucket.sourceRefIds.toList(growable: false),
            visibleOnPayslip: element?.visibleOnPayslip ?? true,
            displayOrder: element?.displayOrder ?? 950,
            calculationSource: PayrollCalculationSources.derived,
          );
        })
        .toList(growable: false);
  }

  double? _asDouble(Object? raw) {
    if (raw == null) {
      return null;
    }
    return switch (raw) {
      num value => value.toDouble(),
      _ => double.tryParse(raw.toString()),
    };
  }
}

class _ViolationAccumulator {
  _ViolationAccumulator({required this.elementCode});

  final String elementCode;
  final List<String> sourceRefIds = <String>[];
  double totalAmount = 0;
}
