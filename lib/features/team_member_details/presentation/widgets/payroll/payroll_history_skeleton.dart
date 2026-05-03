import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class PayrollHistorySkeleton extends StatelessWidget {
  const PayrollHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ZuranoPremiumUiColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ZuranoPremiumUiColors.border.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: ZuranoPremiumUiColors.primaryPurple.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ZuranoPremiumUiColors.softPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: ZuranoPremiumUiColors.lightSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < 3; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: ZuranoPremiumUiColors.border.withValues(alpha: 0.55),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                            color: ZuranoPremiumUiColors.lightSurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 88,
                          decoration: BoxDecoration(
                            color: ZuranoPremiumUiColors.lightSurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 16,
                        width: 72,
                        decoration: BoxDecoration(
                          color: FinanceDashboardColors.greenProfitSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 22,
                        width: 56,
                        decoration: BoxDecoration(
                          color: ZuranoPremiumUiColors.lightSurface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
