import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/salon_streams_provider.dart';
import '../../employee_today/data/repositories/employee_today_attendance_repository.dart';
import '../../employee_today/data/models/employee_workplace_location_snapshot.dart';
import '../../employee_today/providers/employee_today_providers.dart';
import 'employee_dashboard_providers.dart';
import 'employee_today_attendance_vm.dart';

/// Combined attendance view-model for the Today card and quick actions.
final employeeTodayAttendanceProvider =
    Provider.autoDispose<AsyncValue<EmployeeTodayAttendanceVm>>((ref) {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return AsyncData(EmployeeTodayAttendanceVm.noWorkspace());
      }

      final settings = ref.watch(etAttendanceSettingsProvider);
      final day = ref.watch(etTodayAttendanceDayProvider);
      final punches = ref.watch(etTodayPunchesProvider);
      final schedule = ref.watch(etTodayAssignedScheduleProvider);
      final emp = ref.watch(workspaceEmployeeProvider);
      final location = ref.watch(employeeWorkplaceLocationSnapshotProvider);

      if (settings.isLoading || day.isLoading || punches.isLoading) {
        return const AsyncValue.loading();
      }
      if (emp.isLoading) {
        return const AsyncValue.loading();
      }

      if (settings.hasError) {
        return AsyncValue.error(settings.error!, settings.stackTrace!);
      }
      if (day.hasError) {
        return AsyncValue.error(day.error!, day.stackTrace!);
      }
      if (punches.hasError) {
        return AsyncValue.error(punches.error!, punches.stackTrace!);
      }
      if (schedule.hasError) {
        return AsyncValue.error(schedule.error!, schedule.stackTrace!);
      }
      if (emp.hasError) {
        return AsyncValue.error(emp.error!, emp.stackTrace!);
      }

      final s = settings.requireValue;
      final d = day.requireValue;
      final p = punches.requireValue;
      final sch = schedule.asData?.value;
      final e = emp.requireValue;

      final loc =
          location.asData?.value ??
          const EmployeeWorkplaceLocationSnapshot.unresolved();

      final salon = ref.watch(sessionSalonStreamProvider).asData?.value;
      final salonName = salon?.name.trim() ?? '';

      final dk = EmployeeTodayAttendanceRepository.compactDateKey(
        DateTime.now(),
      );
      final attendanceId =
          d?.id ??
          EmployeeTodayAttendanceRepository.attendanceDayId(
            scope.employeeId,
            dk,
          );

      return AsyncData(
        EmployeeTodayAttendanceVm.fromInputs(
          salonId: scope.salonId,
          employeeId: scope.employeeId,
          salonName: salonName,
          todayAttendanceId: attendanceId,
          settings: s,
          day: d,
          punches: p,
          assignedSchedule: sch,
          employee: e,
          location: loc,
        ),
      );
    });
