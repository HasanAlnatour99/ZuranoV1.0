import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/presentation/attendance_adjustment_form_state.dart';
import '../../../attendance/presentation/widgets/attendance_adjustment_sheet.dart';
import '../../../owner/logic/team_management_providers.dart';
import '../../../team_member_profile/presentation/theme/team_member_profile_colors.dart';
import '../../application/team_member_attendance_providers.dart';
import '../widgets/team_member_attendance_history_row.dart';

/// Full attendance list for a team member (from profile "View all").
class TeamMemberAttendanceHistoryScreen extends ConsumerWidget {
  const TeamMemberAttendanceHistoryScreen({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detailsAsync = ref.watch(barberDetailsProvider(employeeId));
    final canManageAsync = ref.watch(canManageTeamMemberAttendanceProvider);

    return detailsAsync.when(
      loading: () => Scaffold(
        backgroundColor: TeamMemberProfileColors.canvas,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: TeamMemberProfileColors.canvas,
          foregroundColor: TeamMemberProfileColors.textPrimary,
          title: Text(
            l10n.teamMemberAttendanceFullHistoryTitle,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: AppLoadingIndicator(size: 40)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: TeamMemberProfileColors.canvas,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: TeamMemberProfileColors.canvas,
          foregroundColor: TeamMemberProfileColors.textPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(padding: const EdgeInsets.all(24), child: Text('$e')),
        ),
      ),
      data: (data) {
        final args = TeamMemberAttendanceArgs(
          salonId: data.employee.salonId,
          employeeId: employeeId,
        );
        return _TeamMemberAttendanceHistoryBody(
          args: args,
          employeeName: formatTeamMemberName(data.employee.name),
          canManage: canManageAsync.asData?.value ?? false,
        );
      },
    );
  }
}

class _TeamMemberAttendanceHistoryBody extends ConsumerStatefulWidget {
  const _TeamMemberAttendanceHistoryBody({
    required this.args,
    required this.employeeName,
    required this.canManage,
  });

  final TeamMemberAttendanceArgs args;
  final String employeeName;
  final bool canManage;

  @override
  ConsumerState<_TeamMemberAttendanceHistoryBody> createState() =>
      _TeamMemberAttendanceHistoryBodyState();
}

class _TeamMemberAttendanceHistoryBodyState
    extends ConsumerState<_TeamMemberAttendanceHistoryBody> {
  DateTime? _draftFrom;
  DateTime? _draftTo;
  bool _draftSeeded = false;

  void _seedDraftFromProviderIfNeeded() {
    if (_draftSeeded) return;
    _draftSeeded = true;
    final f = ref.read(teamMemberAttendanceHistoryFilterProvider(widget.args));
    _draftFrom = f.fromDay;
    _draftTo = f.toDay;
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final initial = isFrom
        ? (_draftFrom ?? _draftTo ?? now)
        : (_draftTo ?? _draftFrom ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 6),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: isFrom
          ? l10n.teamMemberAttendanceHistoryFilterFrom
          : l10n.teamMemberAttendanceHistoryFilterTo,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _draftFrom = picked;
      } else {
        _draftTo = picked;
      }
    });
  }

  void _applyFilter() {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (_draftFrom == null || _draftTo == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.teamMemberAttendanceHistoryFilterNeedBothDates)),
      );
      return;
    }
    var a = DateTime(_draftFrom!.year, _draftFrom!.month, _draftFrom!.day);
    var b = DateTime(_draftTo!.year, _draftTo!.month, _draftTo!.day);
    if (a.isAfter(b)) {
      final t = a;
      a = b;
      b = t;
      setState(() {
        _draftFrom = a;
        _draftTo = b;
      });
    }
    ref.read(teamMemberAttendanceHistoryFilterProvider(widget.args).notifier).state =
        AttendanceHistoryDateFilter(fromDay: a, toDay: b);
    setState(() {
      _draftFrom = a;
      _draftTo = b;
    });
  }

  void _clearFilter() {
    setState(() {
      _draftFrom = null;
      _draftTo = null;
    });
    ref.read(teamMemberAttendanceHistoryFilterProvider(widget.args).notifier).state =
        const AttendanceHistoryDateFilter();
  }

  String _chipLabel(AppLocalizations l10n, DateTime? d, DateFormat fmt) {
    if (d == null) return l10n.teamMemberAttendanceHistoryFilterSelectDate;
    return fmt.format(d);
  }

  @override
  Widget build(BuildContext context) {
    _seedDraftFromProviderIfNeeded();
    final l10n = AppLocalizations.of(context)!;
    final localeTag = Localizations.localeOf(context).toString();
    final timeFormat = DateFormat.jm(localeTag);
    final dateFormat = DateFormat.yMMMEd(localeTag);
    final chipDateFormat = DateFormat.yMMMd(localeTag);

    ref.watch(teamMemberAttendanceHistoryFilterProvider(widget.args));

    final historyAsync = ref.watch(
      teamMemberFullAttendanceHistoryProvider(widget.args),
    );
    final appliedFilter = ref.watch(
      teamMemberAttendanceHistoryFilterProvider(widget.args),
    );

    return Scaffold(
      backgroundColor: TeamMemberProfileColors.canvas,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: TeamMemberProfileColors.canvas,
        foregroundColor: TeamMemberProfileColors.textPrimary,
        title: Text(
          l10n.teamMemberAttendanceFullHistoryTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        color: TeamMemberProfileColors.primary,
        onRefresh: () async {
          ref.invalidate(teamMemberFullAttendanceHistoryProvider(widget.args));
        },
        child: historyAsync.when(
          loading: () => const Center(child: AppLoadingIndicator(size: 40)),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [Text(e.toString())],
          ),
          data: (records) {
            final emptyMessage = appliedFilter.hasCompleteRange
                ? l10n.teamMemberAttendanceHistoryFilterEmptyRange
                : l10n.teamMemberAttendanceHistoryEmpty;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: _ZuranoDateRangeFilterCard(
                      l10n: l10n,
                      draftFromLabel: _chipLabel(l10n, _draftFrom, chipDateFormat),
                      draftToLabel: _chipLabel(l10n, _draftTo, chipDateFormat),
                      onPickFrom: () => _pickDate(isFrom: true),
                      onPickTo: () => _pickDate(isFrom: false),
                      onApply: _applyFilter,
                      onClear: _clearFilter,
                    ),
                  ),
                ),
                if (records.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          emptyMessage,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: TeamMemberProfileColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    sliver: SliverList.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return TeamMemberAttendanceHistoryRow(
                          record: record,
                          dateFormat: dateFormat,
                          timeFormat: timeFormat,
                          canOpenAdjustment: widget.canManage,
                          onOpenAdjustment: () async {
                            final day = record.attendanceCalendarDay();
                            if (day == null) return;
                            final ok = await AttendanceAdjustmentSheet.open(
                              context,
                              params: AttendanceAdjustmentParams(
                                salonId: widget.args.salonId,
                                employeeId: widget.args.employeeId,
                                attendanceDate: day,
                                employeeDisplayName: widget.employeeName,
                              ),
                              prefillAttendancePayload:
                                  record.toAttendanceAdjustmentPrefillPayload(),
                            );
                            if (ok != true || !context.mounted) return;
                            ref.invalidate(
                              teamMemberFullAttendanceHistoryProvider(widget.args),
                            );
                            ref.invalidate(recentAttendanceProvider(widget.args));
                            ref.invalidate(todayAttendanceProvider(widget.args));
                            ref.invalidate(attendanceSummaryProvider(widget.args));
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ZuranoDateRangeFilterCard extends StatelessWidget {
  const _ZuranoDateRangeFilterCard({
    required this.l10n,
    required this.draftFromLabel,
    required this.draftToLabel,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onApply,
    required this.onClear,
  });

  final AppLocalizations l10n;
  final String draftFromLabel;
  final String draftToLabel;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onApply;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: ZuranoTokens.lightPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.date_range_rounded,
                  color: ZuranoTokens.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.teamMemberAttendanceHistoryFilterTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: ZuranoTokens.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _DateChip(
                  label: l10n.teamMemberAttendanceHistoryFilterFrom,
                  valueText: draftFromLabel,
                  onTap: onPickFrom,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateChip(
                  label: l10n.teamMemberAttendanceHistoryFilterTo,
                  valueText: draftToLabel,
                  onTap: onPickTo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onClear,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ZuranoTokens.textGray,
                    side: const BorderSide(color: ZuranoTokens.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ZuranoTokens.radiusButton),
                    ),
                  ),
                  child: Text(
                    l10n.teamMemberAttendanceHistoryFilterClear,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: ZuranoTokens.primaryGradient,
                    borderRadius: BorderRadius.circular(ZuranoTokens.radiusButton),
                    boxShadow: ZuranoTokens.fabGlow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        ZuranoTokens.radiusButton,
                      ),
                      onTap: onApply,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            l10n.teamMemberAttendanceHistoryFilterApply,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.valueText,
    required this.onTap,
  });

  final String label;
  final String valueText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusInput),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: ZuranoTokens.searchFill,
            borderRadius: BorderRadius.circular(ZuranoTokens.radiusInput),
            border: Border.all(color: ZuranoTokens.sectionBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ZuranoTokens.textGray,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valueText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: ZuranoTokens.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
