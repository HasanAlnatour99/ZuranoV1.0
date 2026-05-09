import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/app_localizations.dart';

class AnalyticsPeriodSelector extends StatelessWidget {
  const AnalyticsPeriodSelector({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
    required this.onGenerate,
  });

  final DateTime selectedMonth;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final months = List<DateTime>.generate(
      6,
      (i) {
        final d = DateTime(DateTime.now().year, DateTime.now().month - i);
        return DateTime(d.year, d.month);
      },
      growable: false,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: months.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final m = months[index];
              final selected =
                  m.year == selectedMonth.year && m.month == selectedMonth.month;
              return ChoiceChip(
                label: Text('${m.year}-${m.month.toString().padLeft(2, '0')}'),
                selected: selected,
                onSelected: (_) => onChanged(m),
                selectedColor: FinanceDashboardColors.primaryPurple,
                labelStyle: TextStyle(
                  color: selected
                      ? Colors.white
                      : FinanceDashboardColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        FilledButton(
          onPressed: onGenerate,
          child: Text(l10n.ownerAnalyticsGenerate),
        ),
      ],
    );
  }
}

