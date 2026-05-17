import 'package:barber_shop_app/core/firestore/firestore_paths.dart';
import 'package:barber_shop_app/features/customer/data/models/customer_booking_settings.dart';
import 'package:barber_shop_app/features/customer/data/models/customer_booking_draft.dart';
import 'package:barber_shop_app/features/customer/data/models/customer_service_public_model.dart';
import 'package:barber_shop_app/features/customer/data/repositories/callable_customer_booking_create_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class _MockHttpsCallable extends Mock implements HttpsCallable {}

class _MockHttpsCallableResult extends Mock
    implements HttpsCallableResult<dynamic> {}

class _MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(SetOptions(merge: true));
  });

  test('returns committed booking when guest mirror write fails', () async {
    final functions = _MockFirebaseFunctions();
    final callable = _MockHttpsCallable();
    final response = _MockHttpsCallableResult();
    final firestore = _MockFirebaseFirestore();
    final auth = _MockFirebaseAuth();
    final user = _MockUser();
    final publicSalonRef = _MockDocumentReference();
    final guestBookingRef = _MockDocumentReference();
    final publicSalonSnap = _MockDocumentSnapshot();

    final startAt = DateTime.utc(2026, 5, 18, 9);
    final endAt = startAt.add(const Duration(minutes: 30));

    when(() => functions.httpsCallable('createCustomerBooking'))
        .thenReturn(callable);
    when(() => callable.call(any())).thenAnswer((_) async => response);
    when(() => response.data).thenReturn(<String, dynamic>{
      'bookingId': 'booking-1',
      'salonId': 'salon-1',
      'customerId': 'customer-1',
      'bookingCode': 'ZR-123456',
      'status': 'confirmed',
      'startAtMs': startAt.millisecondsSinceEpoch,
      'endAtMs': endAt.millisecondsSinceEpoch,
    });

    when(() => auth.currentUser).thenReturn(user);
    when(() => user.isAnonymous).thenReturn(true);
    when(() => user.uid).thenReturn('guest-uid');

    when(() => firestore.doc(FirestorePaths.publicSalon('salon-1')))
        .thenReturn(publicSalonRef);
    when(() => firestore.doc(FirestorePaths.guestBooking('ZR-123456')))
        .thenReturn(guestBookingRef);
    when(() => publicSalonRef.get()).thenAnswer((_) async => publicSalonSnap);
    when(() => publicSalonSnap.data())
        .thenReturn(<String, dynamic>{'name': 'Zurano'});
    when(
      () => guestBookingRef.set(
        any<Map<String, dynamic>>(),
        any<SetOptions>(),
      ),
    )
        .thenThrow(StateError('permission denied'));

    final repository = CallableCustomerBookingCreateRepository(
      functions: functions,
      firestore: firestore,
      auth: auth,
    );

    final result = await repository.createBookingFromDraft(
      salonId: 'salon-1',
      draft: CustomerBookingDraft(
        salonId: 'salon-1',
        selectedServices: const [
          CustomerServicePublicModel(
            id: 'service-1',
            salonId: 'salon-1',
            name: 'Haircut',
            displayName: 'Haircut',
            category: 'hair',
            categoryLabel: 'Hair',
            price: 20,
            durationMinutes: 30,
            isActive: true,
            isCustomerVisible: true,
            sortOrder: 1,
          ),
        ],
        selectedEmployeeId: 'barber-1',
        selectedEmployeeName: 'Barber',
        selectedStartAt: startAt,
        selectedEndAt: endAt,
        clientRequestId: 'request-1',
        customerName: 'Guest',
        customerPhoneNormalized: '+97470001043',
        guestNicknameKey: 'guest-zr123',
        guestDisplayName: 'Guest-ZR123',
        subtotal: 20,
        totalAmount: 20,
        durationMinutes: 30,
      ),
      bookingSettings: const CustomerBookingSettings(),
      customerUiLanguageCode: 'en',
      anonymousGuestRequiresNickname: true,
    );

    expect(result.bookingId, 'booking-1');
    expect(result.bookingCode, 'ZR-123456');
    verify(
      () => guestBookingRef.set(
        any<Map<String, dynamic>>(),
        any<SetOptions>(),
      ),
    ).called(1);
  }, tags: ['critical']);
}
