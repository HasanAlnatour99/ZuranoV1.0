import 'package:flutter/material.dart';

import '../../../users/data/models/app_user.dart';
import 'overview/owner_dashboard_hero_header.dart';
import 'overview/owner_premium_overview_body.dart';

/// Owner Overview: hero header + premium dashboard body.
///
/// The legacy scroll layout (KPI grid, fl_chart, etc.) was removed from this
/// tab; [OwnerDashboardV2View] remains available on [OwnerDashboardV2Screen] for
/// a snapshot-focused dashboard if routed there.
class OwnerOverviewSection extends StatelessWidget {
  const OwnerOverviewSection({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOwnerDashboardHeroCanvas,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const OwnerOverviewGradientBackdrop(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OwnerDashboardHeroHeader(
                key: ValueKey<String>('owner_hero_${user.uid}'),
                user: user,
                overGradientBackdrop: true,
              ),
              Expanded(
                child: OwnerPremiumOverviewBody(
                  user: user,
                  embedOnOwnerOverviewGradient: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
