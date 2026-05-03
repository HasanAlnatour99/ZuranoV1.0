import 'package:flutter/material.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.l10n,
    required this.locale,
    required this.currencyCode,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.onDiscountTap,
    this.showManualDiscountEditor = true,
  });

  final AppLocalizations l10n;
  final Locale locale;
  final String currencyCode;
  final double subtotal;
  final double discount;
  final double total;
  final VoidCallback onDiscountTap;
  final bool showManualDiscountEditor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            FinanceDashboardColors.lightPurple.withValues(alpha: 0.72),
            FinanceDashboardColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: FinanceDashboardColors.primaryPurple.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: FinanceDashboardColors.primaryPurple.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: FinanceDashboardColors.primaryPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.addSaleOrderSummaryTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: FinanceDashboardColors.textPrimary,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: l10n.addSaleSubtotal,
            value: formatAppMoney(subtotal, currencyCode, locale),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                l10n.salesDetailsDiscountLabel,
                style: const TextStyle(
                  color: FinanceDashboardColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (showManualDiscountEditor)
                TextButton(
                  onPressed: onDiscountTap,
                  style: TextButton.styleFrom(
                    foregroundColor: FinanceDashboardColors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    discount > 0
                        ? formatAppMoney(discount, currencyCode, locale)
                        : l10n.addSaleDiscountLink,
                  ),
                )
              else
                Text(
                  formatAppMoney(discount, currencyCode, locale),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: FinanceDashboardColors.textPrimary,
                  ),
                ),
            ],
          ),
          Divider(
            height: 24,
            color: FinanceDashboardColors.border.withValues(alpha: 0.82),
          ),
          Row(
            children: [
              Text(
                l10n.addSaleTotal,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                formatAppMoney(total, currencyCode, locale),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: FinanceDashboardColors.primaryPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: FinanceDashboardColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: FinanceDashboardColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
