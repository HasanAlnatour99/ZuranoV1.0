import 'package:flutter/material.dart';

import '../../../../core/ui/app_icons.dart';
import '../../../../l10n/app_localizations.dart';

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

  static const Color _activePurple = Color(0xFF7B2CFF);
  static const Color _borderPurple = Color(0xFFD9C4FF);
  static const Color _navBg = Color(0xFFF7F8FC);

  static const double _stackHeight = 96;
  static const double _barHeight = 74;
  static const double _navBorderRadius = 30;
  static const double _outerRingSize = 62;
  static const double _fabSize = 56;
  static const double _ringTop = 18;
  static const double _fabTop = 22;
  static const double _fabIconSize = 42;
  static const String _fabIconAsset = 'assets/images/zurano_icon_nav.png';
  static const Offset _fabIconNudge = Offset(0, -2);
  static const double _centerGapWidth = 72;

  /// Extra bottom padding for scrollables above this bar.
  static double ownerShellScrollBottomPadding(BuildContext context) {
    final safe = MediaQuery.paddingOf(context).bottom;
    final barTopFromBottom = _barHeight;
    final fabTopFromBottom = _stackHeight - _fabTop;
    final protrusion = (fabTopFromBottom - barTopFromBottom).clamp(0.0, 100.0);
    return protrusion + 26 + safe;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget item({
      required int branchIndex,
      required IconData icon,
      required IconData selectedIcon,
      required String label,
    }) {
      return Expanded(
        child: _OwnerZuranoNavItem(
          icon: icon,
          selectedIcon: selectedIcon,
          label: label,
          isActive: selectedIndex == branchIndex,
          onTap: () => onDestinationSelected(branchIndex),
        ),
      );
    }

    final overview = item(
      branchIndex: 3,
      icon: AppIcons.dashboard_outlined,
      selectedIcon: AppIcons.dashboard,
      label: l10n.ownerTabOverview,
    );
    final team = item(
      branchIndex: 2,
      icon: AppIcons.groups_outlined,
      selectedIcon: AppIcons.groups,
      label: l10n.ownerTabTeam,
    );
    final customers = item(
      branchIndex: 1,
      icon: AppIcons.groups_2_outlined,
      selectedIcon: AppIcons.groups,
      label: l10n.ownerTabCustomers,
    );
    final finance = item(
      branchIndex: 0,
      icon: AppIcons.account_balance_wallet_outlined,
      selectedIcon: AppIcons.account_balance_wallet,
      label: l10n.ownerTabFinance,
    );

    return SafeArea(
      top: false,
      child: Padding(
        // Keep horizontal inset only; no extra bottom gap so the bar sits lower
        // (SafeArea still applies the system home-indicator inset).
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
        child: SizedBox(
          height: _stackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: _barHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: _navBg,
                    borderRadius: BorderRadius.circular(_navBorderRadius),
                    border: Border.all(
                      color: _borderPurple.withValues(alpha: 0.85),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: _activePurple.withValues(alpha: 0.08),
                        blurRadius: 22,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    clipBehavior: Clip.none,
                    child: Row(
                      children: [
                        overview,
                        team,
                        const SizedBox(width: _centerGapWidth),
                        customers,
                        finance,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _ringTop,
                left: 0,
                right: 0,
                child: Center(
                  child: IgnorePointer(
                    child: SizedBox(
                      width: _outerRingSize,
                      height: _outerRingSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _navBg.withValues(alpha: 0.88),
                          border: Border.all(
                            color: _borderPurple.withValues(alpha: 0.65),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _activePurple.withValues(alpha: 0.09),
                              blurRadius: 16,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _fabTop,
                left: 0,
                right: 0,
                child: Center(
                  child: Tooltip(
                    message: l10n.ownerOverviewFabSheetTitle,
                    child: Hero(
                      tag: 'owner_shell_center_fab',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onCenterTap,
                          child: SizedBox(
                            width: _fabSize,
                            height: _fabSize,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: _borderPurple.withValues(alpha: 0.82),
                                  width: 1.25,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _activePurple.withValues(alpha: 0.17),
                                    blurRadius: 18,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Center(
                                  child: Transform.translate(
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
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerZuranoNavItem extends StatelessWidget {
  const _OwnerZuranoNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  static const Color _activePurple = Color(0xFF7B2CFF);
  static const Color _softPurple = Color(0xFFE6DBFF);
  static const Color _inactiveDark = Color(0xFF2D2F39);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.none,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Align(
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isActive ? 12 : 6,
              vertical: isActive ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: isActive ? _softPurple : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: AnimatedScale(
              scale: isActive ? 1.02 : 1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? selectedIcon : icon,
                    size: isActive ? 22 : 21,
                    color: isActive ? _activePurple : _inactiveDark,
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isActive ? 12 : 11.5,
                          height: 1.05,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? _activePurple : _inactiveDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
