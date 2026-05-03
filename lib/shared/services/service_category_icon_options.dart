import 'package:barber_shop_app/features/services/data/service_category_catalog.dart';

/// Picker metadata derived from [ServiceCategoryKeys] (single source of truth).
class ServiceCategoryIconOption {
  const ServiceCategoryIconOption({required this.key, required this.label});

  final String key;
  final String label;
}

/// English labels match [ServiceCategoryKeys.defaultEnglishLabelForKey].
final List<ServiceCategoryIconOption> serviceCategoryIconOptions = [
  for (final key in ServiceCategoryKeys.pickerOrderedKeys)
    ServiceCategoryIconOption(
      key: key,
      label: ServiceCategoryKeys.defaultEnglishLabelForKey(key),
    ),
];
