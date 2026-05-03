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
import 'team_card_info_chip.dart';

class PremiumTeamMemberCard extends StatelessWidget {
  const PremiumTeamMemberCard({
    super.key,
    required this.member,
    required this.index,
    required this.onTap,
    required this.onWhatsAppTap,
    required this.onMenuSelected,
    required this.hasPhone,
  });

  final TeamMemberCardVm member;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onWhatsAppTap;
  final void Function(TeamMemberCardMenuAction action) onMenuSelected;
  final bool hasPhone;

  static const Color _waGreen = Color(0xFF25D366);

  static const double _avatarD = 56;
  static const double _radius = ZuranoTokens.radiusSection + 6;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Transform.translate(
      offset: Offset(0, index * 86.0),
      child: Transform.scale(
        scale: 1 - (index * 0.035),
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(_radius),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: TeamCardPalette.cardBackground,
                borderRadius: BorderRadius.circular(_radius),
                border: Border.all(
                  color: ZuranoPremiumUiColors.border.withValues(alpha: 0.65),
                  width: 1,
                ),
                boxShadow: ZuranoTokens.softCardShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_radius),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Align(
                        alignment: isRtl
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: SizedBox(
                          width: 180,
                          child: AnimatedPerformanceWave(
                            rating: member.rating,
                            hasPerformanceData: member.hasPerformanceData,
                            mirrorHorizontally: isRtl,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Avatar(member: member, l10n: l10n),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _premiumDisplayName(member, l10n),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: ZuranoPremiumUiColors
                                                .textPrimary,
                                            letterSpacing: -0.2,
                                          ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      localizedStaffRole(
                                        l10n,
                                        member.roleFirestore,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.start,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: ZuranoPremiumUiColors
                                                .primaryPurple,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: hasPhone
                                        ? IconButton(
                                            tooltip:
                                                l10n.customerDetailsWhatsApp,
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
                                        Icons.more_vert_rounded,
                                        color:
                                            ZuranoPremiumUiColors.primaryPurple,
                                        size: 22,
                                      ),
                                      color:
                                          ZuranoPremiumUiColors.cardBackground,
                                      surfaceTintColor: Colors.transparent,
                                      onSelected: (action) {
                                        if (action ==
                                            TeamMemberCardMenuAction
                                                .viewProfile) {
                                          onTap();
                                        }
                                        onMenuSelected(action);
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: TeamMemberCardMenuAction
                                              .viewProfile,
                                          child: Text(
                                            l10n.teamMemberViewProfileAction,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: TeamMemberCardMenuAction.edit,
                                          child: Text(
                                            l10n.teamMemberEditAction,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: TeamMemberCardMenuAction
                                              .attendance,
                                          child: Text(
                                            l10n.teamMemberAttendanceAction,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value:
                                              TeamMemberCardMenuAction.payroll,
                                          child: Text(
                                            l10n.teamMemberPayrollAction,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: TeamMemberCardMenuAction
                                              .toggleActive,
                                          child: Text(
                                            member.isActive
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
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.start,
                            children: [
                              TeamCardInfoChip(
                                icon: Icons.verified_user_rounded,
                                label: l10n.teamCardChipLabelStatus,
                                value: member.isActive
                                    ? l10n.teamValueEnabled
                                    : l10n.teamValueDisabled,
                                tone: member.isActive
                                    ? TeamCardChipTone.green
                                    : TeamCardChipTone.red,
                              ),
                              TeamCardInfoChip(
                                icon: Icons.event_available_rounded,
                                label: l10n.teamCardChipLabelAttendToday,
                                value: _attendanceLabel(
                                  l10n,
                                  member.attendanceState,
                                ),
                                tone: _attendanceTone(member.attendanceState),
                              ),
                              TeamCardInfoChip(
                                icon: Icons.star_rounded,
                                label: l10n.teamMemberPerformance,
                                customValue: Semantics(
                                  label: member.hasPerformanceData
                                      ? null
                                      : l10n.teamMemberPerformanceUnrated,
                                  child: PerformanceStars(
                                    rating: member.rating,
                                    compact: true,
                                    hasPerformanceData:
                                        member.hasPerformanceData,
                                    color: TeamCardPalette.goldStar,
                                  ),
                                ),
                                tone: TeamCardChipTone.purple,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _premiumDisplayName(TeamMemberCardVm m, AppLocalizations l10n) {
    final t = formatTeamMemberName(m.name);
    if (t.isEmpty) {
      return l10n.teamCardNameMissing;
    }
    return t;
  }

  static String _attendanceLabel(
    AppLocalizations l10n,
    TeamAttendanceState state,
  ) {
    return switch (state) {
      TeamAttendanceState.working => l10n.teamCardAttendWorking,
      TeamAttendanceState.completed => l10n.teamCardAttendCompleted,
      TeamAttendanceState.absent => l10n.teamCardAttendAbsent,
      TeamAttendanceState.dayOff => l10n.teamCardAttendTodayOff,
      TeamAttendanceState.notCheckedIn => l10n.teamCardAttendNoCheckIn,
    };
  }

  static TeamCardChipTone _attendanceTone(TeamAttendanceState state) {
    return switch (state) {
      TeamAttendanceState.working => TeamCardChipTone.orange,
      TeamAttendanceState.completed => TeamCardChipTone.green,
      TeamAttendanceState.absent => TeamCardChipTone.red,
      TeamAttendanceState.dayOff => TeamCardChipTone.dayOff,
      TeamAttendanceState.notCheckedIn => TeamCardChipTone.pendingCheckIn,
    };
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.member, required this.l10n});

  final TeamMemberCardVm member;
  final AppLocalizations l10n;

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
    final hasPhoto = url != null && url.isNotEmpty;
    final formatted = formatTeamMemberName(member.name);
    final initials = formatted.isEmpty ? '?' : _initials(formatted);
    final active = member.isActive;

    return SizedBox(
      width: PremiumTeamMemberCard._avatarD,
      height: PremiumTeamMemberCard._avatarD,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipOval(
              child: hasPhoto
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (context, _) => ColoredBox(
                        color: theme.colorScheme.surfaceContainerHigh,
                        child: Center(
                          child: Text(
                            initials,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: ZuranoPremiumUiColors.textPrimary,
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
                              color: ZuranoPremiumUiColors.textPrimary,
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
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: ZuranoPremiumUiColors.primaryPurple,
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
                    ? const Color(0xFF16A34A)
                    : theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.45,
                      ),
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
