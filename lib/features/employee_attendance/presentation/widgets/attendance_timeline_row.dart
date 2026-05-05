import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/employee_attendance_models.dart';
import '../employee_attendance_l10n_helpers.dart';

class AttendanceTimelineRow extends StatelessWidget {
  const AttendanceTimelineRow({
    super.key,
    required this.record,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final EmployeeAttendanceDay record;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.MMMd(locale).format(record.date.toLocal());
    final timeLabel = record.checkedInAt != null
        ? DateFormat('hh:mm a', locale).format(record.checkedInAt!.toLocal())
        : '—';
    final worked = formatAttendanceWorkedL10n(l10n, record.totalWorkedMinutes);
    final statusLabel = attendanceStatusLabel(l10n, record.status);
    final shiftLabel = shiftStateLabel(l10n, record.shiftState);
    final layoutDirection = Directionality.of(context);
    final isRtl = layoutDirection == ui.TextDirection.rtl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 36,
                  child: Column(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: isRtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 2,
                            color: isFirst
                                ? Colors.transparent
                                : ZuranoTokens.primary.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ZuranoTokens.surface,
                          border: Border.all(color: ZuranoTokens.primary, width: 2),
                          boxShadow: ZuranoTokens.softCardShadow,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: isRtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 2,
                            color: isLast
                                ? Colors.transparent
                                : ZuranoTokens.primary.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE7D8FF)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateLabel,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1D1233),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$statusLabel · $shiftLabel',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF837A98),
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                timeLabel,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: ZuranoTokens.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              worked,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1D1233),
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Icon(
                              isRtl ? Icons.chevron_left : Icons.chevron_right,
                              color: const Color(0xFF837A98),
                              size: 22,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
