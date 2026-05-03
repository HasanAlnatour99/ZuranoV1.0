import '../../../core/failures/app_failure.dart';
import '../../../l10n/app_localizations.dart';

/// Maps known payroll validation [AppFailure] codes to ARB-backed copy.
String payrollFailureUserMessage({
  required AppFailure failure,
  required AppLocalizations l10n,
}) {
  final validationCode = failure.mapOrNull(
    validation: (v) => v.code,
  );
  switch (validationCode) {
    case 'payrollEmployeeAlreadyPaidForPeriod':
      return l10n.payrollEmployeeAlreadyPaidForPeriod;
    case 'payrollAllStaffAlreadyPaidForPeriod':
      return l10n.payrollAllStaffAlreadyPaidForPeriod;
    default:
      return failure.userMessage;
  }
}
