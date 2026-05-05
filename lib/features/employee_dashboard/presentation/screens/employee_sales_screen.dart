import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import '../../../sales/domain/employee_sales_period.dart';
import '../../../sales/presentation/providers/employee_sales_period_notifier.dart';
import '../../../sales/presentation/providers/employee_sales_providers.dart';
import '../../../sales/presentation/widgets/employee_commission_card.dart';
import '../../../sales/presentation/widgets/employee_recent_sales_list.dart';
import '../../../sales/presentation/widgets/employee_sales_hero_card.dart';
import '../../../sales/presentation/widgets/employee_sales_period_selector.dart';
import '../../../employee/presentation/widgets/employee_streaming_hero_header.dart';
import '../../application/employee_dashboard_providers.dart';
import '../../../employee/providers/employee_header_provider.dart';
import '../widgets/employee_bottom_nav_bar.dart';
import '../widgets/employee_quick_action_fab.dart';
import '../../../../providers/money_currency_providers.dart';
import '../../../../shared/navigation/zurano_floating_bottom_nav.dart';

class EmployeeSalesScreen extends ConsumerWidget {
  const EmployeeSalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final scope = ref.watch(employeeWorkspaceScopeProvider);
    final session = ref.watch(sessionUserProvider).asData?.value;
    final employeeAsync = ref.watch(workspaceEmployeeProvider);
    final salesAsync = ref.watch(employeeSalesStreamProvider);
    final summary = ref.watch(employeeSalesSummaryProvider);
    final salesPeriod = ref.watch(employeeSalesPeriodProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final salesPeriodSubtitle = switch (salesPeriod) {
      EmployeeSalesPeriod.today => l10n.salesDateToday,
      EmployeeSalesPeriod.week => l10n.teamMemberSalesFilterThisWeek,
      EmployeeSalesPeriod.month => l10n.teamMemberSalesFilterThisMonth,
    };
    if (scope == null || session == null) {
      return Scaffold(
        body: Center(child: Text(l10n.employeePayrollNoWorkspace)),
      );
    }

    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    final rate = employeeAsync.maybeWhen(
      data: (e) => e?.effectiveCommissionRate ?? e?.commissionRate ?? 0,
      orElse: () => 0.0,
    );

    const fabDockClearance = 88.0;
    final scrollBottomSpacer =
        ZuranoFloatingBottomNav.scrollBottomPadding(context) + fabDockClearance + 24;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      extendBody: true,
      floatingActionButtonLocation: zuranoEmployeeCenterDockedFabLocation,
      floatingActionButton: const EmployeeQuickActionFab(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF4ECFF), Color(0xFFF8F9FE), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.35, 1],
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(employeeSalesStreamProvider);
              ref.invalidate(workspaceEmployeeProvider);
              ref.invalidate(employeeHeaderStreamProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: EmployeeStreamingHeroHeader(
                    onWorkspaceLinkRetry: () {
                      ref.invalidate(employeeSalesStreamProvider);
                      ref.invalidate(workspaceEmployeeProvider);
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: EmployeeSalesPeriodSelector()),
                SliverToBoxAdapter(
                  child: EmployeeSalesHeroCard(
                    summary: summary,
                    currencyCode: currencyCode,
                    locale: locale,
                  ),
                ),
                SliverToBoxAdapter(
                  child: EmployeeCommissionCard(
                    commissionPercent: rate,
                    summary: summary,
                    currencyCode: currencyCode,
                    locale: locale,
                  ),
                ),
                SliverToBoxAdapter(
                  child: salesAsync.when(
                    loading: () => EmployeeRecentSalesList(
                      sales: const [],
                      currencyCode: currencyCode,
                      locale: locale,
                      isLoading: true,
                      periodSubtitle: salesPeriodSubtitle,
                      onViewAll: () =>
                          context.push(AppRoutes.employeeSalesHistory),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('$e'),
                    ),
                    data: (list) => EmployeeRecentSalesList(
                      sales: list,
                      currencyCode: currencyCode,
                      locale: locale,
                      periodSubtitle: salesPeriodSubtitle,
                      onViewAll: () =>
                          context.push(AppRoutes.employeeSalesHistory),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: scrollBottomSpacer)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
    );
  }
}
