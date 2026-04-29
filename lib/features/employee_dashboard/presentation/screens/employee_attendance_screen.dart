import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart' show AppRoutes;
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/notification_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/session_provider.dart';
import '../widgets/employee_shell_hero_header.dart';
import '../widgets/employee_bottom_nav_bar.dart';
import '../widgets/employee_quick_action_fab.dart';
import '../../application/employee_dashboard_providers.dart';
import '../../data/models/attendance_day_model.dart';

class EmployeeAttendanceScreen extends ConsumerWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final path = GoRouterState.of(context).uri.path;
    final scope = ref.watch(employeeWorkspaceScopeProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final sessionUser = ref.watch(sessionUserProvider).asData?.value;
    final salon = ref.watch(sessionSalonStreamProvider).asData?.value;
    if (scope == null) {
      return Scaffold(
        body: Center(child: Text(l10n.employeePayrollNoWorkspace)),
      );
    }

    return Scaffold(
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const EmployeeQuickActionFab(),
      backgroundColor: const Color(0xFFFCFAFF),
      body: SafeArea(
        child: FutureBuilder<List<AttendanceDayModel>>(
          future: ref
              .read(employeeAttendanceRepositoryProvider)
              .listRecentDays(
                salonId: scope.salonId,
                employeeId: scope.employeeId,
              ),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final rows = snap.data!;
            final displayName = sessionUser?.name.trim().isNotEmpty == true
                ? sessionUser!.name.trim()
                : scope.displayName;
            final salonLabel = salon?.name.trim().isNotEmpty == true
                ? salon!.name.trim()
                : l10n.employeeTodaySalonLabel;
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: rows.isEmpty ? 3 : rows.length + 2,
              separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 12 : 8),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return EmployeeShellHeroHeader(
                    displayName: displayName,
                    salonDisplayName: salonLabel,
                    photoUrl: sessionUser?.photoUrl,
                    unreadCount: unread,
                    onTapSettings: () => context.push(AppRoutes.settings),
                    onTapNotifications: () => context.push(AppRoutes.notifications),
                  );
                }
                if (i == 1) {
                  return Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => context.push(AppRoutes.employeeAttendanceRequest),
                      icon: const Icon(Icons.edit_calendar_outlined),
                      label: Text(l10n.employeeHistoryRequestCta),
                    ),
                  );
                }
                if (rows.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      l10n.employeeHistoryEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ZuranoPremiumUiColors.textSecondary),
                    ),
                  );
                }
                final row = rows[i - 2];
                final df = DateFormat.MMMd();
                return Card(
                  child: ListTile(
                    title: Text(df.format(row.workDate.toLocal())),
                    subtitle: Text(
                      '${row.status} · ${row.currentState} · worked ${row.totalWorkedMinutes} min',
                    ),
                    trailing: row.punchInAt != null
                        ? Text(DateFormat.jm().format(row.punchInAt!.toLocal()))
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
    );
  }
}
