import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class DashboardAlertsCard extends StatelessWidget {
  const DashboardAlertsCard({
    super.key,
    required this.pendingBookings,
    required this.missingCheckouts,
    required this.unpaidCompleted,
    required this.payrollNeedsApproval,
    required this.lowConversion,
  });

  final int pendingBookings;
  final int missingCheckouts;
  final int unpaidCompleted;
  final int payrollNeedsApproval;
  final int lowConversion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final rows = <_AlertRow>[
      _AlertRow(
        label: l10n.ownerDashboardV2AlertPendingBookings,
        count: pendingBookings,
        icon: Icons.schedule_rounded,
      ),
      _AlertRow(
        label: l10n.ownerDashboardV2AlertMissingCheckout,
        count: missingCheckouts,
        icon: Icons.logout_rounded,
      ),
      _AlertRow(
        label: l10n.ownerDashboardV2AlertUnpaidCompleted,
        count: unpaidCompleted,
        icon: Icons.payments_rounded,
      ),
      _AlertRow(
        label: l10n.ownerDashboardV2AlertPayrollApproval,
        count: payrollNeedsApproval,
        icon: Icons.fact_check_rounded,
      ),
      _AlertRow(
        label: l10n.ownerDashboardV2AlertLowConversion,
        count: lowConversion,
        icon: Icons.trending_down_rounded,
      ),
    ];

    final any = rows.any((r) => r.count > 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FinanceDashboardColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FinanceDashboardColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.ownerDashboardV2AlertsTitle,
            style: const TextStyle(
              color: FinanceDashboardColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (!any)
            Text(
              l10n.ownerDashboardV2AlertsAllClear,
              style: const TextStyle(
                color: FinanceDashboardColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Column(
              children: [
                for (final r in rows)
                  if (r.count > 0) ...[
                    _AlertTile(row: r),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
        ],
      ),
    );
  }
}

class _AlertRow {
  const _AlertRow({
    required this.label,
    required this.count,
    required this.icon,
  });

  final String label;
  final int count;
  final IconData icon;
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.row});

  final _AlertRow row;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(row.icon, size: 18, color: FinanceDashboardColors.primaryPurple),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            row.label,
            style: const TextStyle(
              color: FinanceDashboardColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '${row.count}',
          style: const TextStyle(
            color: FinanceDashboardColors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
