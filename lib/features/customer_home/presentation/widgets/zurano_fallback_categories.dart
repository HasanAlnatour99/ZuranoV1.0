import '../../../../l10n/app_localizations.dart';
import '../../data/models/customer_category_model.dart';

/// Offline-only UI fallback while Firestore is unavailable — still seeded from CMS in normal operation.
List<CustomerCategoryModel> zuranoFallbackCustomerCategories(
  AppLocalizations l10n,
) {
  return [
    CustomerCategoryModel(
      id: 'all',
      label: l10n.zuranoDiscoverFallbackCategoryAll,
      iconKey: 'grid',
      imageUrl: '',
      sortOrder: 0,
      isActive: true,
    ),
    CustomerCategoryModel(
      id: 'hair',
      label: l10n.zuranoDiscoverFallbackCategoryHair,
      iconKey: 'hair',
      imageUrl: '',
      sortOrder: 1,
      isActive: true,
    ),
    CustomerCategoryModel(
      id: 'nails',
      label: l10n.zuranoDiscoverFallbackCategoryNails,
      iconKey: 'nails',
      imageUrl: '',
      sortOrder: 2,
      isActive: true,
    ),
    CustomerCategoryModel(
      id: 'beauty',
      label: l10n.zuranoDiscoverFallbackCategoryBeauty,
      iconKey: 'beauty',
      imageUrl: '',
      sortOrder: 3,
      isActive: true,
    ),
    CustomerCategoryModel(
      id: 'barbers',
      label: l10n.zuranoDiscoverFallbackCategoryBarbers,
      iconKey: 'barber',
      imageUrl: '',
      sortOrder: 4,
      isActive: true,
    ),
    CustomerCategoryModel(
      id: 'spa',
      label: l10n.zuranoDiscoverFallbackCategorySpa,
      iconKey: 'spa',
      imageUrl: '',
      sortOrder: 5,
      isActive: true,
    ),
    CustomerCategoryModel(
      id: 'makeup',
      label: l10n.zuranoDiscoverFallbackCategoryMakeup,
      iconKey: 'makeup',
      imageUrl: '',
      sortOrder: 6,
      isActive: true,
    ),
  ];
}
