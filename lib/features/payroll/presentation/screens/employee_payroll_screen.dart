import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/firebase_error_message.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/money_currency_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/session_provider.dart';
import '../../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../../../employee_dashboard/application/employee_session_scope.dart';
import '../../../employee_dashboard/application/employee_workspace_scope.dart';
import '../../data/models/payslip_model.dart';
import '../../../employee_dashboard/presentation/widgets/employee_bottom_nav_bar.dart';
import '../../../employee_dashboard/presentation/widgets/employee_quick_action_fab.dart';
import '../../providers/payroll_providers.dart';
import '../services/payslip_pdf_exporter.dart';
import '../widgets/current_payslip_card.dart';
import '../widgets/employee_salary_notes_card.dart';
import '../widgets/payroll_empty_state.dart';
import '../widgets/payroll_error_state.dart';
import '../widgets/payroll_month_selector.dart';
import '../../../../shared/widgets/zurano_empty_state.dart';
import '../../../../shared/widgets/zurano_permission_state.dart';
import '../widgets/payroll_skeleton_loader.dart';
import '../widgets/payroll_stat_card.dart';
import '../widgets/recent_payslip_tile.dart';

class EmployeePayrollScreen extends ConsumerWidget {
  const EmployeePayrollScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final scope = ref.watch(employeeWorkspaceScopeProvider);
    final session = ref.watch(sessionUserProvider).asData?.value;
    final selectedMonth = ref.watch(payrollSelectedMonthProvider);
    final payslipAsync = ref.watch(
      currentEmployeePayslipProvider(selectedMonth),
    );
    final recentAsync = ref.watch(employeeRecentPayslipsProvider);
    final salon = ref.watch(sessionSalonStreamProvider).asData?.value;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final currency = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    if (session == null) {
      return Scaffold(
        body: Center(child: Text(l10n.employeePayrollNoWorkspace)),
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: const EmployeeQuickActionFab(),
        bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
      );
    }
    if (scope == null) {
      if (UserRoles.isStaffRole(session.role.trim()) &&
          !EmployeeWorkspaceScope.userHasStaffWorkspaceLink(session)) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          body: Center(
            child: SingleChildScrollView(
              child: ZuranoEmptyState(
                icon: Icons.link_off_outlined,
                title: l10n.employeeWorkspaceNotLinkedTitle,
                subtitle: l10n.employeeWorkspaceNotLinkedBody,
              ),
            ),
          ),
          extendBody: true,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: const EmployeeQuickActionFab(),
          bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
        );
      }
      return Scaffold(
        body: Center(child: Text(l10n.employeePayrollNoWorkspace)),
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: const EmployeeQuickActionFab(),
        bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
      );
    }

    final sessionScope = ref.watch(employeeSessionScopeProvider);
    if (sessionScope.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: const Center(child: CircularProgressIndicator.adaptive()),
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: const EmployeeQuickActionFab(),
        bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
      );
    }
    if (sessionScope.hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: Center(
          child: PayrollErrorState(
            message: FirebaseErrorMessage.fromException(sessionScope.error!),
          ),
        ),
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: const EmployeeQuickActionFab(),
        bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
      );
    }
    final EmployeeSessionScope? sess = sessionScope.asData?.value;
    if (sess != null && !sess.canUseStaffWorkspace) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: Center(
          child: SingleChildScrollView(
            child: ZuranoEmptyState(
              icon: Icons.person_off_outlined,
              title: l10n.employeeStaffWorkspaceUnavailableTitle,
              subtitle: l10n.employeeStaffWorkspaceUnavailableBody,
            ),
          ),
        ),
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: const EmployeeQuickActionFab(),
        bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
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
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(currentEmployeePayslipProvider(selectedMonth));
              ref.invalidate(employeeRecentPayslipsProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.employeePayrollTitle,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: ZuranoPremiumUiColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.employeePayrollSubtitle,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color:
                                          ZuranoPremiumUiColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        PayrollMonthSelector(
                          selectedMonth: selectedMonth,
                          onChanged: (d) {
                            ref
                                .read(payrollSelectedMonthProvider.notifier)
                                .setMonth(d);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: payslipAsync.when(
                    loading: () => const PayrollSkeletonLoader(),
                    error: (e, _) {
                      if (e is FirebaseException &&
                          e.code == 'permission-denied') {
                        return ZuranoPermissionState(
                          message: l10n.employeeSectionPermissionDenied,
                        );
                      }
                      return PayrollErrorState(message: e.toString());
                    },
                    data: (payslip) {
                      if (payslip == null) {
                        return const PayrollEmptyState();
                      }
                      return Column(
                        children: [
                          CurrentPayslipCard(payslip: payslip, locale: locale),
                          _SalaryNotesBlock(payslipId: payslip.id),
                          _QuickStats(payslip: payslip, l10n: l10n),
                          _Actions(
                            payslip: payslip,
                            salonName: defaultSalonNameForPdf(salon),
                            enabledPdf: true,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.employeePayrollRecentTitle,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.employeePayrollHistory),
                          child: Text(l10n.employeePayrollViewAll),
                        ),
                      ],
                    ),
                  ),
                ),
                recentAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child:
                        e is FirebaseException && e.code == 'permission-denied'
                        ? ZuranoPermissionState(
                            message: l10n.employeeSectionPermissionDenied,
                          )
                        : PayrollErrorState(message: e.toString()),
                  ),
                  data: (list) {
                    if (list.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      sliver: SliverList.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final p = list[i];
                          return RecentPayslipTile(
                            payslip: p,
                            currency: currency,
                            onTap: () => context.push(
                              '${AppRoutes.employeePayroll}/${p.id}',
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          ),
        ),
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const EmployeeQuickActionFab(),
      bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
    );
  }
}

class _SalaryNotesBlock extends ConsumerWidget {
  const _SalaryNotesBlock({required this.payslipId});

  final String payslipId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(employeeSalaryNotesProvider(payslipId));
    return async.when(
      data: (s) {
        if (s == null) {
          return const SizedBox.shrink();
        }
        return EmployeeSalaryNotesCard(summary: s);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.payslip, required this.l10n});

  final PayslipModel payslip;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: PayrollStatCard(
              icon: Icons.content_cut_rounded,
              title: l10n.employeePayrollServicesStat,
              value: '${payslip.servicesCount}',
              subtitle: l10n.employeePayrollThisMonth,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PayrollStatCard(
              icon: Icons.percent_rounded,
              title: l10n.employeePayrollCommissionStat,
              value: '${payslip.commissionPercent.toStringAsFixed(0)}%',
              subtitle: l10n.employeePayrollOnServices,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: PayrollStatCard(
              icon: Icons.calendar_today_outlined,
              title: l10n.employeePayrollAttendanceStat,
              value:
                  '${payslip.attendanceDaysPresent} / ${payslip.attendanceRequiredDays}',
              subtitle: l10n.employeePayrollDaysPresent,
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({
    required this.payslip,
    required this.salonName,
    required this.enabledPdf,
  });

  final PayslipModel payslip;
  final String salonName;
  final bool enabledPdf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                context.push('${AppRoutes.employeePayroll}/${payslip.id}');
              },
              icon: const Icon(Icons.description_outlined),
              label: Text(l10n.employeePayrollViewFullPayslip),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: ZuranoPremiumUiColors.primaryPurple,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: enabledPdf
                  ? () async {
                      await sharePayslipPdf(
                        payslip: payslip,
                        salonDisplayName: salonName,
                        subject: l10n.employeePayrollPdfShareSubject,
                      );
                    }
                  : null,
              icon: const Icon(Icons.download_outlined),
              label: Text(l10n.employeePayrollDownloadPdf),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: ZuranoPremiumUiColors.primaryPurple,
                side: BorderSide(color: ZuranoPremiumUiColors.primaryPurple),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
