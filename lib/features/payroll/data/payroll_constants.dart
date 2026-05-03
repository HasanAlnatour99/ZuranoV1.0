abstract final class PayrollElementClassifications {
  static const earning = 'earning';
  static const deduction = 'deduction';
  static const information = 'information';
}

abstract final class PayrollRecurrenceTypes {
  static const recurring = 'recurring';
  static const nonrecurring = 'nonrecurring';
}

abstract final class PayrollCalculationMethods {
  static const fixed = 'fixed';
  static const percentage = 'percentage';
  static const derived = 'derived';
}

abstract final class PayrollEntryStatuses {
  static const active = 'active';
  static const inactive = 'inactive';
}

abstract final class PayrollRunTypes {
  static const quickPay = 'quickpay';
  static const payrollRun = 'payroll_run';
}

abstract final class PayrollRunStatuses {
  static const draft = 'draft';
  static const approved = 'approved';
  static const paid = 'paid';
  static const rolledBack = 'rolled_back';

  /// Draft, approved, or paid runs may be fully or partially reversed.
  static bool canRollback(String status) =>
      status == draft || status == approved || status == paid;

  static bool isFinalized(String status) =>
      status == paid || status == rolledBack;
}

abstract final class PayrollResultSourceTypes {
  static const manual = 'manual';
  static const recurringEntry = 'recurring_entry';
  static const nonrecurringEntry = 'nonrecurring_entry';
  static const systemGenerated = 'system_generated';
}

abstract final class PayrollCalculationSources {
  static const snapshot = 'snapshot';
  static const fallback = 'fallback';
  static const derived = 'derived';
  static const manual = 'manual';
}
