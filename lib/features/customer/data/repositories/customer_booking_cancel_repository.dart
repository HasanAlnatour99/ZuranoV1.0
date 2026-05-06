import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/firebase/cloud_functions_region.dart';

enum CustomerBookingCancelFailure {
  notFound,
  invalidStatus,
  cutoffExpired,
  reasonTooLong,
  permissionDenied,
}

class CustomerBookingCancelException implements Exception {
  const CustomerBookingCancelException(this.failure);

  final CustomerBookingCancelFailure failure;

  @override
  String toString() => 'CustomerBookingCancelException($failure)';
}

abstract class CustomerBookingCancelRepository {
  Future<void> cancelBooking({
    required String salonId,
    required String bookingId,
    required String cancelReason,
    required String phoneNormalized,
    required String bookingCode,
  });
}

/// Cancels via [cancelCustomerBooking] (server validates guest uid or phone + code).
class CallableCustomerBookingCancelRepository
    implements CustomerBookingCancelRepository {
  CallableCustomerBookingCancelRepository({FirebaseFunctions? functions})
    : _functions = functions ?? appCloudFunctions();

  final FirebaseFunctions _functions;

  @override
  Future<void> cancelBooking({
    required String salonId,
    required String bookingId,
    required String cancelReason,
    required String phoneNormalized,
    required String bookingCode,
  }) async {
    try {
      final callable = _functions.httpsCallable('cancelCustomerBooking');
      await callable.call(<String, dynamic>{
        'salonId': salonId,
        'bookingId': bookingId,
        'phoneNormalized': phoneNormalized.trim(),
        'bookingCode': bookingCode.trim().toUpperCase(),
        'cancelReason': cancelReason,
      });
    } on FirebaseFunctionsException catch (e) {
      final code = e.code;
      final msg = '${e.message}'.toLowerCase();
      if (code == 'permission-denied') {
        throw const CustomerBookingCancelException(
          CustomerBookingCancelFailure.permissionDenied,
        );
      }
      if (code == 'not-found') {
        throw const CustomerBookingCancelException(
          CustomerBookingCancelFailure.notFound,
        );
      }
      if (code == 'failed-precondition') {
        if (msg.contains('cutoff')) {
          throw const CustomerBookingCancelException(
            CustomerBookingCancelFailure.cutoffExpired,
          );
        }
        if (msg.contains('invalid_status')) {
          throw const CustomerBookingCancelException(
            CustomerBookingCancelFailure.invalidStatus,
          );
        }
      }
      rethrow;
    }
  }
}
