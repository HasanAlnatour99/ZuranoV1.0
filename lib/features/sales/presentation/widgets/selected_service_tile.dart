import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/service_category_visual_style.dart';

class SelectedServiceTile extends StatelessWidget {
  const SelectedServiceTile({
    super.key,
    required this.title,
    required this.priceLabel,
    required this.onRemove,
    this.categoryKey,
    this.iconKey,
    this.subtitle,
    this.dense = false,

    /// Raw service name for category keyword inference (omit when [title] is only the name).
    this.styleServiceName,
  });

  final String title;
  final String priceLabel;
  final VoidCallback onRemove;
  final String? categoryKey;
  final String? iconKey;
  final String? subtitle;
  final bool dense;

  /// Passed from cart lines / models so inference does not use `"Name × 2"`.
  final String? styleServiceName;

  @override
  Widget build(BuildContext context) {
    final style = ServiceCategoryVisualStyleResolver.resolve(
      iconKey: iconKey,
      categoryKey: categoryKey,
      categoryLabel: null,
      serviceName:
          (styleServiceName != null && styleServiceName!.trim().isNotEmpty)
          ? styleServiceName
          : title,
    );

    final tileSide = dense ? 36.0 : 48.0;
    final radius = dense ? 12.0 : 16.0;
    final iconSz = dense ? 18.0 : 24.0;
    final bottomPad = dense ? 6.0 : 8.0;
    final vPad = dense ? 8.0 : 10.0;
    final hStart = dense ? 10.0 : 12.0;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Container(
        padding: EdgeInsets.fromLTRB(hStart, vPad, 4, vPad),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(dense ? 14 : 18),
          border: Border.all(
            color: FinanceDashboardColors.primaryPurple.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: tileSide,
              height: tileSide,
              decoration: BoxDecoration(
                color: style.background,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: style.foreground.withValues(alpha: 0.12),
                ),
              ),
              child: Icon(style.icon, color: style.foreground, size: iconSz),
            ),
            SizedBox(width: dense ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: dense ? 13 : 14,
                      color: FinanceDashboardColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    SizedBox(height: dense ? 2 : 3),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: dense ? 11 : 12,
                        color: FinanceDashboardColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              priceLabel,
              style: TextStyle(
                fontSize: dense ? 12.5 : 14,
                color: FinanceDashboardColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            IconButton(
              visualDensity: dense
                  ? VisualDensity.compact
                  : VisualDensity.standard,
              constraints: dense
                  ? const BoxConstraints(minWidth: 36, minHeight: 36)
                  : null,
              padding: dense ? EdgeInsets.zero : null,
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              onPressed: onRemove,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: dense ? 20 : 24,
                color: FinanceDashboardColors.textSecondary.withValues(
                  alpha: 0.74,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
