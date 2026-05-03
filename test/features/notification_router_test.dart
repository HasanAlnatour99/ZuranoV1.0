import 'package:barber_shop_app/core/constants/app_routes.dart';
import 'package:barber_shop_app/core/constants/user_roles.dart';
import 'package:barber_shop_app/features/notifications/logic/notification_router.dart';
import 'package:barber_shop_app/features/users/data/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('navigateForNotificationPayload routes booking to owner dashboard', () {
    final router = GoRouter(
      initialLocation: AppRoutes.ownerDashboard,
      routes: [
        GoRoute(
          path: AppRoutes.ownerDashboard,
          builder: (_, _) => const Scaffold(body: SizedBox.shrink()),
        ),
      ],
    );
    navigateForNotificationPayload(
      router: router,
      data: {'route': 'booking', 'salonId': 's1', 'bookingId': 'b1'},
      session: const AppUser(
        uid: 'u',
        name: 'n',
        email: 'e',
        role: UserRoles.owner,
      ),
    );
    expect(
      router.routeInformationProvider.value.uri.path,
      AppRoutes.ownerOverview,
    );
  });
}
