import 'package:flutter/material.dart';

import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/notification_controller.dart';

class NotificationFilterChips extends StatelessWidget {
  const NotificationFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final NotificationFilter selectedFilter;
  final ValueChanged<NotificationFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _buildChip(
          label: l10n.notificationsFilterAll,
          selected: selectedFilter == NotificationFilter.all,
          onTap: () => onFilterChanged(NotificationFilter.all),
        ),
        const SizedBox(width: 12),
        _buildChip(
          label: l10n.notificationsFilterUnread,
          selected: selectedFilter == NotificationFilter.unread,
          onTap: () => onFilterChanged(NotificationFilter.unread),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: selected ? ZuranoTokens.primary : ZuranoTokens.chipUnselected,
          boxShadow: selected ? ZuranoTokens.softCardShadow : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : ZuranoTokens.textGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
