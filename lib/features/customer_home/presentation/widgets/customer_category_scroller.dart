import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/services/service_category_visual_style.dart';
import '../../../../shared/widgets/service_category_icon_tile.dart';
import '../../../services/data/service_category_catalog.dart';
import '../../data/models/service_category_model.dart';
import '../controllers/customer_home_canonical_providers.dart';
import '../controllers/customer_home_providers.dart'
    show selectedCustomerCategoryProvider;
import '../theme/zurano_customer_colors.dart';
import 'customer_category_skeleton.dart';
import 'customer_empty_state.dart';

/// Customer home category scroller.
///
/// Reads `customerDiscovery/categories/items` via [serviceCategoriesProvider].
/// Shows a skeleton while the stream is loading; the empty state only appears
/// after the stream has actually resolved with zero rows (no flicker).
class CustomerCategoryScroller extends ConsumerWidget {
  const CustomerCategoryScroller({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cats = ref.watch(serviceCategoriesProvider);

    return cats.when(
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: CustomerCompactEmptyState(
              icon: Icons.category_outlined,
              message: l10n.zuranoDiscoverServiceCategoriesEmpty,
            ),
          );
        }
        return _CategoryScrollerRow(categories: list);
      },
      loading: () => const CustomerCategorySkeleton(),
      error: (_, _) => const CustomerCategorySkeleton(),
    );
  }
}

class _CategoryScrollerRow extends ConsumerWidget {
  const _CategoryScrollerRow({required this.categories});

  final List<ServiceCategoryModel> categories;

  static const double _rowHeight = 72;
  static const double _circle = 44;
  static const double _tileWidth = 62;
  static const double _iconSize = 20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCustomerCategoryProvider);
    final locale = Localizations.localeOf(context);

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
          final label = c.labelForLocale(locale);
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
                    child: c.imageUrl.isEmpty
                        ? CategoryFallback(
                            categoryId: c.id,
                            iconKey: c.iconKey,
                            iconSize: _iconSize,
                          )
                        : CircleAvatar(
                            radius: _circle / 2,
                            backgroundColor: ZuranoCustomerColors.lavenderSoft,
                            foregroundImage: NetworkImage(c.imageUrl),
                          ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
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

/// Resolves a category to a Material icon, preferring `iconKey` when present
/// and falling back to a stable id-based mapping.
class CategoryFallback extends StatelessWidget {
  const CategoryFallback({
    super.key,
    required this.categoryId,
    this.iconKey = '',
    this.iconSize = 28,
  });

  /// Stable catalogue id (`all`, `hair`, …), not localized label.
  final String categoryId;

  /// Optional `iconKey` from the discovery doc (preferred when set).
  final String iconKey;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    const diameter = 44.0;
    final id = categoryId.trim().toLowerCase();
    final key = iconKey.trim().toLowerCase();
    if (id == 'all' || key == 'category_all') {
      return SizedBox(
        width: diameter,
        height: diameter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ZuranoCustomerColors.lavenderSoft,
          ),
          child: Icon(
            Icons.dashboard_rounded,
            color: ZuranoCustomerColors.primary,
            size: iconSize,
          ),
        ),
      );
    }

    // Resolve via icon key first (CMS-controlled), then fall back to id.
    final lookupKey = key.isNotEmpty ? key : id;
    final catalogKey = switch (lookupKey) {
      'hair' || 'haircut' || 'scissors' => ServiceCategoryKeys.hair,
      'nails' || 'gel_nails' => ServiceCategoryKeys.nails,
      'barbers' || 'beard' || 'fade' => ServiceCategoryKeys.barberBeard,
      'spa' || 'hair_spa' || 'massage' => ServiceCategoryKeys.massageSpa,
      'makeup' => ServiceCategoryKeys.makeup,
      'beauty' || 'facial' => ServiceCategoryKeys.facialSkincare,
      _ => ServiceCategoryKeys.other,
    };
    final style = ServiceCategoryVisualStyleResolver.resolve(
      categoryKey: catalogKey,
    );
    return ServiceCategoryIconTile(
      style: style,
      size: diameter,
      borderRadius: diameter / 2,
      iconSize: iconSize,
    );
  }
}
