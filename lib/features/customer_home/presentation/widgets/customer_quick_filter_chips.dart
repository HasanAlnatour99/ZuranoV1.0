import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../customer/search/application/customer_search_controller.dart';
import '../theme/zurano_customer_colors.dart';

class CustomerQuickFilterChips extends ConsumerWidget {
  const CustomerQuickFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(customerSearchControllerProvider);
    final filter = ref.read(customerSearchControllerProvider.notifier).filter;
    final l10n = AppLocalizations.of(context)!;

    final chips = <({
      String label,
      IconData icon,
      bool selected,
      Future<void> Function() onToggle,
    })>[
      (
        label: l10n.customerSearchFilterNearby,
        icon: Icons.near_me_rounded,
        selected: filter.nearbyOnly,
        onToggle: () => ref.read(customerSearchControllerProvider.notifier).toggleNearbyOnly(),
      ),
      (
        label: l10n.customerSearchFilterOpenNow,
        icon: Icons.schedule_rounded,
        selected: filter.openNowOnly,
        onToggle: () => ref.read(customerSearchControllerProvider.notifier).toggleOpenNow(),
      ),
      (
        label: l10n.customerSearchFilterAvailableToday,
        icon: Icons.event_available_rounded,
        selected: filter.availableTodayOnly,
        onToggle: () =>
            ref.read(customerSearchControllerProvider.notifier).toggleAvailableToday(),
      ),
      (
        label: l10n.customerSearchFilterOffers,
        icon: Icons.local_offer_rounded,
        selected: filter.offersOnly,
        onToggle: () => ref.read(customerSearchControllerProvider.notifier).toggleOffers(),
      ),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          final bg = chip.selected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.22);
          final fg = chip.selected ? ZuranoCustomerColors.primary : Colors.white;
          final borderColor = chip.selected
              ? Colors.white.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.28);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () async {
                HapticFeedback.selectionClick();
                await chip.onToggle();
                if (context.mounted) {
                  context.push(AppRoutes.customerSearch);
                }
              },
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(chip.icon, color: fg, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      chip.label,
                      style: TextStyle(
                        color: fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
