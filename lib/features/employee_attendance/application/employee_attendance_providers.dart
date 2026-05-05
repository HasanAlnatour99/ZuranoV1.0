import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/firebase_providers.dart';
import '../../employee_today/data/models/et_attendance_day.dart';
import '../data/employee_attendance_models.dart';
import '../data/employee_attendance_repository.dart';
import '../data/employee_staff_request_models.dart';

final employeeAttendanceViewRepositoryProvider =
    Provider<EmployeeAttendanceViewRepository>((ref) {
      return EmployeeAttendanceViewRepository(
        firestore: ref.read(firestoreProvider),
        auth: ref.read(firebaseAuthProvider),
      );
    });

final employeeAttendanceProfileProvider =
    StreamProvider<EmployeeAttendanceProfile>((ref) {
      return ref
          .watch(employeeAttendanceViewRepositoryProvider)
          .watchEmployeeProfile();
    });

final todayEmployeeAttendanceProvider =
    StreamProvider<EmployeeAttendanceDay?>((ref) {
      return ref
          .watch(employeeAttendanceViewRepositoryProvider)
          .watchTodayAttendance();
    });

final employeeAttendanceHistoryProvider =
    StreamProvider<List<EmployeeAttendanceDay>>((ref) {
      return ref
          .watch(employeeAttendanceViewRepositoryProvider)
          .watchAttendanceHistory(limit: 20);
    });

/// Absent days (v2 `attendanceDays`) eligible for an adjust-absent request.
final absentDaysForAdjustmentProvider =
    StreamProvider<List<EtAttendanceDay>>((ref) {
      return ref
          .watch(employeeAttendanceViewRepositoryProvider)
          .watchAbsentDaysForAdjustment();
    });

/// `salons/{salonId}/employees/{employeeId}/leaveBalances/*`
final employeeLeaveBalancesProvider =
    StreamProvider<List<EmployeeLeaveBalance>>((ref) {
      return ref
          .watch(employeeAttendanceViewRepositoryProvider)
          .watchLeaveBalances();
    });
