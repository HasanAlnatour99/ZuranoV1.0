import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/firestore/firestore_paths.dart';
import '../../data/repositories/schedule_repository.dart';

class AttendanceScheduleLinkService {
  AttendanceScheduleLinkService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>?> getTodayScheduleForEmployee({
    required String salonId,
    required String employeeId,
    required DateTime date,
  }) async {
    final scheduleId = ScheduleRepository.buildAssignmentId(
      employeeId: employeeId,
      date: date,
    );
    final doc = await _firestore
        .doc(FirestorePaths.salonEmployeeSchedule(salonId, scheduleId))
        .get();
    return doc.data();
  }

  Future<({DateTime? startDateTime, DateTime? endDateTime})>
  getExpectedStartEnd({
    required String salonId,
    required String employeeId,
    required DateTime date,
  }) async {
    final data = await getTodayScheduleForEmployee(
      salonId: salonId,
      employeeId: employeeId,
      date: date,
    );
    if (data == null) {
      return (startDateTime: null, endDateTime: null);
    }
    final start = data['startDateTime'];
    final end = data['endDateTime'];
    return (
      startDateTime: start is Timestamp ? start.toDate() : null,
      endDateTime: end is Timestamp ? end.toDate() : null,
    );
  }
}
