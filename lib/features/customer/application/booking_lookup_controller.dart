import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/cloud_functions_region.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';
import '../data/models/customer_booking_lookup_model.dart';
import '../data/repositories/booking_lookup_repository.dart';
import 'customer_phone_normalizer.dart';

enum BookingLookupError { invalidPhone, missingPhoneOrCode }

class BookingLookupException implements Exception {
  const BookingLookupException(this.error);

  final BookingLookupError error;
}

final bookingLookupRepositoryProvider = Provider<BookingLookupRepository>((ref) {
  return CallableBookingLookupRepository(functions: appCloudFunctions());
});

/// Bookings tied to the signed-in user (`guestUid` / `createdByAuthUid`). Empty when anonymous.
final customerAccountBookingsForFindProvider =
    FutureProvider.autoDispose<List<CustomerBookingLookupModel>>((ref) async {
      final uid =
          (ref.watch(sessionUserProvider).asData?.value?.uid ?? '').trim();
      if (uid.isEmpty) {
        return const <CustomerBookingLookupModel>[];
      }
      final page = await ref
          .read(bookingRepositoryProvider)
          .getCustomerBookingDocumentsPage(uid, limit: 50);
      return page.items
          .map(
            (d) => CustomerBookingLookupModel.fromSalonBookingMap(
              d.id,
              d.data(),
            ),
          )
          .toList(growable: false);
    });

final bookingLookupControllerProvider =
    AsyncNotifierProvider<BookingLookupController, List<CustomerBookingLookupModel>?>(
      BookingLookupController.new,
    );

class BookingLookupController extends AsyncNotifier<List<CustomerBookingLookupModel>?> {
  @override
  Future<List<CustomerBookingLookupModel>?> build() async => null;

  Future<List<CustomerBookingLookupModel>?> search({
    required String phoneInput,
    required String bookingCodeInput,
  }) async {
    final phoneTrim = phoneInput.trim();
    final codeTrim = bookingCodeInput.trim();

    if (phoneTrim.isEmpty || codeTrim.isEmpty) {
      state = AsyncValue.error(
        const BookingLookupException(BookingLookupError.missingPhoneOrCode),
        StackTrace.current,
      );
      return null;
    }

    final phoneNormalized = CustomerPhoneNormalizer.normalizePhone(phoneInput);
    if (!CustomerPhoneNormalizer.isValidPhone(phoneNormalized)) {
      state = AsyncValue.error(
        const BookingLookupException(BookingLookupError.invalidPhone),
        StackTrace.current,
      );
      return null;
    }

    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref.read(bookingLookupRepositoryProvider).findBooking(
            phoneNormalized: phoneNormalized,
            bookingCode: codeTrim.toUpperCase(),
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
