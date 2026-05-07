import 'package:flutter/material.dart';

import '../services/service_category_visual_style.dart';

/// Soft premium tile for Lucide category icons (shared customer / owner / POS).
class ServiceCategoryIconTile extends StatelessWidget {
  const ServiceCategoryIconTile({
    super.key,
    required this.style,
    this.size = 58,
    this.borderRadius = 18,
    this.iconSize = 27,
    this.whiteOverlayAlpha = 0.20,
  });

  final ServiceCategoryVisualStyle style;
  final double size;
  final double borderRadius;
  final double iconSize;

  /// Lightens [style.background] for a softer tile (see brand tile spec).
  final double whiteOverlayAlpha;

  @override
  Widget build(BuildContext context) {
    final fill = Color.alphaBlend(
      Colors.white.withValues(alpha: whiteOverlayAlpha),
      style.background,
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: style.foreground.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: style.foreground.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(style.icon, color: style.foreground, size: iconSize),
    );
  }
}
