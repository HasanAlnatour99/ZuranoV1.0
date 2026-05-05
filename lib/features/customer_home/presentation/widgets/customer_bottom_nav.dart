import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart' show AppRoutes;
import '../../../../core/ui/app_icons.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/session/app_session_status.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import '../../../../shared/navigation/zurano_floating_bottom_nav.dart';

class CustomerBottomNav extends ConsumerWidget {
  const CustomerBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onIndexChanged,
  });

  final int currentIndex;
  final ValueChanged<int>? onIndexChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(appSessionBootstrapProvider);
    final signedInCustomer =
        session.status == AppSessionStatus.ready &&
        session.user?.role.trim() == UserRoles.customer;
    final profileRoute = signedInCustomer
        ? AppRoutes.settings
        : AppRoutes.customerAuth;

    void goToIndex(int index) {
      if (onIndexChanged != null) {
        onIndexChanged!(index);
        return;
      }
      if (index == 0) {
        context.go(AppRoutes.customerHome);
        return;
      }
      if (index == 1) {
        context.go(AppRoutes.customerMyBooking);
        return;
      }
      if (index == 2) {
        context.go(AppRoutes.customerSalonDiscovery);
        return;
      }
    }

    final slots = <ZuranoFloatingNavSlot>[
      ZuranoFloatingNavSlot(
        icon: AppIcons.home,
        selectedIcon: AppIcons.home,
        label: l10n.zuranoBottomNavHome,
        onTap: () => goToIndex(0),
      ),
      ZuranoFloatingNavSlot(
        icon: AppIcons.calendar_month_outlined,
        selectedIcon: AppIcons.calendar_month_rounded,
        label: l10n.zuranoBottomNavBookings,
        onTap: () => goToIndex(1),
      ),
      ZuranoFloatingNavSlot(
        icon: AppIcons.star_rounded,
        selectedIcon: AppIcons.star_rounded,
        label: l10n.zuranoBottomNavRewards,
        onTap: () => goToIndex(2),
      ),
      ZuranoFloatingNavSlot(
        icon: AppIcons.person_outline_rounded,
        selectedIcon: AppIcons.person_outline_rounded,
        label: l10n.zuranoBottomNavProfile,
        onTap: () => context.go(profileRoute),
      ),
    ];

    // The customer swipe shell only has 3 pages (0..2). Profile is a separate
    // route, so show "no selection" when it is opened.
    final selectedSlotIndex =
        currentIndex >= 0 && currentIndex <= 2 ? currentIndex : -1;

    return ZuranoFloatingBottomNav(
      slots: slots,
      selectedSlotIndex: selectedSlotIndex,
      showCenterGap: false,
    );
  }
}
