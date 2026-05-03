import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/presentation/attendance_adjustment_form_state.dart';
import '../../../attendance/presentation/widgets/attendance_adjustment_sheet.dart';
import '../../application/team_member_attendance_providers.dart';
import '../../data/models/attendance_record_model.dart';
import 'team_member_attendance_history_row.dart';

class RecentAttendanceHistoryCard extends ConsumerWidget {
  const RecentAttendanceHistoryCard({
    super.key,
    required this.records,
    required this.emptyMessage,
    required this.canManageAttendance,
    required this.salonId,
    required this.employeeId,
    required this.employeeName,
    required this.args,
  });

  final List<AttendanceRecordModel> records;
  final String emptyMessage;
  final bool canManageAttendance;
  final String salonId;
  final String employeeId;
  final String employeeName;
  final TeamMemberAttendanceArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeTag = Localizations.localeOf(context).toString();
    final timeFormat = DateFormat.jm(localeTag);
    final dateFormat = DateFormat.yMMMEd(localeTag);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ZuranoTokens.surface,
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusSection),
        border: Border.all(color: ZuranoTokens.sectionBorder),
        boxShadow: ZuranoTokens.sectionShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
                  Icons.history_rounded,
                  color: ZuranoTokens.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.teamMemberAttendanceHistoryTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: ZuranoTokens.textDark,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push(
                    AppRoutes.ownerTeamMemberAttendanceHistory(employeeId),
                  ),
                  borderRadius: BorderRadius.circular(ZuranoTokens.radiusButton),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) =>
                          ZuranoTokens.primaryGradient.createShader(bounds),
                      child: Text(
                        l10n.teamMemberAttendanceViewAll,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 26),
              child: Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: ZuranoTokens.textGray,
                  height: 1.35,
                ),
              ),
            )
          else
            ...records.map(
              (record) => TeamMemberAttendanceHistoryRow(
                record: record,
                dateFormat: dateFormat,
                timeFormat: timeFormat,
                canOpenAdjustment: canManageAttendance,
                onOpenAdjustment: () async {
                  final day = record.attendanceCalendarDay();
                  if (day == null) return;
                  final ok = await AttendanceAdjustmentSheet.open(
                    context,
                    params: AttendanceAdjustmentParams(
                      salonId: salonId,
                      employeeId: employeeId,
                      attendanceDate: day,
                      employeeDisplayName: employeeName,
                    ),
                    prefillAttendancePayload:
                        record.toAttendanceAdjustmentPrefillPayload(),
                  );
                  if (ok != true || !context.mounted) return;
                  ref.invalidate(todayAttendanceProvider(args));
                  ref.invalidate(recentAttendanceProvider(args));
                  ref.invalidate(attendanceSummaryProvider(args));
                },
              ),
            ),
        ],
      ),
    );
  }
}
