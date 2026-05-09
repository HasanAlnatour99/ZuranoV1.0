import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class DashboardHeroSummary extends StatelessWidget {
  const DashboardHeroSummary({
    super.key,
    required this.revenueToday,
    required this.bookingsToday,
    required this.pendingBookings,
    required this.onOpenBookings,
  });

  final String revenueToday;
  final int bookingsToday;
  final int pendingBookings;
  final VoidCallback onOpenBookings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FinanceDashboardColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: FinanceDashboardColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.ownerDashboardV2TodayLabel,
                  style: const TextStyle(
                    color: FinanceDashboardColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: onOpenBookings,
                child: Text(l10n.ownerDashboardV2OpenBookings),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            revenueToday,
            style: const TextStyle(
              color: FinanceDashboardColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 26,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.ownerDashboardV2RevenueTodayLabel,
            style: TextStyle(
              color: FinanceDashboardColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Mini(
                  label: l10n.ownerDashboardV2BookingsLabel,
                  value: '$bookingsToday',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Mini(
                  label: l10n.ownerDashboardV2PendingLabel,
                  value: '$pendingBookings',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: FinanceDashboardColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FinanceDashboardColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: FinanceDashboardColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: FinanceDashboardColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

