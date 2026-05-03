import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../payroll/domain/models/team_member_payroll_summary.dart';
import 'payroll_breakdown_row.dart';

class PayrollBreakdownCard extends StatelessWidget {
  const PayrollBreakdownCard({
    super.key,
    required this.summary,
    required this.onDeleteBonusElement,
    required this.onDeleteDeductionElement,
    this.onEditBonusElement,
    this.onEditDeductionElement,
  });

  final TeamMemberPayrollSummary summary;
  final ValueChanged<String> onDeleteBonusElement;
  final ValueChanged<String> onDeleteDeductionElement;
  final ValueChanged<PayrollNamedAmount>? onEditBonusElement;
  final ValueChanged<PayrollNamedAmount>? onEditDeductionElement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.earningsBreakdown,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          PayrollBreakdownRow(
            icon: Icons.design_services_rounded,
            label: l10n.servicesRevenue,
            amount: summary.monthServicesRevenue,
            currencyCode: summary.currencyCode,
          ),
          PayrollBreakdownRow(
            icon: Icons.calendar_month_rounded,
            label: l10n.commission,
            amount: summary.commissionPercentPortionForDisplay,
            currencyCode: summary.currencyCode,
          ),
          if (summary.commissionFixedAmount > 0)
            PayrollBreakdownRow(
              icon: Icons.subdirectory_arrow_right_rounded,
              label: l10n.fixedCommissionAmount,
              amount: summary.commissionFixedAmount,
              currencyCode: summary.currencyCode,
            ),
          for (final bonus in summary.bonusItems)
            PayrollBreakdownRow(
              icon: Icons.subdirectory_arrow_right_rounded,
              label: bonus.name,
              amount: bonus.amount,
              currencyCode: summary.currencyCode,
              onEdit: onEditBonusElement == null
                  ? null
                  : () => onEditBonusElement!(bonus),
              onDelete: () => onDeleteBonusElement(bonus.name),
            ),
          for (final deduction in summary.deductionItems)
            PayrollBreakdownRow(
              icon: Icons.subdirectory_arrow_right_rounded,
              label: deduction.name,
              amount: deduction.amount,
              currencyCode: summary.currencyCode,
              isDeduction: true,
              onEdit: onEditDeductionElement == null
                  ? null
                  : () => onEditDeductionElement!(deduction),
              onDelete: () => onDeleteDeductionElement(deduction.name),
            ),
          PayrollBreakdownRow(
            icon: Icons.account_balance_wallet_rounded,
            label: l10n.estimatedPayout,
            amount: summary.estimatedPayout,
            currencyCode: summary.currencyCode,
            highlighted: true,
          ),
        ],
      ),
    );
  }
}
