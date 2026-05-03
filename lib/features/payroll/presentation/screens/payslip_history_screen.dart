import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/money_currency_providers.dart';
import '../../../../providers/session_provider.dart';
import '../../../../shared/widgets/zurano_empty_state.dart';
import '../../../../shared/widgets/zurano_permission_state.dart';
import '../../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../../../employee_dashboard/application/employee_workspace_scope.dart';
import '../../../employee_dashboard/presentation/widgets/employee_bottom_nav_bar.dart';
import '../../../employee_dashboard/presentation/widgets/employee_quick_action_fab.dart';
import '../../providers/payroll_providers.dart';
import '../widgets/payroll_error_state.dart';
import '../widgets/recent_payslip_tile.dart';

class PayslipHistoryScreen extends ConsumerWidget {
  const PayslipHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final l10n = AppLocalizations.of(context)!;
    final scope = ref.watch(employeeWorkspaceScopeProvider);
    final session = ref.watch(sessionUserProvider).asData?.value;
    final currency = ref.watch(sessionSalonMoneyCurrencyCodeProvider);
    final recentAsync = ref.watch(employeeRecentPayslipsProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.employeePayrollHistoryTitle)),
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
          appBar: AppBar(title: Text(l10n.employeePayrollHistoryTitle)),
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
        appBar: AppBar(title: Text(l10n.employeePayrollHistoryTitle)),
        body: Center(child: Text(l10n.employeePayrollNoWorkspace)),
        extendBody: true,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: const EmployeeQuickActionFab(),
        bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(l10n.employeePayrollHistoryTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: recentAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) {
          if (e is FirebaseException && e.code == 'permission-denied') {
            return Center(
              child: ZuranoPermissionState(
                message: l10n.employeeSectionPermissionDenied,
              ),
            );
          }
          return PayrollErrorState(message: e.toString());
        },
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Text(l10n.employeePayrollEmptyTitle));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = list[i];
              return RecentPayslipTile(
                payslip: p,
                currency: currency,
                onTap: () =>
                    context.push('${AppRoutes.employeePayroll}/${p.id}'),
              );
            },
          );
        },
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const EmployeeQuickActionFab(),
      bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
    );
  }
}
