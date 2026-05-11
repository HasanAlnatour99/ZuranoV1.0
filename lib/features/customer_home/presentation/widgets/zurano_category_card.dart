import 'package:flutter/material.dart';

import '../models/customer_home_ui_models.dart';
import '../theme/zurano_customer_home_design_tokens.dart';
import '../utils/zurano_category_icons.dart';

class ZuranoCategoryCard extends StatelessWidget {
  const ZuranoCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.width = 88,
    this.height = 96,
  });

  final CustomerHomeCategoryUi category;
  final VoidCallback onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final icon = zuranoCategoryIcon(
      category.iconKey.isEmpty ? category.id : category.iconKey,
    );

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: category.isSelected
                  ? const LinearGradient(
                      colors: [
                        ZuranoCustomerHomeColors.primary,
                        ZuranoCustomerHomeColors.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: category.isSelected ? null : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: category.isSelected ? 0.12 : 0.05,
                  ),
                  blurRadius: category.isSelected ? 14 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: category.isSelected
                  ? null
                  : Border.all(color: ZuranoCustomerHomeColors.lavender),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: category.isSelected
                      ? Colors.white
                      : ZuranoCustomerHomeColors.mutedText,
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    category.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                      color: category.isSelected
                          ? Colors.white
                          : ZuranoCustomerHomeColors.darkText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
