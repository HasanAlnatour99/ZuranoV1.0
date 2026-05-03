import 'package:flutter/material.dart';

import 'package:barber_shop_app/shared/services/service_category_icon_resolver.dart';

/// Rounded icon tile for a salon service using [ServiceCategoryIconResolver].
///
/// Priority: [iconKey] if non-empty, else [categoryKey], else catalog "other".
class ZuranoServiceCategoryIcon extends StatelessWidget {
  const ZuranoServiceCategoryIcon({
    super.key,
    required this.categoryKey,
    this.iconKey,
    this.size = 42,
    this.iconSize = 21,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius,
  });

  final String? categoryKey;
  final String? iconKey;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg =
        backgroundColor ?? scheme.primaryContainer.withValues(alpha: 0.65);
    final fg = iconColor ?? scheme.primary;
    final icon = ServiceCategoryIconResolver.resolve(
      iconKey: iconKey,
      categoryKey: categoryKey,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius ?? size / 2.6),
      ),
      child: Icon(icon, size: iconSize, color: fg),
    );
  }
}
