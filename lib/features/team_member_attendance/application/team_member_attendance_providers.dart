import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart' show StateProvider;

import '../../../core/constants/user_roles.dart';
import '../../../providers/firebase_providers.dart';
import '../../../providers/repository_providers.dart';
import '../../../providers/session_provider.dart';
import '../data/models/attendance_correction_request_model.dart';
import '../data/models/attendance_record_model.dart';
import '../data/models/attendance_summary_model.dart';
import '../../owner_settings/shifts/data/models/employee_schedule_model.dart';

class TeamMemberAttendanceArgs {
  const TeamMemberAttendanceArgs({
    required this.salonId,
    required this.employeeId,
  });

  final String salonId;
  final String employeeId;

  @override
  bool operator ==(Object other) {
    return other is TeamMemberAttendanceArgs &&
        other.salonId == salonId &&
        other.employeeId == employeeId;
  }

  @override
  int get hashCode => Object.hash(salonId, employeeId);
}

/// Calendar filter for [TeamMemberAttendanceHistoryScreen] (from / to inclusive local days).
class AttendanceHistoryDateFilter {
  const AttendanceHistoryDateFilter({this.fromDay, this.toDay});

  final DateTime? fromDay;
  final DateTime? toDay;

  static DateTime _calendarDay(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  bool get hasCompleteRange {
    if (fromDay == null || toDay == null) return false;
    return !_calendarDay(fromDay!).isAfter(_calendarDay(toDay!));
  }

  DateTime get normalizedFrom => _calendarDay(fromDay!);

  DateTime get normalizedTo => _calendarDay(toDay!);

  @override
  bool operator ==(Object other) {
    return other is AttendanceHistoryDateFilter &&
        _calendarDayOrNull(fromDay) ==
            _calendarDayOrNull(other.fromDay) &&
        _calendarDayOrNull(toDay) == _calendarDayOrNull(other.toDay);
  }

  @override
  int get hashCode => Object.hash(
        _calendarDayOrNull(fromDay),
        _calendarDayOrNull(toDay),
      );

  static int? _calendarDayOrNull(DateTime? d) {
    if (d == null) return null;
    final c = _calendarDay(d);
    return Object.hash(c.year, c.month, c.day);
  }
}

/// Applied date range for full attendance history (per salon + employee tab).
final teamMemberAttendanceHistoryFilterProvider = StateProvider.autoDispose
    .family<AttendanceHistoryDateFilter, TeamMemberAttendanceArgs>(
  (ref, args) => const AttendanceHistoryDateFilter(),
);

/// Owner always; admin only when `employees/{uid}.permissions.canManageAttendance == true`.
final canManageTeamMemberAttendanceProvider = FutureProvider<bool>((ref) async {
  final user = await ref.watch(sessionUserProvider.future);
  if (user == null) return false;
  if (user.role == UserRoles.owner) return true;
  if (user.role != UserRoles.admin) return false;

  final salonId = user.salonId;
  final empId = user.employeeId;
  if (salonId == null ||
      empId == null ||
      salonId.trim().isEmpty ||
      empId.trim().isEmpty) {
    return false;
  }

  final snap = await ref
      .read(firestoreProvider)
      .collection('salons')
      .doc(salonId)
      .collection('employees')
      .doc(empId)
      .get();

  final perms = snap.data()?['permissions'];
  if (perms is! Map) return false;
  return perms['canManageAttendance'] == true;
});

final todayAttendanceProvider =
    StreamProvider.family<AttendanceRecordModel?, TeamMemberAttendanceArgs>((
      ref,
      args,
    ) {
      final repo = ref.watch(teamMemberAttendanceRepositoryProvider);
      return repo.watchTodayAttendance(
        salonId: args.salonId,
        employeeId: args.employeeId,
        today: DateTime.now(),
      );
    });

final todayAssignedScheduleProvider =
    StreamProvider.family<EmployeeScheduleModel?, TeamMemberAttendanceArgs>((
      ref,
      args,
    ) {
      final repo = ref.watch(teamMemberAttendanceRepositoryProvider);
      return repo.watchTodayAssignedSchedule(
        salonId: args.salonId,
        employeeId: args.employeeId,
        today: DateTime.now(),
      );
    });

final recentAttendanceProvider =
    StreamProvider.family<
      List<AttendanceRecordModel>,
      TeamMemberAttendanceArgs
    >((ref, args) {
      final repo = ref.watch(teamMemberAttendanceRepositoryProvider);
      return repo.watchRecentAttendance(
        salonId: args.salonId,
        employeeId: args.employeeId,
        limit: 10,
      );
    });

/// Full history for team profile "View all" (capped for performance).
///
/// When [teamMemberAttendanceHistoryFilterProvider] has both from and to days,
/// queries Firestore by `workDate` range; otherwise last 500 rows by `workDate`.
final teamMemberFullAttendanceHistoryProvider =
    StreamProvider.autoDispose.family<
      List<AttendanceRecordModel>,
      TeamMemberAttendanceArgs
    >((ref, args) {
      final repo = ref.watch(teamMemberAttendanceRepositoryProvider);
      final filter = ref.watch(teamMemberAttendanceHistoryFilterProvider(args));
      if (filter.hasCompleteRange) {
        return repo.watchEmployeeAttendanceWorkDateRange(
          salonId: args.salonId,
          employeeId: args.employeeId,
          fromInclusiveLocalDay: filter.normalizedFrom,
          toInclusiveLocalDay: filter.normalizedTo,
          limit: 500,
        );
      }
      return repo.watchRecentAttendance(
        salonId: args.salonId,
        employeeId: args.employeeId,
        limit: 500,
      );
    });

final attendanceCorrectionRequestsProvider =
    StreamProvider.family<
      List<AttendanceCorrectionRequestModel>,
      TeamMemberAttendanceArgs
    >((ref, args) {
      final repo = ref.watch(teamMemberAttendanceRepositoryProvider);
      return repo.watchCorrectionRequests(
        salonId: args.salonId,
        employeeId: args.employeeId,
        limit: 10,
      );
    });

final attendanceSummaryProvider =
    FutureProvider.family<AttendanceSummaryModel, TeamMemberAttendanceArgs>((
      ref,
      args,
    ) async {
      final repo = ref.watch(teamMemberAttendanceRepositoryProvider);
      return repo.getSummary(
        salonId: args.salonId,
        employeeId: args.employeeId,
        now: DateTime.now(),
      );
    });
