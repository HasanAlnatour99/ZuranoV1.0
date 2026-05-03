import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/services/service_category_icon_resolver.dart';
import '../../../services/data/service_category_catalog.dart';
import '../../data/models/customer_category_model.dart';
import '../controllers/customer_home_providers.dart';
import '../theme/zurano_customer_colors.dart';
import 'customer_category_skeleton.dart';
import 'zurano_fallback_categories.dart';

class CustomerCategoryScroller extends ConsumerWidget {
  const CustomerCategoryScroller({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cats = ref.watch(customerCategoriesProvider);

    return cats.when(
      data: (list) {
        if (list.isEmpty) {
          return const SizedBox.shrink();
        }
        return _CategoryScrollerRow(categories: list);
      },
      loading: () => const CustomerCategorySkeleton(),
      error: (e, _) {
        final fallback = zuranoFallbackCustomerCategories(l10n);
        return _CategoryScrollerRow(categories: fallback);
      },
    );
  }
}

class _CategoryScrollerRow extends ConsumerWidget {
  const _CategoryScrollerRow({required this.categories});

  final List<CustomerCategoryModel> categories;

  static const double _rowHeight = 72;
  static const double _circle = 44;
  static const double _tileWidth = 62;
  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCustomerCategoryProvider);

    return SizedBox(
      height: _rowHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final c = categories[i];
          final isSel = c.id == selected;
          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              ref.read(selectedCustomerCategoryProvider.notifier).state = c.id;
            },
            child: SizedBox(
              width: _tileWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.all(isSel ? 1.4 : 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: isSel
                          ? Border.all(
                              width: 1.4,
                              color: ZuranoCustomerColors.primary,
                            )
                          : null,
                    ),
                    child: CircleAvatar(
                      radius: _circle / 2,
                      backgroundColor: ZuranoCustomerColors.lavenderSoft,
                      foregroundImage: (c.imageUrl.trim().isNotEmpty)
                          ? NetworkImage(c.imageUrl)
                          : null,
                      child: c.imageUrl.trim().isEmpty
                          ? CategoryFallback(
                              categoryId: c.id,
                              iconSize: _iconSize,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    c.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ZuranoCustomerColors.textStrong,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class CategoryFallback extends StatelessWidget {
  const CategoryFallback({
    super.key,
    required this.categoryId,
    this.iconSize = 28,
  });

  /// Stable catalogue id (`all`, `hair`, …), not localized label.
  final String categoryId;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final id = categoryId.trim().toLowerCase();
    if (id == 'all') {
      return Icon(
        Icons.dashboard_rounded,
        color: ZuranoCustomerColors.primary,
        size: iconSize,
      );
    }
    final catalogKey = switch (id) {
      'hair' => ServiceCategoryKeys.hair,
      'nails' => ServiceCategoryKeys.nails,
      'barbers' => ServiceCategoryKeys.barberBeard,
      'spa' => ServiceCategoryKeys.massageSpa,
      'makeup' => ServiceCategoryKeys.makeup,
      'beauty' => ServiceCategoryKeys.facialSkincare,
      _ => ServiceCategoryKeys.other,
    };
    return Icon(
      ServiceCategoryIconResolver.resolve(categoryKey: catalogKey),
      color: ZuranoCustomerColors.primary,
      size: iconSize,
    );
  }
}
