import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'premium_finance_card.dart';

/// Tappable Finance-style promo tile used on the Money dashboard and Payroll hub.
class FinanceQuickActionTile extends StatelessWidget {
  const FinanceQuickActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.wide = false,
    this.stackedLayout = false,
    this.accent,
    this.accentSoft,
    this.zuranoPremiumUi = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool wide;

  /// When true (e.g. Payroll hub), icon sits above title/subtitle with wrapped text.
  final bool stackedLayout;
  final Color? accent;
  final Color? accentSoft;

  /// Use [ZuranoPremiumUiColors] for typography and card chrome (Payroll hub).
  final bool zuranoPremiumUi;

  @override
  Widget build(BuildContext context) {
    final primary = accent ??
        (zuranoPremiumUi
            ? ZuranoPremiumUiColors.primaryPurple
            : FinanceDashboardColors.primaryPurple);
    final soft = accentSoft ??
        (zuranoPremiumUi
            ? ZuranoPremiumUiColors.softPurple
            : FinanceDashboardColors.lightPurple);
    final iconBox = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: soft.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: primary, size: 24),
    );

    final titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: zuranoPremiumUi
          ? ZuranoPremiumUiColors.textPrimary
          : FinanceDashboardColors.textPrimary,
    );
    final subtitleStyle = TextStyle(
      fontSize: 12,
      height: 1.35,
      fontWeight: FontWeight.w500,
      color: zuranoPremiumUi
          ? ZuranoPremiumUiColors.textSecondary
          : FinanceDashboardColors.textSecondary,
    );

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: stackedLayout ? 4 : 1,
          overflow: TextOverflow.ellipsis,
          softWrap: stackedLayout,
          style: titleStyle,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          maxLines: stackedLayout ? 6 : (wide ? 2 : 3),
          overflow: TextOverflow.ellipsis,
          softWrap: stackedLayout,
          style: subtitleStyle,
        ),
      ],
    );

    final content = stackedLayout
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iconBox,
              const SizedBox(height: 12),
              textColumn,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconBox,
              const SizedBox(width: 14),
              Expanded(child: textColumn),
              if (wide) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: (zuranoPremiumUi
                          ? ZuranoPremiumUiColors.textSecondary
                          : FinanceDashboardColors.textSecondary)
                      .withValues(alpha: 0.7),
                ),
              ],
            ],
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: PremiumFinanceCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          zuranoPremiumStyle: zuranoPremiumUi,
          child: content,
        ),
      ),
    );
  }
}
