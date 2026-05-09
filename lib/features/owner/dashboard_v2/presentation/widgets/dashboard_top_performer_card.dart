import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';

class DashboardTopPerformerCard extends StatelessWidget {
  const DashboardTopPerformerCard({
    super.key,
    required this.topEmployeeName,
    required this.topEmployeeRevenue,
    required this.topServiceName,
    required this.topServiceRevenue,
    required this.conversionRate,
  });

  final String topEmployeeName;
  final String topEmployeeRevenue;
  final String topServiceName;
  final String topServiceRevenue;
  final double conversionRate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            l10n.ownerDashboardV2TopPerformersTitle,
            style: TextStyle(
              color: FinanceDashboardColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _Row(
            label: l10n.ownerDashboardV2TopBarberLabel,
            value: topEmployeeName.trim().isEmpty ? '—' : topEmployeeName,
            trailing: topEmployeeName.trim().isEmpty ? null : topEmployeeRevenue,
          ),
          const SizedBox(height: 8),
          _Row(
            label: l10n.ownerDashboardV2TopServiceLabel,
            value: topServiceName.trim().isEmpty ? '—' : topServiceName,
            trailing: topServiceName.trim().isEmpty ? null : topServiceRevenue,
          ),
          const SizedBox(height: 8),
          _Row(
            label: l10n.ownerDashboardV2ConversionLabel,
            value: '${conversionRate.toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.trailing});

  final String label;
  final String value;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              color: FinanceDashboardColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: FinanceDashboardColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Text(
            trailing!,
            style: const TextStyle(
              color: FinanceDashboardColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

