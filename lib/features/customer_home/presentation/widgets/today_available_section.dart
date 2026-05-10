import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firestore_index_building.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/customer_home_canonical_providers.dart';
import 'customer_empty_state.dart';
import 'customer_error_state.dart';
import 'customer_loading_state.dart';
import 'customer_section_header.dart';
import 'today_available_card.dart';

/// Customer home "Available today" section.
///
/// Reads from the canonical [availableTodayProvider] — specialists from
/// `customerSearchIndex` with `availableToday` (same index as search).
///
/// Loading state is a skeleton; the empty state only renders after the stream
/// emits an empty list (no flicker between loading and empty).
class TodayAvailableSection extends ConsumerWidget {
  const TodayAvailableSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final specialistsAsync = ref.watch(availableTodayProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZuranoSectionHeaderL10n(
          title: l10n.zuranoTodayAvailableTitle,
          actionLabel: l10n.zuranoDiscoverSeeAll,
          leading: Icons.flash_on_rounded,
          onAction: () {},
        ),
        const SizedBox(height: 14),
        specialistsAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return CustomerDiscoverEmpty(
                icon: Icons.event_available_outlined,
                message: l10n.zuranoTodayAvailableEmpty,
              );
            }
            return SizedBox(
              height: 128,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return TodayAvailableCard(
                    specialist: list[index],
                    fallbackBadge: l10n.zuranoTodayAvailableBadgeFallback,
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 128,
            child: CustomerHorizontalCardSkeleton(),
          ),
          error: (error, stackTrace) {
            if (isFirestoreIndexBuilding(error)) {
              return const SizedBox(
                height: 128,
                child: CustomerHorizontalCardSkeleton(),
              );
            }
            return CustomerDiscoverError(
              message: l10n.zuranoDiscoverSectionLoadFailed,
            );
          },
        ),
      ],
    );
  }
}
