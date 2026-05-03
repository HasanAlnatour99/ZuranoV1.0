import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../shared/navigation/zurano_swipe_shell.dart';
import '../../../customer/presentation/screens/my_booking_lookup_screen.dart';
import '../../../customer/presentation/screens/salon_discovery_screen.dart';
import '../widgets/customer_bottom_nav.dart';
import 'customer_home_screen.dart';

class CustomerMainSwipeShellScreen extends StatelessWidget {
  const CustomerMainSwipeShellScreen({super.key, required this.currentPath});

  final String currentPath;

  static const List<String> _tabPaths = <String>[
    AppRoutes.customerHome,
    AppRoutes.customerMyBooking,
    AppRoutes.customerSalonDiscovery,
  ];

  int get _currentIndex {
    if (currentPath == AppRoutes.customerMyBooking) {
      return 1;
    }
    if (currentPath == AppRoutes.customerSalonDiscovery) {
      return 2;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    void goToIndex(int index) {
      if (index >= _tabPaths.length) {
        return;
      }
      final target = _tabPaths[index];
      if (target == currentPath) {
        return;
      }
      context.go(target);
    }

    return ZuranoSwipeShell(
      pages: const <Widget>[
        ZuranoCustomerHomeScreen(showBottomNav: false),
        MyBookingLookupScreen(),
        SalonDiscoveryScreen(showBottomNavigationBar: false),
      ],
      currentIndex: _currentIndex,
      onIndexChanged: goToIndex,
      bottomNavigationBar: CustomerBottomNav(
        currentIndex: _currentIndex,
        onIndexChanged: goToIndex,
      ),
    );
  }
}
