import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/cloud_functions_region.dart';
import '../data/repositories/customer_booking_cancel_repository.dart';
import 'customer_booking_cancel_service.dart';

final customerBookingCancelRepositoryProvider =
    Provider<CustomerBookingCancelRepository>((ref) {
      return CallableCustomerBookingCancelRepository(
        functions: appCloudFunctions(),
      );
    });

final customerBookingCancelServiceProvider =
    Provider<CustomerBookingCancelService>((ref) {
      return CustomerBookingCancelService(
        ref.watch(customerBookingCancelRepositoryProvider),
      );
    });

/// Non-null value in [AsyncData] after [CustomerBookingCancelController.cancel] succeeds.
final Object customerBookingCancelSuccess = Object();

final customerBookingCancelControllerProvider =
    AsyncNotifierProvider.autoDispose<CustomerBookingCancelController, Object?>(
      CustomerBookingCancelController.new,
    );

class CustomerBookingCancelController extends AsyncNotifier<Object?> {
  @override
  Future<Object?> build() async => null;

  Future<void> cancel({
    required String salonId,
    required String bookingId,
    required String cancelReason,
    required String phoneNormalized,
    required String bookingCode,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(customerBookingCancelServiceProvider)
          .cancelBooking(
            salonId: salonId,
            bookingId: bookingId,
            cancelReason: cancelReason,
            phoneNormalized: phoneNormalized,
            bookingCode: bookingCode,
          );
      return customerBookingCancelSuccess;
    });
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
