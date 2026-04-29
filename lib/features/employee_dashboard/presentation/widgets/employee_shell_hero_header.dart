import 'package:flutter/material.dart';

import '../../../../core/text/personalized_greeting.dart';
import '../../../../core/widgets/app_notification_badge.dart';
import '../../../../l10n/app_localizations.dart';

String _employeeHeroInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '?';
  }
  final first = parts.first.isNotEmpty ? parts.first[0] : '';
  final last = parts.last.isNotEmpty ? parts.last[0] : '';
  final value = '$first$last'.trim();
  return value.isNotEmpty ? value.toUpperCase() : '?';
}

class EmployeeShellHeroHeader extends StatelessWidget {
  const EmployeeShellHeroHeader({
    super.key,
    required this.displayName,
    required this.salonDisplayName,
    required this.unreadCount,
    required this.onTapSettings,
    required this.onTapNotifications,
    this.photoUrl,
    this.compact = false,
  });

  final String displayName;
  final String salonDisplayName;
  final String? photoUrl;
  final int unreadCount;
  final VoidCallback onTapSettings;
  final VoidCallback onTapNotifications;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final align = isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = isRtl ? TextAlign.right : TextAlign.left;
    final trimmedPhoto = photoUrl?.trim();
    final hasPhoto = trimmedPhoto != null && trimmedPhoto.isNotEmpty;
    final avatarRadius = compact ? 20.0 : 22.0;
    final iconSize = compact ? 19.0 : 20.0;
    final greeting = getGreeting(l10n);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, compact ? 10 : 12, 16, compact ? 14 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B2BE0), Color(0xFF7B3FF2), Color(0xFFA77BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            backgroundImage: hasPhoto ? NetworkImage(trimmedPhoto) : null,
            child: hasPhoto
                ? null
                : Text(
                    _employeeHeroInitials(displayName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: align,
              children: [
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: textAlign,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: textAlign,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  salonDisplayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: textAlign,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _HeroActionIconButton(
            tooltip: l10n.employeeBottomNavProfile,
            icon: Icons.settings_outlined,
            iconSize: iconSize,
            onTap: onTapSettings,
          ),
          const SizedBox(width: 8),
          _HeroActionIconButton(
            tooltip: l10n.notificationsInboxTooltip,
            iconSize: iconSize,
            onTap: onTapNotifications,
            iconBuilder: () => AppNotificationBadge(
              count: unreadCount,
              child: Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroActionIconButton extends StatelessWidget {
  const _HeroActionIconButton({
    this.tooltip,
    this.icon,
    this.iconSize = 20,
    this.iconBuilder,
    required this.onTap,
  });

  final String? tooltip;
  final IconData? icon;
  final double iconSize;
  final Widget Function()? iconBuilder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: iconBuilder?.call() ??
                Icon(icon, color: Colors.white, size: iconSize),
          ),
        ),
      ),
    );
  }
}
