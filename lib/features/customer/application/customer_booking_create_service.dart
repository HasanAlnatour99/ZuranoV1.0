import 'package:cloud_functions/cloud_functions.dart';

import '../data/models/customer_booking_create_result.dart';
import '../data/models/customer_booking_draft.dart';
import '../data/models/customer_booking_settings.dart';
import '../data/repositories/customer_booking_create_repository.dart';

class CustomerBookingCreateException implements Exception {
  const CustomerBookingCreateException(this.code);

  final String code;
}

class CustomerBookingCreateService {
  const CustomerBookingCreateService(this._repository);

  final CustomerBookingCreateRepository _repository;

  Future<CustomerBookingCreateResult> createBooking({
    required String salonId,
    required CustomerBookingDraft draft,
    required CustomerBookingSettings bookingSettings,
    required String customerUiLanguageCode,
    bool anonymousGuestRequiresNickname = false,
  }) async {
    try {
      _validateDraft(
        draft,
        bookingSettings,
        anonymousGuestRequiresNickname: anonymousGuestRequiresNickname,
      );
      return await _repository.createBookingFromDraft(
        salonId: salonId,
        draft: draft,
        bookingSettings: bookingSettings,
        customerUiLanguageCode: customerUiLanguageCode,
        anonymousGuestRequiresNickname: anonymousGuestRequiresNickname,
      );
    } on CustomerBookingCreateException {
      rethrow;
    } on SlotUnavailableException {
      throw const CustomerBookingCreateException('slot_unavailable');
    } on CustomerBookingValidationException catch (error) {
      throw CustomerBookingCreateException(error.message);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'failed-precondition' &&
          '${e.message}'.contains('slot_unavailable')) {
        throw const CustomerBookingCreateException('slot_unavailable');
      }
      throw const CustomerBookingCreateException('unknown');
    } on Object {
      throw const CustomerBookingCreateException('unknown');
    }
  }

  void _validateDraft(
    CustomerBookingDraft draft,
    CustomerBookingSettings bookingSettings, {
    bool anonymousGuestRequiresNickname = false,
  }) {
    if (!draft.hasServices) {
      throw const CustomerBookingCreateException('missing_services');
    }
    if (!draft.hasTeamSelection || draft.selectedEmployeeId == null) {
      throw const CustomerBookingCreateException('missing_specialist');
    }
    if (!draft.hasDateTime) {
      throw const CustomerBookingCreateException('missing_time');
    }
    if (!bookingSettings.customerDetailsSatisfied(
      customerName: draft.customerName,
      customerPhoneNormalized: draft.customerPhoneNormalized,
    )) {
      throw const CustomerBookingCreateException('missing_customer');
    }
    if (anonymousGuestRequiresNickname && !draft.hasGuestNickname) {
      throw const CustomerBookingCreateException('missing_guest_nickname');
    }
  }
}
