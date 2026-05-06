import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/customer_popular_searches_provider.dart';

class PopularSearchesSection extends StatelessWidget {
  const PopularSearchesSection({
    super.key,
    required this.title,
    required this.itemsAsync,
    required this.onTapItem,
  });

  final String title;
  final AsyncValue<List<PopularCustomerSearchItem>> itemsAsync;
  final ValueChanged<String> onTapItem;

  @override
  Widget build(BuildContext context) {
    return itemsAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((s) {
                return ActionChip(
                  label: Text(
                    s.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onTapItem(s.label);
                  },
                );
              }).toList(growable: false),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 72,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

