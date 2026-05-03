import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import 'finance_quick_action_tile.dart';

class FinanceQuickActions extends StatelessWidget {
  const FinanceQuickActions({
    super.key,
    required this.payrollTitle,
    required this.payrollSubtitle,
    required this.salesTitle,
    required this.salesSubtitle,
    required this.expensesTitle,
    required this.expensesSubtitle,
    required this.onPayroll,
    required this.onSales,
    required this.onExpenses,
  });

  final String payrollTitle;
  final String payrollSubtitle;
  final String salesTitle;
  final String salesSubtitle;
  final String expensesTitle;
  final String expensesSubtitle;
  final VoidCallback onPayroll;
  final VoidCallback onSales;
  final VoidCallback onExpenses;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FinanceQuickActionTile(
          icon: AppIcons.payments_outlined,
          title: payrollTitle,
          subtitle: payrollSubtitle,
          onTap: onPayroll,
          wide: true,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FinanceQuickActionTile(
                icon: AppIcons.receipt_long_outlined,
                title: salesTitle,
                subtitle: salesSubtitle,
                onTap: onSales,
                accent: const Color(0xFF16A34A),
                accentSoft: const Color(0xFFEFFBF4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FinanceQuickActionTile(
                icon: AppIcons.wallet_outlined,
                title: expensesTitle,
                subtitle: expensesSubtitle,
                onTap: onExpenses,
                accent: FinanceDashboardColors.expensePink,
                accentSoft: FinanceDashboardColors.expensePinkSoft,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
