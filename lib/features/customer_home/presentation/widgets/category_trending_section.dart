import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/firebase/firestore_index_building.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../customer/application/customer_salon_providers.dart';
import '../controllers/customer_home_providers.dart';
import '../theme/zurano_customer_colors.dart';
import 'customer_empty_state.dart';
import 'customer_error_state.dart';
import 'customer_section_header.dart';
import 'service_category_tile.dart';

class CategoryTrendingSection extends ConsumerWidget {
  const CategoryTrendingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(discoveryServiceCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZuranoSectionHeaderL10n(
          title: l10n.zuranoCategoriesTitle,
          actionLabel: l10n.zuranoDiscoverExploreAll,
          leading: Icons.trending_up_rounded,
          onAction: () => context.go(AppRoutes.customerSalonDiscovery),
        ),
        const SizedBox(height: 14),
        categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return CustomerDiscoverEmpty(
                icon: Icons.category_outlined,
                message: l10n.zuranoDiscoverServiceCategoriesEmpty,
              );
            }
            return SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final c = categories[index];
                  return DiscoveryServiceCategoryTile(
                    category: c,
                    onTap: () {
                      final current = ref.read(customerSalonDiscoveryFiltersProvider);
                      ref
                          .read(customerSalonDiscoveryFiltersProvider.notifier)
                          .setFilters(
                            current.copyWith(
                              serviceCategoryId: c.id,
                            ),
                          );
                      context.go(AppRoutes.customerSalonDiscovery);
                    },
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 104,
            child: Center(
              child: CircularProgressIndicator(
                color: ZuranoCustomerColors.primary,
              ),
            ),
          ),
          error: (e, st) {
            if (isFirestoreIndexBuilding(e)) {
              return const SizedBox(
                height: 104,
                child: Center(
                  child: CircularProgressIndicator(
                    color: ZuranoCustomerColors.primary,
                  ),
                ),
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
