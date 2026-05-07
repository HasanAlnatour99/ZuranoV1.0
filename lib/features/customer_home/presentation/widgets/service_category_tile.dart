import 'package:flutter/material.dart';

import '../../data/models/discovery_service_category_model.dart';
import '../theme/zurano_customer_colors.dart';
import '../utils/discovery_category_icon.dart';

class DiscoveryServiceCategoryTile extends StatelessWidget {
  const DiscoveryServiceCategoryTile({
    super.key,
    required this.category,
    this.onTap,
  });

  final DiscoveryServiceCategoryModel category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final label = category.labelForLocale(locale);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: 108,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ZuranoCustomerColors.borderHairline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              discoveryCategoryIcon(category.iconKey),
              color: ZuranoCustomerColors.primary,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
