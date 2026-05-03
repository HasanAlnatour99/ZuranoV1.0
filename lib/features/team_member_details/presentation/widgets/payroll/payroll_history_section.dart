import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../payroll/domain/models/payroll_record.dart';
import 'payroll_empty_state.dart';
import 'payroll_history_tile.dart';

class PayrollHistorySection extends StatelessWidget {
  const PayrollHistorySection({
    super.key,
    required this.records,
    required this.currencyCode,
    required this.onGenerateFirstPayslip,
  });

  final List<PayrollRecord> records;
  final String currencyCode;
  final VoidCallback? onGenerateFirstPayslip;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ZuranoPremiumUiColors.softPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: ZuranoPremiumUiColors.primaryPurple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.payrollHistory,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: -0.2,
                    color: ZuranoPremiumUiColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (records.isEmpty)
            PayrollEmptyState(
              onGenerateFirstPayslip: onGenerateFirstPayslip,
              titleStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: ZuranoPremiumUiColors.textPrimary,
              ),
              subtitleStyle: const TextStyle(
                fontSize: 14,
                height: 1.35,
                color: ZuranoPremiumUiColors.textSecondary,
              ),
            )
          else
            for (var i = 0; i < records.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: ZuranoPremiumUiColors.border.withValues(alpha: 0.55),
                ),
              PayrollHistoryTile(
                record: records[i],
                currencyCode: currencyCode,
              ),
            ],
        ],
      ),
    );
  }
}
