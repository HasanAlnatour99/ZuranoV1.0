import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../data/models/shift_template_model.dart';
import '../providers/shift_providers.dart';
import '../widgets/shift_stats_panel.dart';
import '../widgets/shift_template_card.dart';
import '../widgets/shift_ui/shift_design_tokens.dart';
import '../widgets/shift_ui/shift_glass_card.dart';
import '../widgets/shift_ui/shift_gradient_button.dart';
import '../widgets/shift_ui/shift_hero_header.dart';
import '../widgets/shift_ui/shift_icon_button.dart';
import '../widgets/shift_ui/shift_icon_tile.dart';
import '../widgets/shift_ui/shift_page_shell.dart';
import '../widgets/shift_ui/shift_section_header.dart';

class ShiftsSettingsScreen extends ConsumerStatefulWidget {
  const ShiftsSettingsScreen({super.key});

  @override
  ConsumerState<ShiftsSettingsScreen> createState() =>
      _ShiftsSettingsScreenState();
}

class _ShiftsSettingsScreenState extends ConsumerState<ShiftsSettingsScreen> {
  Future<void> _confirmDeactivateTemplate(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    String templateId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.smartWorkspaceConfirmationTitle),
          content: Text(l10n.ownerShiftsDeleteConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.ownerServiceActionDelete),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      await ref
          .read(deactivateShiftTemplateControllerProvider.notifier)
          .deactivate(templateId);
    }
  }

  Future<void> _openReorderSheet(
    BuildContext context,
    AppLocalizations l10n,
    List<ShiftTemplateModel> templates,
  ) async {
    final ordered = List<ShiftTemplateModel>.from(templates);
    final saveNotifier = ref.read(
      reorderShiftTemplatesControllerProvider.notifier,
    );
    var isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.74,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.ownerShiftsTemplatesReorder,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: ShiftDesignTokens.textDark,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: isSaving
                                ? null
                                : () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        itemCount: ordered.length,
                        onReorder: (oldIndex, newIndex) {
                          setSheetState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = ordered.removeAt(oldIndex);
                            ordered.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final template = ordered[index];
                          return Container(
                            key: ValueKey<String>(template.id),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: ShiftDesignTokens.border,
                              ),
                              color: ShiftDesignTokens.card,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 2,
                              ),
                              title: Text(
                                template.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: ShiftDesignTokens.textDark,
                                ),
                              ),
                              subtitle: Text(
                                template.type == 'off'
                                    ? l10n.ownerShiftsOffDay
                                    : '${template.startTime ?? '--:--'} - ${template.endTime ?? '--:--'}',
                                style: const TextStyle(
                                  color: ShiftDesignTokens.textMuted,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.drag_handle_rounded,
                                color: ShiftDesignTokens.textMuted,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: ShiftGradientButton(
                        label: l10n.ownerShiftsTemplatesReorder,
                        onPressed: isSaving
                            ? null
                            : () async {
                                setSheetState(() => isSaving = true);
                                try {
                                  await saveNotifier.reorder(
                                    ordered
                                        .map((template) => template.id)
                                        .toList(growable: false),
                                  );
                                  if (!context.mounted) {
                                    return;
                                  }
                                  Navigator.of(sheetContext).pop();
                                } finally {
                                  if (context.mounted) {
                                    setSheetState(() => isSaving = false);
                                  }
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final templatesAsync = ref.watch(shiftTemplatesStreamProvider);
    final deactivateState = ref.watch(
      deactivateShiftTemplateControllerProvider,
    );
    final reorderState = ref.watch(reorderShiftTemplatesControllerProvider);

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
            title: l10n.ownerShiftsTitle,
            subtitle: l10n.ownerShiftsSubtitle,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.ownerSettings);
              }
            },
            trailingActions: [
              ShiftIconButton(
                icon: Icons.calendar_month_rounded,
                onPressed: () =>
                    context.pushNamed(AppRouteNames.ownerWeeklyShifts),
              ),
            ],
          ),
          const SizedBox(height: 22),
          templatesAsync.when(
            loading: () => const _LoadingBlock(),
            error: (error, _) => _ErrorBlock(
              onRetry: () => ref.invalidate(shiftTemplatesStreamProvider),
              label: l10n.ownerShiftsRetry,
              message: l10n.ownerShiftsLoadError,
            ),
            data: (templates) {
              final children = <Widget>[
                ShiftStatsPanel(
                  totalShifts: templates.length,
                  assignedStaffCount: 0,
                  totalShiftsLabel: l10n.ownerShiftsSummaryTotalShifts,
                  assignedStaffLabel: l10n.ownerShiftsSummaryAssignedStaff,
                  templatesLabel: l10n.ownerShiftsSummaryTemplates,
                  employeesLabel: l10n.ownerShiftsSummaryEmployees,
                ),
                const SizedBox(height: 20),
                ShiftSectionHeader(
                  title: l10n.ownerShiftsTemplatesSectionTitle,
                  trailing: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: templates.isEmpty
                          ? null
                          : () => _openReorderSheet(context, l10n, templates),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        child: Text(
                          l10n.ownerShiftsTemplatesReorder,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ShiftDesignTokens.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ];
              if (templates.isEmpty) {
                children.add(
                  _EmptyStateCard(
                    title: l10n.ownerShiftsEmptyStateTitle,
                    subtitle: l10n.ownerShiftsEmptyStateSubtitle,
                    helper: l10n.ownerShiftsEmptyStateHelper,
                  ),
                );
              } else {
                for (final template in templates) {
                  children.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ShiftTemplateCard(
                        template: template,
                        durationLabel: l10n.ownerShiftsDuration,
                        breakLabel: l10n.ownerShiftsBreak,
                        employeesLabel: l10n.ownerShiftsEmployees,
                        overnightLabel: l10n.ownerShiftsOvernightBadge,
                        offDayLabel: l10n.ownerShiftsOffDay,
                        onEdit: () => context.pushNamed(
                          AppRouteNames.ownerEditShiftTemplate,
                          pathParameters: <String, String>{
                            'shiftId': template.id,
                          },
                        ),
                        onDeactivate: () => _confirmDeactivateTemplate(
                          context,
                          ref,
                          l10n,
                          template.id,
                        ),
                      ),
                    ),
                  );
                }
              }

              children.addAll([
                const SizedBox(height: 14),
                _WeeklyScheduleEntryCard(
                  title: l10n.ownerShiftsOpenWeeklyRosterTitle,
                  subtitle: l10n.ownerShiftsOpenWeeklyRosterSubtitle,
                  onTap: () =>
                      context.pushNamed(AppRouteNames.ownerWeeklyShifts),
                ),
              ]);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              );
            },
          ),
          if (deactivateState.hasError) ...[
            const SizedBox(height: 8),
            Text(
              l10n.ownerShiftsDeactivateError,
              style: const TextStyle(
                fontSize: 13,
                color: ShiftDesignTokens.danger,
              ),
            ),
          ],
          if (reorderState.hasError) ...[
            const SizedBox(height: 8),
            Text(
              l10n.ownerShiftsLoadError,
              style: const TextStyle(
                fontSize: 13,
                color: ShiftDesignTokens.danger,
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 120,
            child: ShiftGlassCard(
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({
    required this.onRetry,
    required this.message,
    required this.label,
  });

  final VoidCallback onRetry;
  final String message;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ShiftGlassCard(
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: ShiftDesignTokens.textDark),
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ShiftDesignTokens.border),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ShiftDesignTokens.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
    required this.helper,
  });

  final String title;
  final String subtitle;
  final String helper;

  @override
  Widget build(BuildContext context) {
    return ShiftGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ShiftDesignTokens.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: ShiftDesignTokens.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            helper,
            style: const TextStyle(
              fontSize: 13,
              color: ShiftDesignTokens.textMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyScheduleEntryCard extends StatelessWidget {
  const _WeeklyScheduleEntryCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ShiftDesignTokens.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(ShiftDesignTokens.cardRadius),
        onTap: onTap,
        child: ShiftGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              const ShiftIconTile(
                icon: Icons.calendar_month_outlined,
                size: 52,
                iconSize: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: ShiftDesignTokens.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: ShiftDesignTokens.textMuted,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ShiftDesignTokens.textMuted,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
