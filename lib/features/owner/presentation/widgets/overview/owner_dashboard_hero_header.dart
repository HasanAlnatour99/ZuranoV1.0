import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/constants/user_roles.dart';
import '../../../../../core/text/personalized_greeting.dart';
import '../../../../../core/widgets/app_notification_badge.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../providers/notification_providers.dart';
import '../../../../../providers/salon_streams_provider.dart';
import '../../../../users/data/models/app_user.dart';
import '../../../logic/owner_overview_controller.dart';
import '../../../logic/owner_overview_state.dart';
import 'overview_design_tokens.dart';

/// Matches overview body canvas (light purple-gray).
const Color kOwnerDashboardHeroCanvas = Color(0xFFF7F4FF);

/// Accent for icons on white header action pills (matches premium body purple).
const Color _kOwnerHeroActionIconPurple = Color(0xFF7B3FF2);

String _heroUserInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
  }
  final a = parts.first.isNotEmpty ? parts.first[0] : '';
  final b = parts.last.isNotEmpty ? parts.last[0] : '';
  return ('$a$b').toUpperCase();
}

String _resolveDisplayName(AppUser user, OwnerOverviewState state) {
  final fromUser = user.name.trim();
  if (fromUser.isNotEmpty) return fromUser;
  return (state.ownerName ?? '').trim();
}

Widget _buildWhitePillActionButton({
  required String tooltip,
  required VoidCallback onTap,
  required Widget child,
  required double diameter,
}) {
  return Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(diameter / 2),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    ),
  );
}

Widget _buildAiHeroButton(
  BuildContext context,
  AppLocalizations l10n, {
  required double size,
  required double iconSize,
}) {
  return _buildWhitePillActionButton(
    tooltip: l10n.ownerAiAssistantTooltip,
    onTap: () => context.push(AppRoutes.ownerDashboardAssistant),
    diameter: size,
    child: Icon(
      Icons.auto_awesome_rounded,
      color: _kOwnerHeroActionIconPurple,
      size: iconSize,
    ),
  );
}

/// Purple gradient hero (greeting, salon, AI, notifications) used on owner overview
/// and other owner shell tabs (Team, Customers, Finance).
class OwnerDashboardHeroHeader extends ConsumerWidget {
  const OwnerDashboardHeroHeader({
    super.key,
    required this.user,
    this.compact = false,
  });

  final AppUser user;

  /// When true (e.g. Team tab), reduces vertical padding and avatar size ~20%.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(ownerOverviewControllerProvider);
    final salonLabel = (state.salonName ?? '').trim();
    return _buildOwnerHeroHeader(
      context: context,
      ref: ref,
      user: user,
      state: state,
      l10n: l10n,
      salonLabel: salonLabel,
      compact: compact,
    );
  }
}

Widget _buildOwnerHeroHeader({
  required BuildContext context,
  required WidgetRef ref,
  required AppUser user,
  required OwnerOverviewState state,
  required AppLocalizations l10n,
  required String salonLabel,
  bool compact = false,
}) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  final displayName = _resolveDisplayName(user, state);
  final formattedName = displayName.trim().toUpperCaseFirst();
  final greeting = getGreeting(l10n);
  final trimmedSalon = salonLabel.trim();
  final salonTitle = trimmedSalon.isNotEmpty
      ? trimmedSalon
      : l10n.ownerDashboardTitle;
  final initials = _heroUserInitials(user.name);
  final photo = user.photoUrl?.trim();
  final salonCover = ref
      .watch(sessionSalonStreamProvider)
      .asData
      ?.value
      ?.coverImageUrl
      ?.trim();
  final avatarImage = (photo != null && photo.isNotEmpty)
      ? photo
      : (salonCover != null && salonCover.isNotEmpty)
          ? salonCover
          : null;
  final canOpenOwnerSettings =
      user.role == UserRoles.owner || user.role == UserRoles.admin;
  final unread = ref.watch(unreadNotificationCountProvider);

  final mq = MediaQuery.sizeOf(context);
  final narrow = mq.width < 360;
  final tight = mq.width < 340;
  final actionDiameter = compact || tight ? 40.0 : (narrow ? 42.0 : 46.0);
  final actionIconSize = compact || tight ? 18.0 : (narrow ? 19.0 : 21.0);
  final iconSize = actionIconSize;

  final startAlign = isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  final textAlign = isRtl ? TextAlign.right : TextAlign.left;

  final heroTop = compact ? 6.0 : 10.0;
  final heroBottom = compact ? 18.0 : 26.0;
  final avatarRadius = compact ? 18.0 : (tight ? 20.0 : 22.0);
  final horizontalPad = tight ? 14.0 : 18.0;
  final actionGap = tight ? 4.0 : (narrow ? 5.0 : 6.0);
  final midGap = tight ? 10.0 : 14.0;

  return Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(horizontalPad, heroTop, horizontalPad, heroBottom),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF5B2BE0), Color(0xFF7B3FF2), Color(0xFFA77BFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(34),
        bottomRight: Radius.circular(34),
      ),
    ),
    child: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: startAlign,
        children: [
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push(
                    canOpenOwnerSettings
                        ? AppRoutes.ownerSettings
                        : AppRoutes.settings,
                  ),
                  customBorder: const CircleBorder(),
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    backgroundImage: avatarImage != null
                        ? CachedNetworkImageProvider(avatarImage)
                        : null,
                    child: avatarImage == null
                        ? Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize:
                                  OwnerOverviewTypography.heroAvatarInitials,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              SizedBox(width: midGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: startAlign,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: textAlign,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: OwnerOverviewTypography.heroGreeting,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    if (formattedName.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        formattedName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: textAlign,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: OwnerOverviewTypography.heroName,
                          fontWeight: FontWeight.w800,
                          height: 1.05,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      salonTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: textAlign,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: OwnerOverviewTypography.heroSalon,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: tight ? 6 : 10),
              _buildAiHeroButton(
                context,
                l10n,
                size: actionDiameter,
                iconSize: actionIconSize,
              ),
              SizedBox(width: actionGap),
              _buildWhitePillActionButton(
                tooltip: l10n.notificationsInboxTooltip,
                onTap: () => context.push(AppRoutes.notifications),
                diameter: actionDiameter,
                child: AppNotificationBadge(
                  count: unread,
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: _kOwnerHeroActionIconPurple,
                    size: iconSize,
                  ),
                ),
              ),
              if (canOpenOwnerSettings) ...[
                SizedBox(width: actionGap),
                _buildWhitePillActionButton(
                  tooltip: l10n.ownerDashboardSettingsTooltip,
                  onTap: () => context.push(AppRoutes.ownerSettings),
                  diameter: actionDiameter,
                  child: Icon(
                    Icons.settings_rounded,
                    color: _kOwnerHeroActionIconPurple,
                    size: iconSize,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}

/// Owner shell tab layout: hero + overlapping scroll body (same as overview).
class OwnerDashboardHeroTabScaffold extends StatelessWidget {
  const OwnerDashboardHeroTabScaffold({
    super.key,
    required this.user,
    required this.body,
    this.bodyScaffoldBackgroundColor,
    this.enableBodyOverlap = true,
    this.compactHero = false,
  });

  final AppUser user;
  final Widget body;

  /// When set (e.g. Finance tab), tints the scroll canvas under the hero.
  final Color? bodyScaffoldBackgroundColor;
  final bool enableBodyOverlap;

  /// Shorter hero (e.g. Team tab) while keeping gradient and actions.
  final bool compactHero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyScaffoldBackgroundColor ?? kOwnerDashboardHeroCanvas,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OwnerDashboardHeroHeader(user: user, compact: compactHero),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: enableBodyOverlap ? 0 : 16),
              child: Transform.translate(
                offset: Offset(0, enableBodyOverlap ? -18 : 0),
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
