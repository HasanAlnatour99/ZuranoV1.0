import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

/// Calls HTTPS callable `submitCustomerFeedback` (writes review + updates salon aggregates).
class CustomerFeedbackSubmitService {
  CustomerFeedbackSubmitService(this._functions);

  final FirebaseFunctions _functions;

  Future<void> submit({
    required String salonId,
    required String bookingId,
    required int rating,
    required String comment,
    required String phoneNormalized,
    required String bookingCode,
  }) async {
    final trimmedSalon = salonId.trim();
    final trimmedBooking = bookingId.trim();
    if (trimmedSalon.isEmpty || trimmedBooking.isEmpty) {
      throw StateError('missing salon or booking');
    }
    final callable = _functions.httpsCallable('submitCustomerFeedback');
    try {
      await callable.call({
        'salonId': trimmedSalon,
        'bookingId': trimmedBooking,
        'rating': rating,
        'comment': comment,
        'phoneNormalized': phoneNormalized.trim(),
        'bookingCode': bookingCode.trim(),
      });
    } on FirebaseFunctionsException catch (e, st) {
      debugPrint('submitCustomerFeedback failed: $e\n$st');
      rethrow;
    }
  }

  /// Maps [FirebaseFunctionsException.code] / details to a stable reason key.
  static String? reasonFromException(FirebaseFunctionsException e) {
    final details = e.details;
    if (details is String && details.isNotEmpty) {
      return details;
    }
    final message = e.message ?? '';
    if (message.contains('booking_not_completed')) {
      return 'booking_not_completed';
    }
    return e.code;
  }
}
