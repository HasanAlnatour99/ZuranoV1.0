import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../theme/zurano_customer_home_design_tokens.dart';

/// Three-column quick actions opening search with pre-applied quick filters.
class ZuranoQuickFilterStrip extends StatelessWidget {
  const ZuranoQuickFilterStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    void go(String quickFilter) {
      HapticFeedback.selectionClick();
      context.push(
        AppRoutes.customerSearchUri(quickFilter: quickFilter),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: _QuickFilterCell(
                  icon: Icons.near_me_rounded,
                  title: l10n.zuranoQuickFilterNearbyTitle,
                  subtitle: l10n.zuranoQuickFilterNearbySubtitle,
                  onTap: () => go('nearby'),
                ),
              ),
              SizedBox(
                height: 46,
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: ZuranoCustomerHomeColors.lavender,
                ),
              ),
              Expanded(
                child: _QuickFilterCell(
                  icon: Icons.schedule_rounded,
                  title: l10n.zuranoQuickFilterOpenNowTitle,
                  subtitle: l10n.zuranoQuickFilterOpenNowSubtitle,
                  onTap: () => go('openNow'),
                ),
              ),
              SizedBox(
                height: 46,
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: ZuranoCustomerHomeColors.lavender,
                ),
              ),
              Expanded(
                child: _QuickFilterCell(
                  icon: Icons.event_available_rounded,
                  title: l10n.zuranoQuickFilterAvailableTodayTitle,
                  subtitle: l10n.zuranoQuickFilterAvailableTodaySubtitle,
                  onTap: () => go('availableToday'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickFilterCell extends StatelessWidget {
  const _QuickFilterCell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: ZuranoCustomerHomeColors.lavender,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 18,
                color: ZuranoCustomerHomeColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: ZuranoCustomerHomeColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ZuranoCustomerHomeColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
