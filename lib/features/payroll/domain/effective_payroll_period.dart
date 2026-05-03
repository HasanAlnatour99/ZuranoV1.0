import '../../../core/constants/payroll_period_constants.dart';

/// Resolves per-employee payroll cadence: explicit override, else salon default.
String effectivePayrollPeriodFor({
  required String salonDefaultPayrollPeriod,
  required String? employeePayrollPeriodOverride,
}) {
  return SalonPayrollPeriods.normalize(
    employeePayrollPeriodOverride ?? salonDefaultPayrollPeriod,
  );
}
