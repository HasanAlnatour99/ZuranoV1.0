import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/formatting/staff_role_localized.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_slidable_actions.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../logic/team_management_providers.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

class BarberListCard extends StatelessWidget {
  const BarberListCard({
    super.key,
    required this.data,
    required this.currencyCode,
    required this.onAddSale,
    required this.onMarkAttendance,
    required this.onViewDetails,
    required this.onEditMember,
    required this.onToggleActive,
    required this.onResetPassword,
  });

  final TeamBarberCardData data;
  final String currencyCode;
  final VoidCallback onAddSale;
  final VoidCallback onMarkAttendance;
  final VoidCallback onViewDetails;
  final VoidCallback onEditMember;
  final VoidCallback onToggleActive;
  final VoidCallback onResetPassword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final timeFormat = DateFormat.jm(locale.toString());
    final initials = _initials(formatTeamMemberName(data.employee.name));
    final roleLabel = localizedStaffRole(l10n, data.employee.role);
    final attendanceLabel = _attendanceLabel(l10n, timeFormat);

    return AppSlidableActions(
      endActions: [
        AppSwipeAction(
          icon: AppIcons.edit_outlined,
          label: l10n.teamMemberEditAction,
          onPressed: onEditMember,
        ),
        AppSwipeAction(
          icon: data.employee.isActive
              ? AppIcons.person_off_outlined
              : AppIcons.verified_user_outlined,
          label: data.employee.isActive
              ? l10n.teamMemberDeactivateAction
              : l10n.teamMemberActivateAction,
          onPressed: onToggleActive,
          isDestructive: data.employee.isActive,
        ),
      ],
      child: AppSurfaceCard(
        borderRadius: AppRadius.large,
        showShadow: false,
        outlineOpacity: 0.2,
        onTap: onViewDetails,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: Text(
                    initials,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TeamMemberNameText(
                        data.employee.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        roleLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusChip(status: data.status),
                    PopupMenuButton<String>(
                      tooltip: l10n.teamMemberMoreActions,
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEditMember();
                          return;
                        }
                        if (value == 'toggle') {
                          onToggleActive();
                          return;
                        }
                        onResetPassword();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(l10n.teamMemberEditAction),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(
                            data.employee.isActive
                                ? l10n.teamMemberDeactivateAction
                                : l10n.teamMemberActivateAction,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'reset',
                          child: Text(l10n.teamMemberResetPasswordPlaceholder),
                        ),
                      ],
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(top: 4),
                        child: Icon(
                          AppIcons.more_horiz_rounded,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: l10n.teamMemberSalesToday,
                    value: formatAppMoney(
                      data.todayMetrics.salesToday,
                      currencyCode,
                      locale,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: _MetricTile(
                    label: l10n.teamMemberServicesToday,
                    value: '${data.todayMetrics.servicesToday}',
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: _MetricTile(
                    label: l10n.teamMemberCommissionToday,
                    value: formatAppMoney(
                      data.todayMetrics.commissionToday,
                      currencyCode,
                      locale,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            Row(
              children: [
                Expanded(
                  child: Text(
                    attendanceLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                _QuickActionButton(
                  icon: AppIcons.add_card_outlined,
                  label: l10n.teamMemberAddSaleAction,
                  onPressed: onAddSale,
                ),
                const SizedBox(width: AppSpacing.small),
                _QuickActionButton(
                  icon: AppIcons.badge_outlined,
                  label: l10n.teamMemberMarkAttendanceAction,
                  onPressed: onMarkAttendance,
                ),
                const SizedBox(width: AppSpacing.small),
                _QuickActionButton(
                  icon: AppIcons.open_in_new_rounded,
                  label: l10n.teamMemberViewDetailsAction,
                  onPressed: onViewDetails,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _attendanceLabel(AppLocalizations l10n, DateFormat timeFormat) {
    final attendance = data.todayAttendance;
    if (attendance == null || attendance.checkInAt == null) {
      return l10n.teamMemberNoAttendanceToday;
    }
    if (attendance.checkOutAt != null) {
      return l10n.teamMemberCheckedOutAt(
        timeFormat.format(attendance.checkOutAt!.toLocal()),
      );
    }
    return l10n.teamMemberCheckedInAt(
      timeFormat.format(attendance.checkInAt!.toLocal()),
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      final value = parts.first;
      return value.substring(0, value.length > 1 ? 2 : 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.small),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkResponse(
        onTap: onPressed,
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TeamMemberStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final (label, color) = switch (status) {
      TeamMemberStatus.active => (
        l10n.teamStatusActive,
        scheme.secondaryContainer,
      ),
      TeamMemberStatus.checkedIn => (
        l10n.teamStatusCheckedIn,
        scheme.primaryContainer,
      ),
      TeamMemberStatus.late => (l10n.teamStatusLate, scheme.errorContainer),
      TeamMemberStatus.inactive => (
        l10n.teamStatusInactive,
        scheme.surfaceContainerHigh,
      ),
    };

    final onColor = switch (status) {
      TeamMemberStatus.active => scheme.onSecondaryContainer,
      TeamMemberStatus.checkedIn => scheme.onPrimaryContainer,
      TeamMemberStatus.late => scheme.onErrorContainer,
      TeamMemberStatus.inactive => scheme.onSurfaceVariant,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: onColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
