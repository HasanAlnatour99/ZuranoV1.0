import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../providers/session_provider.dart';
import '../../data/models/weekly_schedule_assignment_model.dart';
import '../../domain/services/schedule_apply_service.dart';
import '../providers/apply_schedule_providers.dart';
import '../providers/shift_providers.dart';
import '../widgets/apply_schedule_calendar_preview.dart';
import '../widgets/schedule_option_tile.dart';
import '../widgets/shift_ui/shift_design_tokens.dart';
import '../widgets/shift_ui/shift_glass_card.dart';
import '../widgets/shift_ui/shift_gradient_button.dart';
import '../widgets/shift_ui/shift_hero_header.dart';
import '../widgets/shift_ui/shift_icon_tile.dart';
import '../widgets/shift_ui/shift_page_shell.dart';

class ApplyScheduleScreen extends ConsumerStatefulWidget {
  const ApplyScheduleScreen({super.key, required this.weekTemplateId});

  final String weekTemplateId;

  @override
  ConsumerState<ApplyScheduleScreen> createState() =>
      _ApplyScheduleScreenState();
}

class _ApplyScheduleScreenState extends ConsumerState<ApplyScheduleScreen> {
  ApplyScheduleOptions _options = const ApplyScheduleOptions(
    rangeType: ScheduleApplyRangeType.remainingMonth,
    repeatEveryWeek: true,
    skipExistingAssignments: true,
    includeOffDays: true,
  );
  AsyncValue<ScheduleApplyResult?> _applyState = const AsyncData(null);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final weekTemplateId = widget.weekTemplateId;
    final templateAsync = ref.watch(weeklyTemplateByIdProvider(weekTemplateId));
    final assignmentsAsync = ref.watch(
      weeklyAssignmentsByIdProvider(weekTemplateId),
    );

    return ShiftPageShell(
      bottomBar: _applyState.isLoading
          ? const SizedBox(
              height: 64,
              child: Center(child: CircularProgressIndicator()),
            )
          : ShiftGradientButton(
              label: l10n.ownerApplyScheduleCta,
              onPressed: () async {
                await _apply(weekTemplateId);
                if (!context.mounted) return;
                final result = _applyState.asData?.value;
                if (result != null) {
                  await showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(l10n.ownerApplyScheduleSuccessTitle),
                      content: Text(
                        l10n.ownerApplyScheduleSuccessBody(
                          result.totalWrites,
                          result.skippedExisting,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.ownerApplyScheduleOk),
                        ),
                      ],
                    ),
                  );
                  if (context.mounted) {
                    context.goNamed(AppRouteNames.ownerWeeklyShifts);
                  }
                }
              },
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShiftHeroHeader(
            title: l10n.ownerApplyScheduleTitle,
            subtitle: l10n.ownerApplyScheduleSubtitle,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(AppRouteNames.ownerWeeklyShifts);
              }
            },
          ),
          const SizedBox(height: 24),
          templateAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) =>
                ShiftGlassCard(child: Text(l10n.ownerWeeklyShiftsLoadError)),
            data: (template) {
              if (template == null) {
                return ShiftGlassCard(
                  child: Text(l10n.ownerWeeklyShiftsLoadError),
                );
              }
              final dates = _previewDates(
                options: _options,
                weekStart: template.weekStartDate,
                weekEnd: template.weekEndDate,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WeeklyPlanPreviewCard(
                    templateName: template.name,
                    dateRange: _dateRangeLabel(
                      context,
                      template.weekStartDate,
                      template.weekEndDate,
                    ),
                    assignmentsAsync: assignmentsAsync,
                    summaryLabel: l10n.ownerApplySchedulePreviewSummary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.ownerApplyScheduleSectionTarget,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: ShiftDesignTokens.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ShiftGlassCard(
                    padding: EdgeInsets.zero,
                    radius: 22,
                    child: Column(
                      children: [
                        ScheduleOptionTile(
                          leadingIcon: Icons.today_outlined,
                          title: l10n.ownerApplyScheduleOptionThisWeek,
                          subtitle: _dateRangeLabel(
                            context,
                            template.weekStartDate,
                            template.weekEndDate,
                          ),
                          selected:
                              _options.rangeType ==
                              ScheduleApplyRangeType.thisWeek,
                          onTap: () => setState(
                            () => _options = _options.copyWith(
                              rangeType: ScheduleApplyRangeType.thisWeek,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ScheduleOptionTile(
                          leadingIcon: Icons.calendar_view_month_outlined,
                          title: l10n.ownerApplyScheduleOptionRemainingMonth,
                          subtitle: l10n
                              .ownerApplyScheduleOptionRemainingMonthSubtitle,
                          selected:
                              _options.rangeType ==
                              ScheduleApplyRangeType.remainingMonth,
                          onTap: () => setState(
                            () => _options = _options.copyWith(
                              rangeType: ScheduleApplyRangeType.remainingMonth,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ScheduleOptionTile(
                          leadingIcon: Icons.date_range_outlined,
                          title: l10n.ownerApplyScheduleOptionCustomRange,
                          subtitle: _customRangeLabel(context, _options),
                          selected:
                              _options.rangeType ==
                              ScheduleApplyRangeType.customRange,
                          onTap: () async {
                            setState(
                              () => _options = _options.copyWith(
                                rangeType: ScheduleApplyRangeType.customRange,
                              ),
                            );
                            final range = await showDateRangePicker(
                              context: context,
                              firstDate: template.weekStartDate,
                              lastDate: template.weekStartDate.add(
                                const Duration(days: 365),
                              ),
                            );
                            if (range != null) {
                              setState(
                                () => _options = _options.copyWith(
                                  customStartDate: range.start,
                                  customEndDate: range.end,
                                ),
                              );
                            }
                          },
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: ShiftDesignTokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ApplyScheduleCalendarPreview(
                    title: l10n.ownerApplyScheduleCalendarPreview,
                    highlightedDates: dates,
                  ),
                  const SizedBox(height: 16),
                  ShiftGlassCard(
                    padding: EdgeInsets.zero,
                    radius: 22,
                    child: Column(
                      children: [
                        _ToggleRow(
                          title: l10n.ownerApplyScheduleRepeatEveryWeek,
                          value: _options.repeatEveryWeek,
                          onChanged: (v) => setState(
                            () => _options = _options.copyWith(
                              repeatEveryWeek: v,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        _ToggleRow(
                          title: l10n.ownerApplyScheduleSkipExistingAssignments,
                          value: _options.skipExistingAssignments,
                          onChanged: (v) => setState(
                            () => _options = _options.copyWith(
                              skipExistingAssignments: v,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        _ToggleRow(
                          title: l10n.ownerApplyScheduleIncludeOffDays,
                          value: _options.includeOffDays,
                          onChanged: (v) => setState(
                            () =>
                                _options = _options.copyWith(includeOffDays: v),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  InfoWarningCard(message: l10n.ownerApplyScheduleInfoCard),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _apply(String weekTemplateId) async {
    final salonId = ref.read(activeOwnerSalonIdProvider);
    final user = ref.read(sessionUserProvider).asData?.value;
    final template = ref
        .read(weeklyTemplateByIdProvider(weekTemplateId))
        .asData
        ?.value;
    final assignments = ref
        .read(weeklyAssignmentsByIdProvider(weekTemplateId))
        .asData
        ?.value;
    if (salonId == null ||
        user == null ||
        template == null ||
        assignments == null) {
      return;
    }
    setState(() => _applyState = const AsyncLoading());
    final result = await AsyncValue.guard(
      () => ref
          .read(scheduleApplyServiceProvider)
          .apply(
            ScheduleApplyRequest(
              salonId: salonId,
              weekTemplateId: weekTemplateId,
              assignments: assignments,
              createdBy: user.uid,
              rangeType: _options.rangeType,
              weekStartDate: template.weekStartDate,
              weekEndDate: template.weekEndDate,
              repeatEveryWeek: _options.repeatEveryWeek,
              skipExistingAssignments: _options.skipExistingAssignments,
              includeOffDays: _options.includeOffDays,
              customStartDate: _options.customStartDate,
              customEndDate: _options.customEndDate,
            ),
          ),
    );
    if (mounted) {
      setState(() => _applyState = result);
    }
  }

  List<DateTime> _previewDates({
    required ApplyScheduleOptions options,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) {
    switch (options.rangeType) {
      case ScheduleApplyRangeType.thisWeek:
        return _range(weekStart, weekEnd);
      case ScheduleApplyRangeType.remainingMonth:
        final monthEnd = DateTime(weekStart.year, weekStart.month + 1, 0);
        return _range(weekStart, monthEnd);
      case ScheduleApplyRangeType.customRange:
        if (options.customStartDate == null || options.customEndDate == null) {
          return _range(weekStart, weekEnd);
        }
        return _range(options.customStartDate!, options.customEndDate!);
    }
  }

  List<DateTime> _range(DateTime start, DateTime end) {
    final list = <DateTime>[];
    var cursor = DateTime(start.year, start.month, start.day);
    final to = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(to)) {
      list.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return list;
  }

  String _dateRangeLabel(BuildContext context, DateTime start, DateTime end) {
    final locale = Localizations.localeOf(context).languageCode;
    final fmt = DateFormat('MMM d', locale);
    return '${fmt.format(start)} - ${fmt.format(end)}';
  }

  String _customRangeLabel(BuildContext context, ApplyScheduleOptions options) {
    final start = options.customStartDate;
    final end = options.customEndDate;
    if (start == null || end == null) {
      return AppLocalizations.of(context)!.ownerApplyScheduleSelectCustomRange;
    }
    return _dateRangeLabel(context, start, end);
  }
}

class WeeklyPlanPreviewCard extends StatelessWidget {
  const WeeklyPlanPreviewCard({
    super.key,
    required this.templateName,
    required this.dateRange,
    required this.assignmentsAsync,
    required this.summaryLabel,
  });

  final String templateName;
  final String dateRange;
  final AsyncValue<List<WeeklyScheduleAssignmentModel>> assignmentsAsync;
  final String Function(int assignments, int offDays) summaryLabel;

  @override
  Widget build(BuildContext context) {
    final assignmentCount = assignmentsAsync.asData?.value.length ?? 0;
    final offCount =
        assignmentsAsync.asData?.value
            .where((item) => item.shiftType == 'off')
            .length ??
        0;
    return ShiftGlassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShiftIconTile(
            icon: Icons.grid_view_rounded,
            size: 64,
            iconSize: 30,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  templateName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ShiftDesignTokens.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateRange,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ShiftDesignTokens.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  summaryLabel(assignmentCount, offCount),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: ShiftDesignTokens.textDark,
                    fontWeight: FontWeight.w600,
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

class InfoWarningCard extends StatelessWidget {
  const InfoWarningCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ShiftDesignTokens.softPurple.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: ShiftDesignTokens.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: ShiftDesignTokens.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                color: ShiftDesignTokens.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const ShiftIconTile.small(
              icon: Icons.tune_rounded,
              size: 44,
              iconSize: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ShiftDesignTokens.textDark,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return ShiftDesignTokens.textMuted;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return ShiftDesignTokens.primary;
                }
                return ShiftDesignTokens.border.withValues(alpha: 0.55);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
