import 'package:flutter/material.dart';

import '../../../users/data/models/app_user.dart';
import 'overview/owner_dashboard_hero_header.dart';
import 'overview/owner_premium_overview_body.dart';

/// Thin top strip (50px): purple accent under status bar; header/cards use canvas + header row.
class _OwnerOverviewTopBackdrop extends StatelessWidget {
  const _OwnerOverviewTopBackdrop();

  static const double height = 50;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
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
      ),
    );
  }
}

/// Owner Overview: shared top gradient backdrop + transparent hero + scroll body.
///
/// The legacy snapshot layout remains on [OwnerDashboardV2Screen] as [OwnerDashboardV2View].
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
          const _OwnerOverviewTopBackdrop(),
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
}
