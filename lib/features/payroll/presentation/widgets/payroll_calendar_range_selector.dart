import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// UTC calendar-day range for weekly payroll (inclusive start / inclusive end day).
class PayrollCalendarRangeSelector extends StatelessWidget {
  const PayrollCalendarRangeSelector({
    super.key,
    required this.rangeStartUtc,
    required this.rangeEndUtc,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final DateTime rangeStartUtc;
  final DateTime rangeEndUtc;
  final Future<void> Function() onPickStart;
  final Future<void> Function() onPickEnd;

  String _formatDay(BuildContext context, DateTime utcDay) {
    final d = DateTime(utcDay.year, utcDay.month, utcDay.day);
    return MaterialLocalizations.of(context).formatCompactDate(d);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.payrollRunWeeklyPaidDaysHint,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.35,
            color: ZuranoPremiumUiColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DateTile(
                label: l10n.payrollRunWeeklyStartLabel,
                value: _formatDay(context, rangeStartUtc),
                onTap: onPickStart,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DateTile(
                label: l10n.payrollRunWeeklyEndLabel,
                value: _formatDay(context, rangeEndUtc),
                onTap: onPickEnd,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ZuranoPremiumUiColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ZuranoPremiumUiColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ZuranoPremiumUiColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: ZuranoPremiumUiColors.primaryPurple,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: ZuranoPremiumUiColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
