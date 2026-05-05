import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/navigation/zurano_floating_bottom_nav.dart';
import '../../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import '../../../employee_today/data/models/et_attendance_punch.dart';
import '../../../employee_today/presentation/employee_today_theme.dart';
import '../../../employee_dashboard/presentation/widgets/employee_bottom_nav_bar.dart';
import '../../../employee_dashboard/presentation/widgets/employee_quick_action_fab.dart';
import '../../../employee_today/providers/employee_today_providers.dart';

class EmployeeAttendanceDetailsScreen extends ConsumerWidget {
  const EmployeeAttendanceDetailsScreen({
    super.key,
    required this.attendanceDayId,
  });

  final String attendanceDayId;

  String _punchTitle(AppLocalizations l10n, AttendancePunchType t) {
    switch (t) {
      case AttendancePunchType.punchIn:
        return l10n.employeeTodayPunchIn;
      case AttendancePunchType.punchOut:
        return l10n.employeeTodayPunchOut;
      case AttendancePunchType.breakOut:
        return l10n.employeeTodayBreakOut;
      case AttendancePunchType.breakIn:
        return l10n.employeeTodayBreakIn;
    }
  }

  String _statusLabel(AppLocalizations l10n, String raw) {
    switch (raw) {
      case 'onBreak':
        return l10n.employeeTodayStatusOnBreak;
      case 'checkedOut':
        return l10n.employeeTodayStatusCheckedOut;
      case 'checkedIn':
        return l10n.employeeTodayStatusCheckedIn;
      case 'notStarted':
        return l10n.employeeAttendanceStatusNotCheckedInTitle;
      default:
        return raw;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final path = GoRouterState.of(context).uri.path;
    final scope = ref.watch(employeeWorkspaceScopeProvider);
    if (scope == null) {
      return Scaffold(
        body: Center(child: Text(l10n.employeePayrollNoWorkspace)),
      );
    }

    final repo = ref.watch(employeeTodayAttendanceRepositoryProvider);
    final day$ = repo.watchAttendanceDay(
      salonId: scope.salonId,
      dayId: attendanceDayId,
    );
    final punches$ = repo.watchDayPunches(
      salonId: scope.salonId,
      attendanceDayId: attendanceDayId,
    );

    return Scaffold(
      extendBody: true,
      floatingActionButtonLocation: zuranoEmployeeCenterDockedFabLocation,
      floatingActionButton: const EmployeeQuickActionFab(),
      appBar: AppBar(
        title: Text(l10n.employeeAttendanceDayTitle),
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder(
        stream: day$,
        builder: (context, daySnap) {
          if (!daySnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final day = daySnap.data;
          if (day == null) {
            return Center(child: Text(l10n.employeeAttendanceDayNoRecord));
          }
          return StreamBuilder<List<EtAttendancePunch>>(
            stream: punches$,
            builder: (context, pSnap) {
              final punches = pSnap.data ?? const [];
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    DateFormat.yMMMEd().format(day.date.toLocal()),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: EmployeeTodayColors.deepText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.employeeAttendanceDayStatusLine(
                      _statusLabel(l10n, day.status),
                    ),
                  ),
                  Text(
                    l10n.employeeAttendanceDayWorkedBreakLine(
                      day.workedMinutes,
                      day.breakMinutes,
                    ),
                  ),
                  const Divider(height: 28),
                  Text(
                    l10n.employeeAttendanceDayPunchesTitle,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  for (final p in punches)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_punchTitle(l10n, p.type)),
                      subtitle: Text(
                        Localizations.localeOf(context).languageCode == 'ar'
                            ? DateFormat.jm('ar').format(p.punchTime.toLocal())
                            : DateFormat.jm('en').format(p.punchTime.toLocal()),
                      ),
                      trailing: p.insideZone == true
                          ? const Icon(
                              Icons.check_circle,
                              color: EmployeeTodayColors.success,
                            )
                          : const Icon(
                              Icons.warning_amber,
                              color: EmployeeTodayColors.amber,
                            ),
                    ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
    );
  }
}
