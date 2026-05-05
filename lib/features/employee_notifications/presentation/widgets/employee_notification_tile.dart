import 'package:flutter/material.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../data/employee_notification_model.dart';

class EmployeeNotificationTile extends StatelessWidget {
  const EmployeeNotificationTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final EmployeeNotificationModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = item.createdAt != null
        ? MaterialLocalizations.of(context).formatShortDate(item.createdAt!)
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusCard),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsetsDirectional.only(top: 6, end: 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isUnread
                      ? ZuranoTokens.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: item.isUnread
                        ? ZuranoTokens.primary
                        : ZuranoTokens.border,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: item.isUnread
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: ZuranoTokens.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: ZuranoTokens.textGray,
                        height: 1.35,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: ZuranoTokens.textGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
