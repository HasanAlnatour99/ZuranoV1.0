/// Salon default and per-employee override for payroll calendar (runs / UI).
abstract final class SalonPayrollPeriods {
  static const monthly = 'monthly';
  static const weekly = 'weekly';

  static bool isValid(String? v) => v == monthly || v == weekly;

  /// Missing or unknown values default to monthly.
  static String normalize(String? v) => v == weekly ? weekly : monthly;
}

/// Stored on each payroll run document.
abstract final class PayrollRunPeriodGranularities {
  static const monthly = 'monthly';
  static const weekly = 'weekly';

  static String normalize(String? v) => v == weekly ? weekly : monthly;
}
