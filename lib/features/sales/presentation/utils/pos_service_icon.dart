import 'package:flutter/material.dart';

import '../../../../shared/services/service_category_icon_resolver.dart';

/// POS / legacy helpers that only need [IconData].
IconData posServiceIconForCategoryKey(String? categoryKey, {String? iconKey}) {
  return ServiceCategoryIconResolver.resolve(
    iconKey: iconKey,
    categoryKey: categoryKey,
  );
}
