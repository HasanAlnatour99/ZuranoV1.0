enum PayrollStatus { draft, ready, paid, cancelled }

extension PayrollStatusX on PayrollStatus {
  String get value {
    switch (this) {
      case PayrollStatus.draft:
        return 'draft';
      case PayrollStatus.ready:
        return 'ready';
      case PayrollStatus.paid:
        return 'paid';
      case PayrollStatus.cancelled:
        return 'cancelled';
    }
  }

  static PayrollStatus fromString(String? value) {
    switch (value) {
      case 'ready':
        return PayrollStatus.ready;
      case 'paid':
        return PayrollStatus.paid;
      case 'cancelled':
        return PayrollStatus.cancelled;
      case 'draft':
      default:
        return PayrollStatus.draft;
    }
  }
}
