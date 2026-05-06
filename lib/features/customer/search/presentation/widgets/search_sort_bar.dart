import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../application/customer_search_controller.dart';
import '../../domain/models/customer_search_filter.dart';

class SearchSortBar extends ConsumerWidget {
  const SearchSortBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.watch(customerSearchControllerProvider.notifier);
    final filter = controller.filter;

    final items = <(CustomerSearchSort, String)>[
      (CustomerSearchSort.recommended, l10n.customerSearchSortRecommended),
      (CustomerSearchSort.nearby, l10n.customerSearchSortNearby),
      (CustomerSearchSort.openNow, l10n.customerSearchSortOpenNow),
      (CustomerSearchSort.topRated, l10n.customerSearchSortTopRated),
      (CustomerSearchSort.priceLowToHigh, l10n.customerSearchSortPriceLow),
      (CustomerSearchSort.priceHighToLow, l10n.customerSearchSortPriceHigh),
      (CustomerSearchSort.offers, l10n.customerSearchSortOffers),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 6),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final (sort, label) = items[index];
          final selected = sort == filter.sort;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) async {
              HapticFeedback.selectionClick();
              await controller.updateSort(sort);
            },
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: items.length,
      ),
    );
  }
}

