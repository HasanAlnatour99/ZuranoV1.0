import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class TopEmployeeCard extends StatelessWidget {
  const TopEmployeeCard({
    super.key,
    required this.employeeName,
    required this.salesTotal,
    required this.salesCount,
  });

  final String employeeName;
  final String salesTotal;
  final int salesCount;

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
              employeeName,
              style: const TextStyle(
                color: FinanceDashboardColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            '$salesTotal · $salesCount',
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

