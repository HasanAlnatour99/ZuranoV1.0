import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/formatting/staff_role_localized.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../owner/presentation/widgets/team_member_card.dart';
import '../../domain/team_member_card_vm.dart';
import '../theme/team_card_palette.dart';
import 'animated_performance_wave.dart';
import 'performance_stars.dart';

String _teamCardPersonName(TeamMemberCardVm m, AppLocalizations l10n) {
  final t = formatTeamMemberName(m.name);
  if (t.isEmpty) {
    return l10n.teamCardNameMissing;
  }
  return t;
}

class TeamDeckCard extends StatelessWidget {
  const TeamDeckCard({
    super.key,
    required this.member,
    required this.onProfileTap,
    required this.onMenuSelected,
  });

  final TeamMemberCardVm member;
  final VoidCallback onProfileTap;
  final void Function(TeamMemberCardMenuAction action) onMenuSelected;

  static const double _cardRadius = ZuranoTokens.radiusSection;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      constraints: const BoxConstraints(minHeight: 168),
      decoration: BoxDecoration(
        color: TeamCardPalette.cardBackground,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(
          color: ZuranoPremiumUiColors.border.withValues(alpha: 0.65),
          width: 1,
        ),
        boxShadow: ZuranoTokens.softCardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Material(
          color: Colors.transparent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Wide enough to read clearly on pastel cards (performance side).
              final waveW = constraints.maxWidth * 0.46;
              final isRtl = Directionality.of(context) == TextDirection.rtl;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // LTR: physical right. RTL (Arabic): physical left + mirrored wave.
                  Positioned(
                    left: isRtl ? 0 : null,
                    right: isRtl ? null : 0,
                    top: 0,
                    bottom: 0,
                    width: waveW,
                    child: AnimatedPerformanceWave(
                      rating: member.rating,
                      hasPerformanceData: member.hasPerformanceData,
                      mirrorHorizontally: isRtl,
                    ),
                  ),
                  _FullCardContent(
                    member: member,
                    l10n: l10n,
                    onProfileTap: onProfileTap,
                    onMenuSelected: onMenuSelected,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

}

class _FullCardContent extends StatelessWidget {
  const _FullCardContent({
    required this.member,
    required this.l10n,
    required this.onProfileTap,
    required this.onMenuSelected,
  });

  final TeamMemberCardVm member;
  final AppLocalizations l10n;
  final VoidCallback onProfileTap;
  final void Function(TeamMemberCardMenuAction action) onMenuSelected;

  @override
  Widget build(BuildContext context) {
    final roleLine = localizedStaffRole(l10n, member.roleFirestore);
    final attendLabel = _attendanceLabel(l10n, member.attendanceState);
    final statusPill = TeamCardPalette.statusMiniPill(member.isActive);
    final attendPill = TeamCardPalette.attendanceMiniPill(member.attendanceState);
    final perfPill = TeamCardPalette.performanceMiniPill();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MemberAvatar(member: member, size: 64),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _teamCardPersonName(member, l10n),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  color: ZuranoPremiumUiColors.textPrimary,
                                  fontSize: 19,
                                  height: 1.05,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.25,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                roleLine,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  color: ZuranoPremiumUiColors.primaryPurple,
                                  fontSize: 13,
                                  height: 1.1,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 4, top: 2),
                child: _DeckMenuButton(
                  member: member,
                  l10n: l10n,
                  onMenuSelected: onMenuSelected,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: _TeamDeckMiniPill(
                      icon: Icons.verified_user_rounded,
                      title: l10n.teamCardChipLabelStatus,
                      value: member.isActive
                          ? l10n.teamValueEnabled
                          : l10n.teamValueDisabled,
                      backgroundColor: statusPill.bg,
                      borderColor: statusPill.border,
                      titleColor: statusPill.fg,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TeamDeckMiniPill(
                      icon: _attendanceIcon(member.attendanceState),
                      title: l10n.teamCardChipLabelAttendToday,
                      value: attendLabel,
                      backgroundColor: attendPill.bg,
                      borderColor: attendPill.border,
                      titleColor: attendPill.fg,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TeamDeckMiniPill(
                      icon: Icons.star_rounded,
                      title: l10n.teamMemberPerformance,
                      customChild: Semantics(
                        label: member.hasPerformanceData
                            ? null
                            : l10n.teamMemberPerformanceUnrated,
                        child: PerformanceStars(
                          rating: member.rating,
                          compact: true,
                          hasPerformanceData: member.hasPerformanceData,
                          color: TeamCardPalette.goldStar,
                        ),
                      ),
                      backgroundColor: perfPill.bg,
                      borderColor: perfPill.border,
                      titleColor: perfPill.fg,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _attendanceIcon(TeamAttendanceState state) {
    return switch (state) {
      TeamAttendanceState.working => Icons.monitor_heart_rounded,
      TeamAttendanceState.completed => Icons.event_available_rounded,
      TeamAttendanceState.absent => Icons.event_busy_rounded,
      TeamAttendanceState.dayOff => Icons.beach_access_rounded,
      TeamAttendanceState.notCheckedIn => Icons.access_time_rounded,
    };
  }

  String _attendanceLabel(AppLocalizations l10n, TeamAttendanceState state) {
    return switch (state) {
      TeamAttendanceState.working => l10n.teamCardAttendWorking,
      TeamAttendanceState.completed => l10n.teamCardAttendCompleted,
      TeamAttendanceState.absent => l10n.teamCardAttendAbsent,
      TeamAttendanceState.dayOff => l10n.teamCardAttendTodayOff,
      TeamAttendanceState.notCheckedIn => l10n.teamCardAttendNoCheckIn,
    };
  }

}

class _TeamDeckMiniPill extends StatelessWidget {
  const _TeamDeckMiniPill({
    required this.icon,
    required this.title,
    this.value,
    this.customChild,
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
  }) : assert(
         (value != null) ^ (customChild != null),
         'Provide exactly one of value or customChild',
       );

  final IconData icon;
  final String title;
  final String? value;
  final Widget? customChild;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusInput),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: isRtl
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: Directionality.of(context),
            children: [
              Icon(icon, size: 13, color: titleColor),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: isRtl ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          if (customChild != null)
            Align(
              alignment: isRtl
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: customChild!,
            )
          else
            Text(
              value ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: ZuranoPremiumUiColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member, required this.size});

  final TeamMemberCardVm member;
  final double size;

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return '?';
    }
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
    final url = member.profileImageUrl;
    final hasPhoto = url != null && url.trim().isNotEmpty;
    final initials = member.name.trim().isEmpty ? '?' : _initials(member.name);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: ZuranoTokens.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: ZuranoTokens.primary.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: SizedBox(
              width: size - 6,
              height: size - 6,
              child: hasPhoto
                  ? CachedNetworkImage(
                      imageUrl: url.trim(),
                      fit: BoxFit.cover,
                      width: size - 6,
                      height: size - 6,
                      placeholder: (context, progress) => ColoredBox(
                        color: theme.colorScheme.surfaceContainerHigh,
                        child: Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: ZuranoPremiumUiColors.primaryPurple,
                              fontSize: size * 0.34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => ColoredBox(
                        color: theme.colorScheme.surfaceContainerHigh,
                        child: Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: ZuranoPremiumUiColors.primaryPurple,
                              fontSize: size * 0.34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    )
                  : ColoredBox(
                      color: ZuranoTokens.lightPurple,
                      child: Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: ZuranoPremiumUiColors.primaryPurple,
                            fontSize: size * 0.34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
        PositionedDirectional(
          end: -1,
          bottom: size * 0.08,
          child: Container(
            width: size * 0.24,
            height: size * 0.24,
            decoration: BoxDecoration(
              color: member.isWorkingNow
                  ? const Color(0xFF18B957)
                  : theme.colorScheme.outlineVariant,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _DeckMenuButton extends StatelessWidget {
  const _DeckMenuButton({
    required this.member,
    required this.l10n,
    required this.onMenuSelected,
  });

  final TeamMemberCardVm member;
  final AppLocalizations l10n;
  final void Function(TeamMemberCardMenuAction action) onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ZuranoPremiumUiColors.cardBackground,
      elevation: 0,
      shape: CircleBorder(
        side: BorderSide(
          color: ZuranoPremiumUiColors.border.withValues(alpha: 0.9),
        ),
      ),
      shadowColor: Colors.transparent,
      child: PopupMenuButton<TeamMemberCardMenuAction>(
        tooltip: l10n.teamMemberMoreActions,
        padding: EdgeInsets.zero,
        color: ZuranoPremiumUiColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        elevation: 10,
        icon: const Icon(
          Icons.more_vert_rounded,
          size: 20,
          color: ZuranoPremiumUiColors.primaryPurple,
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
              member.isActive
                  ? l10n.teamMemberDeactivateAction
                  : l10n.teamMemberActivateAction,
            ),
          ),
        ],
      ),
    );
  }
}
