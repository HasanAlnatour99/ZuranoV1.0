import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Box shadows for elevated marketing / discovery cards.
abstract final class AppShadows {
  static List<BoxShadow> premiumPlaceCard = [
    BoxShadow(
      color: PlaceDiscoveryColors.primary.withValues(alpha: 0.10),
      blurRadius: 28,
      offset: const Offset(0, 14),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
