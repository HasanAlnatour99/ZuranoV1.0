import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'shift_ui/shift_design_tokens.dart';
import 'shift_ui/shift_glass_card.dart';

class ApplyScheduleCalendarPreview extends StatelessWidget {
  const ApplyScheduleCalendarPreview({
    super.key,
    required this.title,
    required this.highlightedDates,
  });

  final String title;
  final List<DateTime> highlightedDates;

  Set<DateTime> _normalizedSet() {
    return {for (final d in highlightedDates) DateTime(d.year, d.month, d.day)};
  }

  DateTime _monthAnchor() {
    if (highlightedDates.isEmpty) {
      final n = DateTime.now();
      return DateTime(n.year, n.month);
    }
    final d = highlightedDates.first;
    return DateTime(d.year, d.month);
  }

  List<DateTime?> _gridCells(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final lead = first.weekday - 1;
    final cells = <DateTime?>[
      for (var i = 0; i < lead; i++) null,
      for (var d = 1; d <= daysInMonth; d++)
        DateTime(month.year, month.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    while (cells.length < 42) {
      cells.add(null);
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final month = _monthAnchor();
    final cells = _gridCells(month);
    final highlight = _normalizedSet();
    final monthLabel = DateFormat.yMMMM(locale).format(month);
    final weekdays = List.generate(7, (i) {
      final d = DateTime(2024, 1, 1 + i);
      return DateFormat.E(locale).format(d);
    });

    return ShiftGlassCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: ShiftDesignTokens.textDark,
                  ),
                ),
              ),
              Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ShiftDesignTokens.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final w in weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      w,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ShiftDesignTokens.textMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (var r = 0; r < 6; r++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  for (var c = 0; c < 7; c++)
                    Expanded(
                      child: _DayCell(
                        date: cells[r * 7 + c],
                        highlight: highlight,
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

class _DayCell extends StatelessWidget {
  const _DayCell({required this.date, required this.highlight});

  final DateTime? date;
  final Set<DateTime> highlight;

  @override
  Widget build(BuildContext context) {
    if (date == null) {
      return const SizedBox(height: 36);
    }
    final d = date!;
    final isOn = highlight.contains(DateTime(d.year, d.month, d.day));
    return SizedBox(
      height: 36,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isOn ? ShiftDesignTokens.softPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isOn
                  ? ShiftDesignTokens.primary.withValues(alpha: 0.35)
                  : Colors.transparent,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${d.day}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isOn
                  ? ShiftDesignTokens.primary
                  : ShiftDesignTokens.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
