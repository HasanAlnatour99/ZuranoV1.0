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

/// Translucent circular control (reference header — no AI button).
Widget _buildHeroTranslucentIconButton({
  required String tooltip,
  required VoidCallback onTap,
  required Widget child,
  double size = 52,
}) {
  return Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Center(child: child),
        ),
      ),
    ),
  );
}

/// Purple gradient hero (greeting, salon + Pro, notifications, settings).
/// Does not include the dashboard AI assistant button — access remains via routes/shell elsewhere.
class OwnerDashboardHeroHeader extends ConsumerWidget {
  const OwnerDashboardHeroHeader({
    super.key,
    required this.user,
    this.compact = false,

    /// Owner Overview: no local purple paint — row sits on [OwnerOverviewSection] backdrop.
    this.transparentOnSharedBackdrop = false,
  });

  final AppUser user;

  /// When true (e.g. Team tab), shorter band, tighter padding and slightly smaller type.
  final bool compact;

  /// When true, header is content-only (no gradient / rounded purple block).
  final bool transparentOnSharedBackdrop;

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
      transparentOnSharedBackdrop: transparentOnSharedBackdrop,
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
  bool transparentOnSharedBackdrop = false,
}) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  final displayName = _resolveDisplayName(user, state);
  final formattedName = displayName.trim().toUpperCaseFirst();
  final greeting = getGreeting(l10n);
  final trimmedSalon = salonLabel.trim();
  final salonTitle = trimmedSalon.isNotEmpty
      ? trimmedSalon
      : l10n.ownerDashboardTitle;
  final initialsName =
      displayName.isNotEmpty ? displayName : user.name;
  final initials = _heroUserInitials(initialsName);

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

  final heroPadding = compact
      ? EdgeInsetsDirectional.fromSTEB(
          narrow ? 16.0 : 18.0,
          8,
          narrow ? 16.0 : 18.0,
          14,
        )
      : transparentOnSharedBackdrop
          ? const EdgeInsetsDirectional.fromSTEB(30, 12, 30, 14)
          : const EdgeInsetsDirectional.fromSTEB(30, 16, 30, 12);

  final avatarRadius = compact ? 20.0 : 28.0;
  final actionSize = compact ? 46.0 : 52.0;
  final actionIconSize = compact ? 22.0 : 24.0;
  final avatarTextGap = compact ? 12.0 : 14.0;
  final actionsGap = 10.0;

  final greetingSize = compact ? 14.0 : 16.0;
  final nameSize = compact ? 17.0 : 22.0;
  final salonSize = compact ? 13.0 : 15.0;

  final startAlign = isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  final textAlign = isRtl ? TextAlign.right : TextAlign.left;

  void onSettingsTap() {
    context.push(
      canOpenOwnerSettings ? AppRoutes.ownerSettings : AppRoutes.settings,
    );
  }

  final heroRow = Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSettingsTap,
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
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: avatarRadius * 0.45,
                    ),
                  )
                : null,
          ),
        ),
      ),
      SizedBox(width: avatarTextGap),
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
                color: Colors.white.withValues(alpha: 0.90),
                fontSize: greetingSize,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
            if (formattedName.isNotEmpty) ...[
              SizedBox(height: compact ? 3 : 4),
              Text(
                formattedName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: textAlign,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: nameSize,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
            SizedBox(height: compact ? 4 : 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    salonTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: textAlign,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: salonSize,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Text(
                    l10n.ownerDashboardHeroProBadge,
                    style: TextStyle(
                      fontSize: compact ? 10 : 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      _buildHeroTranslucentIconButton(
        tooltip: l10n.notificationsInboxTooltip,
        onTap: () => context.push(AppRoutes.notifications),
        size: actionSize,
        child: AppNotificationBadge(
          count: unread,
          child: Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: actionIconSize,
          ),
        ),
      ),
      SizedBox(width: actionsGap),
      _buildHeroTranslucentIconButton(
        tooltip: l10n.ownerDashboardSettingsTooltip,
        onTap: onSettingsTap,
        size: actionSize,
        child: Icon(
          Icons.settings_rounded,
          color: Colors.white,
          size: actionIconSize,
        ),
      ),
    ],
  );

  if (transparentOnSharedBackdrop) {
    final headerHeight = compact ? 142.0 : 160.0;
    return SizedBox(
      width: double.infinity,
      height: headerHeight,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: heroPadding,
          child: heroRow,
        ),
      ),
    );
  }

  /// Tab shell: self-contained purple band (Owner Overview uses shared backdrop instead).
  final headerHeight = compact ? 148.0 : 184.0;

  return SizedBox(
    width: double.infinity,
    height: headerHeight,
    child: ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.52, 0.78, 1.0],
                colors: [
                  const Color(0xFF3F13C8),
                  const Color(0xFF5B22E8),
                  const Color(0xFF7B3FF2).withValues(alpha: 0.92),
                  kOwnerDashboardHeroCanvas,
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
          if (!compact)
            PositionedDirectional(
              end: -80,
              top: -70,
              child: IgnorePointer(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: heroPadding,
              child: heroRow,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Owner shell tab layout: fixed-height hero band + scroll body (no body overlap).
class OwnerDashboardHeroTabScaffold extends StatelessWidget {
  const OwnerDashboardHeroTabScaffold({
    super.key,
    required this.user,
    required this.body,
    this.bodyScaffoldBackgroundColor,
    this.enableBodyOverlap = false,
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
          OwnerDashboardHeroHeader(
            key: ValueKey<String>('owner_hero_tab_${user.uid}'),
            user: user,
            compact: compactHero,
          ),
          Expanded(
            child: enableBodyOverlap
                ? Transform.translate(
                    offset: const Offset(0, -18),
                    child: body,
                  )
                : body,
          ),
        ],
      ),
    );
  }
}
