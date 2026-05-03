import '../../../core/text/team_member_name.dart';
import '../../employees/data/models/employee.dart';
import '../../users/data/models/app_user.dart';
import '../data/payroll_repository.dart';
import '../domain/payroll_adjustment_not_found.dart';
import '../domain/models/payroll_adjustment.dart';
import '../domain/models/payroll_status.dart';
import '../domain/models/team_member_payroll_summary.dart';

class PayrollAppService {
  PayrollAppService({required PayrollRepository payrollRepository})
    : _repository = payrollRepository;

  final PayrollRepository _repository;

  Future<TeamMemberPayrollSummary> loadSummary({
    required String salonId,
    required String employeeId,
    required String monthKey,
    required DateTime monthStart,
    required DateTime nextMonthStart,
    required DateTime todayStart,
    required DateTime tomorrowStart,
  }) async {
    final employee = await _repository.getEmployee(salonId, employeeId);
    if (employee == null) {
      throw StateError('Employee not found.');
    }
    final currencyCode = await _repository.fetchSalonCurrencyCode(salonId);
    final monthSales = await _repository.getEmployeeSalesByRange(
      salonId: salonId,
      employeeId: employeeId,
      start: monthStart,
      endExclusive: nextMonthStart,
    );
    final todaySales = await _repository.getEmployeeSalesByRange(
      salonId: salonId,
      employeeId: employeeId,
      start: todayStart,
      endExclusive: tomorrowStart,
    );
    final adjustments = await _repository.getPayrollAdjustments(
      salonId: salonId,
      employeeId: employeeId,
      monthKey: monthKey,
    );
    final record = await _repository.getTeamMemberPayrollRecord(
      salonId: salonId,
      employeeId: employeeId,
      monthKey: monthKey,
    );

    final commissionPct = employee.resolvedCommissionPercentage;
    final fixedCommission = _round(employee.resolvedCommissionFixedAmount);
    final monthRevenue = monthSales.fold<double>(
      0,
      (sum, sale) => sum + sale.total,
    );
    final todayRevenue = todaySales.fold<double>(
      0,
      (sum, sale) => sum + sale.total,
    );
    final percentCommissionThisMonth = _round(monthRevenue * commissionPct / 100);
    final computedMonthCommission = _round(
      percentCommissionThisMonth + fixedCommission,
    );
    final computedTodayCommission = _round(todayRevenue * commissionPct / 100);
    final bonuses = _sumAdjustments(adjustments, PayrollAdjustmentType.bonus);
    final deductions = _sumAdjustments(
      adjustments,
      PayrollAdjustmentType.deduction,
    );
    final bonusItems = _namedAdjustments(
      adjustments,
      PayrollAdjustmentType.bonus,
    );
    final deductionItems = _namedAdjustments(
      adjustments,
      PayrollAdjustmentType.deduction,
    );
    final liveCommissionThisMonth = computedMonthCommission;
    final liveBonusesTotal = bonuses;
    final liveDeductionsTotal = deductions;
    final liveEstimatedPayout = _nonNegative(
      liveCommissionThisMonth + liveBonusesTotal - liveDeductionsTotal,
    );
    final employeeActive = _isEmployeeActive(employee);
    final paid = record?.status == PayrollStatus.paid;
    final payslipAbsentOrReversed =
        record == null || record.status == PayrollStatus.cancelled;
    final canEdit = employeeActive && !paid && payslipAbsentOrReversed;

    if (record != null && paid) {
      return TeamMemberPayrollSummary(
        salonId: salonId,
        employeeId: employeeId,
        employeeName: formatTeamMemberName(employee.name),
        monthKey: monthKey,
        currencyCode: record.currencyCode,
        commissionPercentage: record.commissionPercentage,
        commissionFixedAmount: fixedCommission,
        todayServicesRevenue: todayRevenue,
        monthServicesRevenue: record.servicesRevenue,
        commissionToday: computedTodayCommission,
        commissionThisMonth: record.commissionAmount,
        bonusesTotal: record.bonusesTotal,
        deductionsTotal: record.deductionsTotal,
        estimatedPayout: _nonNegative(record.netPayout),
        salesCount: record.salesCount,
        status: record.status,
        employeeActive: employeeActive,
        canEditPayroll: false,
        hasGeneratedPayroll: true,
        bonusItems: bonusItems,
        deductionItems: deductionItems,
      );
    }

    return TeamMemberPayrollSummary(
      salonId: salonId,
      employeeId: employeeId,
      employeeName: formatTeamMemberName(employee.name),
      monthKey: monthKey,
      currencyCode: currencyCode,
      commissionPercentage: commissionPct,
      commissionFixedAmount: fixedCommission,
      todayServicesRevenue: todayRevenue,
      monthServicesRevenue: monthRevenue,
      commissionToday: computedTodayCommission,
      // Keep editable payroll aligned with live sales + adjustments.
      commissionThisMonth: liveCommissionThisMonth,
      bonusesTotal: liveBonusesTotal,
      deductionsTotal: liveDeductionsTotal,
      estimatedPayout: liveEstimatedPayout,
      salesCount: record?.salesCount ?? monthSales.length,
      status: record?.status ?? PayrollStatus.draft,
      employeeActive: employeeActive,
      canEditPayroll: canEdit,
      hasGeneratedPayroll: record != null,
      bonusItems: bonusItems,
      deductionItems: deductionItems,
    );
  }

  Future<void> addAdjustment({
    required String salonId,
    required String employeeId,
    required String monthKey,
    required PayrollAdjustmentType type,
    required double amount,
    required String reason,
    required bool isRecurring,
    String? note,
    required TeamMemberPayrollSummary summary,
    required AppUser actor,
  }) async {
    _validateCanManage(actor);
    if (!summary.canEditPayroll) {
      throw StateError('Payroll is locked.');
    }
    if (amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Amount must be greater than zero.',
      );
    }
    if (reason.trim().isEmpty) {
      throw ArgumentError('Reason is required.');
    }
    await _repository.addPayrollAdjustment(
      salonId: salonId,
      employeeId: employeeId,
      monthKey: monthKey,
      type: type,
      amount: amount,
      reason: reason.trim(),
      isRecurring: isRecurring,
      note: note?.trim(),
      userId: actor.uid,
    );
  }

  Future<void> removeAdjustmentElement({
    required String salonId,
    required String employeeId,
    required String monthKey,
    required PayrollAdjustmentType type,
    required String reason,
    required TeamMemberPayrollSummary summary,
    required AppUser actor,
  }) async {
    _validateCanManage(actor);
    if (!summary.canEditPayroll) {
      throw StateError('Payroll is locked.');
    }
    if (reason.trim().isEmpty) {
      throw ArgumentError('Element name is required.');
    }
    final removed = await _repository.removePayrollAdjustmentElement(
      salonId: salonId,
      employeeId: employeeId,
      monthKey: monthKey,
      type: type,
      reason: reason.trim(),
      userId: actor.uid,
    );
    if (removed == 0) {
      throw const PayrollAdjustmentNotFound();
    }
  }

  Future<void> updateAdjustmentElement({
    required String salonId,
    required String employeeId,
    required String monthKey,
    required PayrollAdjustmentType type,
    required String reason,
    required double newAmount,
    required bool isRecurring,
    String? note,
    required TeamMemberPayrollSummary summary,
    required AppUser actor,
  }) async {
    _validateCanManage(actor);
    if (!summary.canEditPayroll) {
      throw StateError('Payroll is locked.');
    }
    if (newAmount <= 0) {
      throw ArgumentError.value(
        newAmount,
        'newAmount',
        'Amount must be greater than zero.',
      );
    }
    if (reason.trim().isEmpty) {
      throw ArgumentError('Reason is required.');
    }
    final removed = await _repository.removePayrollAdjustmentElement(
      salonId: salonId,
      employeeId: employeeId,
      monthKey: monthKey,
      type: type,
      reason: reason.trim(),
      userId: actor.uid,
    );
    if (removed == 0) {
      throw const PayrollAdjustmentNotFound();
    }
    await _repository.addPayrollAdjustment(
      salonId: salonId,
      employeeId: employeeId,
      monthKey: monthKey,
      type: type,
      amount: newAmount,
      reason: reason.trim(),
      isRecurring: isRecurring,
      note: note?.trim(),
      userId: actor.uid,
    );
  }

  Future<void> generatePayslip({
    required TeamMemberPayrollSummary summary,
    required AppUser actor,
  }) async {
    _validateCanManage(actor);
    if (!summary.canEditPayroll) {
      throw StateError('Payroll is locked.');
    }
    await _repository.generateTeamMemberPayroll(
      salonId: summary.salonId,
      employeeId: summary.employeeId,
      employeeName: formatTeamMemberName(summary.employeeName),
      monthKey: summary.monthKey,
      currencyCode: summary.currencyCode,
      servicesRevenue: summary.monthServicesRevenue,
      commissionPercentage: summary.commissionPercentage,
      commissionAmount: summary.commissionThisMonth,
      bonusesTotal: summary.bonusesTotal,
      deductionsTotal: summary.deductionsTotal,
      netPayout: summary.estimatedPayout,
      salesCount: summary.salesCount,
      adjustmentIds: const [],
      userId: actor.uid,
    );
  }

  Future<void> reverseLatestPayrollMonth({
    required String salonId,
    required String employeeId,
    required AppUser actor,
  }) async {
    _validateCanManage(actor);
    await _repository.reverseLatestTeamMemberPayrollMonth(
      salonId: salonId,
      employeeId: employeeId,
      userId: actor.uid,
    );
  }

  bool _isEmployeeActive(Employee employee) {
    final status = employee.status.trim().toLowerCase();
    return employee.isActive && status != 'inactive' && status != 'frozen';
  }

  double _sumAdjustments(
    List<PayrollAdjustment> items,
    PayrollAdjustmentType type,
  ) {
    return _round(
      items
          .where((item) => item.type == type)
          .fold<double>(0, (sum, item) => sum + item.amount),
    );
  }

  List<PayrollNamedAmount> _namedAdjustments(
    List<PayrollAdjustment> items,
    PayrollAdjustmentType type,
  ) {
    final byKey = <String, List<PayrollAdjustment>>{};
    final displayNamesByKey = <String, String>{};
    for (final item in items) {
      if (item.type != type || item.amount <= 0) {
        continue;
      }
      final displayName = item.reason.trim();
      if (displayName.isEmpty) {
        continue;
      }
      final key = displayName.toLowerCase();
      displayNamesByKey.putIfAbsent(key, () => displayName);
      byKey.putIfAbsent(key, () => []).add(item);
    }
    if (byKey.isEmpty) {
      return const [];
    }
    return byKey.entries.map((entry) {
      final list = entry.value;
      final total = _round(
        list.fold<double>(0, (sum, item) => sum + item.amount),
      );
      final anyRecurring = list.any((item) => item.isRecurring);
      String? note;
      final withNotes = list
          .where((item) => (item.note?.trim().isNotEmpty ?? false))
          .toList();
      if (withNotes.isNotEmpty) {
        withNotes.sort((a, b) {
          final cmp = b.monthKey.compareTo(a.monthKey);
          if (cmp != 0) return cmp;
          final ca = a.createdAt;
          final cb = b.createdAt;
          if (ca != null && cb != null) return cb.compareTo(ca);
          if (cb != null) return 1;
          if (ca != null) return -1;
          return 0;
        });
        note = withNotes.first.note?.trim();
      }
      return PayrollNamedAmount(
        name: displayNamesByKey[entry.key] ?? entry.key,
        amount: total,
        isRecurring: anyRecurring,
        note: note,
      );
    }).toList(growable: false);
  }

  double _round(double value) {
    if (!value.isFinite) {
      return 0;
    }
    return double.parse(value.toStringAsFixed(2));
  }

  double _nonNegative(double value) => value < 0 ? 0 : _round(value);

  void _validateCanManage(AppUser actor) {
    if (actor.role != 'owner' && actor.role != 'admin') {
      throw StateError('Only owner/admin can manage payroll.');
    }
  }
}
