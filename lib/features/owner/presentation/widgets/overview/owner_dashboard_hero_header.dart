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
import '../../../../../shared/widgets/zurano_header_icon_button.dart';
import '../../../../users/data/models/app_user.dart';
import '../../../logic/owner_overview_controller.dart';
import '../../../logic/owner_overview_state.dart';
import 'overview_design_tokens.dart';

/// Matches overview body canvas (light purple-gray).
const Color kOwnerDashboardHeroCanvas = Color(0xFFF7F4FF);

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

Widget _buildAiHeroButton(BuildContext context, AppLocalizations l10n) {
  const size = 46.0;
  const iconSize = 21.0;
  return Tooltip(
    message: l10n.ownerAiAssistantTooltip,
    child: InkWell(
      onTap: () => context.push(AppRoutes.ownerDashboardAssistant),
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          Icons.auto_awesome_rounded,
          color: const Color(0xFF7B3FF2),
          size: iconSize,
        ),
      ),
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
  final canOpenOwnerSettings =
      user.role == UserRoles.owner || user.role == UserRoles.admin;
  final unread = ref.watch(unreadNotificationCountProvider);
  final iconSize = compact ? 19.0 : 21.0;

  final startAlign = isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  final textAlign = isRtl ? TextAlign.right : TextAlign.left;

  final heroTop = compact ? 6.0 : 10.0;
  final heroBottom = compact ? 18.0 : 26.0;
  final avatarRadius = compact ? 18.0 : 22.0;

  return Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(18, heroTop, 18, heroBottom),
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
                    backgroundImage: photo != null && photo.isNotEmpty
                        ? CachedNetworkImageProvider(photo)
                        : null,
                    child: photo == null || photo.isEmpty
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
              const SizedBox(width: 14),
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
              const SizedBox(width: 12),
              _buildAiHeroButton(context, l10n),
              const SizedBox(width: 6),
              ZuranoHeaderIconButton(
                tooltip: l10n.notificationsInboxTooltip,
                compact: true,
                onTap: () => context.push(AppRoutes.notifications),
                icon: AppNotificationBadge(
                  count: unread,
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
              ),
              if (canOpenOwnerSettings) ...[
                const SizedBox(width: 6),
                ZuranoHeaderIconButton(
                  tooltip: l10n.ownerDashboardSettingsTooltip,
                  compact: true,
                  onTap: () => context.push(AppRoutes.ownerSettings),
                  icon: Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
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
