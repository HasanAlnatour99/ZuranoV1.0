import 'payroll_status.dart';

class PayrollNamedAmount {
  final String name;
  final double amount;
  final bool isRecurring;
  final String? note;

  const PayrollNamedAmount({
    required this.name,
    required this.amount,
    this.isRecurring = false,
    this.note,
  });
}

class TeamMemberPayrollSummary {
  final String salonId;
  final String employeeId;
  final String employeeName;
  final String monthKey;
  final String currencyCode;
  final double commissionPercentage;
  final double commissionFixedAmount;
  final double todayServicesRevenue;
  final double monthServicesRevenue;
  final double commissionToday;
  final double commissionThisMonth;
  final double bonusesTotal;
  final double deductionsTotal;
  final double estimatedPayout;
  final int salesCount;
  final PayrollStatus status;
  final bool employeeActive;
  final bool canEditPayroll;
  final bool hasGeneratedPayroll;
  final List<PayrollNamedAmount>? _bonusItems;
  final List<PayrollNamedAmount>? _deductionItems;

  List<PayrollNamedAmount> get bonusItems => _bonusItems ?? const [];
  List<PayrollNamedAmount> get deductionItems => _deductionItems ?? const [];

  /// Commission attributable to percentage of sales (remainder after fixed portion).
  /// Used in the breakdown when [commissionFixedAmount] is shown as its own row.
  double get commissionPercentPortionForDisplay {
    if (commissionFixedAmount <= 0) return commissionThisMonth;
    final variable = commissionThisMonth - commissionFixedAmount;
    return variable > 0 ? variable : 0;
  }

  const TeamMemberPayrollSummary({
    required this.salonId,
    required this.employeeId,
    required this.employeeName,
    required this.monthKey,
    required this.currencyCode,
    required this.commissionPercentage,
    required this.commissionFixedAmount,
    required this.todayServicesRevenue,
    required this.monthServicesRevenue,
    required this.commissionToday,
    required this.commissionThisMonth,
    required this.bonusesTotal,
    required this.deductionsTotal,
    required this.estimatedPayout,
    required this.salesCount,
    required this.status,
    required this.employeeActive,
    required this.canEditPayroll,
    required this.hasGeneratedPayroll,
    List<PayrollNamedAmount>? bonusItems,
    List<PayrollNamedAmount>? deductionItems,
  }) : _bonusItems = bonusItems,
       _deductionItems = deductionItems;
}
