import '../../services/data/models/service.dart';
import '../../services/data/service_category_catalog.dart';
import '../data/models/customer_service_public_model.dart';

/// Maps customer-safe public service rows to [SalonService] for booking flows.
SalonService salonServiceFromCustomerPublic(
  CustomerServicePublicModel service,
) {
  final ck = service.categoryKey?.trim().isNotEmpty == true
      ? service.categoryKey!.trim()
      : (ServiceCategoryKeys.migrateLegacyCategoryLabelToKey(
              service.categoryLabel.trim().isNotEmpty
                  ? service.categoryLabel
                  : service.category,
            ) ??
            ServiceCategoryKeys.other);
  final ik = service.iconKey?.trim().isNotEmpty == true
      ? service.iconKey!.trim()
      : null;

  return SalonService(
    id: service.id,
    salonId: service.salonId,
    name: service.name.trim().isNotEmpty
        ? service.name.trim()
        : service.displayTitle,
    serviceName: service.displayTitle,
    nameAr: service.nameAr,
    durationMinutes: service.durationMinutes > 0 ? service.durationMinutes : 30,
    price: service.price,
    description: service.description,
    categoryKey: ck,
    categoryLabel: service.categoryLabel,
    category: service.category,
    iconKey: ik,
    imageUrl: service.imageUrl,
    isActive: service.isActive,
    bookable: service.isCustomerVisible,
    createdAt: service.createdAt,
    updatedAt: service.updatedAt,
  );
}
