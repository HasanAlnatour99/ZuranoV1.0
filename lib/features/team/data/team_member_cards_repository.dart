import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/firestore/firestore_paths.dart';
import '../../attendance/data/models/attendance_record.dart';
import '../../employees/data/models/employee.dart';
import '../domain/team_member_card_vm.dart';

/// Firestore-backed monthly performance row (`salons/{salonId}/performance/{yyyyMM}_{employeeId}`).
@immutable
class SalonEmployeeMonthlyPerformance {
  const SalonEmployeeMonthlyPerformance({
    required this.employeeId,
    required this.rating,
    required this.servicesCount,
    required this.salesAmount,
  });

  final String employeeId;
  final double rating;
  final int servicesCount;
  final double salesAmount;

  factory SalonEmployeeMonthlyPerformance.fromMap(
    String employeeId,
    Map<String, dynamic> data,
  ) {
    return SalonEmployeeMonthlyPerformance(
      employeeId: employeeId,
      rating: ((data['rating'] ?? 0) as num).toDouble(),
      servicesCount: ((data['servicesCount'] ?? 0) as num).toInt(),
      salesAmount: ((data['salesAmount'] ?? 0) as num).toDouble(),
    );
  }
}

/// Loads composite attendance / performance docs for team stacked cards.
class TeamMemberCardsRepository {
  TeamMemberCardsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// `yyyyMMdd` (no separators), local calendar day of [day].
  static String todayCompactKey(DateTime day) {
    final local = day.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  /// `yyyyMM` for [day] in local time.
  static String monthCompactKey(DateTime day) {
    final local = day.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    return '$y$m';
  }

  Future<Map<String, SalonEmployeeMonthlyPerformance>> fetchPerformanceBatch({
    required String salonId,
    required List<String> employeeIds,
    required String monthKey,
  }) async {
    if (salonId.isEmpty || employeeIds.isEmpty) {
      return const {};
    }
    final refs = <DocumentReference<Map<String, dynamic>>>[
      for (final id in employeeIds)
        _firestore.doc(
          FirestorePaths.salonPerformanceRecord(salonId, '${monthKey}_$id'),
        ),
    ];
    final snaps = await Future.wait(refs.map((r) => r.get()));
    final out = <String, SalonEmployeeMonthlyPerformance>{};
    for (var i = 0; i < snaps.length; i++) {
      final snap = snaps[i];
      final id = employeeIds[i];
      final data = snap.data();
      if (data == null) {
        continue;
      }
      out[id] = SalonEmployeeMonthlyPerformance.fromMap(id, data);
    }
    return out;
  }

  /// Live doc for this calendar month: `performance/{yyyyMM}_{employeeId}`.
  ///
  /// Emits `null` when the document is missing. The doc id is fixed when the
  /// stream is created (month rollover while the screen stays open is rare).
  Stream<SalonEmployeeMonthlyPerformance?> watchCurrentMonthPerformance({
    required String salonId,
    required String employeeId,
  }) {
    if (salonId.isEmpty || employeeId.isEmpty) {
      return Stream<SalonEmployeeMonthlyPerformance?>.value(null);
    }
    final monthKey = monthCompactKey(DateTime.now());
    final path = FirestorePaths.salonPerformanceRecord(
      salonId,
      '${monthKey}_$employeeId',
    );
    return _firestore.doc(path).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) {
        return null;
      }
      return SalonEmployeeMonthlyPerformance.fromMap(employeeId, data);
    });
  }

  Future<Map<String, Map<String, dynamic>?>> fetchCompositeAttendanceBatch({
    required String salonId,
    required List<String> employeeIds,
    required String todayCompact,
  }) async {
    if (salonId.isEmpty || employeeIds.isEmpty) {
      return const {};
    }
    final refs = <DocumentReference<Map<String, dynamic>>>[
      for (final id in employeeIds)
        _firestore.doc(
          FirestorePaths.salonAttendanceRecord(salonId, '${todayCompact}_$id'),
        ),
    ];
    final snaps = await Future.wait(refs.map((r) => r.get()));
    final out = <String, Map<String, dynamic>?>{};
    for (var i = 0; i < snaps.length; i++) {
      final snap = snaps[i];
      final id = employeeIds[i];
      out[id] = snap.data();
    }
    return out;
  }

  Map<String, dynamic>? _rawFromAttendanceRecord(AttendanceRecord r) {
    return <String, dynamic>{
      'checkInAt': r.checkInAt != null
          ? Timestamp.fromDate(r.checkInAt!)
          : null,
      'checkOutAt': r.checkOutAt != null
          ? Timestamp.fromDate(r.checkOutAt!)
          : null,
      'isDayOff': false,
      'isAbsent': r.status.toLowerCase() == 'absent',
    };
  }

  AttendanceRecord? _bestTodayRecordForEmployee(
    String employeeId,
    List<AttendanceRecord> todayRecords,
  ) {
    final matches = todayRecords
        .where((r) => r.employeeId == employeeId)
        .toList(growable: false);
    if (matches.isEmpty) {
      return null;
    }
    matches.sort((a, b) {
      final at = a.checkInAt ?? a.workDate;
      final bt = b.checkInAt ?? b.workDate;
      return bt.compareTo(at);
    });
    return matches.first;
  }

  TeamAttendanceState mapAttendanceState(Map<String, dynamic>? data) {
    if (data == null) {
      return TeamAttendanceState.absent;
    }
    if (data['isDayOff'] == true) {
      return TeamAttendanceState.dayOff;
    }
    final checkInAt = data['checkInAt'];
    final checkOutAt = data['checkOutAt'];
    if (checkInAt != null && checkOutAt == null) {
      return TeamAttendanceState.working;
    }
    if (checkInAt != null && checkOutAt != null) {
      return TeamAttendanceState.completed;
    }
    if (data['isAbsent'] == true) {
      return TeamAttendanceState.absent;
    }
    return TeamAttendanceState.notCheckedIn;
  }

  Map<String, dynamic>? _resolveRawForEmployee({
    required String employeeId,
    required Map<String, Map<String, dynamic>?> compositeByEmployee,
    required AttendanceRecord? streamAttendance,
    required List<AttendanceRecord> todayRecords,
  }) {
    final composite = compositeByEmployee[employeeId];
    if (composite != null) {
      return composite;
    }
    if (streamAttendance != null) {
      return _rawFromAttendanceRecord(streamAttendance);
    }
    final r = _bestTodayRecordForEmployee(employeeId, todayRecords);
    if (r != null) {
      return _rawFromAttendanceRecord(r);
    }
    return null;
  }

  TeamMemberCardVm buildVmSync({
    required Employee employee,
    required AttendanceRecord? streamTodayAttendance,
    required Map<String, Map<String, dynamic>?> compositeByEmployee,
    required List<AttendanceRecord> todayRecords,
    required SalonEmployeeMonthlyPerformance? performance,
  }) {
    final raw = _resolveRawForEmployee(
      employeeId: employee.id,
      compositeByEmployee: compositeByEmployee,
      streamAttendance: streamTodayAttendance,
      todayRecords: todayRecords,
    );
    final state = mapAttendanceState(raw);
    final hasPerf = performance != null;
    final rating = performance?.rating ?? 0;

    final avatar = employee.avatarUrl?.trim();
    return TeamMemberCardVm(
      employeeId: employee.id,
      name: employee.name,
      roleFirestore: employee.role,
      profileImageUrl: (avatar == null || avatar.isEmpty) ? null : avatar,
      isActive: employee.isActive,
      attendanceState: state,
      hasPerformanceData: hasPerf,
      rating: rating,
    );
  }

  Future<List<TeamMemberCardVm>> buildVmList({
    required List<Employee> employeesInOrder,
    required List<AttendanceRecord?> streamAttendanceInOrder,
    required Map<String, SalonEmployeeMonthlyPerformance> performanceByEmployee,
    required List<AttendanceRecord> todayRecords,
    required String todayCompact,
  }) async {
    if (employeesInOrder.isEmpty) {
      return const [];
    }
    final salonId = employeesInOrder.first.salonId;
    final ids = [for (final e in employeesInOrder) e.id];
    final composite = await fetchCompositeAttendanceBatch(
      salonId: salonId,
      employeeIds: ids,
      todayCompact: todayCompact,
    );
    return [
      for (var i = 0; i < employeesInOrder.length; i++)
        buildVmSync(
          employee: employeesInOrder[i],
          streamTodayAttendance: streamAttendanceInOrder[i],
          compositeByEmployee: composite,
          todayRecords: todayRecords,
          performance: performanceByEmployee[employeesInOrder[i].id],
        ),
    ];
  }
}
