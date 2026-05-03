import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/text/team_member_name.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../data/models/shift_template_model.dart';
import '../../data/models/weekly_schedule_assignment_model.dart';
import '../../data/repositories/schedule_repository.dart';
import '../providers/weekly_schedule_providers.dart';
import '../widgets/draggable_shift_strip.dart';
import '../widgets/shift_ui/shift_design_tokens.dart';
import '../widgets/shift_ui/shift_glass_card.dart';
import '../widgets/shift_ui/shift_gradient_button.dart';
import '../widgets/shift_ui/shift_hero_header.dart';
import '../widgets/shift_ui/shift_icon_tile.dart';
import '../widgets/shift_ui/shift_page_shell.dart';
import '../widgets/week_range_navigator.dart';
import '../widgets/weekly_roster_grid.dart';

class WeeklyShiftsScreen extends ConsumerWidget {
  const WeeklyShiftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final weekStart = ref.watch(selectedWeekStartProvider);
    final weekDays = List<DateTime>.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );
    final weekTemplateAsync = ref.watch(weeklyTemplateProvider);
    final employeesAsync = ref.watch(activeEmployeesProvider);
    final shiftsAsync = ref.watch(shiftTemplatesForWeeklyProvider);
    final assignmentsAsync = ref.watch(weeklyAssignmentsProvider);

    return ShiftPageShell(
      bottomBar: ShiftGradientButton(
        label: l10n.ownerShiftsCreateTemplateCta,
        icon: Icons.add,
        onPressed: () =>
            context.pushNamed(AppRouteNames.ownerCreateShiftTemplate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShiftHeroHeader(
            title: l10n.ownerWeeklyShiftsTitle,
            subtitle: l10n.ownerWeeklyShiftsSubtitle,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(AppRouteNames.ownerShiftsSettings);
              }
            },
          ),
          const SizedBox(height: 20),
          WeekRangeNavigator(
            rangeLabel: _weekRangeLabel(context, weekStart),
            onPrev: () =>
                ref.read(selectedWeekStartProvider.notifier).previousWeek(),
            onNext: () =>
                ref.read(selectedWeekStartProvider.notifier).nextWeek(),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SegmentedWeekToggle(
                  weekStart: weekStart,
                  thisWeekLabel: l10n.ownerWeeklyShiftsThisWeek,
                  nextWeekLabel: l10n.ownerWeeklyShiftsNextWeek,
                  onThisWeek: () =>
                      ref.read(selectedWeekStartProvider.notifier).thisWeek(),
                  onNextWeek: () {
                    final current = DateTime.now().add(const Duration(days: 7));
                    ref
                        .read(selectedWeekStartProvider.notifier)
                        .setWeekStart(current);
                  },
                ),
              ),
              const SizedBox(width: 10),
              _ApplyMonthPill(
                label: l10n.ownerWeeklyShiftsApplyToMonth,
                enabled: weekTemplateAsync.asData?.value != null,
                onTap: weekTemplateAsync.asData?.value == null
                    ? null
                    : () => context.pushNamed(
                        AppRouteNames.ownerApplySchedule,
                        queryParameters: <String, String>{
                          'weekTemplateId': weekTemplateAsync.asData!.value!.id,
                        },
                      ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          shiftsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => ShiftGlassCard(
              child: Text(
                l10n.ownerShiftsLoadError,
                style: const TextStyle(color: ShiftDesignTokens.danger),
              ),
            ),
            data: (shifts) {
              if (shifts.isEmpty) {
                return ShiftGlassCard(
                  child: Text(l10n.ownerWeeklyShiftsNoTemplates),
                );
              }
              return DraggableShiftStrip(
                templates: shifts,
                helperBody: l10n.ownerWeeklyShiftsDragStripBody,
              );
            },
          ),
          const SizedBox(height: 20),
          employeesAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, _) =>
                ShiftGlassCard(child: Text(l10n.ownerWeeklyShiftsLoadError)),
            data: (employees) {
              if (employees.isEmpty) {
                return ShiftGlassCard(
                  child: Text(l10n.ownerWeeklyShiftsNoEmployees),
                );
              }
              return assignmentsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, _) => ShiftGlassCard(
                  child: Text(l10n.ownerWeeklyShiftsLoadError),
                ),
                data: (assignments) {
                  final byKey = <String, WeeklyScheduleAssignmentModel>{
                    for (final a in assignments) a.id: a,
                  };
                  return WeeklyRosterGrid(
                    employees: employees,
                    days: weekDays,
                    assignmentsByKey: byKey,
                    emptyCellLabel: l10n.ownerWeeklyShiftsEmptyCell,
                    employeeHeaderLabel: l10n.ownerWeeklyShiftsEmployeesHeader,
                    weekdayLabelBuilder: (date) => DateFormat(
                      'EEE d',
                      Localizations.localeOf(context).languageCode,
                    ).format(date),
                    onDrop: (employee, date, shift) => ref
                        .read(
                          weeklyScheduleAssignmentsControllerProvider.notifier,
                        )
                        .assignShift(
                          employee: employee,
                          date: date,
                          shift: shift,
                        ),
                    onTapCell: (employee, date, assignment) => _showCellActions(
                      context: context,
                      ref: ref,
                      l10n: l10n,
                      employee: employee,
                      date: date,
                      assignment: assignment,
                      shifts: shiftsAsync.asData?.value ?? const [],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          ShiftGlassCard(
            radius: 20,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShiftIconTile.small(
                  icon: Icons.touch_app_outlined,
                  size: 44,
                  iconSize: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    l10n.ownerWeeklyShiftsTipCardBody,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: ShiftDesignTokens.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _showCellActions({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required ScheduleEmployeeItem employee,
    required DateTime date,
    required WeeklyScheduleAssignmentModel? assignment,
    required List<ShiftTemplateModel> shifts,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: ShiftDesignTokens.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatTeamMemberName(employee.name)} • ${DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(date)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: ShiftDesignTokens.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                _SheetActionRow(
                  icon: Icons.event_busy_outlined,
                  label: l10n.ownerWeeklyShiftsMarkOffAction,
                  onTap: () {
                    Navigator.of(context).pop();
                    ref
                        .read(
                          weeklyScheduleAssignmentsControllerProvider.notifier,
                        )
                        .markOff(employee: employee, date: date);
                  },
                ),
                if (assignment != null) ...[
                  const Divider(height: 1),
                  _SheetActionRow(
                    icon: Icons.delete_outline,
                    label: l10n.ownerWeeklyShiftsRemoveAssignmentAction,
                    onTap: () {
                      Navigator.of(context).pop();
                      ref
                          .read(
                            weeklyScheduleAssignmentsControllerProvider
                                .notifier,
                          )
                          .remove(assignmentId: assignment.id);
                    },
                  ),
                ],
                if (shifts.isNotEmpty)
                  for (final shift in shifts) ...[
                    const Divider(height: 1),
                    _SheetActionRow(
                      icon: Icons.swap_horiz_rounded,
                      label:
                          '${l10n.ownerWeeklyShiftsAssignAction} ${shift.name}',
                      onTap: () {
                        Navigator.of(context).pop();
                        ref
                            .read(
                              weeklyScheduleAssignmentsControllerProvider
                                  .notifier,
                            )
                            .assignShift(
                              employee: employee,
                              date: date,
                              shift: shift,
                            );
                      },
                    ),
                  ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _weekRangeLabel(BuildContext context, DateTime start) {
    final locale = Localizations.localeOf(context).languageCode;
    final end = start.add(const Duration(days: 6));
    final fmt = DateFormat('MMM d', locale);
    return '${fmt.format(start)} - ${fmt.format(end)}';
  }
}

DateTime _weekStartSaturday(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  final daysFromSaturday = (normalized.weekday + 1) % 7;
  return normalized.subtract(Duration(days: daysFromSaturday));
}

class _SegmentedWeekToggle extends StatelessWidget {
  const _SegmentedWeekToggle({
    required this.weekStart,
    required this.thisWeekLabel,
    required this.nextWeekLabel,
    required this.onThisWeek,
    required this.onNextWeek,
  });

  final DateTime weekStart;
  final String thisWeekLabel;
  final String nextWeekLabel;
  final VoidCallback onThisWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context) {
    final thisAnchor = _weekStartSaturday(DateTime.now());
    final nextAnchor = thisAnchor.add(const Duration(days: 7));
    final isThis = weekStart == thisAnchor;
    final isNext = weekStart == nextAnchor;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ShiftDesignTokens.offGray,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ShiftDesignTokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegCell(
              label: thisWeekLabel,
              selected: isThis,
              onTap: onThisWeek,
            ),
          ),
          Expanded(
            child: _SegCell(
              label: nextWeekLabel,
              selected: isNext,
              onTap: onNextWeek,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegCell extends StatelessWidget {
  const _SegCell({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: selected
                    ? ShiftDesignTokens.primary
                    : ShiftDesignTokens.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplyMonthPill extends StatelessWidget {
  const _ApplyMonthPill({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: SizedBox(
        width: 118,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [Color(0xFF5E35D8), Color(0xFF9B4DFF)],
                  )
                : null,
            color: enabled ? null : ShiftDesignTokens.border,
            borderRadius: BorderRadius.circular(22),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: ShiftDesignTokens.primary.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: enabled ? onTap : null,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      color: enabled
                          ? Colors.white
                          : ShiftDesignTokens.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      height: 1.15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetActionRow extends StatelessWidget {
  const _SheetActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, color: ShiftDesignTokens.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ShiftDesignTokens.textDark,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ShiftDesignTokens.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
