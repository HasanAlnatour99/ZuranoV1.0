import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/service_category_icon_resolver.dart';

class ServiceQuickCard extends StatelessWidget {
  const ServiceQuickCard({
    super.key,
    required this.title,
    required this.priceLabel,
    required this.categoryKey,
    this.iconKey,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  final String title;
  final String priceLabel;
  final String? categoryKey;
  final String? iconKey;
  final bool isSelected;
  final VoidCallback onTap;

  /// One-line full-width row for vertical lists (add sale).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        FinanceDashboardColors.primaryPurple.withValues(
                          alpha: 0.10,
                        ),
                        FinanceDashboardColors.lightPurple.withValues(
                          alpha: 0.32,
                        ),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? FinanceDashboardColors.primaryPurple
                    : FinanceDashboardColors.border,
                width: isSelected ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        FinanceDashboardColors.primaryPurple,
                        FinanceDashboardColors.deepPurple,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    ServiceCategoryIconResolver.resolve(
                      iconKey: iconKey,
                      categoryKey: categoryKey,
                    ),
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          height: 1.2,
                          color: FinanceDashboardColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        priceLabel,
                        style: const TextStyle(
                          color: FinanceDashboardColors.primaryPurple,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: FinanceDashboardColors.primaryPurple,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 164,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      FinanceDashboardColors.primaryPurple.withValues(
                        alpha: 0.12,
                      ),
                      FinanceDashboardColors.lightPurple.withValues(
                        alpha: 0.42,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? FinanceDashboardColors.primaryPurple
                  : FinanceDashboardColors.border,
              width: isSelected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? FinanceDashboardColors.primaryPurple.withValues(
                        alpha: 0.16,
                      )
                    : Colors.black.withValues(alpha: 0.035),
                blurRadius: isSelected ? 18 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              FinanceDashboardColors.primaryPurple,
                              FinanceDashboardColors.deepPurple,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: FinanceDashboardColors.primaryPurple
                                  .withValues(alpha: 0.20),
                              blurRadius: 14,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Icon(
                          ServiceCategoryIconResolver.resolve(
                            iconKey: iconKey,
                            categoryKey: categoryKey,
                          ),
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: FinanceDashboardColors.primaryPurple,
                          size: 22,
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      height: 1.15,
                      color: FinanceDashboardColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    priceLabel,
                    style: const TextStyle(
                      color: FinanceDashboardColors.primaryPurple,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
