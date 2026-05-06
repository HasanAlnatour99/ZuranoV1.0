import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchSuggestionSection extends StatelessWidget {
  const SearchSuggestionSection({
    super.key,
    required this.title,
    required this.suggestions,
    required this.onTapSuggestion,
  });

  final String title;
  final List<String> suggestions;
  final ValueChanged<String> onTapSuggestion;

  @override
  Widget build(BuildContext context) {
    final clean = suggestions.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (clean.isEmpty) return const SizedBox.shrink();

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
          children: clean.map((s) {
            return ActionChip(
              label: Text(s),
              onPressed: () {
                HapticFeedback.selectionClick();
                onTapSuggestion(s);
              },
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}

