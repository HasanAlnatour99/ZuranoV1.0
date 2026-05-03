import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/motion/app_motion_widgets.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/repository_providers.dart';
import '../../logic/team_management_providers.dart';
import 'add_barber_sheet.dart';
import '../../../team/application/team_cards_provider.dart';
import '../../../team/presentation/widgets/stacked_team_deck.dart';
import '../../../team/presentation/widgets/team_empty_state_card.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import 'team_member_card.dart';
import '../../../../providers/money_currency_providers.dart';

class TeamOperationsModule extends ConsumerStatefulWidget {
  const TeamOperationsModule({super.key, required this.salonId});

  final String salonId;

  @override
  ConsumerState<TeamOperationsModule> createState() =>
      _TeamOperationsModuleState();
}

class _TeamOperationsModuleState extends ConsumerState<TeamOperationsModule> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('✅ NEW TeamOperationsModule rendering');
    }
    final l10n = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(teamSummaryProvider);
    final analyticsAsync = ref.watch(teamAnalyticsProvider);
    final allCardsAsync = ref.watch(teamBarberCardsProvider);
    final cardsAsync = ref.watch(filteredTeamBarberCardsProvider);
    final selectedFilter = ref.watch(teamFilterProvider);
    final searchQuery = ref.watch(teamSearchQueryProvider);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    final hasError =
        summaryAsync.hasError || allCardsAsync.hasError || cardsAsync.hasError;
    final isLoading =
        summaryAsync.isLoading ||
        allCardsAsync.isLoading ||
        cardsAsync.isLoading;
    final hasTeamMembers = allCardsAsync.asData?.value.isNotEmpty ?? false;
    final hasNoEmployees = (allCardsAsync.asData?.value.isEmpty) ?? false;
    final hasNoFilteredResults =
        hasTeamMembers && (cardsAsync.asData?.value.isEmpty ?? false);
    final filterLabel = selectedFilter == TeamFilter.all
        ? null
        : _filterLabel(l10n, selectedFilter);
    final trimmedSearchQuery = searchQuery.trim();

    return Stack(
      children: [
        AppMotionPlayback(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
            children: [
              _TeamTitleRow(
                onAnalyticsPressed: () =>
                    _showAnalyticsSheet(context, analyticsAsync, currencyCode),
              ),
              const SizedBox(height: AppSpacing.large),
              if (isLoading)
                const _TeamModuleLoadingState()
              else if (hasError)
                AppEmptyState(
                  title: l10n.teamLoadErrorTitle,
                  message: l10n.genericError,
                  icon: AppIcons.groups_outlined,
                  centerContent: true,
                )
              else ...[
                AppEntranceMotion(
                  motionId: 'team-summary-strip',
                  child: _TeamStatsRow(
                    summary: summaryAsync.requireValue,
                    currencyCode: currencyCode,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                _TeamFilterChips(
                  selectedFilter: selectedFilter,
                  onSelected: (value) =>
                      ref.read(teamFilterProvider.notifier).setFilter(value),
                ),
                const SizedBox(height: AppSpacing.medium),
                _TeamSearchRow(
                  controller: _searchController,
                  selectedSort: ref.watch(teamSortProvider),
                  onChanged: (value) => ref
                      .read(teamSearchQueryProvider.notifier)
                      .setQuery(value),
                  onSortPressed: () => _showSortSheet(
                    context,
                    selectedSort: ref.read(teamSortProvider),
                    onSelected: (value) =>
                        ref.read(teamSortProvider.notifier).setSort(value),
                  ),
                  onFilterPressed: () => _showFiltersSheet(
                    context,
                    selectedFilter: ref.read(teamFilterProvider),
                    onSelected: (value) =>
                        ref.read(teamFilterProvider.notifier).setFilter(value),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                AppFadeThroughSwitcher(
                  transitionKey: 'team-filter-${selectedFilter.name}',
                  child: hasNoEmployees
                      ? SafeArea(
                          top: false,
                          child: TeamEmptyStateCard(
                            key: const ValueKey<String>('team-empty-first-use'),
                            isSearchMode: false,
                            searchQuery: '',
                            onPrimaryAction: () => showAddBarberSheet(
                              context,
                              salonId: widget.salonId,
                            ),
                            onSecondaryAction: () =>
                                _showTeamGuideSheet(context),
                          ),
                        )
                      : hasNoFilteredResults
                      ? SafeArea(
                          top: false,
                          child: TeamEmptyStateCard(
                            key: const ValueKey<String>(
                              'team-empty-search-no-results',
                            ),
                            isSearchMode: true,
                            searchQuery: trimmedSearchQuery,
                            activeFilterLabel: trimmedSearchQuery.isEmpty
                                ? filterLabel
                                : null,
                            onPrimaryAction: () {
                              _searchController.clear();
                              ref
                                  .read(teamSearchQueryProvider.notifier)
                                  .setQuery('');
                              ref
                                  .read(teamFilterProvider.notifier)
                                  .setFilter(TeamFilter.all);
                              ref
                                  .read(teamSortProvider.notifier)
                                  .setSort(TeamSort.nameAsc);
                            },
                            onSecondaryAction: () => showAddBarberSheet(
                              context,
                              salonId: widget.salonId,
                            ),
                          ),
                        )
                      : _TeamStackedCardCollection(
                          key: ValueKey<String>(
                            'team-list-${selectedFilter.name}',
                          ),
                          salonId: widget.salonId,
                          onToggleActive: (data) =>
                              _toggleActiveState(context, ref, data),
                        ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showTeamGuideSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Text(
              AppLocalizations.of(context)!.teamGuideDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      },
    );
  }

  void _showSortSheet(
    BuildContext context, {
    required TeamSort selectedSort,
    required ValueChanged<TeamSort> onSelected,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            0,
            AppSpacing.large,
            AppSpacing.large,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.teamSortSheetTitle,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: [
                  for (final sort in _allTeamSorts)
                    _TeamModernFilterChip(
                      label: _sortLabel(l10n, sort),
                      selected: selectedSort == sort,
                      onTap: () {
                        onSelected(sort);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFiltersSheet(
    BuildContext context, {
    required TeamFilter selectedFilter,
    required ValueChanged<TeamFilter> onSelected,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            0,
            AppSpacing.large,
            AppSpacing.large,
          ),
          child: Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            children: [
              for (final filter in _businessTeamFilters)
                _TeamModernFilterChip(
                  label: _businessFilterLabel(l10n, filter),
                  selected: selectedFilter == filter,
                  onTap: () {
                    onSelected(filter);
                    Navigator.of(sheetContext).pop();
                  },
                  leading: filter == TeamFilter.topSellers
                      ? Icon(
                          AppIcons.workspace_premium_outlined,
                          size: 14,
                          color: scheme.onSurface,
                        )
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnalyticsSheet(
    BuildContext context,
    AsyncValue<TeamAnalyticsData> analyticsAsync,
    String currencyCode,
  ) {
    final locale = Localizations.localeOf(context);
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final scheme = theme.colorScheme;
        final maxSheetHeight = MediaQuery.sizeOf(sheetContext).height * 0.82;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: analyticsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Text(l10n.genericError),
                data: (data) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.65),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.shadow.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1ECFF),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  AppIcons.insights_outlined,
                                  color: Color(0xFF7C3AED),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.teamAnalyticsAction,
                                  textAlign: TextAlign.start,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF5B2BE0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(height: 28, color: scheme.outlineVariant),
                          _analyticsSheetListTile(
                            sheetContext,
                            icon: AppIcons.groups_2_outlined,
                            label: l10n.teamSummaryTotalMembers,
                            value: '${data.totalMembers}',
                          ),
                          _analyticsSheetListTile(
                            sheetContext,
                            icon: AppIcons.how_to_reg_outlined,
                            label: l10n.teamAnalyticsActiveInactiveLabel,
                            value:
                                '${data.activeMembers} / ${data.inactiveMembers}',
                          ),
                          _analyticsSheetListTile(
                            sheetContext,
                            icon: AppIcons.schedule_outlined,
                            label: l10n.teamSummaryWorkingNow,
                            value: '${data.workingNow}',
                          ),
                          _analyticsSheetListTile(
                            sheetContext,
                            icon: AppIcons.event_busy_outlined,
                            label: l10n.teamSummaryAbsentToday,
                            value: '${data.absentToday}',
                          ),
                          _analyticsSheetListTile(
                            sheetContext,
                            icon: AppIcons.payments_outlined,
                            label: l10n.teamSalesRevenueMonth,
                            value: formatAppMoney(
                              data.totalRevenueThisMonth,
                              currencyCode,
                              locale,
                            ),
                          ),
                          _analyticsSheetListTile(
                            sheetContext,
                            icon: AppIcons.design_services_outlined,
                            label: l10n.teamSalesServicesMonth,
                            value: '${data.servicesThisMonth}',
                          ),
                          _analyticsSheetListTile(
                            sheetContext,
                            icon: AppIcons.workspace_premium_outlined,
                            label: l10n.teamAnalyticsTopPerformerLabel,
                            value: data.topPerformerName,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleActiveState(
    BuildContext context,
    WidgetRef ref,
    TeamBarberCardData data,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(employeeRepositoryProvider)
          .setEmployeeActiveState(
            salonId: data.employee.salonId,
            employeeId: data.employee.id,
            isActive: !data.employee.isActive,
          );
      if (context.mounted) {
        showAppSuccessSnackBar(
          context,
          data.employee.isActive
              ? l10n.teamMemberDeactivated(
                  formatTeamMemberName(data.employee.name),
                )
              : l10n.teamMemberActivated(
                  formatTeamMemberName(data.employee.name),
                ),
        );
      }
    } catch (error, stackTrace) {
      developer.log(
        'Failed to toggle team member active state',
        name: 'team.module',
        error: error,
        stackTrace: stackTrace,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.teamSaveErrorGeneric)));
      }
    }
  }

}

Widget _analyticsSheetListTile(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String value,
}) {
  final scheme = Theme.of(context).colorScheme;
  return ListTile(
    contentPadding: EdgeInsets.zero,
    horizontalTitleGap: 10,
    minVerticalPadding: 2,
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECFF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: const Color(0xFF7C3AED), size: 20),
    ),
    title: Text(
      label,
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    ),
    trailing: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 128),
      child: Text(
        value,
        textAlign: TextAlign.end,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
    ),
  );
}

class _TeamTitleRow extends StatelessWidget {
  const _TeamTitleRow({required this.onAnalyticsPressed});

  final VoidCallback onAnalyticsPressed;

  static const Color _purpleAccent = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.teamManagementTitle,
          textAlign: TextAlign.start,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.teamManagementSubtitle,
          textAlign: TextAlign.start,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    final analyticsControl = Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onAnalyticsPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.75),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                AppIcons.insights_outlined,
                size: 20,
                color: _purpleAccent,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.teamAnalyticsAction,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 390) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleBlock,
              const SizedBox(height: AppSpacing.medium),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: analyticsControl,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: AppSpacing.medium),
            Flexible(flex: 0, child: analyticsControl),
          ],
        );
      },
    );
  }
}

class _TeamStatsRow extends StatelessWidget {
  const _TeamStatsRow({required this.summary, required this.currencyCode});

  final TeamSummaryData summary;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 620
            ? (constraints.maxWidth - (AppSpacing.small * 3)) / 4
            : 136.0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _TeamStatCard(
                width: cardWidth,
                icon: AppIcons.groups_2_outlined,
                iconColor: const Color(0xFF7C3AED),
                iconBackground: const Color(0xFFF1ECFF),
                label: l10n.teamSummaryTotalMembers,
                value: '${summary.totalMembers}',
                helper: l10n.teamSummaryTotalMembersHelper,
              ),
              const SizedBox(width: AppSpacing.small),
              _TeamStatCard(
                width: cardWidth,
                icon: AppIcons.how_to_reg_outlined,
                iconColor: const Color(0xFF2E9D45),
                iconBackground: const Color(0xFFEAF8ED),
                label: l10n.teamSummaryWorkingNow,
                value: '${summary.workingNow}',
                helper: l10n.teamSummaryWorkingNowHelper(summary.totalMembers),
              ),
              const SizedBox(width: AppSpacing.small),
              _TeamStatCard(
                width: cardWidth,
                icon: AppIcons.event_busy_outlined,
                iconColor: const Color(0xFFC8752D),
                iconBackground: const Color(0xFFFFF3E8),
                label: l10n.teamSummaryAbsentToday,
                value: '${summary.absentToday}',
                helper: l10n.teamSummaryAbsentTodayHelper,
              ),
              const SizedBox(width: AppSpacing.small),
              _TeamStatCard(
                width: cardWidth,
                icon: AppIcons.payments_outlined,
                iconColor: const Color(0xFF336BD8),
                iconBackground: const Color(0xFFEAF0FF),
                label: l10n.teamSummaryRevenueToday,
                value: formatAppMoney(summary.salesToday, currencyCode, locale),
                helper: l10n.teamSummaryRevenueTodayHelper,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TeamStatCard extends StatelessWidget {
  const _TeamStatCard({
    required this.width,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
    required this.helper,
  });

  final double width;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;
  final String helper;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        color: scheme.surface,
        shadowColor: scheme.shadow.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(height: 14),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                helper,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamFilterChips extends StatelessWidget {
  const _TeamFilterChips({
    required this.selectedFilter,
    required this.onSelected,
  });

  final TeamFilter selectedFilter;
  final ValueChanged<TeamFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: _visibleTeamFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _visibleTeamFilters[index];
          return _TeamModernFilterChip(
            label: _filterLabel(l10n, filter),
            selected: selectedFilter == filter,
            onTap: () => onSelected(filter),
            leading: filter == TeamFilter.topSellers
                ? Icon(
                    AppIcons.workspace_premium_outlined,
                    size: 14,
                    color: scheme.onSurface,
                  )
                : null,
          );
        },
      ),
    );
  }
}

class _TeamModernFilterChip extends StatelessWidget {
  const _TeamModernFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;

  static const Color _purpleA = Color(0xFF7B61FF);
  static const Color _purpleB = Color(0xFF9F7BFF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (selected) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Ink(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              gradient: LinearGradient(
                colors: [_purpleA, _purpleB],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.95)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamSearchRow extends StatelessWidget {
  const _TeamSearchRow({
    required this.controller,
    required this.selectedSort,
    required this.onChanged,
    required this.onSortPressed,
    required this.onFilterPressed,
  });

  final TextEditingController controller;
  final TeamSort selectedSort;
  final ValueChanged<String> onChanged;
  final VoidCallback onSortPressed;
  final VoidCallback onFilterPressed;

  static const double _fieldHeight = 56;
  static const double _radius = 19;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final borderSide = BorderSide(
      color: scheme.outlineVariant.withValues(alpha: 0.55),
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
      side: borderSide,
    );

    final sortActive = selectedSort != TeamSort.nameAsc;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            height: _fieldHeight,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.search,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: l10n.teamSearchHint,
                isDense: true,
                prefixIcon: const Icon(AppIcons.search_rounded, size: 22),
                filled: true,
                fillColor: scheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.medium,
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_radius),
                  borderSide: borderSide,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_radius),
                  borderSide: borderSide,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_radius),
                  borderSide: BorderSide(color: scheme.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        SizedBox(
          width: _fieldHeight,
          height: _fieldHeight,
          child: Material(
            color: scheme.surface,
            shape: shape,
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              tooltip: l10n.teamSortAction,
              onPressed: onSortPressed,
              icon: const Icon(Icons.sort_rounded),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                iconSize: 24,
                foregroundColor:
                    sortActive ? scheme.primary : scheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.small),
        SizedBox(
          width: _fieldHeight,
          height: _fieldHeight,
          child: Material(
            color: scheme.surface,
            shape: shape,
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              tooltip: l10n.teamFilterAction,
              onPressed: onFilterPressed,
              icon: const Icon(AppIcons.tune_rounded),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                iconSize: 24,
                foregroundColor: scheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TeamStackedCardCollection extends ConsumerWidget {
  const _TeamStackedCardCollection({
    super.key,
    required this.salonId,
    required this.onToggleActive,
  });

  final String salonId;
  final ValueChanged<TeamBarberCardData> onToggleActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cardsAsync = ref.watch(filteredTeamBarberCardsProvider);
    final vmsAsync = ref.watch(filteredTeamDeckVmsProvider(salonId));

    return vmsAsync.when(
      loading: () => const _TeamStackedSkeleton(),
      error: (error, _) => AppEmptyState(
        title: l10n.teamLoadErrorTitle,
        message: l10n.genericError,
        icon: AppIcons.groups_outlined,
        centerContent: true,
      ),
      data: (vms) {
        if (!cardsAsync.hasValue) {
          return const _TeamStackedSkeleton();
        }
        final cards = cardsAsync.requireValue;
        if (vms.length != cards.length) {
          return const _TeamStackedSkeleton();
        }
        return AppEntranceMotion(
          motionId: 'team-stack-deck',
          child: StackedTeamDeck(
            members: vms,
            cards: cards,
            onMenuSelected: (data, action) {
              final id = data.employee.id;
              switch (action) {
                case TeamMemberCardMenuAction.viewProfile:
                  context.push(AppRoutes.ownerTeamMemberDetails(id));
                  break;
                case TeamMemberCardMenuAction.edit:
                  showAddBarberSheet(
                    context,
                    salonId: salonId,
                    existing: data.employee,
                  );
                  break;
                case TeamMemberCardMenuAction.attendance:
                  context.push(
                    AppRoutes.ownerTeamMemberDetails(
                      id,
                      tab: 'attendance',
                    ),
                  );
                  break;
                case TeamMemberCardMenuAction.payroll:
                  context.push(
                    AppRoutes.ownerTeamMemberDetails(
                      id,
                      tab: 'payroll',
                    ),
                  );
                  break;
                case TeamMemberCardMenuAction.toggleActive:
                  onToggleActive(data);
                  break;
              }
            },
          ),
        );
      },
    );
  }
}

class _TeamStackedSkeleton extends StatelessWidget {
  const _TeamStackedSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSkeletonBlock(height: 174),
        SizedBox(height: AppSpacing.medium),
        AppSkeletonBlock(height: 174),
        SizedBox(height: AppSpacing.medium),
        AppSkeletonBlock(height: 174),
      ],
    );
  }
}

class _TeamModuleLoadingState extends StatelessWidget {
  const _TeamModuleLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        AppSkeletonBlock(height: 132),
        SizedBox(height: AppSpacing.large),
        AppSkeletonBlock(height: 48),
        SizedBox(height: AppSpacing.medium),
        AppSkeletonBlock(height: 56),
        SizedBox(height: AppSpacing.large),
        AppSkeletonBlock(height: 108),
        SizedBox(height: AppSpacing.medium),
        AppSkeletonBlock(height: 108),
        SizedBox(height: AppSpacing.medium),
        AppSkeletonBlock(height: 108),
      ],
    );
  }
}

const _visibleTeamFilters = <TeamFilter>[
  TeamFilter.all,
  TeamFilter.active,
  TeamFilter.checkedIn,
  TeamFilter.inactive,
  TeamFilter.topSellers,
];

const _businessTeamFilters = <TeamFilter>[
  TeamFilter.topSellers,
  TeamFilter.topServices,
  TeamFilter.topPerformance,
];

const _allTeamSorts = <TeamSort>[
  TeamSort.nameAsc,
  TeamSort.nameDesc,
  TeamSort.roleThenName,
  TeamSort.joinedNewest,
  TeamSort.joinedOldest,
  TeamSort.salesTodayHigh,
  TeamSort.salesMonthHigh,
];

String _filterLabel(AppLocalizations l10n, TeamFilter filter) {
  return switch (filter) {
    TeamFilter.all => l10n.teamFilterAll,
    TeamFilter.active => l10n.teamFilterActive,
    TeamFilter.checkedIn => l10n.teamFilterWorking,
    TeamFilter.inactive => l10n.teamFilterInactive,
    TeamFilter.topSellers => l10n.teamFilterTopPerformers,
    TeamFilter.needsAttention => l10n.teamFilterNeedsAttention,
    TeamFilter.topServices => l10n.teamFilterTopServices,
    TeamFilter.topPerformance => l10n.teamFilterTopPerformance,
  };
}

String _businessFilterLabel(AppLocalizations l10n, TeamFilter filter) {
  return switch (filter) {
    TeamFilter.topSellers => l10n.teamFilterTopSellers,
    TeamFilter.topServices => l10n.teamFilterTopServices,
    TeamFilter.topPerformance => l10n.teamFilterTopPerformance,
    TeamFilter.all => l10n.teamFilterAll,
    TeamFilter.active => l10n.teamFilterActive,
    TeamFilter.checkedIn => l10n.teamFilterWorking,
    TeamFilter.inactive => l10n.teamFilterInactive,
    TeamFilter.needsAttention => l10n.teamFilterNeedsAttention,
  };
}

String _sortLabel(AppLocalizations l10n, TeamSort sort) {
  return switch (sort) {
    TeamSort.nameAsc => l10n.teamSortNameAsc,
    TeamSort.nameDesc => l10n.teamSortNameDesc,
    TeamSort.roleThenName => l10n.teamSortRole,
    TeamSort.joinedNewest => l10n.teamSortJoinedNewest,
    TeamSort.joinedOldest => l10n.teamSortJoinedOldest,
    TeamSort.salesTodayHigh => l10n.teamSortSalesToday,
    TeamSort.salesMonthHigh => l10n.teamSortSalesMonth,
  };
}
