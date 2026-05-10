import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/customer_home_canonical_providers.dart';
import '../controllers/customer_home_providers.dart'
    show selectedCustomerCategoryProvider;
import '../models/customer_home_ui_models.dart';
import '../theme/zurano_customer_home_design_tokens.dart';
import 'customer_empty_state.dart';
import 'customer_error_state.dart';
import 'zurano_category_card.dart';

/// Horizontal category scroller (`ListView.separated`).
class ZuranoCategoriesSection extends ConsumerWidget {
  const ZuranoCategoriesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final catsAsync = ref.watch(serviceCategoriesProvider);
    final selectedId = ref.watch(selectedCustomerCategoryProvider);

    ref.listen(serviceCategoriesProvider, (prev, next) {
      next.whenData((cats) {
        if (cats.isEmpty) return;
        final sel = ref.read(selectedCustomerCategoryProvider);
        final exists = cats.any((c) => c.id == sel);
        if (!exists) {
          Future.microtask(() {
            ref.read(selectedCustomerCategoryProvider.notifier).state =
                cats.first.id;
          });
        }
      });
    });

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  l10n.zuranoCategoriesTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ZuranoCustomerHomeColors.darkText,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push(AppRoutes.customerSearch),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.zuranoCategoriesViewAll,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: ZuranoCustomerHomeColors.primary,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: ZuranoCustomerHomeColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: catsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: CustomerCompactEmptyState(
                        icon: Icons.category_outlined,
                        message: l10n.zuranoCategoriesEmptyHome,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final c = list[i];
                    final ui = CustomerHomeCategoryUi(
                      id: c.id,
                      name: c.labelForLocale(locale),
                      iconKey: c.iconKey,
                      isSelected: c.id == selectedId,
                    );
                    return ZuranoCategoryCard(
                      category: ui,
                      onTap: () {
                        ref.read(selectedCustomerCategoryProvider.notifier).state =
                            c.id;
                      },
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CustomerCategoryRowSkeleton(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomerDiscoverError(
                  message: l10n.zuranoDiscoverSectionLoadFailed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal shimmer placeholders for category row.
class CustomerCategoryRowSkeleton extends StatelessWidget {
  const CustomerCategoryRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, _) => Container(
        width: 88,
        height: 96,
        decoration: BoxDecoration(
          color: ZuranoCustomerHomeColors.lavender.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
