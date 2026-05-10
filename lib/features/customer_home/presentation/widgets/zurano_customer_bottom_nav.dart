import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/session/app_session_status.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import '../theme/zurano_customer_home_design_tokens.dart';

/// Four-destination Material navigation bar (no center FAB / notch).
class ZuranoCustomerBottomNav extends ConsumerWidget {
  const ZuranoCustomerBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onIndexChanged,
  });

  /// Active tab for shell routes (0 home, 1 bookings, 2 rewards browse).
  final int currentIndex;

  /// When null, uses default `go_router` destinations (home shell).
  final ValueChanged<int>? onIndexChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(appSessionBootstrapProvider);
    final signedInCustomer =
        session.status == AppSessionStatus.ready &&
        session.user?.role.trim() == UserRoles.customer;
    final profileRoute =
        signedInCustomer ? AppRoutes.settings : AppRoutes.customerAuth;

    void goToIndex(int index) {
      if (onIndexChanged != null) {
        onIndexChanged!(index);
        return;
      }
      if (index == 0) {
        context.go(AppRoutes.customerHome);
      } else if (index == 1) {
        context.go(AppRoutes.customerMyBooking);
      } else if (index == 2) {
        context.go(AppRoutes.customerSalonDiscovery);
      } else if (index == 3) {
        context.go(profileRoute);
      }
    }

    final safeIndex = currentIndex < 0 ? 0 : (currentIndex > 3 ? 3 : currentIndex);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: ZuranoCustomerHomeColors.lavender,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected
                  ? ZuranoCustomerHomeColors.primary
                  : ZuranoCustomerHomeColors.mutedText,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected
                  ? ZuranoCustomerHomeColors.primary
                  : ZuranoCustomerHomeColors.mutedText,
              size: 24,
            );
          }),
        ),
        child: NavigationBar(
          height: 68,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          elevation: 8,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          selectedIndex: safeIndex,
          onDestinationSelected: goToIndex,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.zuranoBottomNavHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month_rounded),
              label: l10n.zuranoBottomNavBookings,
            ),
            NavigationDestination(
              icon: const Icon(Icons.star_border_rounded),
              selectedIcon: const Icon(Icons.star_rounded),
              label: l10n.zuranoBottomNavRewards,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: l10n.zuranoBottomNavProfile,
            ),
          ],
        ),
      ),
    );
  }
}
