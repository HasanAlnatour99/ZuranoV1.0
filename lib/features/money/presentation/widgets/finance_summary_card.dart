import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import 'finance_kpi_tile.dart';
import 'premium_finance_card.dart';

class FinanceSummaryCard extends StatelessWidget {
  const FinanceSummaryCard({
    super.key,
    required this.monthTitle,
    required this.salesLabel,
    required this.expensesLabel,
    required this.payrollLabel,
    required this.netLabel,
    required this.salesValue,
    required this.expensesValue,
    required this.payrollValue,
    required this.netValue,
    required this.salesTrend,
    required this.expensesTrend,
    required this.payrollTrend,
    required this.netTrend,
    required this.salesTrendColor,
    required this.expensesTrendColor,
    required this.payrollTrendColor,
    required this.netTrendColor,
    required this.netProfitIcon,
    this.netProfitIconColor,
    this.netProfitIconBackground,
    this.netLossWarning,
    this.onMorePressed,
  });

  final String monthTitle;
  final String salesLabel;
  final String expensesLabel;
  final String payrollLabel;
  final String netLabel;
  final String salesValue;
  final String expensesValue;
  final String payrollValue;
  final String netValue;
  final String salesTrend;
  final String expensesTrend;
  final String payrollTrend;
  final String netTrend;
  final Color salesTrendColor;
  final Color expensesTrendColor;
  final Color payrollTrendColor;
  final Color netTrendColor;
  final IconData netProfitIcon;
  final Color? netProfitIconColor;
  final Color? netProfitIconBackground;
  final String? netLossWarning;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    return PremiumFinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: FinanceDashboardColors.primaryPurple,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  monthTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: FinanceDashboardColors.primaryPurple,
                  ),
                ),
              ),
              IconButton(
                onPressed: onMorePressed,
                icon: const Icon(Icons.more_horiz_rounded),
                color: FinanceDashboardColors.textSecondary,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          if (netLossWarning != null) ...[
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.errorContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.28),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      AppIcons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        netLossWarning!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: FinanceKpiTile(
                      icon: Icons.attach_money_rounded,
                      label: salesLabel,
                      value: salesValue,
                      trend: salesTrend,
                      iconColor: FinanceDashboardColors.primaryPurple,
                      iconBackground: FinanceDashboardColors.lightPurple,
                      trendColor: salesTrendColor,
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 18,
                  thickness: 1,
                  color: FinanceDashboardColors.border,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 6),
                    child: FinanceKpiTile(
                      icon: Icons.trending_down_rounded,
                      label: expensesLabel,
                      value: expensesValue,
                      trend: expensesTrend,
                      iconColor: FinanceDashboardColors.expensePink,
                      iconBackground: FinanceDashboardColors.expensePinkSoft,
                      trendColor: expensesTrendColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 28, color: FinanceDashboardColors.border),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: FinanceKpiTile(
                      icon: Icons.groups_rounded,
                      label: payrollLabel,
                      value: payrollValue,
                      trend: payrollTrend,
                      iconColor: FinanceDashboardColors.bluePayroll,
                      iconBackground: FinanceDashboardColors.bluePayrollSoft,
                      trendColor: payrollTrendColor,
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 18,
                  thickness: 1,
                  color: FinanceDashboardColors.border,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 6),
                    child: FinanceKpiTile(
                      icon: netProfitIcon,
                      label: netLabel,
                      value: netValue,
                      trend: netTrend,
                      iconColor:
                          netProfitIconColor ?? FinanceDashboardColors.greenProfit,
                      iconBackground: netProfitIconBackground ??
                          FinanceDashboardColors.greenProfitSoft,
                      trendColor: netTrendColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
