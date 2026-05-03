import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart' show AppRoutes;
import '../../../../core/constants/user_roles.dart';
import '../../../../core/session/app_session_status.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import '../../../../shared/widgets/nav_bar_top_notch_clipper.dart';
import '../../../../shared/widgets/zurano_center_fab.dart';
import '../theme/zurano_customer_colors.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final session = ref.watch(appSessionBootstrapProvider);
    final signedInCustomer =
        session.status == AppSessionStatus.ready &&
        session.user?.role.trim() == UserRoles.customer;
    final profileRoute = signedInCustomer
        ? AppRoutes.settings
        : AppRoutes.customerAuth;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final barH = 60.0 + bottomInset;
    const fabDownInset = 6.0;

    return SizedBox(
      height: 78 + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: ClipPath(
                clipper: NavBarTopNotchClipper(
                  notchHalfWidth: ZuranoCenterFab.outerRadius,
                  scoopDepth: ZuranoCenterFab.outerRadius * 0.92,
                  topCornerRadius: 20,
                ),
                child: Container(
                  height: barH,
                  padding: EdgeInsets.only(bottom: bottomInset),
                  color: scheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavChip(
                          selected: currentIndex == 0,
                          icon: Icons.home_rounded,
                          label: l10n.zuranoBottomNavHome,
                          onTap: () {
                            if (onIndexChanged != null) {
                              onIndexChanged!(0);
                              return;
                            }
                            context.go(AppRoutes.customerHome);
                          },
                        ),
                        _NavChip(
                          selected: currentIndex == 1,
                          icon: Icons.calendar_month_rounded,
                          label: l10n.zuranoBottomNavBookings,
                          onTap: () {
                            if (onIndexChanged != null) {
                              onIndexChanged!(1);
                              return;
                            }
                            context.go(AppRoutes.customerMyBooking);
                          },
                        ),
                        SizedBox(width: ZuranoCenterFab.outerSize + 8),
                        _NavChip(
                          selected: currentIndex == 2,
                          icon: Icons.card_giftcard_rounded,
                          label: l10n.zuranoBottomNavRewards,
                          onTap: () {
                            if (onIndexChanged != null) {
                              onIndexChanged!(2);
                              return;
                            }
                            context.go(AppRoutes.customerSalonDiscovery);
                          },
                        ),
                        _NavChip(
                          selected: currentIndex == 3,
                          icon: Icons.person_rounded,
                          label: l10n.zuranoBottomNavProfile,
                          onTap: () => context.go(profileRoute),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom:
                barH - ZuranoCenterFab.outerSize / 2 - fabDownInset,
            child: Center(
              child: SizedBox(
                width: ZuranoCenterFab.outerSize,
                height: ZuranoCenterFab.outerSize,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: ZuranoCenterFab.whiteBorderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ZuranoCustomerColors.primary.withValues(
                          alpha: 0.45,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ClipOval(
                    child: Material(
                      color: ZuranoCustomerColors.primary,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          if (onIndexChanged != null) {
                            onIndexChanged!(2);
                            return;
                          }
                          context.go(AppRoutes.customerSalonDiscovery);
                        },
                        child: const SizedBox.expand(
                          child: Center(
                            child: Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 27,
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
    );
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? ZuranoCustomerColors.primary
        : ZuranoCustomerColors.textMuted;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(height: 2),
            Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
