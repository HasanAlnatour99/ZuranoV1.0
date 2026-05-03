import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/user_roles.dart';
import '../../../core/firestore/firestore_paths.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../attendance/data/models/attendance_record.dart';
import '../domain/team_member_card_vm.dart';

/// Streams salon employees and merges composite attendance + monthly performance reads.
class TeamDeckFirestoreRepository {
  TeamDeckFirestoreRepository(this._firestore, this._attendanceRepository);

  final FirebaseFirestore _firestore;
  final AttendanceRepository _attendanceRepository;

  static String todayCompactKey(DateTime day) {
    final local = day.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }

  static String monthCompactKey(DateTime day) {
    final local = day.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    return '$y$m';
  }

  Stream<List<TeamMemberCardVm>> watchTeamCards({
    required String salonId,
    required String todayKey,
    required String monthKey,
  }) {
    if (salonId.isEmpty) {
      return Stream.value(const []);
    }
    return _firestore
        .collection(FirestorePaths.salonEmployees(salonId))
        .orderBy('name')
        .snapshots()
        .asyncMap(
          (snapshot) => _buildVmsForSnapshot(
            salonId: salonId,
            todayKey: todayKey,
            monthKey: monthKey,
            docs: snapshot.docs,
          ),
        );
  }

  Future<List<TeamMemberCardVm>> _buildVmsForSnapshot({
    required String salonId,
    required String todayKey,
    required String monthKey,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  }) async {
    final localNow = DateTime.now().toLocal();
    final dayStart = DateTime(localNow.year, localNow.month, localNow.day);
    final dayEnd = DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
      23,
      59,
      59,
      999,
    );

    final filtered = docs.where((doc) {
      final data = doc.data();
      if (data['deletedAt'] != null) {
        return false;
      }
      final role = (data['role'] ?? '').toString().trim();
      if (role == UserRoles.owner) {
        return false;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return const [];
    }

    final refs = <DocumentReference<Map<String, dynamic>>>[];
    for (final id in filtered.map((d) => d.id)) {
      refs.add(
        _firestore.doc(
          FirestorePaths.salonAttendanceRecord(salonId, '${todayKey}_$id'),
        ),
      );
      refs.add(
        _firestore.doc(
          FirestorePaths.salonPerformanceRecord(salonId, '${monthKey}_$id'),
        ),
      );
    }

    final attendanceFuture = _attendanceRepository.getAttendance(
      salonId,
      workDateFrom: dayStart,
      workDateTo: dayEnd,
      limit: 200,
    );
    final docSnapsFuture = _parallelDocumentGets(refs);

    final parallel = await Future.wait<Object>([
      attendanceFuture,
      docSnapsFuture,
    ]);
    final todayRecords = parallel[0] as List<AttendanceRecord>;
    final snaps = parallel[1] as List<DocumentSnapshot<Map<String, dynamic>>>;

    final out = <TeamMemberCardVm>[];
    for (var i = 0; i < filtered.length; i++) {
      final doc = filtered[i];
      final data = doc.data();
      final employeeId = doc.id;
      final composite = snaps[i * 2].data();
      final perfData = snaps[i * 2 + 1].data();

      Map<String, dynamic>? raw = composite;
      if (raw == null) {
        final best = _bestTodayRecord(employeeId, todayRecords);
        if (best != null) {
          raw = _rawFromAttendanceRecord(best);
        }
      }

      out.add(
        TeamMemberCardVm(
          employeeId: employeeId,
          name: _displayName(data),
          roleFirestore: (data['role'] ?? UserRoles.barber).toString().trim(),
          profileImageUrl: _profileUrl(data),
          isActive: data['isActive'] != false,
          attendanceState: _mapAttendanceState(raw),
          hasPerformanceData: perfData != null,
          rating: _safeRating(perfData?['rating']),
        ),
      );
    }
    return out;
  }

  /// Parallel `.get()` for many document refs (overlapped with [getAttendance]).
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> _parallelDocumentGets(
    List<DocumentReference<Map<String, dynamic>>> refs,
  ) {
    if (refs.isEmpty) {
      return Future.value(const <DocumentSnapshot<Map<String, dynamic>>>[]);
    }
    return Future.wait(refs.map((r) => r.get()));
  }

  /// Empty when missing — UI shows a localized placeholder (never raw doc id).
  static String _displayName(Map<String, dynamic> data) {
    final n = (data['name'] as String?)?.trim();
    if (n == null || n.isEmpty) {
      return '';
    }
    return n;
  }

  static String? _profileUrl(Map<String, dynamic> data) {
    final a = (data['profileImageUrl'] as String?)?.trim();
    if (a != null && a.isNotEmpty) {
      return a;
    }
    final b = (data['avatarUrl'] as String?)?.trim();
    if (b != null && b.isNotEmpty) {
      return b;
    }
    return null;
  }

  static AttendanceRecord? _bestTodayRecord(
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

  static Map<String, dynamic> _rawFromAttendanceRecord(AttendanceRecord r) {
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

  static TeamAttendanceState _mapAttendanceState(Map<String, dynamic>? data) {
    if (data == null) {
      return TeamAttendanceState.absent;
    }
    if (data['isDayOff'] == true) {
      return TeamAttendanceState.dayOff;
    }
    if (data['isAbsent'] == true) {
      return TeamAttendanceState.absent;
    }
    final checkInAt = data['checkInAt'];
    final checkOutAt = data['checkOutAt'];
    if (checkInAt != null && checkOutAt == null) {
      return TeamAttendanceState.working;
    }
    if (checkInAt != null && checkOutAt != null) {
      return TeamAttendanceState.completed;
    }
    return TeamAttendanceState.notCheckedIn;
  }

  static double _safeRating(Object? value) {
    if (value is num) {
      return value.toDouble().clamp(0.0, 5.0);
    }
    return 0;
  }
}
