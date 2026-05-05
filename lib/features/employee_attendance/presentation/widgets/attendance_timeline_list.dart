import 'package:flutter/material.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/employee_attendance_models.dart';
import 'attendance_details_bottom_sheet.dart';
import 'attendance_timeline_row.dart';

class AttendanceTimelineList extends StatelessWidget {
  const AttendanceTimelineList({
    super.key,
    required this.records,
    this.isLoading = false,
    this.periodSubtitle,
    this.viewAllLabel,
    this.onViewAll,
  });

  final List<EmployeeAttendanceDay> records;
  final bool isLoading;

  /// e.g. “Last 7 days” when showing a short preview.
  final String? periodSubtitle;

  /// If null, [onViewAll] uses [AppLocalizations.employeeAttendanceViewAllLogs].
  final String? viewAllLabel;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasHeaderRow =
        periodSubtitle != null || onViewAll != null;

    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasHeaderRow)
            _TimelineHeader(
              l10n: l10n,
              periodSubtitle: periodSubtitle,
              viewAllLabel: viewAllLabel,
              onViewAll: onViewAll,
            ),
          AttendanceTimelineSkeleton(
            includeTitleLine: !hasHeaderRow,
          ),
        ],
      );
    }

    if (records.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasHeaderRow)
            _TimelineHeader(
              l10n: l10n,
              periodSubtitle: periodSubtitle,
              viewAllLabel: viewAllLabel,
              onViewAll: onViewAll,
            ),
          _EmptyHistory(l10n: l10n),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TimelineHeader(
          l10n: l10n,
          periodSubtitle: periodSubtitle,
          viewAllLabel: viewAllLabel,
          onViewAll: onViewAll,
        ),
        const SizedBox(height: 12),
        ...List<Widget>.generate(records.length, (i) {
          final r = records[i];
          return AttendanceTimelineRow(
            record: r,
            isFirst: i == 0,
            isLast: i == records.length - 1,
            onTap: () => showAttendanceDetailsBottomSheet(context, r),
          );
        }),
      ],
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  const _TimelineHeader({
    required this.l10n,
    this.periodSubtitle,
    this.viewAllLabel,
    this.onViewAll,
  });

  final AppLocalizations l10n;
  final String? periodSubtitle;
  final String? viewAllLabel;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.employeeAttendanceTabHistoryTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1D1233),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (periodSubtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  periodSubtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF837A98),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ],
          ),
        ),
        if (onViewAll != null) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: onViewAll,
            child: Text(
              viewAllLabel ?? l10n.employeeAttendanceViewAllLogs,
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE7D8FF)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_month_rounded,
            size: 48,
            color: ZuranoTokens.primary.withValues(alpha: 0.65),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.employeeAttendanceTabEmptyHistory,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFF1D1233),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.employeeAttendanceTabEmptyHistoryHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF837A98),
                ),
          ),
        ],
      ),
    );
  }
}

class AttendanceTimelineSkeleton extends StatelessWidget {
  const AttendanceTimelineSkeleton({
    super.key,
    this.includeTitleLine = true,
  });

  final bool includeTitleLine;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (includeTitleLine) ...[
          Container(
            height: 20,
            width: 120,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE7E0F5),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
        ...List<Widget>.generate(3, (_) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE7D8FF)),
              ),
            ),
          );
        }),
      ],
    );
  }
}
