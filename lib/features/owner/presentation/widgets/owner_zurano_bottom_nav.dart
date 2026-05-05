import 'package:flutter/material.dart';

import '../../../../core/ui/app_icons.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/navigation/zurano_floating_bottom_nav.dart';

/// Premium floating owner bottom navigation (custom [Stack], not [BottomNavigationBar]).
///
/// Branch indices (unchanged): `0` Finance, `1` Customers, `2` Team, `3` Overview.
/// Visual order (LTR): Overview, Team, center, Customers, Finance.
class OwnerZuranoBottomNav extends StatelessWidget {
  const OwnerZuranoBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onCenterTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onCenterTap;

  static const double _fabIconSize = 42;
  static const String _fabIconAsset = 'assets/images/zurano_icon_nav.png';
  static const Offset _fabIconNudge = Offset(0, -2);

  /// Extra bottom padding for scrollables above this bar.
  static double ownerShellScrollBottomPadding(BuildContext context) {
    return ZuranoFloatingBottomNav.scrollBottomPadding(context);
  }

  /// Maps shell branch index to visual slot `0..3` (Overview → Finance).
  static int _selectedSlotForBranch(int branchIndex) {
    const order = <int>[3, 2, 1, 0];
    final i = order.indexOf(branchIndex);
    return i >= 0 ? i : 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedSlot = _selectedSlotForBranch(selectedIndex);

    void goBranch(int branchIndex) => onDestinationSelected(branchIndex);

    final slots = <ZuranoFloatingNavSlot>[
      ZuranoFloatingNavSlot(
        icon: AppIcons.dashboard_outlined,
        selectedIcon: AppIcons.dashboard,
        label: l10n.ownerTabOverview,
        onTap: () => goBranch(3),
      ),
      ZuranoFloatingNavSlot(
        icon: AppIcons.groups_outlined,
        selectedIcon: AppIcons.groups,
        label: l10n.ownerTabTeam,
        onTap: () => goBranch(2),
      ),
      ZuranoFloatingNavSlot(
        icon: AppIcons.groups_2_outlined,
        selectedIcon: AppIcons.groups,
        label: l10n.ownerTabCustomers,
        onTap: () => goBranch(1),
      ),
      ZuranoFloatingNavSlot(
        icon: AppIcons.account_balance_wallet_outlined,
        selectedIcon: AppIcons.account_balance_wallet,
        label: l10n.ownerTabFinance,
        onTap: () => goBranch(0),
      ),
    ];

    return ZuranoFloatingBottomNav(
      slots: slots,
      selectedSlotIndex: selectedSlot,
      centerTooltip: l10n.ownerOverviewFabSheetTitle,
      centerHeroTag: 'owner_shell_center_fab',
      onCenterTap: onCenterTap,
      centerChild: Transform.translate(
        offset: _fabIconNudge,
        child: Image.asset(
          _fabIconAsset,
          width: _fabIconSize,
          height: _fabIconSize,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
