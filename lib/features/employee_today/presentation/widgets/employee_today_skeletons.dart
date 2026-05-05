import 'package:flutter/material.dart';

import '../../../../core/widgets/app_skeleton.dart';
import 'employee_today_widgets.dart';

/// Placeholder for [PremiumAttendanceCard] (status + tiles + row of 4 actions + strip).
class EtTodayAttendanceCardSkeleton extends StatelessWidget {
  const EtTodayAttendanceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(12, 0, 12, 14),
      padding: const EdgeInsetsDirectional.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9D5FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              AppSkeletonBlock(height: 64, width: 64),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonBlock(height: 18, width: 140),
                    SizedBox(height: 6),
                    AppSkeletonBlock(height: 12, width: 180),
                  ],
                ),
              ),
              AppSkeletonBlock(height: 76, width: 76),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: AppSkeletonBlock(height: 72)),
              SizedBox(width: 8),
              Expanded(child: AppSkeletonBlock(height: 72)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: AppSkeletonBlock(height: 118)),
              SizedBox(width: 8),
              Expanded(child: AppSkeletonBlock(height: 118)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Expanded(child: AppSkeletonBlock(height: 118)),
              SizedBox(width: 8),
              Expanded(child: AppSkeletonBlock(height: 118)),
            ],
          ),
          const SizedBox(height: 12),
          const SizedBox(
            width: double.infinity,
            height: 96,
            child: AppSkeletonBlock(height: 96),
          ),
        ],
      ),
    );
  }
}

/// Three KPI placeholders (layout matches wide stats row).
class EtTodayStatsSkeleton extends StatelessWidget {
  const EtTodayStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: EtPremiumCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppSkeletonBlock(height: 20, width: 20),
                SizedBox(height: 8),
                AppSkeletonBlock(height: 16, width: 56),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: EtPremiumCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppSkeletonBlock(height: 20, width: 20),
                SizedBox(height: 8),
                AppSkeletonBlock(height: 16, width: 72),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: EtPremiumCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppSkeletonBlock(height: 20, width: 20),
                SizedBox(height: 8),
                AppSkeletonBlock(height: 16, width: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Narrow layout: stacked KPI skeletons.
class EtTodayStatsSkeletonNarrow extends StatelessWidget {
  const EtTodayStatsSkeletonNarrow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EtPremiumCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              AppSkeletonBlock(height: 20, width: 20),
              SizedBox(height: 8),
              AppSkeletonBlock(height: 16, width: 56),
            ],
          ),
        ),
        const SizedBox(height: 10),
        EtPremiumCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              AppSkeletonBlock(height: 20, width: 20),
              SizedBox(height: 8),
              AppSkeletonBlock(height: 16, width: 72),
            ],
          ),
        ),
        const SizedBox(height: 10),
        EtPremiumCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              AppSkeletonBlock(height: 20, width: 20),
              SizedBox(height: 8),
              AppSkeletonBlock(height: 16, width: 48),
            ],
          ),
        ),
      ],
    );
  }
}

class EtTodayTimelineSkeleton extends StatelessWidget {
  const EtTodayTimelineSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return EtPremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              AppSkeletonBlock(height: 18, width: 140),
              Spacer(),
              AppSkeletonBlock(height: 14, width: 48),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: double.infinity,
            child: AppSkeletonBlock(height: 14),
          ),
          const SizedBox(height: 12),
          const AppSkeletonBlock(height: 14, width: 220),
          const SizedBox(height: 12),
          const AppSkeletonBlock(height: 14, width: 180),
        ],
      ),
    );
  }
}

/// Today performance: title + hero + 3 metrics + message row.
class EtTodayPerformanceSkeleton extends StatelessWidget {
  const EtTodayPerformanceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSkeletonBlock(height: 20, width: 160),
        const SizedBox(height: 12),
        const SizedBox(
          width: double.infinity,
          child: AppSkeletonBlock(height: 132),
        ),
        const SizedBox(height: 14),
        Row(
          children: const [
            Expanded(child: AppSkeletonBlock(height: 118)),
            SizedBox(width: 10),
            Expanded(child: AppSkeletonBlock(height: 118)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(child: AppSkeletonBlock(height: 118)),
            SizedBox(width: 10),
            Expanded(child: AppSkeletonBlock(height: 118)),
          ],
        ),
        const SizedBox(height: 14),
        const SizedBox(
          width: double.infinity,
          child: AppSkeletonBlock(height: 56),
        ),
      ],
    );
  }
}
