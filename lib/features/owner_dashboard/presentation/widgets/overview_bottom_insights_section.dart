import 'package:flutter/material.dart';

import 'customer_growth_card.dart';
import 'service_mix_card.dart';

class OverviewBottomInsightsSection extends StatelessWidget {
  const OverviewBottomInsightsSection({
    super.key,
    required this.salonId,
    required this.currencyCode,
  });

  final String salonId;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ServiceMixCard(salonId: salonId, currencyCode: currencyCode),
        const SizedBox(height: 16),
        CustomerGrowthCard(salonId: salonId),
      ],
    );
  }
}
