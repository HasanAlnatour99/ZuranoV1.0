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

/// Find Booking tab: first three account bookings + whether to show **View all**.
final customerAccountBookingsForFindProvider =
    FutureProvider.autoDispose<CustomerAccountBookingsPreview>((ref) async {
      final uid =
          (ref.watch(sessionUserProvider).asData?.value?.uid ?? '').trim();
      if (uid.isEmpty) {
        return const CustomerAccountBookingsPreview(
          items: [],
          showViewAll: false,
        );
      }
      final page = await ref
          .read(bookingRepositoryProvider)
          .getCustomerBookingDocumentsPage(uid, limit: 4);
      final mapped = page.items
          .map(CustomerBookingLookupModel.fromFirestore)
          .toList(growable: false);
      final showViewAll = page.hasMore || mapped.length > 3;
      final visible = mapped.take(3).toList(growable: false);
      return CustomerAccountBookingsPreview(
        items: visible,
        showViewAll: showViewAll,
      );
    });

/// Account booking list preview for [FindBookingScreen].
class CustomerAccountBookingsPreview {
  const CustomerAccountBookingsPreview({
    required this.items,
    required this.showViewAll,
  });

  final List<CustomerBookingLookupModel> items;
  final bool showViewAll;
}

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
