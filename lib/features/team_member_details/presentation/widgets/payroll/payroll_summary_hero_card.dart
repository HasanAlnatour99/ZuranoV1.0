import 'package:flutter/material.dart';

import '../../../../../core/utils/money_formatter.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../payroll/domain/models/team_member_payroll_summary.dart';
import 'payroll_status_chip.dart';

class PayrollSummaryHeroCard extends StatelessWidget {
  const PayrollSummaryHeroCard({super.key, required this.summary});

  final TeamMemberPayrollSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final amountText = MoneyFormatter.format(
      context,
      summary.estimatedPayout,
      currencyCode: summary.currencyCode,
    );
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primaryContainer, scheme.tertiary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white),
              const Spacer(),
              PayrollStatusChip(status: summary.status, light: true),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.estimatedPayout,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amountText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
