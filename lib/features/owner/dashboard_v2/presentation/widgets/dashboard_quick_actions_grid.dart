import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/permissions/permission_gate.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../reports/application/reports_providers.dart';
import '../../../../permissions/data/models/permission_key.dart';

class DashboardQuickActionsGrid extends ConsumerWidget {
  const DashboardQuickActionsGrid({
    super.key,
    required this.onBookings,
    required this.onSales,
    required this.onAttendance,
    required this.onPayroll,
    required this.onExpenses,
    required this.onAnalytics,
    required this.onTeam,
    required this.onServices,
    this.onReports,
  });

  final VoidCallback onBookings;
  final VoidCallback onSales;
  final VoidCallback onAttendance;
  final VoidCallback onPayroll;
  final VoidCallback onExpenses;
  final VoidCallback onAnalytics;
  final VoidCallback onTeam;
  final VoidCallback onServices;
  final VoidCallback? onReports;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final showReports = ref.watch(canAccessReportsCenterProvider) &&
        onReports != null;
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
            l10n.ownerDashboardV2QuickActionsTitle,
            style: TextStyle(
              color: FinanceDashboardColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PermissionGate(
                permission: PermissionKey.bookingsView,
                child: _Action(
                  label: l10n.ownerDashboardV2QuickBookings,
                  icon: AppIcons.calendar_today_outlined,
                  onTap: onBookings,
                ),
              ),
              PermissionGate(
                permission: PermissionKey.salesView,
                child: _Action(
                  label: l10n.ownerDashboardV2QuickSales,
                  icon: AppIcons.receipt_long_outlined,
                  onTap: onSales,
                ),
              ),
              PermissionGate(
                permission: PermissionKey.attendanceView,
                child: _Action(
                  label: l10n.ownerDashboardV2QuickAttendance,
                  icon: AppIcons.fact_check_outlined,
                  onTap: onAttendance,
                ),
              ),
              PermissionGate(
                permission: PermissionKey.payrollView,
                child: _Action(
                  label: l10n.ownerDashboardV2QuickPayroll,
                  icon: AppIcons.payments_outlined,
                  onTap: onPayroll,
                ),
              ),
              PermissionGate(
                permission: PermissionKey.expensesView,
                child: _Action(
                  label: l10n.ownerDashboardV2QuickExpenses,
                  icon: AppIcons.wallet_outlined,
                  onTap: onExpenses,
                ),
              ),
              PermissionGate(
                permission: PermissionKey.analyticsView,
                child: _Action(
                  label: l10n.ownerDashboardV2QuickAnalytics,
                  icon: AppIcons.query_stats_rounded,
                  onTap: onAnalytics,
                ),
              ),
              if (showReports)
                _Action(
                  label: l10n.ownerDashboardQuickReports,
                  icon: Icons.insert_drive_file_outlined,
                  onTap: onReports!,
                ),
              PermissionGate(
                permission: PermissionKey.teamView,
                child: _Action(
                  label: l10n.ownerDashboardV2QuickTeam,
                  icon: AppIcons.group_outlined,
                  onTap: onTeam,
                ),
              ),
              PermissionGate(
                permission: PermissionKey.teamView,
                child: _Action(
                  label: l10n.ownerDashboardV2QuickServices,
                  icon: AppIcons.content_cut_outlined,
                  onTap: onServices,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: FinanceDashboardColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FinanceDashboardColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: FinanceDashboardColors.textPrimary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: FinanceDashboardColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

