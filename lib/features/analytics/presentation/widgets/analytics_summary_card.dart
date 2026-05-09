import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  const AnalyticsSummaryCard({
    super.key,
    required this.grossRevenue,
    required this.payrollCost,
    required this.expensesTotal,
    required this.netProfit,
    required this.salesCount,
    required this.bookingsCount,
    required this.completedBookingsCount,
    required this.averageTicket,
  });

  final String grossRevenue;
  final String payrollCost;
  final String expensesTotal;
  final String netProfit;
  final int salesCount;
  final int bookingsCount;
  final int completedBookingsCount;
  final String averageTicket;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FinanceDashboardColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FinanceDashboardColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Row(label: l10n.ownerAnalyticsGrossRevenueLabel, value: grossRevenue),
          const SizedBox(height: 8),
          _Row(label: l10n.ownerAnalyticsPayrollCostLabel, value: payrollCost),
          const SizedBox(height: 8),
          _Row(label: l10n.ownerAnalyticsExpensesLabel, value: expensesTotal),
          const Divider(height: 18),
          _Row(
            label: l10n.ownerAnalyticsNetProfitLabel,
            value: netProfit,
            valueStyle: const TextStyle(
              color: FinanceDashboardColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Chip(label: l10n.ownerAnalyticsSalesCountLabel, value: '$salesCount'),
              _Chip(label: l10n.ownerAnalyticsBookingsCountLabel, value: '$bookingsCount'),
              _Chip(label: l10n.ownerAnalyticsCompletedBookingsLabel, value: '$completedBookingsCount'),
              _Chip(label: l10n.ownerAnalyticsAverageTicketLabel, value: averageTicket),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: FinanceDashboardColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                color: FinanceDashboardColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: FinanceDashboardColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: FinanceDashboardColors.border),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: FinanceDashboardColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

