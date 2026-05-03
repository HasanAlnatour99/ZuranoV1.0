import 'package:barber_shop_app/features/customers/data/models/customer.dart';
import 'package:barber_shop_app/features/customers/logic/create_booking_controller.dart';
import 'package:barber_shop_app/features/customers/logic/create_customer_controller.dart';
import 'package:barber_shop_app/features/bookings/data/models/booking.dart';
import 'package:barber_shop_app/features/customers/logic/customer_providers.dart';
import 'package:barber_shop_app/features/customers/presentation/providers/customer_details_providers.dart';
import 'package:barber_shop_app/features/customers/presentation/screens/add_customer_screen.dart';
import 'package:barber_shop_app/features/customers/presentation/screens/create_booking_screen.dart';
import 'package:barber_shop_app/features/customers/presentation/screens/customer_details_screen.dart';
import 'package:barber_shop_app/features/sales/data/models/sale.dart';
import 'package:barber_shop_app/features/salon/data/models/salon.dart';
import 'package:barber_shop_app/features/users/data/models/app_user.dart';
import 'package:barber_shop_app/l10n/app_localizations.dart';
import 'package:barber_shop_app/providers/app_settings_providers.dart';
import 'package:barber_shop_app/providers/salon_streams_provider.dart';
import '../helpers/create_test_shared_preferences.dart';
import 'package:barber_shop_app/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCreateCustomerController extends Mock
    implements CreateCustomerController {}

class _MockCreateBookingController extends Mock
    implements CreateBookingController {}

class _FakeCreateCustomerInput extends Fake implements CreateCustomerInput {}

class _FakeCreateBookingInput extends Fake implements CreateBookingInput {}

AppUser _ownerUser() => AppUser(
  uid: 'u-1',
  name: 'Owner',
  email: 'owner@example.com',
  role: 'owner',
  salonId: 'salon-1',
);

MaterialApp _l10nMaterialApp({required Widget home}) => MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: home,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeCreateCustomerInput());
    registerFallbackValue(_FakeCreateBookingInput());
  });

  testWidgets('Add Customer form validation appears on empty submit', (
    tester,
  ) async {
    final prefs = await createTestSharedPreferences();
    final createCustomerController = _MockCreateCustomerController();
    when(
      () => createCustomerController.createCustomer(any()),
    ).thenAnswer((_) async => 'c-1');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          createCustomerControllerProvider.overrideWithValue(
            createCustomerController,
          ),
        ],
        child: _l10nMaterialApp(home: const AddCustomerScreen()),
      ),
    );

    await tester.tap(find.text('Save customer'));
    await tester.pumpAndSettle();

    expect(find.text('Full name is required'), findsOneWidget);
  });

  testWidgets('Create Booking form validation blocks incomplete submit', (
    tester,
  ) async {
    final prefs = await createTestSharedPreferences();
    final createBookingController = _MockCreateBookingController();
    when(
      () => createBookingController.createBooking(any()),
    ).thenAnswer((_) async => 'b-1');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          createBookingControllerProvider.overrideWithValue(
            createBookingController,
          ),
          servicesStreamProvider.overrideWith((ref) => const Stream.empty()),
          employeesStreamProvider.overrideWith((ref) => const Stream.empty()),
          customerSearchProvider.overrideWith(
            (ref, params) => Future.value(const <Customer>[]),
          ),
          sessionUserProvider.overrideWith((ref) => Stream.value(_ownerUser())),
        ],
        child: _l10nMaterialApp(home: const CreateBookingScreen()),
      ),
    );

    final context = tester.element(find.byType(CreateBookingScreen));
    final l10n = AppLocalizations.of(context)!;

    final saveBookingCta = find.text(l10n.createBookingSaveCta);
    await tester.scrollUntilVisible(
      saveBookingCta,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveBookingCta);
    await tester.pumpAndSettle();

    expect(find.text(l10n.createBookingValidationIncomplete), findsWidgets);
  });

  testWidgets('Customer Details shows book appointment CTA for owner', (
    tester,
  ) async {
    final prefs = await createTestSharedPreferences();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sessionUserProvider.overrideWith((ref) => Stream.value(_ownerUser())),
          customerDetailsProvider.overrideWith(
            (ref, args) => Stream.value(
              const Customer(
                id: 'c-1',
                salonId: 'salon-1',
                fullName: 'Ali Hassan',
                phone: '5550000',
                isActive: true,
                createdBy: 'u-1',
              ),
            ),
          ),
          bookingsStreamProvider.overrideWith((ref) => const Stream.empty()),
          customerDetailSalesProvider.overrideWith(
            (ref, id) => Stream.value(const <Sale>[]),
          ),
          customerDetailUpcomingBookingsProvider.overrideWith(
            (ref, id) => Stream.value(const <Booking>[]),
          ),
          sessionSalonStreamProvider.overrideWith(
            (ref) => Stream.value(
              Salon(
                id: 'salon-1',
                salonId: 'salon-1',
                name: 'Test',
                phone: '+1',
                address: 'a',
                ownerUid: 'u-1',
                ownerName: 'Owner',
                ownerEmail: 'o@e.com',
                currencyCode: 'SAR',
              ),
            ),
          ),
        ],
        child: _l10nMaterialApp(
          home: const CustomerDetailsScreen(customerId: 'c-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Book appointment'), findsWidgets);
  });
}
