import 'package:flutter/material.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../domain/enums/notification_type.dart';

class NotificationIconBadge extends StatelessWidget {
  const NotificationIconBadge({super.key, required this.type});

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: ZuranoTokens.lightPurple,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(_iconForType(type), color: ZuranoTokens.primary, size: 21),
    );
  }

  IconData _iconForType(NotificationType value) {
    switch (value) {
      case NotificationType.booking:
        return Icons.calendar_month_outlined;
      case NotificationType.attendance:
        return Icons.fact_check_outlined;
      case NotificationType.payroll:
        return Icons.account_balance_wallet_outlined;
      case NotificationType.sales:
        return Icons.bar_chart_rounded;
      case NotificationType.system:
        return Icons.settings_suggest_outlined;
      case NotificationType.approval:
        return Icons.verified_outlined;
      case NotificationType.violation:
        return Icons.report_problem_outlined;
      case NotificationType.general:
        return Icons.notifications_active_outlined;
    }
  }
}
