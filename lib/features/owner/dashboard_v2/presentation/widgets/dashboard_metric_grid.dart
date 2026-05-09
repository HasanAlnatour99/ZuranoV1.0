import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class DashboardMetricGrid extends StatelessWidget {
  const DashboardMetricGrid({
    super.key,
    required this.monthlyRevenue,
    required this.monthlyNetProfit,
    required this.monthlyPayrollCost,
    required this.monthlyExpenses,
  });

  final String monthlyRevenue;
  final String monthlyNetProfit;
  final String monthlyPayrollCost;
  final String monthlyExpenses;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _Tile(
                label: l10n.ownerDashboardV2MonthlyRevenueLabel,
                value: monthlyRevenue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Tile(
                label: l10n.ownerDashboardV2MonthlyNetProfitLabel,
                value: monthlyNetProfit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Tile(
                label: l10n.ownerDashboardV2MonthlyPayrollCostLabel,
                value: monthlyPayrollCost,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Tile(
                label: l10n.ownerDashboardV2MonthlyExpensesLabel,
                value: monthlyExpenses,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FinanceDashboardColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FinanceDashboardColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: FinanceDashboardColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: FinanceDashboardColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

