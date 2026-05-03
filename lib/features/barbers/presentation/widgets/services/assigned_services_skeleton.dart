import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../features/team_member_profile/presentation/theme/team_member_profile_colors.dart';

class AssignedServicesSkeleton extends StatelessWidget {
  const AssignedServicesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                const _SkeletonBlock(height: 102, radius: 26),
                const SizedBox(height: 28),
                const _SkeletonBlock(height: 56, radius: 16),
                const SizedBox(height: 16),
                const _SkeletonBlock(height: 140, radius: 26),
                const SizedBox(height: 14),
                const _SkeletonBlock(height: 140, radius: 26),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height, required this.radius});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: TeamMemberProfileColors.softPurple,
      highlightColor: TeamMemberProfileColors.card,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: TeamMemberProfileColors.softPurple,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
