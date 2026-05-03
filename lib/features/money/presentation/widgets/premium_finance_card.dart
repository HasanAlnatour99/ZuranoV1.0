import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PremiumFinanceCard extends StatelessWidget {
  const PremiumFinanceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.zuranoPremiumStyle = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// When true, matches [ZuranoCard] (Settings / Team premium) instead of Money hub chrome.
  final bool zuranoPremiumStyle;

  @override
  Widget build(BuildContext context) {
    if (zuranoPremiumStyle) {
      return Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: ZuranoPremiumUiColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: ZuranoPremiumUiColors.border.withValues(alpha: 0.7),
          ),
          boxShadow: [
            BoxShadow(
              color: ZuranoPremiumUiColors.primaryPurple.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: child,
      );
    }

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: FinanceDashboardColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FinanceDashboardColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
