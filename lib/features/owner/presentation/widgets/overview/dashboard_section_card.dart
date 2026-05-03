import 'package:flutter/material.dart';

import 'overview_design_tokens.dart';

class DashboardSectionCard extends StatelessWidget {
  const DashboardSectionCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
    this.backgroundColor,
    this.useCanvasStyle = false,
    this.useStatCardStyle = false,
  });

  final Widget child;
  final EdgeInsetsGeometry margin;

  /// When set, used instead of white. If [useCanvasStyle] is true, shadow is omitted.
  final Color? backgroundColor;

  /// Softer border, no drop shadow (for overview sections on [kOwnerDashboardHeroCanvas]).
  final bool useCanvasStyle;

  /// White fill and visible light-purple border (e.g. revenue chart on owner overview).
  final bool useStatCardStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final Color bg;
    final BoxBorder? border;
    final List<BoxShadow> boxShadows;

    if (useStatCardStyle) {
      bg = Colors.white;
      border = Border.all(
        color: OwnerOverviewTokens.purple.withValues(alpha: 0.28),
        width: 1.5,
      );
      boxShadows = const <BoxShadow>[];
    } else {
      bg = backgroundColor ?? Colors.white;
      border = useCanvasStyle
          ? Border.all(color: scheme.outline.withValues(alpha: 0.06))
          : null;
      boxShadows = useCanvasStyle
          ? const <BoxShadow>[]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ];
    }

    return Container(
      margin: margin,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(OwnerOverviewTokens.cardRadius),
        border: border,
        boxShadow: boxShadows,
      ),
      child: child,
    );
  }
}

class DashboardMiniActionCard extends StatelessWidget {
  const DashboardMiniActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.margin = const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 16),
    this.onTap,
    this.showArrow = false,
    this.backgroundColor,
    this.useCanvasStyle = false,
    this.useStatCardStyle = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final bool showArrow;

  /// Overrides the default tinted card fill when non-null.
  final Color? backgroundColor;

  /// Lighter border and no purple glow shadow (overview on hero canvas).
  final bool useCanvasStyle;

  /// Owner overview stat row: white fill and visible light-purple border.
  final bool useStatCardStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconSurface = OwnerOverviewTokens.purple.withValues(alpha: 0.12);

    final Color cardSurface;
    final Color borderColor;
    final double borderWidth;
    final List<BoxShadow> boxShadows;

    if (useStatCardStyle) {
      cardSurface = Colors.white;
      borderColor = OwnerOverviewTokens.purple.withValues(alpha: 0.28);
      borderWidth = 1.5;
      boxShadows = const <BoxShadow>[];
    } else {
      cardSurface = backgroundColor ??
          Color.alphaBlend(
            OwnerOverviewTokens.purple.withValues(alpha: 0.04),
            scheme.surfaceContainer,
          );
      borderColor = scheme.outline.withValues(
        alpha: useCanvasStyle ? 0.05 : 0.08,
      );
      borderWidth = 1;
      boxShadows = useCanvasStyle
          ? const <BoxShadow>[]
          : [
              BoxShadow(
                color: OwnerOverviewTokens.purple.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ];
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(OwnerOverviewTokens.cardRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: boxShadows,
      ),
      child: Material(
        color: cardSurface,
        borderRadius: BorderRadius.circular(OwnerOverviewTokens.cardRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(OwnerOverviewTokens.cardRadius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconSurface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: OwnerOverviewTokens.purple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: OwnerOverviewTypography.miniTitle,
                          color: OwnerOverviewTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: OwnerOverviewTypography.miniSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showArrow) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.72),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
