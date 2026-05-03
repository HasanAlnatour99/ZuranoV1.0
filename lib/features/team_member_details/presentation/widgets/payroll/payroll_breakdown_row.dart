import 'package:flutter/material.dart';

import '../../../../../core/utils/money_formatter.dart';

class PayrollBreakdownRow extends StatelessWidget {
  const PayrollBreakdownRow({
    super.key,
    required this.icon,
    required this.label,
    required this.amount,
    required this.currencyCode,
    this.isDeduction = false,
    this.highlighted = false,
    this.onDelete,
    this.onEdit,
  });

  final IconData icon;
  final String label;
  final double amount;
  final String currencyCode;
  final bool isDeduction;
  final bool highlighted;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final absAmountText = MoneyFormatter.format(
      context,
      amount.abs(),
      currencyCode: currencyCode,
    );
    final amountText = isDeduction ? '-$absAmountText' : absAmountText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: highlighted
            ? scheme.primaryContainer.withValues(alpha: 0.35)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    softWrap: true,
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: scheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amountText,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isDeduction ? scheme.error : scheme.onSurface,
            ),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline_rounded, color: scheme.error),
            ),
        ],
      ),
    );
  }
}
