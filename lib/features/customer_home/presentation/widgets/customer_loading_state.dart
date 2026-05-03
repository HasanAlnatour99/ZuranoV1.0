import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../shared/ui/zurano_responsive.dart';
import '../theme/zurano_customer_colors.dart';

class CustomerHorizontalCardSkeleton extends StatelessWidget {
  const CustomerHorizontalCardSkeleton({super.key, this.cardWidth = 186});

  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final baseColor = ZuranoCustomerColors.borderHairline.withValues(
      alpha: 0.95,
    );
    final highlight = ZuranoCustomerColors.background.withValues(alpha: 0.92);
    final rowH = ZuranoResponsive.v(context, 204);
    final w = ZuranoResponsive.s(context, cardWidth);
    return SizedBox(
      height: rowH,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) => Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlight,
          period: const Duration(milliseconds: 1100),
          child: SizedBox(
            width: w,
            height: rowH,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ZuranoCustomerColors.borderHairline,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomerVerticalBannerSkeleton extends StatelessWidget {
  const CustomerVerticalBannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = ZuranoCustomerColors.borderHairline.withValues(
      alpha: 0.96,
    );
    final highlight = ZuranoCustomerColors.background.withValues(alpha: 0.92);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlight,
        period: const Duration(milliseconds: 1100),
        child: SizedBox(
          height: ZuranoResponsive.v(context, 112),
          width: double.infinity,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFEDE7F6),
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact horizontal placeholders for trending pills (matches [TrendingServicesSection] height).
class CustomerTrendingRowSkeleton extends StatelessWidget {
  const CustomerTrendingRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = ZuranoCustomerColors.borderHairline.withValues(
      alpha: 0.95,
    );
    final highlight = ZuranoCustomerColors.background.withValues(alpha: 0.92);
    final h = ZuranoResponsive.v(context, 96);
    final tileW = ZuranoResponsive.s(context, 92);
    return SizedBox(
      height: h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, _) => Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlight,
          period: const Duration(milliseconds: 1100),
          child: SizedBox(
            width: tileW,
            height: h - 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFE8E0F2)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact vertical list placeholders for nearby rows.
class CustomerNearbyListSkeleton extends StatelessWidget {
  const CustomerNearbyListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = ZuranoCustomerColors.borderHairline.withValues(
      alpha: 0.95,
    );
    final highlight = ZuranoCustomerColors.background.withValues(alpha: 0.92);
    // Keep total height ≤ [NearbySalonsSection] loading box (~160): 3×48 + 2×6 = 156.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i == 2 ? 0 : 6),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlight,
            period: const Duration(milliseconds: 1100),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: ZuranoCustomerColors.borderHairline,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      }),
    );
  }
}
