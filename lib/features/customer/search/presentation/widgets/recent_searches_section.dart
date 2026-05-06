import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/recent_customer_search.dart';

class RecentSearchesSection extends StatelessWidget {
  const RecentSearchesSection({
    super.key,
    required this.title,
    required this.items,
    required this.onTapItem,
    required this.onClearAll,
    required this.clearAllLabel,
  });

  final String title;
  final List<RecentCustomerSearch> items;
  final ValueChanged<String> onTapItem;
  final VoidCallback onClearAll;
  final String clearAllLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            TextButton(
              onPressed: onClearAll,
              child: Text(clearAllLabel),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((s) {
            return ActionChip(
              label: Text(
                s.query,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                onTapItem(s.query);
              },
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}

