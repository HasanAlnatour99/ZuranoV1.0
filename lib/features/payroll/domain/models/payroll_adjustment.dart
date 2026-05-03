enum PayrollAdjustmentType { bonus, deduction }

extension PayrollAdjustmentTypeX on PayrollAdjustmentType {
  String get value {
    switch (this) {
      case PayrollAdjustmentType.bonus:
        return 'bonus';
      case PayrollAdjustmentType.deduction:
        return 'deduction';
    }
  }
}

class PayrollAdjustment {
  final String id;
  final String salonId;
  final String employeeId;
  final String monthKey;
  final PayrollAdjustmentType type;
  final double amount;
  final String reason;
  final String? note;
  final String status;
  final bool isRecurring;
  final DateTime? createdAt;
  final String? createdBy;

  const PayrollAdjustment({
    required this.id,
    required this.salonId,
    required this.employeeId,
    required this.monthKey,
    required this.type,
    required this.amount,
    required this.reason,
    this.note,
    required this.status,
    this.isRecurring = false,
    this.createdAt,
    this.createdBy,
  });

  bool get isBonus => type == PayrollAdjustmentType.bonus;
  bool get isDeduction => type == PayrollAdjustmentType.deduction;
}
