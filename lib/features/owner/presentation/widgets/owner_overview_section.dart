import 'package:flutter/material.dart';

import '../../../users/data/models/app_user.dart';
import 'overview/owner_dashboard_hero_header.dart';
import 'overview/owner_premium_overview_body.dart';

/// Tall top fade: purple behind header and upper half of first card / chart, then canvas.
class _OwnerOverviewTopBackdrop extends StatelessWidget {
  const _OwnerOverviewTopBackdrop();

  static const double height = 420;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.42, 0.68, 0.86, 1.0],
                    colors: [
                      const Color(0xFF3F13C8),
                      const Color(0xFF5120D8),
                      const Color(0xFF6D28F6),
                      Color(0xFF9D6CFF).withValues(alpha: 0.35),
                      kOwnerDashboardHeroCanvas,
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.05),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.03),
                      ],
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                end: -72,
                top: -56,
                child: IgnorePointer(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.09),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
