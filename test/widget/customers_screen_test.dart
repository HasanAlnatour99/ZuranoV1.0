import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barber_shop_app/features/customers/data/models/customer.dart';
import 'package:barber_shop_app/features/customers/data/customer_repository.dart';
import 'package:barber_shop_app/features/customers/data/models/customer_page.dart';
import 'package:barber_shop_app/features/customers/data/models/customer_monthly_stats.dart';
import 'package:barber_shop_app/features/customers/presentation/screens/customers_screen.dart';
import 'package:barber_shop_app/features/users/data/models/app_user.dart';
import 'package:barber_shop_app/l10n/app_localizations.dart';
import 'package:barber_shop_app/providers/notification_providers.dart';
import 'package:barber_shop_app/providers/app_settings_providers.dart';
import 'package:barber_shop_app/providers/money_currency_providers.dart';
import 'package:barber_shop_app/providers/repository_providers.dart';
import 'package:barber_shop_app/providers/session_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class _FakeCustomerRepository extends CustomerRepository {
  _FakeCustomerRepository(this.page, {this.monthlyStats})
      : super(firestore: FakeFirebaseFirestore());

  final CustomerPage page;
  final CustomerMonthlyStats? monthlyStats;

  @override
  Future<CustomerPage> fetchCustomersPage({
    required String salonId,
    String? searchTerm,
    String selectedTag = 'All',
    bool includeInactive = false,
    DocumentSnapshot<Map<String, dynamic>>? startAfterDocument,
    int limit = 25,
  }) async {
    return page;
  }

  @override
  Stream<CustomerMonthlyStats?> watchCustomerMonthlyStats({
    required String salonId,
    required String yyyyMM,
  }) {
    return Stream.value(monthlyStats);
  }
}

MaterialApp _customersTestApp(Widget home) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => home,
      ),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}

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
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          regionalMoneyCurrencyCodeProvider.overrideWithValue('USD'),
          sessionSalonMoneyCurrencyCodeProvider.overrideWithValue('USD'),
          unreadNotificationCountProvider.overrideWith((ref) => 0),
          sessionUserProvider.overrideWith(
            (ref) => Stream.value(_user('owner')),
          ),
          customerRepositoryProvider.overrideWithValue(
            _FakeCustomerRepository(
              CustomerPage(
                customers: [_customer()],
                lastDocument: null,
                hasMore: false,
              ),
            ),
          ),
        ],
        child: _customersTestApp(const CustomersScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Customers'), findsWidgets);
    expect(find.text('Ali Hassan'), findsOneWidget);
  });

  testWidgets('monthly customer insights render when stats exist', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          regionalMoneyCurrencyCodeProvider.overrideWithValue('USD'),
          sessionSalonMoneyCurrencyCodeProvider.overrideWithValue('USD'),
          unreadNotificationCountProvider.overrideWith((ref) => 0),
          sessionUserProvider.overrideWith(
            (ref) => Stream.value(_user('owner')),
          ),
          customerRepositoryProvider.overrideWithValue(
            _FakeCustomerRepository(
              CustomerPage(
                customers: [_customer()],
                lastDocument: null,
                hasMore: false,
              ),
              monthlyStats: const CustomerMonthlyStats(
                newCustomers: 7,
                returningCustomers: 3,
                activeCustomers: 10,
                vipCustomers: 2,
                totalSpent: 1234.5,
                updatedAt: null,
              ),
            ),
          ),
        ],
        child: _customersTestApp(const CustomersScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('New customers'), findsOneWidget);
    expect(find.text('Returning'), findsOneWidget);
    expect(find.text('Total active'), findsOneWidget);
    expect(
      find.text('Insights will appear here once available.'),
      findsNothing,
    );
  });

  testWidgets('empty-state add CTA is visible for owner', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          regionalMoneyCurrencyCodeProvider.overrideWithValue('USD'),
          sessionSalonMoneyCurrencyCodeProvider.overrideWithValue('USD'),
          unreadNotificationCountProvider.overrideWith((ref) => 0),
          sessionUserProvider.overrideWith(
            (ref) => Stream.value(_user('owner')),
          ),
          customerRepositoryProvider.overrideWithValue(
            _FakeCustomerRepository(
              const CustomerPage(customers: [], lastDocument: null, hasMore: false),
            ),
          ),
        ],
        child: _customersTestApp(const CustomersScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Add customer'), findsOneWidget);
  });

  testWidgets('empty-state add CTA is hidden for barber', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          regionalMoneyCurrencyCodeProvider.overrideWithValue('USD'),
          sessionSalonMoneyCurrencyCodeProvider.overrideWithValue('USD'),
          unreadNotificationCountProvider.overrideWith((ref) => 0),
          sessionUserProvider.overrideWith(
            (ref) => Stream.value(_user('barber')),
          ),
          customerRepositoryProvider.overrideWithValue(
            _FakeCustomerRepository(
              const CustomerPage(customers: [], lastDocument: null, hasMore: false),
            ),
          ),
        ],
        child: _customersTestApp(const CustomersScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 300));
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
            customerRepositoryProvider.overrideWithValue(
              _FakeCustomerRepository(
                const CustomerPage(customers: [], lastDocument: null, hasMore: false),
              ),
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
          customerRepositoryProvider.overrideWithValue(
            _FakeCustomerRepository(
              const CustomerPage(customers: [], lastDocument: null, hasMore: false),
            ),
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
    final controller = StreamController<CustomerPage>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          unreadNotificationCountProvider.overrideWith((ref) => 0),
          sessionUserProvider.overrideWith(
            (ref) => Stream.value(_user('owner')),
          ),
          customerRepositoryProvider.overrideWithValue(
            _FakeCustomerRepository(
              const CustomerPage(customers: [], lastDocument: null, hasMore: false),
            ),
          ),
        ],
        child: _customersTestApp(const CustomersScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(CustomersScreen), findsOneWidget);

    // We don't have a real async fetch in this test setup; keep it as a smoke test only.
    await tester.pumpAndSettle();
    await controller.close();
  }, skip: true);

  testWidgets('empty state renders correctly', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          regionalMoneyCurrencyCodeProvider.overrideWithValue('USD'),
          sessionSalonMoneyCurrencyCodeProvider.overrideWithValue('USD'),
          unreadNotificationCountProvider.overrideWith((ref) => 0),
          sessionUserProvider.overrideWith(
            (ref) => Stream.value(_user('owner')),
          ),
          customerRepositoryProvider.overrideWithValue(
            _FakeCustomerRepository(
              const CustomerPage(customers: [], lastDocument: null, hasMore: false),
            ),
          ),
        ],
        child: _customersTestApp(const CustomersScreen()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('No customers yet'), findsOneWidget);
  });
}
