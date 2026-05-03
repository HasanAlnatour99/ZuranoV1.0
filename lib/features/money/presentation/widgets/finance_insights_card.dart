import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import 'premium_finance_card.dart';

class FinanceInsightsCard extends StatelessWidget {
  const FinanceInsightsCard({
    super.key,
    required this.title,
    required this.insightLines,
    required this.emptyMessage,
  });

  final String title;
  final List<String> insightLines;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return PremiumFinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: FinanceDashboardColors.lightPurple.withValues(
                    alpha: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: FinanceDashboardColors.primaryPurple,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: FinanceDashboardColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (insightLines.isEmpty)
            DecoratedBox(
              decoration: BoxDecoration(
                color: FinanceDashboardColors.lightPurple.withValues(
                  alpha: 0.25,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FinanceDashboardColors.border.withValues(alpha: 0.7),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      AppIcons.query_stats_rounded,
                      size: 22,
                      color: FinanceDashboardColors.primaryPurple.withValues(
                        alpha: 0.85,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        emptyMessage,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: FinanceDashboardColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < insightLines.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 20,
                      color: FinanceDashboardColors.border,
                    ),
                  _InsightBlock(text: insightLines[i], index: i),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _InsightBlock extends StatelessWidget {
  const _InsightBlock({required this.text, required this.index});

  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    final icon = switch (index % 3) {
      0 => Icons.trending_up_rounded,
      1 => Icons.groups_rounded,
      _ => Icons.star_rounded,
    };
    final color = switch (index % 3) {
      0 => FinanceDashboardColors.greenProfit,
      1 => FinanceDashboardColors.primaryPurple,
      _ => const Color(0xFFF59E0B),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: FinanceDashboardColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
