import 'package:flutter/material.dart';

import '../../../../core/feature_flags/owner_overview_ui.dart';
import '../../../users/data/models/app_user.dart';
import '../../dashboard_v2/presentation/screens/owner_dashboard_v2_screen.dart';
import 'overview/owner_dashboard_hero_header.dart';
import 'overview/owner_premium_overview_body.dart';

/// Height of the top purple band only; below this is forced [kOwnerDashboardHeroCanvas].
const double _kOwnerOverviewPurpleBandHeight = 390;

/// Purple gradient only in this band — never full-screen / scroll body.
class _OwnerOverviewTopBackdrop extends StatelessWidget {
  const _OwnerOverviewTopBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.45, 0.68, 0.84, 1.0],
            colors: [
              const Color(0xFF3F13C8),
              const Color(0xFF5120D8),
              const Color(0xFF6D28F6),
              Color(0xFF8F63F6).withValues(alpha: 0.28),
              kOwnerDashboardHeroCanvas,
            ],
          ),
        ),
      ),
    );
  }
}

/// Owner Overview: premium body when [kOwnerDashboardV2Enabled]; canvas + masked purple band.
///
/// Legacy snapshot layout: [OwnerDashboardV2Screen] / [OwnerDashboardV2View].
class OwnerOverviewSection extends StatelessWidget {
  const OwnerOverviewSection({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    if (kOwnerDashboardV2Enabled) {
      return Scaffold(
        backgroundColor: kOwnerDashboardHeroCanvas,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const Positioned.fill(
              child: ColoredBox(color: kOwnerDashboardHeroCanvas),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _kOwnerOverviewPurpleBandHeight,
              child: _OwnerOverviewTopBackdrop(),
            ),
            Positioned(
              top: _kOwnerOverviewPurpleBandHeight,
              left: 0,
              right: 0,
              bottom: 0,
              child: const ColoredBox(color: kOwnerDashboardHeroCanvas),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OwnerDashboardHeroHeader(
                  key: ValueKey<String>('owner_hero_${user.uid}'),
                  user: user,
                  transparentOnSharedBackdrop: true,
                ),
                Expanded(
                  child: OwnerPremiumOverviewBody(
                    user: user,
                    sharedTopBackdrop: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: kOwnerDashboardHeroCanvas,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OwnerDashboardHeroHeader(
            key: ValueKey<String>('owner_hero_legacy_${user.uid}'),
            user: user,
          ),
          const Expanded(
            child: OwnerDashboardV2View(embedded: true),
          ),
        ],
      ),
    );
  }
}
