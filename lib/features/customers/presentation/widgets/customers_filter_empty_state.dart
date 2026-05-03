import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';

class CustomersFilterEmptyState extends StatelessWidget {
  const CustomersFilterEmptyState({
    super.key,
    required this.onClearFilters,
  });

  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: ZuranoTokens.lightPurple,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.manage_search_rounded,
              color: ZuranoTokens.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.customersFilterEmptyTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ZuranoTokens.textDark,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.customersFilterEmptySubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: FinanceDashboardColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          FilledButton.tonal(
            onPressed: onClearFilters,
            child: Text(l10n.customersClearFilters),
          ),
        ],
      ),
    );
  }
}
