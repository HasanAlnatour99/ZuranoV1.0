import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';

class PayrollMonthSelector extends StatelessWidget {
  const PayrollMonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  final DateTime selectedMonth;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final label = DateFormat.yMMMM(locale.toString()).format(selectedMonth);
    const surface = ZuranoPremiumUiColors.cardBackground;
    const accent = ZuranoPremiumUiColors.primaryPurple;
    const primaryText = ZuranoPremiumUiColors.textPrimary;
    const secondaryText = ZuranoPremiumUiColors.textSecondary;
    final border = ZuranoPremiumUiColors.border.withValues(alpha: 0.7);

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedMonth,
            firstDate: DateTime(2020),
            lastDate: DateTime(DateTime.now().year + 1, 12),
            helpText: label,
          );
          if (picked != null) {
            onChanged(DateTime(picked.year, picked.month));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_rounded, size: 20, color: accent),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_more_rounded, color: secondaryText),
            ],
          ),
        ),
      ),
    );
  }
}
