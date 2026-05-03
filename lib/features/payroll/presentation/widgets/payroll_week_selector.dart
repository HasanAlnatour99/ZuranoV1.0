import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/time/iso_week.dart';
import '../../../../l10n/app_localizations.dart';

/// ISO week picker (prev / label / next). [onChanged] receives ISO week-year and week number.
class PayrollWeekSelector extends StatelessWidget {
  const PayrollWeekSelector({
    super.key,
    required this.weekYear,
    required this.weekNumber,
    required this.onChanged,
  });

  final int weekYear;
  final int weekNumber;
  final void Function(int weekYear, int weekNumber) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const surface = ZuranoPremiumUiColors.cardBackground;
    const accent = ZuranoPremiumUiColors.primaryPurple;
    const primaryText = ZuranoPremiumUiColors.textPrimary;
    const secondaryText = ZuranoPremiumUiColors.textSecondary;
    final border = ZuranoPremiumUiColors.border.withValues(alpha: 0.7);

    final label = l10n.payrollIsoWeekShortLabel(
      weekYear,
      weekNumber.toString().padLeft(2, '0'),
    );

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () {
                final mon = isoWeekMondayUtc(weekYear, weekNumber)
                    .subtract(const Duration(days: 7));
                final spec = isoWeekSpecForUtcDate(mon);
                onChanged(spec.weekYear, spec.weekNumber);
              },
              icon: Icon(Icons.chevron_left_rounded, color: accent),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final mon = isoWeekMondayUtc(weekYear, weekNumber);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: mon.toLocal(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(DateTime.now().year + 1, 12, 31),
                  helpText: l10n.payrollWeekPickerHelp,
                );
                if (picked != null) {
                  final utc = DateTime.utc(picked.year, picked.month, picked.day);
                  final spec = isoWeekSpecForUtcDate(utc);
                  onChanged(spec.weekYear, spec.weekNumber);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.date_range_rounded, size: 20, color: accent),
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
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () {
                final mon = isoWeekMondayUtc(weekYear, weekNumber)
                    .add(const Duration(days: 7));
                final spec = isoWeekSpecForUtcDate(mon);
                onChanged(spec.weekYear, spec.weekNumber);
              },
              icon: Icon(Icons.chevron_right_rounded, color: accent),
            ),
          ],
        ),
      ),
    );
  }
}
