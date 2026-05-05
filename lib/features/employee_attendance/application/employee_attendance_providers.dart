import 'package:flutter/foundation.dart';
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

/// Rolling last 7 **calendar** days (including today), based on recent rows.
final employeeAttendanceLastSevenDaysProvider =
    StreamProvider<List<EmployeeAttendanceDay>>((ref) {
      return ref
          .watch(employeeAttendanceViewRepositoryProvider)
          .watchAttendanceHistory(limit: 31)
          .map(takeLastSevenCalendarDays);
    });

/// Full log list for [EmployeeAttendanceDateRangeKey] (inclusive local days).
final employeeAttendanceHistoryRangeProvider =
    StreamProvider.autoDispose
        .family<List<EmployeeAttendanceDay>, EmployeeAttendanceDateRangeKey>((
          ref,
          key,
        ) {
          return ref
              .watch(employeeAttendanceViewRepositoryProvider)
              .watchAttendanceHistoryInLocalDateRange(
                fromLocalDay: key.fromDay,
                toLocalDay: key.toDay,
              );
        });

/// Inclusive calendar bounds for the ISO week that contains [anchor].
(DateTime monday, DateTime sunday) employeeAttendanceWeekBounds(
  DateTime anchor,
) {
  final day = DateTime(anchor.year, anchor.month, anchor.day);
  final mondayOffset = day.weekday - DateTime.monday;
  final monday = day.subtract(Duration(days: mondayOffset));
  final sunday = monday.add(const Duration(days: 6));
  return (monday, sunday);
}

(DateTime start, DateTime end) employeeAttendanceCalendarMonthBounds(
  DateTime now,
) {
  final start = DateTime(now.year, now.month);
  final end = DateTime(now.year, now.month + 1, 0);
  return (start, end);
}

List<EmployeeAttendanceDay> takeLastSevenCalendarDays(
  List<EmployeeAttendanceDay> records,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final cutoff = today.subtract(const Duration(days: 6));
  return records
      .where((r) {
        final d = r.date.toLocal();
        final day = DateTime(d.year, d.month, d.day);
        return !day.isBefore(cutoff);
      })
      .toList(growable: false);
}

@immutable
class EmployeeAttendanceDateRangeKey {
  const EmployeeAttendanceDateRangeKey({
    required this.fromDay,
    required this.toDay,
  });

  final DateTime fromDay;
  final DateTime toDay;

  @override
  bool operator ==(Object other) {
    if (other is! EmployeeAttendanceDateRangeKey) return false;
    return EmployeeAttendanceDateRangeKey._day(fromDay) ==
            EmployeeAttendanceDateRangeKey._day(other.fromDay) &&
        EmployeeAttendanceDateRangeKey._day(toDay) ==
            EmployeeAttendanceDateRangeKey._day(other.toDay);
  }

  @override
  int get hashCode =>
      Object.hash(_day(fromDay), _day(toDay));

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
}

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
