import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/firebase/cloud_functions_region.dart';
import '../models/customer_booking_lookup_model.dart';

abstract class BookingLookupRepository {
  Future<List<CustomerBookingLookupModel>> findBooking({
    required String phoneNormalized,
    required String bookingCode,
  });
}

/// Uses [lookupCustomerBookings] (Admin SDK) so cross-device lookup stays secure:
/// phone and booking code are verified server-side; clients cannot read by phone alone.
class CallableBookingLookupRepository implements BookingLookupRepository {
  CallableBookingLookupRepository({FirebaseFunctions? functions})
    : _functions = functions ?? appCloudFunctions();

  final FirebaseFunctions _functions;

  @override
  Future<List<CustomerBookingLookupModel>> findBooking({
    required String phoneNormalized,
    required String bookingCode,
  }) async {
    final trimmedPhone = phoneNormalized.trim();
    final code = bookingCode.trim();
    if (trimmedPhone.isEmpty || code.isEmpty) {
      return const [];
    }

    try {
      final callable = _functions.httpsCallable('lookupCustomerBookings');
      final response = await callable.call(<String, dynamic>{
        'phoneNormalized': trimmedPhone,
        'bookingCode': code,
      });

      final raw = response.data;
      if (raw is! Map) {
        return const [];
      }
      final map = Map<String, dynamic>.from(raw);
      final list = map['bookings'];
      if (list is! List) {
        return const [];
      }

      return list
          .whereType<Map>()
          .map((e) => CustomerBookingLookupModel.fromLookupCallableJson(
                Map<String, dynamic>.from(e),
              ))
          .toList(growable: false);
    } on FirebaseFunctionsException catch (e) {
      // Wrong phone/code should behave like "not found" (no leaks).
      if (e.code == 'not-found') {
        return const [];
      }
      rethrow;
    }
  }
}
