import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../application/customer_search_controller.dart';
import '../../domain/models/customer_search_filter.dart';
import '../../../../customer_home/presentation/theme/zurano_customer_colors.dart';

/// Single scrollable row: quick filters + sort (replaces a separate sort bar to avoid duplicate chips).
class SearchQuickFilterStrip extends ConsumerWidget {
  const SearchQuickFilterStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(customerSearchControllerProvider);
    final filter = ref.read(customerSearchControllerProvider.notifier).filter;
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(customerSearchControllerProvider.notifier);

    final chips = <({
      String label,
      IconData icon,
      bool selected,
      Future<void> Function() onTap,
    })>[
      (
        label: l10n.customerSearchSortRecommended,
        icon: Icons.auto_awesome_rounded,
        selected: filter.sort == CustomerSearchSort.recommended,
        onTap: () => notifier.updateSort(CustomerSearchSort.recommended),
      ),
      (
        label: l10n.customerSearchFilterNearby,
        icon: Icons.near_me_rounded,
        selected: filter.sort == CustomerSearchSort.nearby,
        onTap: notifier.toggleNearby,
      ),
      (
        label: l10n.customerSearchFilterOpenNow,
        icon: Icons.schedule_rounded,
        selected: filter.sort == CustomerSearchSort.openNow,
        onTap: notifier.toggleOpenNow,
      ),
      (
        label: l10n.customerSearchFilterAvailableToday,
        icon: Icons.event_available_rounded,
        selected: filter.availableTodayOnly,
        onTap: notifier.toggleAvailableToday,
      ),
      (
        label: l10n.customerSearchSortTopRated,
        icon: Icons.star_rounded,
        selected: filter.sort == CustomerSearchSort.topRated,
        onTap: () => notifier.updateSort(CustomerSearchSort.topRated),
      ),
      (
        label: l10n.customerSearchSortPriceLow,
        icon: Icons.arrow_upward_rounded,
        selected: filter.sort == CustomerSearchSort.priceLowToHigh,
        onTap: () => notifier.updateSort(CustomerSearchSort.priceLowToHigh),
      ),
      (
        label: l10n.customerSearchSortPriceHigh,
        icon: Icons.arrow_downward_rounded,
        selected: filter.sort == CustomerSearchSort.priceHighToLow,
        onTap: () => notifier.updateSort(CustomerSearchSort.priceHighToLow),
      ),
      (
        label: l10n.customerSearchFilterOffers,
        icon: Icons.local_offer_rounded,
        selected: filter.sort == CustomerSearchSort.offers,
        onTap: notifier.toggleOffers,
      ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 8),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final c = chips[index];
          return _ZuranoQuickChip(
            label: c.label,
            icon: c.icon,
            selected: c.selected,
            onTap: c.onTap,
          );
        },
      ),
    );
  }
}

class _ZuranoQuickChip extends StatelessWidget {
  const _ZuranoQuickChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          HapticFeedback.selectionClick();
          await onTap();
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: selected
                ? const LinearGradient(
                    colors: [
                      ZuranoCustomerColors.primary,
                      ZuranoCustomerColors.headerGradientEnd,
                    ],
                  )
                : null,
            color: selected ? null : Colors.white,
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : ZuranoCustomerColors.lavenderOutline.withValues(alpha: 0.35),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: ZuranoCustomerColors.primary.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : ZuranoCustomerColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : ZuranoCustomerColors.textStrong,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
