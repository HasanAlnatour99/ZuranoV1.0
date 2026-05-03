import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../team_member_profile/presentation/theme/team_member_profile_colors.dart';
import '../application/team_member_attendance_providers.dart';
import 'widgets/attendance_correction_requests_card.dart';
import 'widgets/attendance_summary_grid.dart';
import 'widgets/attendance_today_admin_card.dart';
import 'widgets/recent_attendance_history_card.dart';

class TeamMemberAttendanceTab extends ConsumerWidget {
  const TeamMemberAttendanceTab({
    super.key,
    required this.salonId,
    required this.employeeId,
    required this.employeeName,
    required this.canManageAttendance,
  });

  final String salonId;
  final String employeeId;
  final String employeeName;
  final bool canManageAttendance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final args = TeamMemberAttendanceArgs(
      salonId: salonId,
      employeeId: employeeId,
    );

    final todayAsync = ref.watch(todayAttendanceProvider(args));
    final assignedScheduleAsync = ref.watch(
      todayAssignedScheduleProvider(args),
    );
    final summaryAsync = ref.watch(attendanceSummaryProvider(args));
    final requestsAsync = ref.watch(attendanceCorrectionRequestsProvider(args));
    final historyAsync = ref.watch(recentAttendanceProvider(args));

    return ColoredBox(
      color: TeamMemberProfileColors.canvas,
      child: RefreshIndicator(
        color: TeamMemberProfileColors.primary,
        onRefresh: () async {
          ref.invalidate(todayAttendanceProvider(args));
          ref.invalidate(todayAssignedScheduleProvider(args));
          ref.invalidate(attendanceSummaryProvider(args));
          ref.invalidate(attendanceCorrectionRequestsProvider(args));
          ref.invalidate(recentAttendanceProvider(args));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            todayAsync.when(
              data: (record) => AttendanceTodayAdminCard(
                employeeName: employeeName,
                record: record,
                assignedSchedule: assignedScheduleAsync.asData?.value,
                canManageAttendance: canManageAttendance,
                salonId: salonId,
                employeeId: employeeId,
                args: args,
              ),
              loading: () => const _CardSkeleton(height: 190),
              error: (error, _) => _ErrorCard(message: error.toString()),
            ),
            const SizedBox(height: 14),
            summaryAsync.when(
              data: (summary) => AttendanceSummaryGrid(summary: summary),
              loading: () => const _CardSkeleton(height: 220),
              error: (error, _) => _ErrorCard(message: error.toString()),
            ),
            const SizedBox(height: 14),
            requestsAsync.when(
              data: (requests) => AttendanceCorrectionRequestsCard(
                requests: requests,
                salonId: salonId,
                canManageAttendance: canManageAttendance,
                args: args,
              ),
              loading: () => const _CardSkeleton(height: 150),
              error: (error, _) => _ErrorCard(message: error.toString()),
            ),
            const SizedBox(height: 14),
            historyAsync.when(
              data: (records) => RecentAttendanceHistoryCard(
                records: records,
                emptyMessage: l10n.teamMemberAttendanceHistoryEmpty,
                canManageAttendance: canManageAttendance,
                salonId: salonId,
                employeeId: employeeId,
                employeeName: employeeName,
                args: args,
              ),
              loading: () => const _CardSkeleton(height: 220),
              error: (error, _) => _ErrorCard(message: error.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: TeamMemberProfileColors.softPurple.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFD1D1)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFB42318),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
