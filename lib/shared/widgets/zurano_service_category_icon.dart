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
    this.labelHint,
    this.size = 42,
    this.iconSize = 21,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius,
  });

  final String? categoryKey;
  final String? iconKey;

  /// Service title + category text (any locale) for keyword-based icons.
  final String? labelHint;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg =
        backgroundColor ?? scheme.primaryContainer.withValues(alpha: 0.88);
    final fg = iconColor ?? scheme.primary;
    final borderColor = scheme.primary.withValues(alpha: 0.14);
    final icon = ServiceCategoryIconResolver.resolve(
      iconKey: iconKey,
      categoryKey: categoryKey,
      labelHint: labelHint,
    );
    final r = borderRadius ?? size / 2.6;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, size: iconSize, color: fg, weight: 600, grade: 25),
      ),
    );
  }
}
