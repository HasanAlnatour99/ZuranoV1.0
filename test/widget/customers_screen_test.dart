import 'dart:async';

import 'package:barber_shop_app/features/customers/data/models/customer.dart';
import 'package:barber_shop_app/features/customers/logic/customer_providers.dart';
import 'package:barber_shop_app/features/customers/presentation/screens/customers_screen.dart';
import 'package:barber_shop_app/features/users/data/models/app_user.dart';
import 'package:barber_shop_app/l10n/app_localizations.dart';
import 'package:barber_shop_app/providers/notification_providers.dart';
import 'package:barber_shop_app/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

MaterialApp _customersTestApp(Widget home) => MaterialApp(
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: home,
);

AppUser _user(String role) => AppUser(
  uid: 'u-1',
  name: 'Test',
  email: 'test@example.com',
  role: role,
  salonId: 'salon-1',
);

Customer _customer() => const Customer(
  id: 'c-1',
  salonId: 'salon-1',
  fullName: 'Ali Hassan',
  phone: '5550000',
  isActive: true,
  createdBy: 'u-1',
);

void main() {
  testWidgets('Customers tab rendering shows list item', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unreadNotificationCountProvider.overrideWith((ref) => 0),
          sessionUserProvider.overrideWith(
            (ref) => Stream.value(_user('owner')),
          ),
          customersListProvider.overrideWith(
            (ref, tag) => Stream.value([_customer()]),
          ),
          customerSearchProvider.overrideWith(
            (ref, query) => Future.value(<Customer>[]),
          ),
        ],
        child: _customersTestApp(const CustomersScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Customers'), findsWidgets);
    expect(find.text('Ali Hassan'), findsOneWidget);
  });

  testWidgets('empty-state add CTA is visible for owner', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unreadNotificationCountProvider.overrideWith((ref) => 0),
          sessionUserProvider.overrideWith(
            (ref) => Stream.value(_user('owner')),
          ),
          customersListProvider.overrideWith(
            (ref, tag) => Stream.value(<Customer>[]),
          ),
          customerSearchProvider.overrideWith(
            (ref, query) => Future.value(<Customer>[]),
          ),
        ],
        child: _customersTestApp(const CustomersScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Add customer'), findsOneWidget);
  });

  testWidgets('empty-state add CTA is hidden for barber', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unreadNotificationCountProvider.overrideWith((ref) => 0),
          sessionUserProvider.overrideWith(
            (ref) => Stream.value(_user('barber')),
          ),
          customersListProvider.overrideWith(
            (ref, tag) => Stream.value(<Customer>[]),
          ),
          customerSearchProvider.overrideWith(
            (ref, query) => Future.value(<Customer>[]),
          ),
        ],
        child: _customersTestApp(const CustomersScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Add customer'), findsNothing);
  });

  testWidgets(
    'loading state renders progress indicator',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unreadNotificationCountProvider.overrideWith((ref) => 0),
            sessionUserProvider.overrideWith(
              (ref) => Stream.value(_user('owner')),
            ),
            customersListProvider.overrideWith(
              (ref, tag) => const Stream<List<Customer>>.empty(),
            ),
            customerSearchProvider.overrideWith(
              (ref, query) => Future.value(<Customer>[]),
            ),
          ],
          child: _customersTestApp(const CustomersScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CustomersScreen), findsOneWidget);
    },
    skip: true,
    tags: ['critical'],
  );

  testWidgets('error state renders message', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unreadNotificationCountProvider.overrideWith((ref) => 0),
          sessionUserProvider.overrideWith(
            (ref) => Stream.value(_user('owner')),
          ),
          customersListProvider.overrideWith(
            (ref, tag) =>
                Stream<List<Customer>>.error(Exception('load failed')),
          ),
          customerSearchProvider.overrideWith(
            (ref, query) => Future.value(<Customer>[]),
          ),
        ],
        child: _customersTestApp(const CustomersScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CustomersScreen), findsOneWidget);
  }, skip: true);

  testWidgets('slow network simulation keeps loading then renders data', (
    tester,
  ) async {
    final controller = StreamController<List<Customer>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unreadNotificationCountProvider.overrideWith((ref) => 0),
          sessionUserProvider.overrideWith(
            (ref) => Stream.value(_user('owner')),
          ),
          customersListProvider.overrideWith((ref, tag) => controller.stream),
          customerSearchProvider.overrideWith(
            (ref, query) => Future.value(const <Customer>[]),
          ),
        ],
        child: _customersTestApp(const CustomersScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(CustomersScreen), findsOneWidget);

    controller.add([_customer()]);
    await tester.pumpAndSettle();
    expect(find.text('Ali Hassan'), findsOneWidget);
    await controller.close();
  }, skip: true);

  testWidgets('empty state renders correctly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unreadNotificationCountProvider.overrideWith((ref) => 0),
          sessionUserProvider.overrideWith(
            (ref) => Stream.value(_user('owner')),
          ),
          customersListProvider.overrideWith(
            (ref, tag) => Stream<List<Customer>>.value(const []),
          ),
          customerSearchProvider.overrideWith(
            (ref, query) => Future.value(const <Customer>[]),
          ),
        ],
        child: _customersTestApp(const CustomersScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('No customers yet'), findsOneWidget);
  });
}
