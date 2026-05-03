import 'package:flutter/material.dart';

import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../logic/owner_overview_state.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

/// Operational team snapshot with up to three barber rows.
class TeamStatusCard extends StatelessWidget {
  const TeamStatusCard({
    super.key,
    required this.state,
    required this.onSeeAll,
    this.onMarkAttendance,
    this.showMarkAttendance = false,
    this.onAddBarber,
    this.onAddService,
    this.onCreateBooking,
  });

  final OwnerOverviewState state;
  final VoidCallback onSeeAll;
  final VoidCallback? onMarkAttendance;
  final bool showMarkAttendance;
  final VoidCallback? onAddBarber;
  final VoidCallback? onAddService;
  final VoidCallback? onCreateBooking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final hasBarbers = state.activeBarberCount > 0;

    return AppSurfaceCard(
      borderRadius: AppRadius.large,
      padding: const EdgeInsets.all(18),
      showShadow: false,
      outlineOpacity: 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(AppIcons.groups_outlined, color: scheme.primary, size: 22),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ownerOverviewTeamCardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small / 2),
                    Wrap(
                      spacing: AppSpacing.small,
                      runSpacing: AppSpacing.small / 2,
                      children: [
                        if (showMarkAttendance && onMarkAttendance != null)
                          _HeaderActionButton(
                            label: l10n.ownerOverviewTeamMarkAttendance,
                            onPressed: onMarkAttendance!,
                          ),
                        _HeaderActionButton(
                          label: l10n.ownerOverviewSeeAll,
                          onPressed: onSeeAll,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.ownerOverviewTeamActiveBarbersLabel(state.activeBarberCount),
            textAlign: TextAlign.start,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.92),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.ownerOverviewTeamCheckedInShort(state.checkedInBarbersToday),
            textAlign: TextAlign.start,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 12),
          if (!hasBarbers)
            _TeamEmptyState(
              l10n: l10n,
              scheme: scheme,
              theme: theme,
              onAddBarber: onAddBarber,
              onAddService: onAddService,
              onCreateBooking: onCreateBooking,
            )
          else
            for (var i = 0; i < state.teamBarberPreview.length; i++) ...[
              _TeamBarberRow(
                row: state.teamBarberPreview[i],
                l10n: l10n,
                theme: theme,
                scheme: scheme,
              ),
              if (i < state.teamBarberPreview.length - 1)
                Divider(
                  height: AppSpacing.medium,
                  color: scheme.outlineVariant.withValues(alpha: 0.65),
                ),
            ],
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TeamEmptyState extends StatelessWidget {
  const _TeamEmptyState({
    required this.l10n,
    required this.scheme,
    required this.theme,
    this.onAddBarber,
    this.onAddService,
    this.onCreateBooking,
  });

  final AppLocalizations l10n;
  final ColorScheme scheme;
  final ThemeData theme;
  final VoidCallback? onAddBarber;
  final VoidCallback? onAddService;
  final VoidCallback? onCreateBooking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.small),
                _PlaceholderAvatar(scheme: scheme),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.person_add_alt_outlined,
                color: scheme.primary.withValues(alpha: 0.85),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ownerOverviewTeamEmptyTitle,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.ownerOverviewTeamEmptyBody,
                      textAlign: TextAlign.start,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onAddBarber != null ||
              onAddService != null ||
              onCreateBooking != null) ...[
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: [
                if (onAddBarber != null)
                  OutlinedButton.icon(
                    onPressed: onAddBarber,
                    icon: const Icon(
                      AppIcons.person_add_alt_outlined,
                      size: 18,
                    ),
                    label: Text(l10n.ownerOverviewSmartAddBarber),
                  ),
                if (onAddService != null)
                  OutlinedButton.icon(
                    onPressed: onAddService,
                    icon: const Icon(
                      AppIcons.design_services_outlined,
                      size: 18,
                    ),
                    label: Text(l10n.ownerOverviewSmartAddService),
                  ),
                if (onCreateBooking != null)
                  OutlinedButton.icon(
                    onPressed: onCreateBooking,
                    icon: const Icon(
                      AppIcons.event_available_outlined,
                      size: 18,
                    ),
                    label: Text(l10n.ownerOverviewSmartCreateBooking),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PlaceholderAvatar extends StatelessWidget {
  const _PlaceholderAvatar({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Icon(
        AppIcons.person_outline_rounded,
        color: scheme.onSurfaceVariant.withValues(alpha: 0.45),
        size: 22,
      ),
    );
  }
}

class _TeamBarberRow extends StatelessWidget {
  const _TeamBarberRow({
    required this.row,
    required this.l10n,
    required this.theme,
    required this.scheme,
  });

  final OwnerTeamBarberPreview row;
  final AppLocalizations l10n;
  final ThemeData theme;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final displayName = formatTeamMemberName(row.name);
    final initial = displayName.isNotEmpty
        ? displayName.characters.first.toUpperCase()
        : (row.name.trim().isNotEmpty
            ? row.name.trim().characters.first.toUpperCase()
            : '?');
    final statusLabel = _statusLabel(l10n, row.status);
    final activity = (row.activityDetail ?? '').trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small / 2),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: scheme.primary.withValues(alpha: 0.16),
            foregroundColor: scheme.primary,
            child: Text(
              initial,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TeamMemberNameText(
                  row.name,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (activity.isNotEmpty)
                  Text(
                    activity,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.primary.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(AppLocalizations l10n, OwnerTeamBarberStatus s) {
    switch (s) {
      case OwnerTeamBarberStatus.checkedIn:
        return l10n.ownerOverviewTeamStatusCheckedIn;
      case OwnerTeamBarberStatus.notCheckedIn:
        return l10n.ownerOverviewTeamStatusNotCheckedIn;
      case OwnerTeamBarberStatus.onService:
        return l10n.ownerOverviewTeamStatusOnService;
      case OwnerTeamBarberStatus.late:
        return l10n.ownerOverviewTeamStatusLate;
    }
  }
}
