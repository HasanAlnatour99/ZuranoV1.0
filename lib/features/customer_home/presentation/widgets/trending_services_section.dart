import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/firestore_index_building.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/ui/zurano_responsive.dart';
import '../controllers/customer_home_providers.dart';
import 'customer_empty_state.dart';
import 'customer_error_state.dart';
import 'customer_loading_state.dart';
import 'customer_section_header.dart';
import 'trending_service_card.dart';

class TrendingServicesSection extends ConsumerWidget {
  const TrendingServicesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncTrend = ref.watch(trendingServicesProvider);
    final rowH = ZuranoResponsive.v(context, 96);

    return Column(
      children: [
        ZuranoSectionHeaderL10n(
          title: l10n.zuranoTrendingServicesTitle,
          actionLabel: l10n.zuranoDiscoverExploreAll,
          leading: Icons.trending_up_rounded,
          onAction: () => context.go(AppRoutes.customerSalonDiscovery),
        ),
        asyncTrend.when(
          data: (items) {
            if (items.isEmpty) {
              return CustomerCompactEmptyState(
                icon: Icons.trending_up_rounded,
                message: l10n.zuranoDiscoverTrendingServicesEmpty,
              );
            }
            return SizedBox(
              height: rowH,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) => TrendingServiceCard(item: items[i]),
              ),
            );
          },
          loading: () => const CustomerTrendingRowSkeleton(),
          error: (e, st) {
            if (isFirestoreIndexBuilding(e)) {
              return const CustomerTrendingRowSkeleton();
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
