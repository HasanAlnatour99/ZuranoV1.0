import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../logic/team_management_providers.dart';

class TeamFilterBar extends StatelessWidget {
  const TeamFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  final TeamFilter selectedFilter;
  final ValueChanged<TeamFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: l10n.teamFilterAll,
            selected: selectedFilter == TeamFilter.all,
            onTap: () => onSelected(TeamFilter.all),
          ),
          _FilterChip(
            label: l10n.teamFilterActive,
            selected: selectedFilter == TeamFilter.active,
            onTap: () => onSelected(TeamFilter.active),
          ),
          _FilterChip(
            label: l10n.teamFilterWorking,
            selected: selectedFilter == TeamFilter.checkedIn,
            onTap: () => onSelected(TeamFilter.checkedIn),
          ),
          _FilterChip(
            label: l10n.teamFilterInactive,
            selected: selectedFilter == TeamFilter.inactive,
            onTap: () => onSelected(TeamFilter.inactive),
          ),
          _FilterChip(
            label: l10n.teamFilterTopPerformers,
            selected: selectedFilter == TeamFilter.topSellers,
            onTap: () => onSelected(TeamFilter.topSellers),
          ),
          _FilterChip(
            label: l10n.teamFilterNeedsAttention,
            selected: selectedFilter == TeamFilter.needsAttention,
            onTap: () => onSelected(TeamFilter.needsAttention),
          ),
          _FilterChip(
            label: l10n.teamFilterTopServices,
            selected: selectedFilter == TeamFilter.topServices,
            onTap: () => onSelected(TeamFilter.topServices),
          ),
          _FilterChip(
            label: l10n.teamFilterTopPerformance,
            selected: selectedFilter == TeamFilter.topPerformance,
            onTap: () => onSelected(TeamFilter.topPerformance),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: AppSpacing.small),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
