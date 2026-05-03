import 'package:flutter/material.dart';

import '../theme/zurano_customer_colors.dart';

/// Shown while category chips stream is loading — fixed height avoids layout jumps.
class CustomerCategorySkeleton extends StatelessWidget {
  const CustomerCategorySkeleton({super.key});

  static const double _rowHeight = 72;
  static const double _dot = 44;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _rowHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _dot,
                height: _dot,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ZuranoCustomerColors.lavenderSoft.withValues(
                    alpha: 0.45,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Container(
                height: 10,
                width: 48,
                decoration: BoxDecoration(
                  color: ZuranoCustomerColors.borderHairline.withValues(
                    alpha: 0.45,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
