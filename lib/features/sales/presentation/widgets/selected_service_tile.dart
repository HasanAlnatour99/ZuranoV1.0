import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/service_category_icon_resolver.dart';

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
  });

  final String title;
  final String priceLabel;
  final VoidCallback onRemove;
  final String? categoryKey;
  final String? iconKey;
  final String? subtitle;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final iconSize = dense ? 18.0 : 20.0;
    final leading = dense ? 32.0 : 40.0;
    final radius = dense ? 12.0 : 14.0;
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
              width: leading,
              height: leading,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    FinanceDashboardColors.primaryPurple,
                    FinanceDashboardColors.deepPurple,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Icon(
                ServiceCategoryIconResolver.resolve(
                  iconKey: iconKey,
                  categoryKey: categoryKey,
                ),
                color: Colors.white,
                size: iconSize,
              ),
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
