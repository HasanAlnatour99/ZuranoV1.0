import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';
import '../../employee_today/data/attendance_exception.dart';
import '../../employee_today/providers/employee_today_providers.dart';
import '../domain/enums/attendance_punch_type.dart';
import '../domain/services/attendance_location_service.dart';
import 'employee_dashboard_providers.dart';
import 'employee_today_attendance_ui_provider.dart';

final employeeTodayAttendanceControllerProvider = AsyncNotifierProvider.autoDispose<
    EmployeeTodayAttendanceController,
    AttendancePunchType?>(EmployeeTodayAttendanceController.new);

@Deprecated('Use employeeTodayAttendanceControllerProvider')
final employeePunchControllerProvider = employeeTodayAttendanceControllerProvider;

class EmployeeTodayAttendanceController
    extends AsyncNotifier<AttendancePunchType?> {
  @override
  Future<AttendancePunchType?> build() async => null;

  /// Submits a punch; surfaces user-facing messages via [onMessage] / [onSuccess].
  Future<void> submitPunch(
    AttendancePunchType type,
    AppLocalizations l10n, {
    required void Function(String message) onMessage,
    void Function()? onSuccess,
  }) async {
    final online = ref.read(connectivityStatusProvider).asData?.value ?? true;
    if (!online) {
      onMessage(l10n.employeeTodayOfflinePunch);
      return;
    }

    final scope = ref.read(employeeWorkspaceScopeProvider);
    final emp = await ref.read(workspaceEmployeeProvider.future);
    final user = ref.read(sessionUserProvider).asData?.value;
    if (scope == null || emp == null || user == null) {
      return;
    }

    final settings = await ref.read(etAttendanceSettingsProvider.future);

    state = AsyncData(type);
    final location = AttendanceLocationService();
    try {
      Position? pos;
      final zoneMandatory =
          emp.attendanceRequired &&
          settings.gpsRequired &&
          (type == AttendancePunchType.punchIn ||
              type == AttendancePunchType.punchOut);
      if (zoneMandatory) {
        pos = await location.getCurrentPosition(
          timeout: const Duration(seconds: 12),
        );
      } else {
        pos = await location.tryGetCurrentPosition(
          timeout: const Duration(seconds: 8),
        );
      }

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
          );

      ref.invalidate(etTodayAttendanceDayProvider);
      ref.invalidate(employeeTodayAttendanceProvider);
      _invalidateAfterPunch();
      onSuccess?.call();
    } on AttendanceException catch (e) {
      onMessage(e.message);
    } on FirebaseException catch (e) {
      onMessage(e.message ?? l10n.employeeRequestFailed);
    } on Object catch (e) {
      final msg = e.toString();
      if (msg.contains('permanently denied')) {
        await openAppSettings();
      }
      onMessage(msg);
    } finally {
      state = const AsyncData(null);
    }
  }

  Future<void> loadTodayAttendance() async {
    ref.invalidate(employeeTodayAttendanceProvider);
  }

  Future<void> submitCorrectionRequest() async {
    ref.invalidate(etEmployeeCorrectionRequestsProvider);
  }

  void _invalidateAfterPunch() {
    ref.invalidate(workspaceEmployeeProvider);
    ref.invalidate(etAttendanceSettingsProvider);
    ref.invalidate(etTodayAttendanceDayProvider);
    ref.invalidate(etTodayPunchesProvider);
    ref.invalidate(employeeTodaySummaryProvider);
    ref.invalidate(employeeWorkplaceLocationSnapshotProvider);
    ref.invalidate(etEmployeeCorrectionRequestsProvider);
    ref.invalidate(employeeTodayAttendanceProvider);
  }
}
