import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../application/customer_search_controller.dart';

class SearchFilterBottomSheet extends ConsumerWidget {
  const SearchFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final c = ref.watch(customerSearchControllerProvider.notifier);
    final filter = c.filter;

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.42,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 44,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.customerSearchFiltersTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilterChip(
                    label: Text(l10n.customerSearchFilterNearby),
                    selected: filter.nearbyOnly,
                    onSelected: (_) async {
                      HapticFeedback.selectionClick();
                      await c.toggleNearbyOnly();
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.customerSearchFilterOpenNow),
                    selected: filter.openNowOnly,
                    onSelected: (_) async {
                      HapticFeedback.selectionClick();
                      await c.toggleOpenNow();
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.customerSearchFilterOffers),
                    selected: filter.offersOnly,
                    onSelected: (_) async {
                      HapticFeedback.selectionClick();
                      await c.toggleOffers();
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.customerSearchFilterAvailableToday),
                    selected: filter.availableTodayOnly,
                    onSelected: (_) async {
                      HapticFeedback.selectionClick();
                      await c.toggleAvailableToday();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                l10n.customerSearchFilterAudienceTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ChoiceChip(
                    label: Text(l10n.customerSearchAudienceMen),
                    selected: filter.audience == 'men',
                    onSelected: (_) async {
                      HapticFeedback.selectionClick();
                      await c.updateAudience(filter.audience == 'men' ? null : 'men');
                    },
                  ),
                  ChoiceChip(
                    label: Text(l10n.customerSearchAudienceLadies),
                    selected: filter.audience == 'ladies',
                    onSelected: (_) async {
                      HapticFeedback.selectionClick();
                      await c.updateAudience(
                        filter.audience == 'ladies' ? null : 'ladies',
                      );
                    },
                  ),
                  ChoiceChip(
                    label: Text(l10n.customerSearchAudienceUnisex),
                    selected: filter.audience == 'unisex',
                    onSelected: (_) async {
                      HapticFeedback.selectionClick();
                      await c.updateAudience(
                        filter.audience == 'unisex' ? null : 'unisex',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        await c.resetFiltersKeepingQuery();
                        if (context.mounted) {
                          Navigator.of(context).maybePop();
                        }
                      },
                      child: Text(l10n.customerSearchFiltersReset),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).maybePop();
                      },
                      child: Text(l10n.customerSearchFiltersDone),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

