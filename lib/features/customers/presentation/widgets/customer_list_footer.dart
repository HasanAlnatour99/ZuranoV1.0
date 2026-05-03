import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Encourages growing the list when the directory is still small.
class CustomerListFooter extends StatelessWidget {
  const CustomerListFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: FinanceDashboardColors.lightPurple.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: FinanceDashboardColors.primaryPurple.withValues(alpha: 0.16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.customersListFooterTitle,
              style: const TextStyle(
                color: FinanceDashboardColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.customersListFooterSubtitle,
              style: const TextStyle(
                color: FinanceDashboardColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
