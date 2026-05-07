import 'package:flutter/material.dart';

import '../../../../shared/services/service_category_visual_style.dart';
import '../../../../shared/widgets/service_category_icon_tile.dart';
import '../../data/models/trending_service_model.dart';
import '../theme/zurano_customer_colors.dart';

class TrendingServiceCard extends StatelessWidget {
  const TrendingServiceCard({super.key, required this.item});

  final TrendingServiceModel item;

  static const double _tileW = 92.0;
  static const double _tileH = 90.0;

  @override
  Widget build(BuildContext context) {
    final rawIcon = item.iconKey.trim();
    final rawCat = item.categoryId.trim();
    final style = ServiceCategoryVisualStyleResolver.resolve(
      iconKey: rawIcon.isNotEmpty ? rawIcon : null,
      categoryKey: rawCat.isNotEmpty ? rawCat : null,
      categoryLabel: item.label,
      serviceName: item.label,
    );

    return SizedBox(
      width: _tileW,
      height: _tileH,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZuranoCustomerColors.borderHairline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ServiceCategoryIconTile(
                style: style,
                size: 44,
                borderRadius: 14,
                iconSize: 24,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  color: ZuranoCustomerColors.textStrong,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Text(
                item.bookingCountText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ZuranoCustomerColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
