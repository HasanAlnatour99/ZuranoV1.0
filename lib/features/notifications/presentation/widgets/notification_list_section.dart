import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../domain/entities/app_notification.dart';
import 'notification_card.dart';

class NotificationListSection extends StatelessWidget {
  const NotificationListSection({
    super.key,
    required this.notifications,
    required this.readerId,
    required this.onTapNotification,
  });

  final List<AppNotification> notifications;
  final String readerId;
  final ValueChanged<AppNotification> onTapNotification;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final grouped = _groupByDate(notifications, locale);
    return ListView.separated(
      itemCount: grouped.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final section = grouped[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.label,
              style: const TextStyle(
                color: ZuranoTokens.textGray,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ...section.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NotificationCard(
                  notification: item,
                  isUnread: item.isUnreadFor(readerId),
                  onTap: () => onTapNotification(item),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<_NotificationGroup> _groupByDate(
    List<AppNotification> items,
    String locale,
  ) {
    final map = <String, List<AppNotification>>{};
    final formatter = DateFormat.yMMMMd(locale);
    for (final item in items) {
      final date = item.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final key = formatter.format(DateTime(date.year, date.month, date.day));
      map.putIfAbsent(key, () => <AppNotification>[]).add(item);
    }
    return map.entries
        .map(
          (entry) => _NotificationGroup(label: entry.key, items: entry.value),
        )
        .toList();
  }
}

class _NotificationGroup {
  const _NotificationGroup({required this.label, required this.items});

  final String label;
  final List<AppNotification> items;
}
