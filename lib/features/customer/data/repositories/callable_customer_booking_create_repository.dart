import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/firebase/cloud_functions_region.dart';
import '../../../../core/firestore/firestore_paths.dart';
import '../models/customer_booking_create_result.dart';
import '../models/customer_booking_draft.dart';
import '../models/customer_booking_settings.dart';
import 'customer_booking_create_repository.dart';

/// Creates bookings via the [createCustomerBooking] HTTPS callable (Admin SDK).
///
/// Avoids client-side reads on `salons/{salonId}/bookings` day-range queries,
/// which Firestore rules deny for customers.
class CallableCustomerBookingCreateRepository
    implements CustomerBookingCreateRepository {
  CallableCustomerBookingCreateRepository({
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _functions = functions ?? appCloudFunctions(),
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<CustomerBookingCreateResult> createBookingFromDraft({
    required String salonId,
    required CustomerBookingDraft draft,
    required CustomerBookingSettings bookingSettings,
    required String customerUiLanguageCode,
    bool anonymousGuestRequiresNickname = false,
  }) async {
    FirestoreCustomerBookingCreateRepository.validateDraft(
      draft,
      bookingSettings,
      anonymousGuestRequiresNickname: anonymousGuestRequiresNickname,
    );

    final draftPayload = _serializedDraft(
      draft,
      customerUiLanguageCode,
    );

    try {
      final callable = _functions.httpsCallable('createCustomerBooking');
      final response = await callable.call(<String, dynamic>{
        'salonId': salonId,
        'draft': draftPayload,
      });

      final raw = response.data;
      if (raw is! Map) {
        throw StateError('createCustomerBooking: invalid response.');
      }
      final data = Map<String, dynamic>.from(raw);
      final bookingId = '${data['bookingId'] ?? ''}'.trim();
      if (bookingId.isEmpty) {
        throw StateError('createCustomerBooking: missing bookingId.');
      }
      final sid = '${data['salonId'] ?? salonId}'.trim();
      final customerId = '${data['customerId'] ?? ''}'.trim();
      final bookingCode = '${data['bookingCode'] ?? ''}'.trim();
      final status = '${data['status'] ?? 'pending'}'.trim();
      final startMs = _parseMs(data['startAtMs']);
      final endMs = _parseMs(data['endAtMs']);

      final result = CustomerBookingCreateResult(
        bookingId: bookingId,
        salonId: sid,
        customerId: customerId,
        bookingCode: bookingCode,
        status: status,
        startAt: DateTime.fromMillisecondsSinceEpoch(startMs, isUtc: true),
        endAt: DateTime.fromMillisecondsSinceEpoch(endMs, isUtc: true),
      );

      await _writeGuestBookingMirrorIfNeeded(
        salonId: sid,
        draft: draft,
        result: result,
        customerUiLanguageCode: customerUiLanguageCode,
      );

      return result;
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'failed-precondition' &&
          '${e.message}'.contains('slot_unavailable')) {
        throw const SlotUnavailableException();
      }
      if (e.code == 'failed-precondition' &&
          '${e.message}'.toLowerCase().contains('online booking is disabled')) {
        throw const CustomerBookingValidationException('booking_disabled');
      }
      if (e.code == 'invalid-argument') {
        throw CustomerBookingValidationException(
          '${e.message}'.trim().isEmpty ? 'invalid_draft' : 'invalid_draft',
        );
      }
      rethrow;
    }
  }

  Map<String, dynamic> _serializedDraft(
    CustomerBookingDraft draft,
    String lang,
  ) {
    final start = draft.selectedStartAt!;
    final end = draft.selectedEndAt!;
    final services = draft.selectedServices
        .map(
          (s) => <String, dynamic>{
            'id': s.id,
            'serviceId': s.id,
            'displayTitle': s.localizedTitleForLanguageCode(lang),
            'name': s.displayTitle,
            'price': s.price,
            'durationMinutes': s.durationMinutes,
            'category': s.category,
          },
        )
        .toList(growable: false);

    return <String, dynamic>{
      'selectedServices': services,
      'selectedEmployeeId': draft.selectedEmployeeId!.trim(),
      'selectedEmployeeName': draft.selectedEmployeeName?.trim() ?? '',
      'selectedStartAt': start.millisecondsSinceEpoch,
      'selectedEndAt': end.millisecondsSinceEpoch,
      'customerName': draft.customerName?.trim() ?? '',
      'customerPhoneNormalized': draft.customerPhoneNormalized?.trim() ?? '',
      'customerPhone': draft.customerPhone?.trim() ?? '',
      'customerGender': draft.customerGender,
      'customerNote': draft.customerNote,
      'subtotal': draft.subtotal,
      'discountAmount': draft.discountAmount,
      'totalAmount': draft.totalAmount,
      'durationMinutes': draft.durationMinutes,
    };
  }

  Future<void> _writeGuestBookingMirrorIfNeeded({
    required String salonId,
    required CustomerBookingDraft draft,
    required CustomerBookingCreateResult result,
    required String customerUiLanguageCode,
  }) async {
    if (!draft.hasGuestNickname) {
      return;
    }
    final uid = _auth.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      return;
    }

    final publicSnap = await _firestore.doc(FirestorePaths.publicSalon(salonId)).get();
    final salonName =
        (publicSnap.data()?['name'] as String?)?.trim() ?? salonId;

    final services = draft.selectedServices
        .map(
          (service) => <String, dynamic>{
            'serviceId': service.id,
            'serviceName': service.localizedTitleForLanguageCode(
              customerUiLanguageCode,
            ),
            'price': service.price,
            'durationMinutes': service.durationMinutes,
            'category': service.category,
          },
        )
        .toList(growable: false);

    final now = FieldValue.serverTimestamp();
    await _firestore.doc(FirestorePaths.guestBooking(result.bookingCode)).set(
      <String, dynamic>{
        'bookingCode': result.bookingCode,
        'salonBookingId': result.bookingId,
        'authUid': uid,
        'accountType': 'guest',
        'nicknameKey': draft.guestNicknameKey,
        'guestDisplayName': draft.guestDisplayName,
        'salonId': salonId,
        'salonName': salonName,
        'barberId': draft.selectedEmployeeId!.trim(),
        'barberName': draft.selectedEmployeeName?.trim() ?? '',
        'serviceItems': services,
        'subtotal': draft.subtotal,
        'discountAmount': draft.discountAmount,
        'totalAmount': draft.totalAmount,
        'paymentMethod': 'unspecified',
        'paymentStatus': 'pending',
        'bookingStatus': result.status,
        'saleCreated': false,
        'saleId': null,
        'appointmentStartAt': Timestamp.fromDate(result.startAt.toUtc()),
        'appointmentEndAt': Timestamp.fromDate(result.endAt.toUtc()),
        'createdAt': now,
        'updatedAt': now,
      },
      SetOptions(merge: true),
    );
  }

  static int _parseMs(Object? v) {
    if (v is int) {
      return v;
    }
    if (v is num) {
      return v.toInt();
    }
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
