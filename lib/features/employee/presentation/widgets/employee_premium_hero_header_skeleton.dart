import 'package:flutter/material.dart';

import '../../../../core/widgets/app_skeleton.dart';

/// Shimmer placeholder for full-bleed [EmployeePremiumHeroHeader].
class EmployeePremiumHeroHeaderSkeleton extends StatelessWidget {
  const EmployeePremiumHeroHeaderSkeleton({super.key});

  static const BorderRadius _bottomRadius = BorderRadius.vertical(
    bottom: Radius.circular(24),
  );

  @override
  Widget build(BuildContext context) {
    const contentDrop = 10.0;
    const baseHeight = 210.0;
    final statusTop = MediaQuery.paddingOf(context).top;
    final topInset = statusTop + contentDrop;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      height: baseHeight + topInset,
      decoration: BoxDecoration(
        borderRadius: _bottomRadius,
        color: const Color(0xFF2D0B68).withValues(alpha: 0.35),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16 + topInset, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSkeletonBlock(height: 64, width: 64),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeletonBlock(height: 14, width: 120),
                        SizedBox(height: 8),
                        AppSkeletonBlock(height: 20, width: 160),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const AppSkeletonBlock(height: 48, width: 48),
                  const SizedBox(width: 8),
                  const AppSkeletonBlock(height: 48, width: 48),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  AppSkeletonBlock(height: 30, width: 100),
                  SizedBox(width: 10),
                  AppSkeletonBlock(height: 30, width: 140),
                  SizedBox(width: 10),
                  AppSkeletonBlock(height: 30, width: 110),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
