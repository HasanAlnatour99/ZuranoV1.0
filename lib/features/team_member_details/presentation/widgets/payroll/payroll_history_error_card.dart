import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class PayrollHistoryErrorCard extends StatelessWidget {
  const PayrollHistoryErrorCard({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ZuranoPremiumUiColors.dangerSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: ZuranoPremiumUiColors.danger,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.payrollHistoryLoadFailed,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: ZuranoPremiumUiColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(
                    foregroundColor: ZuranoPremiumUiColors.primaryPurple,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: AlignmentDirectional.centerStart,
                  ),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
