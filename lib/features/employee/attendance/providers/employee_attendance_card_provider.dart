import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../../../employee_today/data/models/et_attendance_day.dart';
import '../../../employee_today/providers/employee_today_providers.dart';

typedef EmployeeWeekRollup = ({int totalWorkedMinutes, int workingDays});

/// Week-to-date rollup from [attendanceDays] (Monday–Sunday, local calendar).
final employeeWeekAttendanceRollupProvider =
    FutureProvider.autoDispose<EmployeeWeekRollup>((ref) async {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return (totalWorkedMinutes: 0, workingDays: 0);
      }
      final repo = ref.watch(employeeTodayAttendanceRepositoryProvider);
      final days = await repo.getEmployeeAttendanceDaysForWeek(
        salonId: scope.salonId,
        employeeId: scope.employeeId,
        anchor: DateTime.now(),
      );
      var total = 0;
      var withWork = 0;
      for (final EtAttendanceDay d in days) {
        final m = d.workedMinutes;
        if (m > 0) {
          total += m;
          withWork += 1;
        }
      }
      return (totalWorkedMinutes: total, workingDays: withWork);
    });
