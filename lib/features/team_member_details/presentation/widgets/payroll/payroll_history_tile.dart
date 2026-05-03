import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/money_formatter.dart';
import '../../../../payroll/domain/models/payroll_record.dart';
import 'payroll_status_chip.dart';

class PayrollHistoryTile extends StatelessWidget {
  const PayrollHistoryTile({
    super.key,
    required this.record,
    required this.currencyCode,
  });

  final PayrollRecord record;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final amount = MoneyFormatter.format(
      context,
      record.netPayout,
      currencyCode: currencyCode,
    );
    final generated = record.generatedAt == null
        ? '-'
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toString(),
          ).format(record.generatedAt!);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.monthKey,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.1,
                    color: ZuranoPremiumUiColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  generated,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.25,
                    color: ZuranoPremiumUiColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: -0.2,
                  color: FinanceDashboardColors.greenProfit,
                ),
              ),
              const SizedBox(height: 6),
              PayrollStatusChip(status: record.status),
            ],
          ),
        ],
      ),
    );
  }
}
