import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../domain/entities/app_notification.dart';
import 'notification_icon_badge.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.isUnread,
    required this.onTap,
  });

  final AppNotification notification;
  final bool isUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ZuranoTokens.radiusCard),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? ZuranoTokens.activeCardFill : ZuranoTokens.surface,
          borderRadius: BorderRadius.circular(ZuranoTokens.radiusCard),
          border: Border.all(color: ZuranoTokens.sectionBorder),
          boxShadow: ZuranoTokens.softCardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NotificationIconBadge(type: notification.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ZuranoTokens.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: ZuranoTokens.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ZuranoTokens.textGray,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(notification.createdAt, locale),
                    style: TextStyle(
                      color: ZuranoTokens.textGray.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? value, String locale) {
    if (value == null) {
      return '';
    }
    return DateFormat.yMMMd(locale).add_jm().format(value);
  }
}
