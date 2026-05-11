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

/// Full-width top fade: deep purple → brand purple → soft violet → canvas.
/// Used under the owner overview header + first cards (not a hard rounded header block).
class OwnerOverviewGradientBackdrop extends StatelessWidget {
  const OwnerOverviewGradientBackdrop({super.key});

  static const double preferredHeight = 320;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: preferredHeight,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.42, 0.70, 1.0],
              colors: [
                const Color(0xFF4C18D8),
                const Color(0xFF6D28F6),
                Color(0xFF9D6CFF).withValues(alpha: 0.55),
                kOwnerDashboardHeroCanvas,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

    /// When true (Owner Overview with [OwnerOverviewGradientBackdrop]), no purple
    /// rounded [Container] — content only, drawn on the shared top gradient.
    this.overGradientBackdrop = false,
  });

  final AppUser user;

  /// When true (e.g. Team tab), tighter padding and slightly smaller type.
  final bool compact;

  /// Overview tab: transparent row on the stack gradient (no hard header block).
  final bool overGradientBackdrop;

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
      overGradientBackdrop: overGradientBackdrop,
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
  bool overGradientBackdrop = false,
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
      ? EdgeInsets.fromLTRB(
          narrow ? 16.0 : 18.0,
          8,
          narrow ? 16.0 : 18.0,
          18,
        )
      : overGradientBackdrop
          ? const EdgeInsets.fromLTRB(28, 12, 28, 18)
          : const EdgeInsets.fromLTRB(22, 14, 22, 28);

  final avatarRadius = compact
      ? 20.0
      : (overGradientBackdrop ? 28.0 : 27.0);
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

  if (overGradientBackdrop) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: heroPadding,
        child: heroRow,
      ),
    );
  }

  return Container(
    width: double.infinity,
    padding: heroPadding,
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
      child: heroRow,
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
          OwnerDashboardHeroHeader(
            key: ValueKey<String>('owner_hero_tab_${user.uid}'),
            user: user,
            compact: compactHero,
          ),
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
