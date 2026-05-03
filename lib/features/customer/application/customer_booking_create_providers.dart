import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/firebase_providers.dart';
import '../data/models/customer_booking_create_result.dart';
import '../data/models/customer_booking_draft.dart';
import '../data/models/customer_booking_settings.dart';
import '../data/repositories/customer_booking_create_repository.dart';
import 'customer_booking_create_service.dart';

final customerBookingCreateRepositoryProvider =
    Provider<CustomerBookingCreateRepository>((ref) {
      return FirestoreCustomerBookingCreateRepository(
        ref.watch(firestoreProvider),
      );
    });

final customerBookingCreateServiceProvider =
    Provider<CustomerBookingCreateService>((ref) {
      return CustomerBookingCreateService(
        ref.watch(customerBookingCreateRepositoryProvider),
      );
    });

final customerBookingCreateControllerProvider =
    AsyncNotifierProvider<
      CustomerBookingCreateController,
      CustomerBookingCreateResult?
    >(CustomerBookingCreateController.new);

class CustomerBookingCreateController
    extends AsyncNotifier<CustomerBookingCreateResult?> {
  @override
  Future<CustomerBookingCreateResult?> build() async => null;

  Future<CustomerBookingCreateResult?> create({
    required String salonId,
    required CustomerBookingDraft draft,
    required CustomerBookingSettings bookingSettings,
    required String customerUiLanguageCode,
  }) async {
    state = const AsyncValue.loading();
    final anonymousGuest =
        ref.read(firebaseAuthProvider).currentUser?.isAnonymous == true;
    final result = await AsyncValue.guard(
      () => ref
          .read(customerBookingCreateServiceProvider)
          .createBooking(
            salonId: salonId,
            draft: draft,
            bookingSettings: bookingSettings,
            customerUiLanguageCode: customerUiLanguageCode,
            anonymousGuestRequiresNickname: anonymousGuest,
          ),
    );
    state = result;
    return result.when(
      data: (value) => value,
      error: (_, _) => null,
      loading: () => null,
    );
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
