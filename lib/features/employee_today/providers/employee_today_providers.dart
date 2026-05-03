import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/firebase_providers.dart';
import '../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../../employee_dashboard/domain/services/attendance_location_service.dart';
import '../data/models/et_attendance_day.dart';
import '../data/models/et_attendance_punch.dart';
import '../data/models/et_attendance_settings.dart';
import '../data/models/et_correction_request.dart';
import '../data/models/et_policy_readable.dart';
import '../data/models/employee_workplace_location_snapshot.dart';
import '../data/repositories/attendance_policy_repository.dart';
import '../data/repositories/employee_today_attendance_repository.dart';
import '../../owner_settings/shifts/data/models/employee_schedule_model.dart';

final attendancePolicyRepositoryProvider = Provider<AttendancePolicyRepository>(
  (ref) {
    return AttendancePolicyRepository(firestore: ref.read(firestoreProvider));
  },
);

final employeeTodayAttendanceRepositoryProvider =
    Provider<EmployeeTodayAttendanceRepository>((ref) {
      return EmployeeTodayAttendanceRepository(
        firestore: ref.read(firestoreProvider),
      );
    });

/// Current device position vs salon zone for employee Today / map card.
/// Invalidate after pull-to-refresh or a successful punch.
final employeeWorkplaceLocationSnapshotProvider =
    FutureProvider.autoDispose<EmployeeWorkplaceLocationSnapshot>((ref) async {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return const EmployeeWorkplaceLocationSnapshot.unresolved();
      }
      final settings = await ref.watch(etAttendanceSettingsProvider.future);
      if (!settings.hasSalonLocationConfigured) {
        return const EmployeeWorkplaceLocationSnapshot.unresolved();
      }
      final salonLat = settings.salonLatitude!;
      final salonLng = settings.salonLongitude!;
      final svc = AttendanceLocationService();
      try {
        final p = await svc.tryGetCurrentPosition();
        if (p == null) {
          return const EmployeeWorkplaceLocationSnapshot.unresolved();
        }
        final dist = svc.calculateDistanceMeters(
          fromLat: p.latitude,
          fromLng: p.longitude,
          toLat: salonLat,
          toLng: salonLng,
        );
        final inside = svc.isInsideZone(
          employeeLat: p.latitude,
          employeeLng: p.longitude,
          salonLat: salonLat,
          salonLng: salonLng,
          radiusMeters: settings.allowedRadiusMeters.toDouble(),
        );
        return EmployeeWorkplaceLocationSnapshot(
          employeeLatitude: p.latitude,
          employeeLongitude: p.longitude,
          distanceMeters: dist,
          insideZone: inside,
        );
      } on Object {
        return const EmployeeWorkplaceLocationSnapshot.unresolved();
      }
    });

final etAttendanceSettingsProvider =
    StreamProvider.autoDispose<EtAttendanceSettings>((ref) {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return Stream<EtAttendanceSettings>.value(
          EtAttendanceSettings.defaults(''),
        );
      }
      return ref
          .watch(employeeTodayAttendanceRepositoryProvider)
          .watchAttendanceSettings(scope.salonId);
    });

final etTodayAttendanceDayProvider =
    StreamProvider.autoDispose<EtAttendanceDay?>((ref) {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return Stream<EtAttendanceDay?>.value(null);
      }
      return ref
          .watch(employeeTodayAttendanceRepositoryProvider)
          .watchTodayAttendanceDay(
            salonId: scope.salonId,
            employeeId: scope.employeeId,
          );
    });

final etTodayPunchesProvider =
    StreamProvider.autoDispose<List<EtAttendancePunch>>((ref) {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return Stream<List<EtAttendancePunch>>.value(const []);
      }
      final dk = EmployeeTodayAttendanceRepository.compactDateKey(
        DateTime.now(),
      );
      final id = EmployeeTodayAttendanceRepository.attendanceDayId(
        scope.employeeId,
        dk,
      );
      return ref
          .watch(employeeTodayAttendanceRepositoryProvider)
          .watchTodayPunches(salonId: scope.salonId, attendanceDayId: id);
    });

final etTodayAssignedScheduleProvider =
    StreamProvider.autoDispose<EmployeeScheduleModel?>((ref) {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return Stream<EmployeeScheduleModel?>.value(null);
      }
      return ref
          .watch(employeeTodayAttendanceRepositoryProvider)
          .watchEmployeeScheduleForDate(
            salonId: scope.salonId,
            employeeId: scope.employeeId,
            date: DateTime.now(),
          );
    });

final etEmployeeCorrectionRequestsProvider =
    StreamProvider.autoDispose<List<EtCorrectionRequest>>((ref) {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return Stream<List<EtCorrectionRequest>>.value(const []);
      }
      return ref
          .watch(employeeTodayAttendanceRepositoryProvider)
          .watchEmployeeCorrectionRequests(
            salonId: scope.salonId,
            employeeId: scope.employeeId,
            limit: 8,
          );
    });

final etAttendancePolicyReadableProvider =
    StreamProvider.autoDispose<EtPolicyReadable?>((ref) {
      final scope = ref.watch(employeeWorkspaceScopeProvider);
      if (scope == null) {
        return Stream<EtPolicyReadable?>.value(null);
      }
      return ref
          .watch(attendancePolicyRepositoryProvider)
          .watchReadablePolicy(scope.salonId);
    });
