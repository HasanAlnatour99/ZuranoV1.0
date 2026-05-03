import '../../../../l10n/app_localizations.dart';

String localizedAddSaleBookingError(AppLocalizations l10n, String? code) {
  switch (code) {
    case 'empty_code':
      return l10n.addSaleBookingErrorEmptyCode;
    case 'not_found':
      return l10n.addSaleBookingErrorNotFound;
    case 'wrong_salon':
      return l10n.addSaleBookingErrorWrongSalon;
    case 'cancelled':
      return l10n.addSaleBookingErrorCancelled;
    case 'sale_exists':
      return l10n.addSaleBookingErrorSaleExists;
    case 'no_services':
      return l10n.addSaleBookingErrorNoServices;
    case 'zero_total':
      return l10n.addSaleBookingErrorZeroTotal;
    case 'barber_mismatch':
      return l10n.addSaleBookingErrorBarberMismatch;
    case 'not_your_booking':
      return l10n.addSaleBookingErrorNotYourBooking;
    case 'no_preview':
      return l10n.addSaleBookingErrorNoPreview;
    case 'no_session':
      return l10n.addSaleBookingErrorNoSession;
    case 'barber_missing':
      return l10n.addSaleBookingErrorBarberMissing;
    case 'manual_name_required':
      return l10n.addSaleBookingErrorManualNameRequired;
    default:
      return l10n.addSaleBookingErrorUnknown;
  }
}
