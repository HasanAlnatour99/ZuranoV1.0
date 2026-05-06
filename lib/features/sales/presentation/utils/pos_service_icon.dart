import 'package:flutter/material.dart';

import '../../../../shared/services/service_category_visual_style.dart';

/// POS / legacy helpers that only need [IconData].
IconData posServiceIconForCategoryKey(String? categoryKey, {String? iconKey}) {
  return ServiceCategoryVisualStyleResolver.resolve(
    iconKey: iconKey,
    categoryKey: categoryKey,
  ).icon;
}
