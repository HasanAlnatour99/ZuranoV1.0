import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/formatting/app_money_format.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_empty_state.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../audit/application/audit_providers.dart';
import '../../../../../providers/money_currency_providers.dart';
import '../../../presentation/widgets/owner_zurano_bottom_nav.dart';
import '../../application/owner_dashboard_actions_controller.dart';
import '../../application/owner_dashboard_providers.dart';
import '../widgets/dashboard_alerts_card.dart';
import '../widgets/dashboard_hero_summary.dart';
import '../widgets/dashboard_metric_grid.dart';
import '../widgets/dashboard_quick_actions_grid.dart';
import '../widgets/dashboard_top_performer_card.dart';

/// Snapshot-backed owner dashboard. Also embedded in the Overview tab when enabled.
class OwnerDashboardV2Screen extends ConsumerWidget {
  const OwnerDashboardV2Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final canAudit = ref.watch(canReadSalonActivityAuditProvider);

    return Scaffold(
      backgroundColor: FinanceDashboardColors.background,
      appBar: AppBar(
        backgroundColor: FinanceDashboardColors.background,
        foregroundColor: FinanceDashboardColors.textPrimary,
        elevation: 0,
        title: Text(l10n.ownerDashboardV2Title),
        actions: [
          if (canAudit)
            IconButton(
              tooltip: l10n.ownerDashboardActivityCenterTooltip,
              icon: const Icon(Icons.manage_history_outlined),
              onPressed: () => context.push(AppRoutes.ownerActivityCenter),
            ),
          _RefreshButton(),
        ],
      ),
      body: const OwnerDashboardV2View(embedded: false),
    );
  }
}

class _RefreshButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final actions = ref.watch(ownerDashboardActionsControllerProvider);
    return IconButton(
      tooltip: l10n.ownerDashboardRefresh,
      onPressed: actions.isLoading
          ? null
          : () => ref
              .read(ownerDashboardActionsControllerProvider.notifier)
              .refresh(),
      icon: actions.isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: FinanceDashboardColors.primaryPurple,
              ),
            )
          : const Icon(Icons.refresh_rounded),
    );
  }
}

class OwnerDashboardV2View extends ConsumerStatefulWidget {
  const OwnerDashboardV2View({super.key, required this.embedded});

  /// When **true**, omits outer scaffold padding tuned for the Overview shell.
  final bool embedded;

  @override
  ConsumerState<OwnerDashboardV2View> createState() =>
      _OwnerDashboardV2ViewState();
}

class _OwnerDashboardV2ViewState extends ConsumerState<OwnerDashboardV2View> {
  var _didBootstrap = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _didBootstrap) return;
      _didBootstrap = true;
      await ref.read(ownerDashboardActionsControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    final dailyAsync = ref.watch(todayDashboardSnapshotProvider);
    final monthlyAsync = ref.watch(currentMonthDashboardSnapshotProvider);
    final actions = ref.watch(ownerDashboardActionsControllerProvider);

    final dateLabel =
        DateFormat.yMMMEd(locale.toString()).format(DateTime.now());

    final bottomPad = widget.embedded
        ? OwnerZuranoBottomNav.ownerShellScrollBottomPadding(context)
        : 120.0;

    final horizontalPad = widget.embedded ? 18.0 : 20.0;
    final topPad = widget.embedded ? 8.0 : 14.0;

    final isLoading =
        (dailyAsync.isLoading || monthlyAsync.isLoading) && !actions.isLoading;
    final error = dailyAsync.asError ?? monthlyAsync.asError;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: FinanceDashboardColors.primaryPurple,
        ),
      );
    }

    if (error != null) {
      return AppEmptyState(
        title: l10n.ownerDashboardV2ErrorTitle,
        message: l10n.ownerDashboardV2ErrorMessage,
        icon: Icons.dashboard_customize_rounded,
        compactTypography: true,
        primaryActionLabel: l10n.ownerDashboardRefresh,
        onPrimaryAction: () =>
            ref.read(ownerDashboardActionsControllerProvider.notifier).refresh(),
      );
    }

    final daily = dailyAsync.value;
    final monthly = monthlyAsync.value;

    if (daily == null && monthly == null && !actions.isLoading) {
      return AppEmptyState(
        title: l10n.ownerDashboardV2EmptyTitle,
        message: l10n.ownerDashboardV2EmptyMessage,
        icon: Icons.insights_outlined,
        compactTypography: true,
        primaryActionLabel: l10n.ownerDashboardRefresh,
        onPrimaryAction: () =>
            ref.read(ownerDashboardActionsControllerProvider.notifier).refresh(),
      );
    }

    return RefreshIndicator(
      color: FinanceDashboardColors.primaryPurple,
      onRefresh: () =>
          ref.read(ownerDashboardActionsControllerProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(horizontalPad, topPad, horizontalPad, bottomPad),
        children: [
          Text(
            dateLabel,
            style: const TextStyle(
              color: FinanceDashboardColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          DashboardHeroSummary(
            revenueToday: formatSalonMoneyWithCode(
              daily?.revenueToday ?? 0,
              currencyCode,
              locale,
            ),
            bookingsToday: daily?.bookingsToday ?? 0,
            pendingBookings: daily?.pendingBookings ?? 0,
            onOpenBookings: () => context.push(AppRoutes.ownerBookings),
          ),
          const SizedBox(height: 14),
          DashboardMetricGrid(
            monthlyRevenue: formatSalonMoneyWithCode(
              monthly?.monthlyRevenue ?? 0,
              currencyCode,
              locale,
            ),
            monthlyNetProfit: formatSalonMoneyWithCode(
              monthly?.monthlyNetProfit ?? 0,
              currencyCode,
              locale,
            ),
            monthlyPayrollCost: formatSalonMoneyWithCode(
              monthly?.monthlyPayrollCost ?? 0,
              currencyCode,
              locale,
            ),
            monthlyExpenses: formatSalonMoneyWithCode(
              monthly?.monthlyExpenses ?? 0,
              currencyCode,
              locale,
            ),
          ),
          const SizedBox(height: 14),
          DashboardAlertsCard(
            pendingBookings: daily?.pendingBookings ?? 0,
            missingCheckouts: daily?.alertMissingCheckouts ?? 0,
            unpaidCompleted: daily?.alertUnpaidCompletedBookings ?? 0,
            payrollNeedsApproval: monthly?.alertPayrollNeedsApproval ?? 0,
            lowConversion: monthly?.alertLowBookingConversion ?? 0,
          ),
          const SizedBox(height: 14),
          DashboardTopPerformerCard(
            topEmployeeName: monthly?.topEmployeeName?.trim() ?? '',
            topEmployeeRevenue: formatSalonMoneyWithCode(
              monthly?.topEmployeeRevenue ?? 0,
              currencyCode,
              locale,
            ),
            topServiceName: monthly?.topServiceName?.trim() ?? '',
            topServiceRevenue: formatSalonMoneyWithCode(
              monthly?.topServiceRevenue ?? 0,
              currencyCode,
              locale,
            ),
            conversionRate: monthly?.conversionRate ?? 0,
          ),
          const SizedBox(height: 14),
          DashboardQuickActionsGrid(
            onBookings: () => context.push(AppRoutes.ownerBookings),
            onSales: () => context.push(AppRoutes.ownerSales),
            onAttendance: () => context.push(AppRoutes.ownerAttendanceSettings),
            onPayroll: () => context.push(AppRoutes.ownerPayroll),
            onExpenses: () => context.push(AppRoutes.ownerExpenses),
            onAnalytics: () => context.push(AppRoutes.ownerAnalytics),
            onTeam: () => context.push(AppRoutes.ownerTeamStack),
            onServices: () => context.push(AppRoutes.ownerServices),
            onReports: () => context.push(AppRoutes.ownerReportsCenter),
          ),
        ],
      ),
    );
  }
}
