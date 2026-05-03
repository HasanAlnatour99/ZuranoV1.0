import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/firestore_index_building.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/ui/zurano_responsive.dart';
import '../controllers/customer_home_providers.dart';
import '../utils/customer_salon_query.dart';
import 'customer_empty_state.dart';
import 'customer_loading_state.dart';
import 'customer_error_state.dart';
import 'customer_section_header.dart';
import 'recommended_salon_card.dart';

class RecommendedSalonsSection extends ConsumerWidget {
  const RecommendedSalonsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final salonsAsync = ref.watch(recommendedSalonsProvider);
    final query = ref.watch(customerSearchTextProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZuranoSectionHeaderL10n(
          title: l10n.zuranoDiscoverRecommendedTitle,
          actionLabel: l10n.zuranoDiscoverSeeAll,
          leading: Icons.star_rounded,
          onAction: () => context.go(AppRoutes.customerSalonDiscovery),
        ),
        const SizedBox(height: 6),
        salonsAsync.when(
          data: (raw) {
            final salons = filterSalonsForQuery(raw, query);
            if (salons.isEmpty) {
              return CustomerDiscoverEmpty(
                icon: Icons.storefront_rounded,
                message: l10n.zuranoDiscoverRecommendedEmpty,
              );
            }
            return SizedBox(
              height: ZuranoResponsive.v(context, 204),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: salons.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final s = salons[i];
                  return RecommendedSalonCard(
                    salon: s,
                    onOpen: () {
                      context.pushNamed(
                        AppRouteNames.customerSalonProfile,
                        pathParameters: {'salonId': s.id},
                      );
                    },
                  );
                },
              ),
            );
          },
          loading: () => const CustomerHorizontalCardSkeleton(),
          error: (e, st) {
            if (isFirestoreIndexBuilding(e)) {
              return const CustomerHorizontalCardSkeleton();
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
