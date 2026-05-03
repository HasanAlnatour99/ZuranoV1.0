import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/text/personalized_greeting.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_notification_badge.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/notification_providers.dart';
import '../../../users/data/models/app_user.dart';

/// Full-bleed gradient header for standalone [CustomersScreen] (not embedded in owner shell).
class CustomersPremiumHeader extends ConsumerWidget {
  const CustomersPremiumHeader({
    super.key,
    required this.user,
    required this.salonName,
    this.leading,
  });

  final AppUser user;
  final String salonName;

  /// Optional back / menu control (e.g. standalone route without [AppPageHeader]).
  final Widget? leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final greeting = getGreeting(l10n);
    final displayName = user.name.trim().toUpperCaseFirst();
    final unread = ref.watch(unreadNotificationCountProvider);
    final lead = leading;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 14,
        20,
        22,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FinanceDashboardColors.deepPurple,
            FinanceDashboardColors.headerGradientMid,
            FinanceDashboardColors.headerGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (lead != null) ...[
                lead,
                const SizedBox(width: 6),
              ],
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                child: Text(
                  _initials(user.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.customersHeroGreeting(greeting, displayName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            salonName.trim().isEmpty
                                ? l10n.customersScreenTitle
                                : salonName.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _HeaderIconButton(
                icon: Icons.auto_awesome_rounded,
                onTap: () => context.push(AppRoutes.ownerDashboardAssistant),
                filledWhite: true,
              ),
              const SizedBox(width: 10),
              _HeaderIconButton(
                icon: Icons.notifications_none_rounded,
                onTap: () => context.push(AppRoutes.notifications),
                filledWhite: false,
                badge: unread,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(AppRoutes.ownerBentoDashboard),
              borderRadius: BorderRadius.circular(26),
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.manage_search_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.customersGlobalSearchHint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || name.trim().isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
    }
    final a = parts.first.isNotEmpty ? parts.first[0] : '';
    final b = parts.last.isNotEmpty ? parts.last[0] : '';
    return ('$a$b').toUpperCase();
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    required this.filledWhite,
    this.badge = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filledWhite;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final child = Icon(
      icon,
      color: filledWhite ? FinanceDashboardColors.primaryPurple : Colors.white,
    );
    return Material(
      color: filledWhite ? Colors.white : Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: badge > 0 && !filledWhite
              ? Center(
                  child: AppNotificationBadge(count: badge, child: child),
                )
              : Center(child: child),
        ),
      ),
    );
  }
}
