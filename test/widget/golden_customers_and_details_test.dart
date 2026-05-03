import 'package:barber_shop_app/features/customers/data/models/customer.dart';
import 'package:barber_shop_app/features/customers/logic/customer_providers.dart';
import 'package:barber_shop_app/features/bookings/data/models/booking.dart';
import 'package:barber_shop_app/features/customers/presentation/providers/customer_details_providers.dart';
import 'package:barber_shop_app/features/customers/presentation/screens/customer_details_screen.dart';
import 'package:barber_shop_app/features/sales/data/models/sale.dart';
import 'package:barber_shop_app/features/salon/data/models/salon.dart';
import 'package:barber_shop_app/features/customers/presentation/screens/customers_screen.dart';
import 'package:barber_shop_app/features/users/data/models/app_user.dart';
import 'package:barber_shop_app/l10n/app_localizations.dart';
import 'package:barber_shop_app/providers/app_settings_providers.dart';
import 'package:barber_shop_app/providers/notification_providers.dart';
import 'package:barber_shop_app/providers/salon_streams_provider.dart';
import 'package:barber_shop_app/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/create_test_shared_preferences.dart';

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

AppUser _owner() => AppUser(
  uid: 'u-1',
  name: 'Owner',
  email: 'owner@example.com',
  role: 'owner',
  salonId: 'salon-1',
);

void main() {
  testWidgets('golden - Customers screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unreadNotificationCountProvider.overrideWith((ref) => 0),
          sessionUserProvider.overrideWith((ref) => Stream.value(_owner())),
          customersListProvider.overrideWith(
            (ref, salonId) => Stream.value([
              const Customer(
                id: 'c-1',
                salonId: 'salon-1',
                fullName: 'Ali Hassan',
                phone: '5550000',
                isActive: true,
                createdBy: 'u-1',
              ),
            ]),
          ),
          customerSearchProvider.overrideWith(
            (ref, params) => Future.value(const <Customer>[]),
          ),
        ],
        child: _l10nMaterialApp(home: const CustomersScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CustomersScreen),
      matchesGoldenFile('goldens/customers_screen.png'),
    );
  }, tags: ['golden']);

  testWidgets('golden - Customer Details screen', (tester) async {
    final prefs = await createTestSharedPreferences();
    await tester.binding.setSurfaceSize(const Size(430, 932));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sessionUserProvider.overrideWith((ref) => Stream.value(_owner())),
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
    await expectLater(
      find.byType(CustomerDetailsScreen),
      matchesGoldenFile('goldens/customer_details_screen.png'),
    );
  }, tags: ['golden']);
}
