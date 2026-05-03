import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/formatting/staff_role_localized.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import '../../../attendance/data/models/attendance_record.dart';
import '../../../employees/data/models/employee.dart';
import '../../logic/team_management_providers.dart';

/// Menu actions for the team member overflow menu (owner team list).
enum TeamMemberCardMenuAction {
  viewProfile,
  edit,
  attendance,
  payroll,
  toggleActive,
}

/// Premium compact card for a single team row on the owner Team tab.
///
/// Data is bound from [TeamBarberCardData] (Firestore-backed [Employee] +
/// derived attendance status).
class TeamMemberCard extends StatelessWidget {
  const TeamMemberCard({
    super.key,
    required this.data,
    required this.onTap,
    required this.onWhatsAppTap,
    required this.onMenuSelected,
  });

  final TeamBarberCardData data;
  final VoidCallback onTap;
  final VoidCallback onWhatsAppTap;
  final void Function(TeamMemberCardMenuAction action) onMenuSelected;

  static const Color _pagePurple = Color(0xFF7C3AED);
  static const Color _border = Color(0xFFE7E2EF);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _successGreen = Color(0xFF16A34A);
  static const Color _softGreenBg = Color(0xFFEAF7EE);
  static const Color _waGreen = Color(0xFF25D366);
  static const Color _orangeBreak = Color(0xFFF97316);

  static const double _avatarD = 56;
  static const double _radius = 28;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final phone = data.employee.phone?.trim();
    final hasPhone = phone != null && phone.isNotEmpty;
    final frozen = data.employee.status.trim().toLowerCase() == 'frozen';
    final layoutTextDir = Directionality.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(_radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              textDirection: TextDirection.ltr,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TeamMemberAvatar(employee: data.employee),
                const SizedBox(width: 14),
                Expanded(
                  child: Directionality(
                    textDirection: layoutTextDir,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TeamMemberNameText(
                          data.employee.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 19,
                            letterSpacing: -0.2,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizedStaffRole(l10n, data.employee.role),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: _pagePurple,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _AccountStatusChip(
                          isActive: data.employee.isActive,
                          frozen: frozen,
                        ),
                        const SizedBox(height: 8),
                        _AttendanceStatusRow(l10n: l10n, data: data),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: hasPhone
                          ? IconButton(
                              tooltip: l10n.customerDetailsWhatsApp,
                              padding: EdgeInsets.zero,
                              onPressed: onWhatsAppTap,
                              icon: const Icon(
                                Icons.chat_rounded,
                                color: _waGreen,
                                size: 22,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: PopupMenuButton<TeamMemberCardMenuAction>(
                        tooltip: l10n.teamMemberMoreActions,
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          AppIcons.more_horiz_rounded,
                          color: _textMuted,
                          size: 22,
                        ),
                        onSelected: onMenuSelected,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: TeamMemberCardMenuAction.viewProfile,
                            child: Text(l10n.teamMemberViewProfileAction),
                          ),
                          PopupMenuItem(
                            value: TeamMemberCardMenuAction.edit,
                            child: Text(l10n.teamMemberEditAction),
                          ),
                          PopupMenuItem(
                            value: TeamMemberCardMenuAction.attendance,
                            child: Text(l10n.teamMemberAttendanceAction),
                          ),
                          PopupMenuItem(
                            value: TeamMemberCardMenuAction.payroll,
                            child: Text(l10n.teamMemberPayrollAction),
                          ),
                          PopupMenuItem(
                            value: TeamMemberCardMenuAction.toggleActive,
                            child: Text(
                              data.employee.isActive
                                  ? l10n.teamMemberDeactivateAction
                                  : l10n.teamMemberActivateAction,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamMemberAvatar extends StatelessWidget {
  const _TeamMemberAvatar({required this.employee});

  final Employee employee;

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final v = parts.first;
      return v.substring(0, v.length > 1 ? 2 : 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = employee.avatarUrl?.trim();
    final hasPhoto = url != null && url.isNotEmpty;
    final initials = _initials(formatTeamMemberName(employee.name));
    final active = employee.isActive;

    return SizedBox(
      width: TeamMemberCard._avatarD,
      height: TeamMemberCard._avatarD,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipOval(
              child: hasPhoto
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => ColoredBox(
                        color: theme.colorScheme.surfaceContainerHigh,
                        child: Center(
                          child: Text(
                            initials,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: TeamMemberCard._textDark,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => ColoredBox(
                        color: theme.colorScheme.surfaceContainerHigh,
                        child: Center(
                          child: Text(
                            initials,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: TeamMemberCard._textDark,
                            ),
                          ),
                        ),
                      ),
                    )
                  : ColoredBox(
                      color: const Color(0xFFEDE3FF),
                      child: Center(
                        child: Text(
                          initials,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: TeamMemberCard._pagePurple,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          PositionedDirectional(
            end: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: active
                    ? TeamMemberCard._successGreen
                    : TeamMemberCard._textMuted.withValues(alpha: 0.45),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountStatusChip extends StatelessWidget {
  const _AccountStatusChip({required this.isActive, required this.frozen});

  final bool isActive;
  final bool frozen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (frozen) {
      return _chip(
        theme,
        label: l10n.teamCardAccountFrozen,
        fg: const Color(0xFFB3261E),
        bg: const Color(0xFFF9DEDC),
        border: const Color(0xFFB3261E).withValues(alpha: 0.25),
      );
    }
    if (!isActive) {
      return _chip(
        theme,
        label: l10n.teamValueDisabled,
        fg: TeamMemberCard._textMuted,
        bg: const Color(0xFFF3F4F6),
        border: TeamMemberCard._textMuted.withValues(alpha: 0.2),
      );
    }
    return _chip(
      theme,
      label: l10n.teamValueEnabled,
      fg: TeamMemberCard._successGreen,
      bg: TeamMemberCard._softGreenBg,
      border: TeamMemberCard._successGreen.withValues(alpha: 0.2),
    );
  }

  Widget _chip(
    ThemeData theme, {
    required String label,
    required Color fg,
    required Color bg,
    required Color border,
  }) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: fg,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _AttendanceStatusRow extends StatelessWidget {
  const _AttendanceStatusRow({required this.l10n, required this.data});

  final AppLocalizations l10n;
  final TeamBarberCardData data;

  static bool _onBreak(AttendanceRecord? a) {
    if (a == null) return false;
    final s = a.status.toLowerCase();
    return s.contains('break');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final timeFormat = DateFormat.jm(locale.toString());
    final emp = data.employee;
    final a = data.todayAttendance;

    late final IconData icon;
    late final String label;
    late final Color color;

    if (!emp.isActive) {
      icon = AppIcons.circle_outlined;
      label = l10n.teamMemberInactiveStatus;
      color = TeamMemberCard._textMuted;
    } else if (!emp.attendanceRequired) {
      icon = AppIcons.event_busy_outlined;
      label = l10n.teamCardAttendanceNotRequired;
      color = TeamMemberCard._textMuted;
    } else if (a == null || a.checkInAt == null) {
      icon = AppIcons.schedule_outlined;
      label = l10n.teamMemberNotCheckedIn;
      color = TeamMemberCard._textMuted;
    } else if (a.checkOutAt != null) {
      icon = AppIcons.check_circle_outline;
      label = l10n.teamMemberCheckedOutAt(
        timeFormat.format(a.checkOutAt!.toLocal()),
      );
      color = TeamMemberCard._textMuted;
    } else if (_onBreak(a)) {
      icon = Icons.coffee_rounded;
      label = l10n.teamCardAttendanceOnBreak;
      color = TeamMemberCard._orangeBreak;
    } else if (data.status == TeamMemberStatus.late ||
        a.minutesLate > 0 ||
        a.status.toLowerCase() == 'late') {
      icon = AppIcons.timelapse_outlined;
      label = l10n.teamMemberLateAt(timeFormat.format(a.checkInAt!.toLocal()));
      color = TeamMemberCard._orangeBreak;
    } else {
      icon = AppIcons.check_circle_outline;
      label = l10n.teamMemberCheckedInAt(
        timeFormat.format(a.checkInAt!.toLocal()),
      );
      color = TeamMemberCard._successGreen;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}
