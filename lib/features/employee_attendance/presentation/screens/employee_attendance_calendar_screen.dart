import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../shared/navigation/zurano_floating_bottom_nav.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../../../employee_today/data/models/et_attendance_day.dart';
import '../../../employee_today/data/repositories/employee_today_attendance_repository.dart';
import '../../../employee_today/presentation/employee_today_theme.dart';
import '../../../employee_dashboard/presentation/widgets/employee_bottom_nav_bar.dart';
import '../../../employee_dashboard/presentation/widgets/employee_quick_action_fab.dart';
import '../providers/employee_attendance_providers.dart';

class EmployeeAttendanceCalendarScreen extends ConsumerWidget {
  const EmployeeAttendanceCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final path = GoRouterState.of(context).uri.path;
    final scope = ref.watch(employeeWorkspaceScopeProvider);
    final now = DateTime.now();
    final key = now.year * 100 + now.month;
    final monthAsync = ref.watch(employeeAttendanceMonthDaysProvider(key));

    if (scope == null) {
      return Scaffold(
        body: Center(child: Text(l10n.employeePayrollNoWorkspace)),
      );
    }

    return Scaffold(
      extendBody: true,
      floatingActionButtonLocation: zuranoEmployeeCenterDockedFabLocation,
      floatingActionButton: const EmployeeQuickActionFab(),
      appBar: AppBar(
        title: Text(DateFormat.yMMMM().format(now)),
        backgroundColor: Colors.transparent,
      ),
      body: monthAsync.when(
        data: (List<EtAttendanceDay> days) {
          final keys = {for (final d in days) d.dateKey: d};
          final firstWeekday = DateTime(now.year, now.month).weekday;
          final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: firstWeekday - 1 + daysInMonth,
            itemBuilder: (context, i) {
              if (i < firstWeekday - 1) {
                return const SizedBox.shrink();
              }
              final dayNum = i - (firstWeekday - 1) + 1;
              final date = DateTime(now.year, now.month, dayNum);
              final dk = EmployeeTodayAttendanceRepository.compactDateKey(date);
              final row = keys[dk];
              final has = row?.firstPunchInAt != null;
              return InkWell(
                onTap: row == null
                    ? null
                    : () => context.push(
                        '${AppRoutes.employeeAttendance}/${row.id}',
                      ),
                borderRadius: BorderRadius.circular(12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: has
                        ? EmployeeTodayColors.primaryPurple.withValues(
                            alpha: 0.12,
                          )
                        : EmployeeTodayColors.cardBorder.withValues(
                            alpha: 0.35,
                          ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      if (has)
                        const Icon(
                          Icons.check,
                          size: 14,
                          color: EmployeeTodayColors.primaryPurple,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.employeeCalendarLoadError)),
      ),
      bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
    );
  }
}
