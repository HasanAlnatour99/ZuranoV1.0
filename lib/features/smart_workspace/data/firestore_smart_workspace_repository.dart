import '../../../core/utils/currency_for_country.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../attendance/data/models/attendance_record.dart';
import '../../employees/data/employee_repository.dart';
import '../../employees/data/models/employee.dart';
import '../../expenses/data/expense_repository.dart';
import '../../payroll/data/employee_element_entry_repository.dart';
import '../../payroll/data/models/employee_element_entry_model.dart';
import '../../payroll/data/models/payroll_element_model.dart';
import '../../payroll/data/payroll_constants.dart';
import '../../payroll/data/payroll_element_repository.dart';
import '../../payroll/data/payroll_run_repository.dart';
import '../../payroll/logic/quickpay_usecase.dart';
import '../../sales/data/models/sale.dart';
import '../../sales/data/sales_repository.dart';
import '../../salon/data/salon_repository.dart';
import '../domain/repositories/smart_workspace_repository.dart';

class FirestoreSmartWorkspaceRepository implements SmartWorkspaceRepository {
  FirestoreSmartWorkspaceRepository({
    required EmployeeRepository employeeRepository,
    required PayrollElementRepository payrollElementRepository,
    required EmployeeElementEntryRepository employeeElementEntryRepository,
    required QuickPayUseCase quickPayUseCase,
    required PayrollRunRepository payrollRunRepository,
    required SalesRepository salesRepository,
    required ExpenseRepository expenseRepository,
    required AttendanceRepository attendanceRepository,
    required SalonRepository salonRepository,
  }) : _employeeRepository = employeeRepository,
       _payrollElementRepository = payrollElementRepository,
       _employeeElementEntryRepository = employeeElementEntryRepository,
       _quickPayUseCase = quickPayUseCase,
       _payrollRunRepository = payrollRunRepository,
       _salesRepository = salesRepository,
       _expenseRepository = expenseRepository,
       _attendanceRepository = attendanceRepository,
       _salonRepository = salonRepository;

  final EmployeeRepository _employeeRepository;
  final PayrollElementRepository _payrollElementRepository;
  final EmployeeElementEntryRepository _employeeElementEntryRepository;
  final QuickPayUseCase _quickPayUseCase;
  final PayrollRunRepository _payrollRunRepository;
  final SalesRepository _salesRepository;
  final ExpenseRepository _expenseRepository;
  final AttendanceRepository _attendanceRepository;
  final SalonRepository _salonRepository;

  @override
  Future<PayrollSetupWorkspaceData> getPayrollSetupData({
    required String salonId,
    required DateTime period,
    String? employeeQuery,
    String? employeeId,
  }) async {
    final employees = await _eligibleEmployees(salonId);
    final selectedEmployee = _resolveEmployee(
      employees,
      employeeId: employeeId,
      employeeQuery: employeeQuery,
    );
    final elements = await _payrollElementRepository.getElements(
      salonId,
      activeOnly: false,
    );
    final entries = selectedEmployee == null
        ? const <EmployeeElementEntryModel>[]
        : await _employeeElementEntryRepository.getEntriesForEmployee(
            salonId,
            selectedEmployee.id,
            activeOnly: true,
          );

    final missingSetupCount = await _countEmployeesMissingBasicSalary(
      salonId,
      employees,
    );

    return PayrollSetupWorkspaceData(
      employees: employees,
      elements: elements,
      entries: entries,
      selectedPeriod: DateTime(period.year, period.month),
      missingSetupCount: missingSetupCount,
      selectedEmployee: selectedEmployee,
    );
  }

  @override
  Future<PayrollExplanationWorkspaceData> getPayrollExplanationData({
    required String salonId,
    required DateTime period,
    required String createdBy,
    String? employeeQuery,
    String? employeeId,
  }) async {
    final employees = await _eligibleEmployees(salonId);
    final selectedEmployee = _resolveEmployee(
      employees,
      employeeId: employeeId,
      employeeQuery: employeeQuery,
    );
    if (selectedEmployee == null) {
      throw StateError('No employee selected for payroll explanation.');
    }

    final bundleResult = await _quickPayUseCase.calculate(
      salonId: salonId,
      employeeId: selectedEmployee.id,
      year: period.year,
      month: period.month,
      createdBy: createdBy,
    );
    final bundle = bundleResult.match(
      (failure) => throw StateError(failure.userMessage),
      (value) => value,
    );

    final statement = bundle.employeeStatements.firstWhere(
      (candidate) => candidate.employee.id == selectedEmployee.id,
      orElse: () => bundle.employeeStatements.first,
    );

    final salon = await _salonRepository.getSalon(salonId);
    final currencyCode = resolvedSalonMoneyCurrency(
      salonCurrencyCode: salon?.currencyCode,
      salonCountryIso: salon?.countryCode,
    );

    return PayrollExplanationWorkspaceData(
      selectedPeriod: DateTime(period.year, period.month),
      employees: employees,
      bundle: bundle,
      statement: statement,
      currencyCode: currencyCode,
      selectedEmployee: selectedEmployee,
    );
  }

  @override
  Future<AnalyticsWorkspaceData> getAnalyticsData({
    required String salonId,
    required DateTime period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final salon = await _salonRepository.getSalon(salonId);
    final range = _resolveAnalyticsRange(
      period: period,
      startDate: startDate,
      endDate: endDate,
    );

    final sales = await _salesRepository.getSalesBySalon(
      salonId,
      soldFrom: range.start,
      soldTo: range.endInclusive,
      limit: 2000,
    );
    final expenses = await _expenseRepository.getExpenses(
      salonId,
      incurredFrom: range.start,
      incurredTo: range.endInclusive,
      limit: 1200,
    );
    final payrollRuns = await _payrollRunRepository.getRuns(
      salonId,
      limit: 120,
    );

    final completedSales = sales
        .where((sale) => sale.status == 'completed')
        .toList(growable: false);
    final totalRevenue = completedSales.fold<double>(
      0,
      (sum, sale) => sum + _saleTotal(sale),
    );
    final totalExpenses = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final payrollInRange = payrollRuns.where(
      (run) => _periodMonthOverlapsRange(run.year, run.month, range),
    );
    final totalPayroll = payrollInRange.fold<double>(
      0,
      (sum, run) => sum + run.netPay,
    );
    final draftPayrollRuns = payrollInRange
        .where((run) => run.status == PayrollRunStatuses.draft)
        .length;

    final chartPoints = <({String label, double revenue, double expenses})>[];
    for (var offset = 5; offset >= 0; offset -= 1) {
      final monthDate = DateTime(period.year, period.month - offset);
      final monthSales = await _salesRepository.getSalesBySalon(
        salonId,
        soldFrom: DateTime(monthDate.year, monthDate.month, 1),
        soldTo: DateTime(
          monthDate.year,
          monthDate.month + 1,
          0,
          23,
          59,
          59,
          999,
        ),
        limit: 1200,
      );
      final monthExpenses = await _expenseRepository.getMonthlyExpenses(
        salonId,
        year: monthDate.year,
        month: monthDate.month,
      );
      chartPoints.add((
        label: '${monthDate.month}/${monthDate.year.toString().substring(2)}',
        revenue: monthSales
            .where((sale) => sale.status == 'completed')
            .fold<double>(0, (sum, sale) => sum + _saleTotal(sale)),
        expenses: monthExpenses.fold<double>(
          0,
          (sum, expense) => sum + expense.amount,
        ),
      ));
    }

    return AnalyticsWorkspaceData(
      currencyCode: resolvedSalonMoneyCurrency(
        salonCurrencyCode: salon?.currencyCode,
        salonCountryIso: salon?.countryCode,
      ),
      rangeLabel: range.label,
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      totalPayroll: totalPayroll,
      netAfterExpensesAndPayroll: totalRevenue - totalExpenses - totalPayroll,
      transactionCount: completedSales.length,
      draftPayrollRuns: draftPayrollRuns,
      chartPoints: chartPoints,
    );
  }

  @override
  Future<AttendanceCorrectionWorkspaceData> getAttendanceCorrectionData({
    required String salonId,
    required DateTime startDate,
    required DateTime endDate,
    String? employeeQuery,
    String? employeeId,
    String? recordId,
  }) async {
    final employees = await _eligibleEmployees(salonId);
    final selectedEmployee = _resolveEmployee(
      employees,
      employeeId: employeeId,
      employeeQuery: employeeQuery,
    );
    final records = await _attendanceRepository.getAttendance(
      salonId,
      employeeId: selectedEmployee?.id,
      workDateFrom: DateTime(startDate.year, startDate.month, startDate.day),
      workDateTo: DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
        999,
      ),
      limit: 120,
    );

    AttendanceRecord? selectedRecord;
    if (recordId != null && recordId.trim().isNotEmpty) {
      for (final record in records) {
        if (record.id == recordId) {
          selectedRecord = record;
          break;
        }
      }
    }
    selectedRecord ??= records.cast<AttendanceRecord?>().firstWhere(
      (record) => record?.needsCorrection == true,
      orElse: () => records.isEmpty ? null : records.first,
    );

    return AttendanceCorrectionWorkspaceData(
      employees: employees,
      records: records,
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      endDate: DateTime(endDate.year, endDate.month, endDate.day),
      pendingCount: records
          .where((record) => record.approvalStatus == 'pending')
          .length,
      needsCorrectionCount: records
          .where((record) => record.needsCorrection)
          .length,
      selectedEmployee: selectedEmployee,
      selectedRecord: selectedRecord,
    );
  }

  @override
  Future<void> createPayrollElement({
    required String salonId,
    required PayrollElementProposal proposal,
  }) async {
    final trimmedName = proposal.name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Payroll element name is required.');
    }
    if (proposal.defaultAmount < 0) {
      throw ArgumentError('Payroll element amount cannot be negative.');
    }

    final existing = await _payrollElementRepository.getElements(
      salonId,
      activeOnly: false,
    );
    final desiredCode = _slugify(trimmedName);
    final duplicate = existing.any(
      (element) =>
          element.code == desiredCode || element.name.trim() == trimmedName,
    );
    if (duplicate) {
      throw StateError('A payroll element with the same name already exists.');
    }

    await _payrollElementRepository.createElement(
      salonId,
      PayrollElementModel(
        id: '',
        code: desiredCode,
        name: trimmedName,
        classification: proposal.classification,
        recurrenceType: proposal.recurrenceType,
        calculationMethod: proposal.calculationMethod,
        defaultAmount: proposal.defaultAmount,
        displayOrder: existing.length + 50,
      ),
    );
  }

  @override
  Future<void> applyAttendanceCorrection({
    required String salonId,
    required AttendanceCorrectionProposal proposal,
  }) async {
    final existing = await _attendanceRepository.getAttendanceRecord(
      salonId,
      proposal.recordId,
    );
    if (existing == null) {
      throw StateError('Attendance record not found.');
    }

    final correctedCheckIn = _mergeTime(
      existing.workDate,
      proposal.checkInTime,
      existing.checkInAt,
    );
    final correctedCheckOut = _mergeTime(
      existing.workDate,
      proposal.checkOutTime,
      existing.checkOutAt,
    );
    if (correctedCheckIn != null &&
        correctedCheckOut != null &&
        correctedCheckOut.isBefore(correctedCheckIn)) {
      throw StateError('Check-out time must be after check-in time.');
    }

    final updated = AttendanceRecord(
      id: existing.id,
      salonId: existing.salonId,
      employeeId: existing.employeeId,
      employeeName: existing.employeeName,
      workDate: existing.workDate,
      dateKey: existing.dateKey,
      status: proposal.status?.trim().isNotEmpty == true
          ? proposal.status!.trim()
          : existing.status,
      checkInAt: correctedCheckIn,
      checkOutAt: correctedCheckOut,
      minutesLate: existing.minutesLate,
      needsCorrection: false,
      notes: proposal.note?.trim().isNotEmpty == true
          ? proposal.note!.trim()
          : existing.notes,
      approvalStatus: existing.approvalStatus,
      approvedByUid: existing.approvedByUid,
      approvedByName: existing.approvedByName,
      approvedAt: existing.approvedAt,
      rejectionReason: existing.rejectionReason,
      createdAt: existing.createdAt,
      updatedAt: existing.updatedAt,
    );

    await _attendanceRepository.updateAttendanceRecord(salonId, updated);
    await _attendanceRepository.approveAttendance(
      salonId: salonId,
      attendanceId: proposal.recordId,
      approvedByUid: proposal.approvedByUid,
      approvedByName: proposal.approvedByName,
      approvalStatus: 'approved',
    );
  }

  Future<List<Employee>> _eligibleEmployees(String salonId) async {
    final employees = await _employeeRepository.getEmployees(
      salonId,
      onlyActive: true,
    );
    return employees
        .where((employee) => employee.role != 'owner')
        .toList(growable: false);
  }

  Employee? _resolveEmployee(
    List<Employee> employees, {
    String? employeeId,
    String? employeeQuery,
  }) {
    final normalizedId = employeeId?.trim();
    if (normalizedId != null && normalizedId.isNotEmpty) {
      for (final employee in employees) {
        if (employee.id == normalizedId) {
          return employee;
        }
      }
    }

    final normalizedQuery = employeeQuery?.trim().toLowerCase();
    if (normalizedQuery != null && normalizedQuery.isNotEmpty) {
      for (final employee in employees) {
        if (employee.name.toLowerCase().contains(normalizedQuery)) {
          return employee;
        }
      }
    }

    return employees.isEmpty ? null : employees.first;
  }

  Future<int> _countEmployeesMissingBasicSalary(
    String salonId,
    List<Employee> employees,
  ) async {
    var count = 0;
    for (final employee in employees) {
      final entries = await _employeeElementEntryRepository
          .getEntriesForEmployee(salonId, employee.id, activeOnly: true);
      final hasBasicSalary = entries.any(
        (entry) =>
            entry.elementCode == 'basic_salary' &&
            entry.recurrenceType == PayrollRecurrenceTypes.recurring,
      );
      if (!hasBasicSalary) {
        count += 1;
      }
    }
    return count;
  }

  double _saleTotal(Sale sale) {
    if (sale.lineItems.isEmpty) {
      return sale.total;
    }
    final sum = sale.lineItems.fold<double>(
      0,
      (runningTotal, item) => runningTotal + item.total,
    );
    return sum > 0 ? sum : sale.total;
  }

  _AnalyticsRange _resolveAnalyticsRange({
    required DateTime period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (startDate != null && endDate != null) {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
        999,
      );
      return _AnalyticsRange(
        start: start,
        endInclusive: end,
        label:
            '${_formatDate(start)} - ${_formatDate(DateTime(endDate.year, endDate.month, endDate.day))}',
      );
    }
    final monthStart = DateTime(period.year, period.month, 1);
    final monthEnd = DateTime(
      period.year,
      period.month + 1,
      0,
      23,
      59,
      59,
      999,
    );
    return _AnalyticsRange(
      start: monthStart,
      endInclusive: monthEnd,
      label: '${period.month}/${period.year}',
    );
  }

  bool _periodMonthOverlapsRange(int year, int month, _AnalyticsRange range) {
    final runStart = DateTime(year, month, 1);
    final runEnd = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    return !runEnd.isBefore(range.start) &&
        !runStart.isAfter(range.endInclusive);
  }

  DateTime? _mergeTime(DateTime workDate, String? rawTime, DateTime? fallback) {
    final trimmed = rawTime?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return fallback;
    }
    final match = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$').firstMatch(trimmed);
    if (match == null) {
      throw StateError('Time must use HH:mm format.');
    }
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    return DateTime(workDate.year, workDate.month, workDate.day, hour, minute);
  }

  String _slugify(String name) {
    final lowered = name.toLowerCase().trim();
    final collapsed = lowered.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return collapsed.replaceAll(RegExp(r'^_+|_+$'), '');
  }
}

class _AnalyticsRange {
  const _AnalyticsRange({
    required this.start,
    required this.endInclusive,
    required this.label,
  });

  final DateTime start;
  final DateTime endInclusive;
  final String label;
}

String _formatDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
