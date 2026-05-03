import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/attendance_record_model.dart';

/// Premium Zurano-style row for team member attendance lists (profile tab + full history).
class TeamMemberAttendanceHistoryRow extends StatelessWidget {
  const TeamMemberAttendanceHistoryRow({
    super.key,
    required this.record,
    required this.dateFormat,
    required this.timeFormat,
    required this.canOpenAdjustment,
    required this.onOpenAdjustment,
  });

  final AttendanceRecordModel record;
  final DateFormat dateFormat;
  final DateFormat timeFormat;
  final bool canOpenAdjustment;
  final Future<void> Function() onOpenAdjustment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final parsed = DateTime.tryParse(record.attendanceDate);
    final dateLabel = parsed != null
        ? dateFormat.format(parsed.toLocal())
        : record.attendanceDate;

    final statusLabel = _statusLabel(l10n, record.status);
    final statusColor = _statusColor(record.status);

    final tappable =
        canOpenAdjustment && record.attendanceCalendarDay() != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusInput),
        onTap: tappable ? () => onOpenAdjustment() : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: ZuranoTokens.searchFill,
            borderRadius: BorderRadius.circular(ZuranoTokens.radiusInput),
            border: Border.all(color: ZuranoTokens.sectionBorder),
            boxShadow: ZuranoTokens.softCardShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: ZuranoTokens.lightPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: ZuranoTokens.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: ZuranoTokens.textDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_formatTime(record.checkInAt, timeFormat)} — ${_formatTime(record.checkOutAt, timeFormat)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ZuranoTokens.textGray,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime? value, DateFormat timeFormat) {
    if (value == null) return '--:--';
    return timeFormat.format(value.toLocal());
  }

  static String _statusLabel(AppLocalizations l10n, String status) {
    return switch (status) {
      'present' => l10n.teamMemberAttendanceRecordStatusPresent,
      'late' => l10n.teamMemberAttendanceRecordStatusLate,
      'incomplete' => l10n.teamMemberAttendanceRecordStatusIncomplete,
      'manual' => l10n.teamMemberAttendanceRecordStatusManual,
      'absent' => l10n.teamMemberAttendanceRecordStatusAbsent,
      'onBreak' => l10n.teamMemberAttendanceRecordStatusOnBreak,
      'checkedIn' => l10n.teamMemberAttendanceRecordStatusCheckedIn,
      'checkedOut' => l10n.teamMemberAttendanceRecordStatusPresent,
      'backFromBreak' => l10n.teamMemberAttendanceRecordStatusPresent,
      _ => status,
    };
  }

  static Color _statusColor(String status) {
    return switch (status) {
      'present' => const Color(0xFF16A34A),
      'late' => const Color(0xFFF97316),
      'incomplete' => const Color(0xFFF59E0B),
      'onBreak' => const Color(0xFF0EA5E9),
      'manual' => ZuranoTokens.primary,
      'absent' => const Color(0xFFDC2626),
      'checkedIn' => const Color(0xFF64748B),
      'checkedOut' => const Color(0xFF16A34A),
      'backFromBreak' => const Color(0xFF16A34A),
      _ => ZuranoTokens.textGray,
    };
  }
}
