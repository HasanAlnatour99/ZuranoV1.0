import 'package:flutter/material.dart';

import '../../../services/data/service_category_catalog.dart';
import '../../../../shared/services/service_category_icon_resolver.dart';

IconData trendingServiceIconKey(String raw) {
  final key = raw.trim();
  if (ServiceCategoryKeys.isKnownKey(key)) {
    return ServiceCategoryIconResolver.resolve(categoryKey: key);
  }
  switch (key.toLowerCase()) {
    case 'haircut':
      return Icons.content_cut_rounded;
    case 'blow_dry':
      return Icons.dry_cleaning_rounded;
    case 'gel_nails':
      return Icons.brush_rounded;
    case 'facial':
      return Icons.spa_rounded;
    case 'hair_color':
      return Icons.color_lens_rounded;
    case 'hair':
      return Icons.face_retouching_natural_rounded;
    case 'nails':
      return Icons.volunteer_activism_rounded;
    default:
      return ServiceCategoryIconResolver.resolve(categoryKey: null);
  }
}
