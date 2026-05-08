import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firestore_index_building.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/customer_home_canonical_providers.dart';
import 'customer_empty_state.dart';
import 'customer_error_state.dart';
import 'customer_loading_state.dart';
import 'customer_section_header.dart';
import 'specialist_card.dart';

/// Customer home "Recommended specialists" section.
///
/// Reads from the canonical [recommendedSpecialistsProvider] which is a
/// customer-safe view (`customerDiscovery/specialists/items`). Never joins
/// payroll, attendance, commission, or other private employee data.
class RecommendedSpecialistsSection extends ConsumerWidget {
  const RecommendedSpecialistsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final specialistsAsync = ref.watch(recommendedSpecialistsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZuranoSectionHeaderL10n(
          title: l10n.zuranoRecommendedSpecialistsTitle,
          actionLabel: l10n.zuranoDiscoverSeeAll,
          leading: Icons.person_rounded,
          onAction: () {},
        ),
        const SizedBox(height: 14),
        specialistsAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return CustomerDiscoverEmpty(
                icon: Icons.person_outline_rounded,
                message: l10n.zuranoRecommendedSpecialistsEmpty,
              );
            }
            return SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return SpecialistCard(
                    specialist: list[index],
                    viewLabel: l10n.zuranoSpecialistView,
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 170,
            child: CustomerHorizontalCardSkeleton(),
          ),
          error: (error, stackTrace) {
            if (isFirestoreIndexBuilding(error)) {
              return const SizedBox(
                height: 170,
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
