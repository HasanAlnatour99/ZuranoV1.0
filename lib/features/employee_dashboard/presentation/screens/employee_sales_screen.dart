import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/notification_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/session_provider.dart';
import '../../../sales/presentation/providers/employee_sales_providers.dart';
import '../../../sales/presentation/widgets/employee_commission_card.dart';
import '../../../sales/presentation/widgets/employee_recent_sales_list.dart';
import '../../../sales/presentation/widgets/employee_sales_hero_card.dart';
import '../../../sales/presentation/widgets/employee_sales_kpi_grid.dart';
import '../../../sales/presentation/widgets/employee_sales_period_selector.dart';
import '../widgets/employee_shell_hero_header.dart';
import '../../application/employee_dashboard_providers.dart';
import '../widgets/employee_bottom_nav_bar.dart';
import '../widgets/employee_quick_action_fab.dart';
import '../../../../providers/money_currency_providers.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final unread = ref.watch(unreadNotificationCountProvider);

    if (scope == null || session == null) {
      return Scaffold(
        body: Center(child: Text(l10n.employeePayrollNoWorkspace)),
      );
    }

    final salon = ref.watch(sessionSalonStreamProvider).asData?.value;
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    final rate = employeeAsync.maybeWhen(
      data: (e) => e?.effectiveCommissionRate ?? e?.commissionRate ?? 0,
      orElse: () => 0.0,
    );

    final media = MediaQuery.of(context);
    final bottomInset = media.padding.bottom;
    const bottomNavBarApprox = 88.0;
    const fabDockClearance = 88.0;
    final scrollBottomSpacer =
        bottomInset + bottomNavBarApprox + fabDockClearance + 24;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(employeeSalesStreamProvider);
              ref.invalidate(workspaceEmployeeProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: EmployeeShellHeroHeader(
                      displayName: scope.displayName,
                      photoUrl: session.photoUrl,
                      salonDisplayName: salon?.name.trim().isNotEmpty == true
                          ? salon!.name.trim()
                          : l10n.employeeTodaySalonLabel,
                      unreadCount: unread,
                      onTapSettings: () => context.push(AppRoutes.settings),
                      onTapNotifications: () =>
                          context.push(AppRoutes.notifications),
                    ),
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
                  child: EmployeeSalesKpiGrid(
                    summary: summary,
                    currencyCode: currencyCode,
                    locale: locale,
                  ),
                ),
                SliverToBoxAdapter(
                  child: EmployeeSalesKpiGridRow2(
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
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('$e'),
                    ),
                    data: (list) => EmployeeRecentSalesList(
                      sales: list,
                      currencyCode: currencyCode,
                      locale: locale,
                      onViewReceiptsTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.employeeSalesViewReceiptsHint),
                          ),
                        );
                      },
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
