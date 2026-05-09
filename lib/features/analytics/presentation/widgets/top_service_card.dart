import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class TopServiceCard extends StatelessWidget {
  const TopServiceCard({
    super.key,
    required this.serviceName,
    required this.revenue,
    required this.count,
  });

  final String serviceName;
  final String revenue;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FinanceDashboardColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FinanceDashboardColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              serviceName,
              style: const TextStyle(
                color: FinanceDashboardColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '$revenue · $count',
            style: const TextStyle(
              color: FinanceDashboardColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

