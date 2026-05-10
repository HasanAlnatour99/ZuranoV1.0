import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/session/app_session_status.dart';
import '../../../../providers/session_provider.dart';
import '../../../../shared/navigation/zurano_swipe_shell.dart';
import '../../../customer/presentation/screens/find_booking_screen.dart';
import '../../../customer/presentation/screens/salon_discovery_screen.dart';
import '../widgets/zurano_customer_bottom_nav.dart';
import 'customer_home_screen.dart';

class CustomerMainSwipeShellScreen extends ConsumerWidget {
  const CustomerMainSwipeShellScreen({super.key, required this.currentPath});

  final String currentPath;

  static const List<String> _tabPaths = <String>[
    AppRoutes.customerHome,
    AppRoutes.customerMyBooking,
    AppRoutes.customerSalonDiscovery,
  ];

  int get _shellTabIndex {
    if (currentPath.startsWith(AppRoutes.customerMyBooking)) {
      return 1;
    }
    if (currentPath.startsWith(AppRoutes.customerSalonDiscovery)) {
      return 2;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appSessionBootstrapProvider);
    final signedInCustomer =
        session.status == AppSessionStatus.ready &&
        session.user?.role.trim() == UserRoles.customer;
    final profileRoute =
        signedInCustomer ? AppRoutes.settings : AppRoutes.customerAuth;

    void goToIndex(int index) {
      if (index == 3) {
        context.go(profileRoute);
        return;
      }
      if (index >= _tabPaths.length) {
        return;
      }
      final target = _tabPaths[index];
      if (target == AppRoutes.customerHome &&
          currentPath.startsWith(AppRoutes.customerHome)) {
        return;
      }
      if (target == AppRoutes.customerMyBooking &&
          currentPath.startsWith(AppRoutes.customerMyBooking)) {
        return;
      }
      if (target == AppRoutes.customerSalonDiscovery &&
          currentPath.startsWith(AppRoutes.customerSalonDiscovery)) {
        return;
      }
      context.go(target);
    }

    return ZuranoSwipeShell(
      pages: const <Widget>[
        ZuranoCustomerHomeScreen(showBottomNav: false),
        FindBookingScreen(),
        SalonDiscoveryScreen(showBottomNavigationBar: false),
      ],
      currentIndex: _shellTabIndex,
      onIndexChanged: goToIndex,
      bottomNavigationBar: ZuranoCustomerBottomNav(
        currentIndex: _shellTabIndex,
        onIndexChanged: goToIndex,
      ),
    );
  }
}
