import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../attendance/data/location_attendance_service.dart';
import '../../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../../../employee_dashboard/application/employee_today_attendance_ui_provider.dart';
import '../../../employee_dashboard/domain/enums/attendance_punch_type.dart';
import '../../../employee_today/data/attendance_exception.dart';
import '../../../employee_today/data/models/et_attendance_day.dart';
import '../../../employee_today/providers/employee_today_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/session_provider.dart';
import '../../domain/employee_monthly_attendance_stats.dart';

final locationAttendanceServiceProvider = Provider<LocationAttendanceService>(
  (ref) => LocationAttendanceService(),
);

class EmployeeAttendanceLocationSnapshot {
  const EmployeeAttendanceLocationSnapshot({
    this.position,
    this.errorLabel,
    this.permissionDenied = false,
  });

  final Position? position;
  final String? errorLabel;
  final bool permissionDenied;

  LatLng? get latLng =>
      position == null ? null : LatLng(position!.latitude, position!.longitude);

  /// Rough GPS quality for the “Location health” chip.
  String get accuracyLabel {
    final a = position?.accuracy;
    if (a == null) {
      return 'Unknown';
    }
    if (a <= 25) {
      return 'Good';
    }
    if (a <= 80) {
      return 'Fair';
    }
    return 'Weak';
  }
}

/// Latest GPS sample for the attendance map card (accuracy + position).
final employeeAttendanceLocationProvider =
    FutureProvider.autoDispose<EmployeeAttendanceLocationSnapshot>((ref) async {
      final svc = ref.read(locationAttendanceServiceProvider);
      try {
        final p = await svc.getCurrentPosition();
        return EmployeeAttendanceLocationSnapshot(position: p);
      } on Object catch (e) {
        final msg = e.toString();
        final denied = msg.contains('permission') || msg.contains('Permission');
        return EmployeeAttendanceLocationSnapshot(
          errorLabel: denied
              ? null
              : 'Could not verify your location. Please try again.',
          permissionDenied: denied,
        );
      }
    });

final employeeRecentAttendanceDaysProvider =
    StreamProvider.autoDispose<List<EtAttendanceDay>>((ref) {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return Stream<List<EtAttendanceDay>>.value(const []);
      }
      return ref
          .watch(employeeTodayAttendanceRepositoryProvider)
          .watchRecentAttendanceDays(
            salonId: scope.salonId,
            employeeId: scope.employeeId,
            limit: 5,
          );
    });

final employeeMonthlyAttendanceStatsProvider =
    FutureProvider.autoDispose<EmployeeMonthlyAttendanceStats>((ref) async {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return const EmployeeMonthlyAttendanceStats(
          presentDays: 0,
          absentDays: 0,
          lateDays: 0,
          totalDaysTracked: 0,
        );
      }
      final now = DateTime.now();
      final days = await ref
          .read(employeeTodayAttendanceRepositoryProvider)
          .getEmployeeMonthAttendance(
            salonId: scope.salonId,
            employeeId: scope.employeeId,
            year: now.year,
            month: now.month,
          );
      return EmployeeMonthlyAttendanceStats.compute(
        daysInMonth: days,
        now: now,
      );
    });

/// Coordinates punch UX + snackbars are handled by the screen using this state.
class PunchBusyTypeNotifier extends Notifier<AttendancePunchType?> {
  @override
  AttendancePunchType? build() => null;

  void setBusy(AttendancePunchType? type) => state = type;
}

final punchBusyTypeProvider =
    NotifierProvider.autoDispose<PunchBusyTypeNotifier, AttendancePunchType?>(
      PunchBusyTypeNotifier.new,
    );

Future<void> submitEmployeeAttendancePunch(
  WidgetRef ref,
  AttendancePunchType type, {
  required void Function(String message) onMessage,
}) async {
  final online = ref.read(connectivityStatusProvider).asData?.value ?? true;
  if (!online) {
    onMessage('You need an internet connection to punch.');
    return;
  }

  final scope = ref.read(employeeWorkspaceScopeProvider);
  final emp = await ref.read(workspaceEmployeeProvider.future);
  final user = ref.read(sessionUserProvider).asData?.value;
  if (scope == null || emp == null || user == null) {
    return;
  }

  final settings = await ref.read(etAttendanceSettingsProvider.future);
  ref.read(punchBusyTypeProvider.notifier).setBusy(type);
  try {
    Position? pos;
    if (emp.attendanceRequired && settings.gpsRequired) {
      pos = await ref
          .read(locationAttendanceServiceProvider)
          .getCurrentPosition();
    } else {
      try {
        pos = await ref
            .read(locationAttendanceServiceProvider)
            .getCurrentPosition();
      } on Object {
        pos = null;
      }
    }

    final vm = ref.read(employeeTodayAttendanceProvider).asData?.value;
    await ref
        .read(employeeTodayAttendanceRepositoryProvider)
        .submitPunch(
          uid: user.uid,
          salonId: scope.salonId,
          employeeId: scope.employeeId,
          employeeName: emp.name,
          employeeActive: emp.isActive,
          attendanceRequired: emp.attendanceRequired,
          type: type,
          position: pos,
          settings: settings,
          shiftStartHhmm: vm?.shiftStartRaw,
          shiftEndHhmm: vm?.shiftEndRaw,
        );

    switch (type) {
      case AttendancePunchType.punchIn:
        onMessage('Checked in successfully.');
      case AttendancePunchType.breakOut:
        onMessage('Break started successfully.');
      case AttendancePunchType.breakIn:
        onMessage('Break ended successfully.');
      case AttendancePunchType.punchOut:
        onMessage('Checked out successfully.');
    }

    ref.invalidate(etTodayAttendanceDayProvider);
    ref.invalidate(etTodayPunchesProvider);
    ref.invalidate(employeeRecentAttendanceDaysProvider);
    ref.invalidate(employeeMonthlyAttendanceStatsProvider);
    ref.invalidate(employeeAttendanceLocationProvider);
  } on AttendanceException catch (e) {
    onMessage(
      e.message == AttendanceExceptionCodes.outsideShiftBreak
          ? 'Breaks can only be started during your scheduled shift hours.'
          : e.message,
    );
  } on Object catch (e) {
    onMessage('Something went wrong. Please try again.');
    assert(() {
      // ignore: avoid_print
      print(e);
      return true;
    }());
  } finally {
    ref.read(punchBusyTypeProvider.notifier).setBusy(null);
  }
}

/// `yearMonth` = `year * 100 + month` (e.g. 202604).
final employeeAttendanceMonthDaysProvider = FutureProvider.autoDispose
    .family<List<EtAttendanceDay>, int>((ref, yearMonth) async {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return const [];
      }
      final y = yearMonth ~/ 100;
      final m = yearMonth % 100;
      return ref
          .read(employeeTodayAttendanceRepositoryProvider)
          .getEmployeeMonthAttendance(
            salonId: scope.salonId,
            employeeId: scope.employeeId,
            year: y,
            month: m,
          );
    });
