import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Title row: screen title, localized count badge, optional filter affordance.
class CustomersHeader extends StatelessWidget {
  const CustomersHeader({
    super.key,
    required this.count,
    required this.onFilterTap,
  });

  final int count;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.customersScreenTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: FinanceDashboardColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: FinanceDashboardColors.lightPurple,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.customersCountBadge(count),
                  style: const TextStyle(
                    color: FinanceDashboardColors.primaryPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          style: IconButton.styleFrom(
            backgroundColor: FinanceDashboardColors.surface,
            foregroundColor: FinanceDashboardColors.primaryPurple,
            side: BorderSide(
              color: FinanceDashboardColors.primaryPurple.withValues(
                alpha: 0.18,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          onPressed: onFilterTap,
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    );
  }
}
