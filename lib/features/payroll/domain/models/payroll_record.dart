import 'payroll_status.dart';

class PayrollRecord {
  final String id;
  final String salonId;
  final String employeeId;
  final String employeeName;
  final String monthKey;
  final String currencyCode;
  final double servicesRevenue;
  final double commissionPercentage;
  final double commissionAmount;
  final double bonusesTotal;
  final double deductionsTotal;
  final double netPayout;
  final PayrollStatus status;
  final int salesCount;
  final DateTime? generatedAt;
  final String? generatedBy;
  final DateTime? paidAt;
  final String? paidBy;

  const PayrollRecord({
    required this.id,
    required this.salonId,
    required this.employeeId,
    required this.employeeName,
    required this.monthKey,
    required this.currencyCode,
    required this.servicesRevenue,
    required this.commissionPercentage,
    required this.commissionAmount,
    required this.bonusesTotal,
    required this.deductionsTotal,
    required this.netPayout,
    required this.status,
    required this.salesCount,
    this.generatedAt,
    this.generatedBy,
    this.paidAt,
    this.paidBy,
  });
}
