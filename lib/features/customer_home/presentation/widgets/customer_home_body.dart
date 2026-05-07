import 'package:flutter/material.dart';

import 'category_trending_section.dart';
import 'nearby_salons_section.dart';
import 'recommended_specialists_section.dart';
import 'today_available_section.dart';
import 'recent_activity_section.dart';

/// Premium discovery sections below the purple header and category scroller.
class CustomerHomeBody extends StatelessWidget {
  const CustomerHomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NearbySalonsSection(),
          SizedBox(height: 28),
          CategoryTrendingSection(),
          SizedBox(height: 28),
          TodayAvailableSection(),
          SizedBox(height: 28),
          RecommendedSpecialistsSection(),
          SizedBox(height: 28),
          RecentActivitySection(),
        ],
      ),
    );
  }
}
