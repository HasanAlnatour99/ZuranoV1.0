import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/formatting/staff_role_localized.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../team_member_profile/presentation/theme/team_member_profile_colors.dart';
import '../../data/models/team_member_model.dart';
import '../theme/team_card_palette.dart';
import 'animated_performance_wave.dart';

class TeamMemberProfileHeader extends StatelessWidget {
  const TeamMemberProfileHeader({
    super.key,
    required this.member,
    required this.l10n,
    required this.localeName,
    this.performanceRating = 0,
    this.hasPerformanceData = false,
  });

  final TeamMemberModel member;
  final AppLocalizations l10n;
  final String localeName;

  /// 0–5 from monthly performance doc when [hasPerformanceData] is true.
  final double performanceRating;

  /// Whether a `performance/{yyyyMM}_{employeeId}` doc exists for this month.
  final bool hasPerformanceData;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final joinDateText = _joinDateText(context);

    final rawUrl = member.profileImageUrl?.trim();
    final hasPhoto = rawUrl != null && rawUrl.isNotEmpty;
    final resolvedUrl = hasPhoto ? rawUrl : '';

    return Container(
      decoration: BoxDecoration(
        color: TeamCardPalette.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: ZuranoPremiumUiColors.border.withValues(alpha: 0.65),
        ),
        boxShadow: ZuranoTokens.softCardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isRtl = Directionality.of(context) == TextDirection.rtl;
            final waveW = constraints.maxWidth * 0.44;
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                PositionedDirectional(
                  end: 0,
                  top: 0,
                  bottom: 0,
                  width: waveW,
                  child: AnimatedPerformanceWave(
                    rating: performanceRating,
                    hasPerformanceData: hasPerformanceData,
                    mirrorHorizontally: isRtl,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: TeamMemberProfileColors.softPurple,
                            backgroundImage: hasPhoto
                                ? CachedNetworkImageProvider(resolvedUrl)
                                : null,
                            child: !hasPhoto
                                ? Text(
                                    member.initials,
                                    style: textTheme.headlineSmall?.copyWith(
                                      color: ZuranoPremiumUiColors.primaryPurple,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                : null,
                          ),
                          PositionedDirectional(
                            end: 3,
                            bottom: 3,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: member.isActive && !member.isFrozen
                                    ? TeamCardPalette.statusOnFg
                                    : scheme.outline,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: TeamCardPalette.cardBackground,
                                  width: 4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TeamMemberNameText(
                              member.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: ZuranoPremiumUiColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              localizedStaffRole(l10n, _roleString(member)),
                              style: textTheme.titleMedium?.copyWith(
                                color: ZuranoPremiumUiColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _StatusBadge(
                              label: _statusLabel(l10n),
                              kind: _statusBadgeKind(member),
                              textTheme: textTheme,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: TeamMemberProfileColors.softPurple,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: TeamMemberProfileColors.border
                                          .withValues(alpha: 0.65),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_outlined,
                                    size: 17,
                                    color: TeamMemberProfileColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    joinDateText,
                                    softWrap: true,
                                    style: textTheme.labelLarge?.copyWith(
                                      color: ZuranoPremiumUiColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  _StatusBadgeKind _statusBadgeKind(TeamMemberModel m) {
    if (m.isFrozen) {
      return _StatusBadgeKind.frozen;
    }
    if (!m.isActive) {
      return _StatusBadgeKind.inactive;
    }
    return _StatusBadgeKind.active;
  }

  String _roleString(TeamMemberModel m) {
    return switch (m.profileRole) {
      TeamMemberProfileRole.owner => 'owner',
      TeamMemberProfileRole.admin => 'admin',
      TeamMemberProfileRole.barber => 'barber',
      TeamMemberProfileRole.teamMember => 'readonly',
    };
  }

  String _statusLabel(AppLocalizations l10n) {
    if (member.isFrozen) return l10n.teamProfileStatusFrozen;
    if (!member.isActive) return l10n.teamStatusInactive;
    return l10n.teamStatusActive;
  }

  /// Prefer [TeamMemberModel.hiredAt], then Firestore `createdAt` (legacy records).
  String _joinDateText(BuildContext context) {
    final label = l10n.teamDetailsJoinDate;
    final hired = member.hiredAt;
    if (hired != null) {
      final formatted = DateFormat.yMMMd(localeName).format(hired.toLocal());
      return '$label: $formatted';
    }
    final ts = member.createdAt;
    if (ts == null) return l10n.teamProfileJoinDateMissing;
    final formatted = DateFormat.yMMMd(
      localeName,
    ).format(ts.toDate().toLocal());
    return '$label: $formatted';
  }
}

enum _StatusBadgeKind { active, inactive, frozen }

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.kind,
    required this.textTheme,
  });

  final String label;
  final _StatusBadgeKind kind;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color bg, Color border) = switch (kind) {
      _StatusBadgeKind.active => (
        TeamCardPalette.statusOnFg,
        TeamCardPalette.statusOnBg,
        TeamCardPalette.statusOnBorder,
      ),
      _StatusBadgeKind.inactive => (
        TeamCardPalette.statusOffFg,
        TeamCardPalette.statusOffBg,
        TeamCardPalette.statusOffBorder,
      ),
      _StatusBadgeKind.frozen => (
        ZuranoPremiumUiColors.textSecondary,
        ZuranoPremiumUiColors.lightSurface,
        ZuranoPremiumUiColors.border,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
