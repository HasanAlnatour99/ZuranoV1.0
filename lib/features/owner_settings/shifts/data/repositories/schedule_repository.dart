import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/firestore/firestore_paths.dart';
import '../../domain/services/employee_schedule_from_weekly_assignment.dart';
import '../models/weekly_schedule_assignment_model.dart';
import '../models/weekly_schedule_template_model.dart';

class ScheduleEmployeeItem {
  const ScheduleEmployeeItem({
    required this.id,
    required this.name,
    required this.isActive,
    this.avatarUrl,
    this.uid,
  });

  final String id;
  final String name;
  final bool isActive;
  final String? avatarUrl;
  final String? uid;

  factory ScheduleEmployeeItem.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return ScheduleEmployeeItem(
      id: doc.id,
      name: (data['name'] as String? ?? '').trim(),
      isActive: data['isActive'] != false,
      avatarUrl: ((data['avatarUrl'] as String?)?.trim().isNotEmpty ?? false)
          ? (data['avatarUrl'] as String).trim()
          : ((data['profileImageUrl'] as String?)?.trim().isNotEmpty ?? false)
          ? (data['profileImageUrl'] as String).trim()
          : null,
      uid: (data['uid'] as String?)?.trim(),
    );
  }
}

class ScheduleRepository {
  ScheduleRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _weeklyTemplates(String salonId) {
    return _firestore.collection(
      FirestorePaths.salonWeeklyScheduleTemplates(salonId),
    );
  }

  CollectionReference<Map<String, dynamic>> _assignments(
    String salonId,
    String weekTemplateId,
  ) {
    return _firestore.collection(
      FirestorePaths.salonWeeklyScheduleAssignments(salonId, weekTemplateId),
    );
  }

  Stream<List<ScheduleEmployeeItem>> streamActiveEmployees(String salonId) {
    return _firestore
        .collection(FirestorePaths.salonEmployees(salonId))
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final mapped = snapshot.docs.map(ScheduleEmployeeItem.fromFirestore);
          final employees = mapped.toList(growable: false);
          return Future.wait(
            employees.map((employee) async {
              if (employee.avatarUrl != null &&
                  employee.avatarUrl!.isNotEmpty) {
                return employee;
              }
              final uid = employee.uid;
              if (uid == null || uid.isEmpty) {
                return employee;
              }
              try {
                final userDoc = await _firestore
                    .doc(FirestorePaths.user(uid))
                    .get();
                final data = userDoc.data();
                final photoUrl = (data?['photoUrl'] as String?)?.trim();
                if (photoUrl == null || photoUrl.isEmpty) {
                  return employee;
                }
                return ScheduleEmployeeItem(
                  id: employee.id,
                  name: employee.name,
                  isActive: employee.isActive,
                  avatarUrl: photoUrl,
                  uid: employee.uid,
                );
              } catch (_) {
                return employee;
              }
            }),
          );
        });
  }

  Future<WeeklyScheduleTemplateModel> ensureWeeklyTemplate({
    required String salonId,
    required DateTime weekStartDate,
    required String createdBy,
  }) async {
    final dateKey = _dateOnly(weekStartDate);
    final existing = await _weeklyTemplates(
      salonId,
    ).where('weekStartDate', isEqualTo: dateKey).limit(1).get();
    if (existing.docs.isNotEmpty) {
      return WeeklyScheduleTemplateModel.fromFirestore(existing.docs.first);
    }

    final doc = _weeklyTemplates(salonId).doc();
    final model = WeeklyScheduleTemplateModel(
      id: doc.id,
      salonId: salonId,
      name: 'Default Weekly Schedule',
      weekStartDate: weekStartDate,
      weekEndDate: weekStartDate.add(const Duration(days: 6)),
      status: 'draft',
      createdBy: createdBy,
    );
    await doc.set(model.toCreateMap());
    return model;
  }

  Stream<List<WeeklyScheduleAssignmentModel>> streamAssignments({
    required String salonId,
    required String weekTemplateId,
  }) {
    return _assignments(salonId, weekTemplateId).snapshots().map(
      (snapshot) => snapshot.docs
          .map(WeeklyScheduleAssignmentModel.fromFirestore)
          .toList(growable: false),
    );
  }

  /// Writes the weekly roster cell and the denormalized per-day
  /// `employeeSchedules/{assignmentId}` doc (used by attendance and functions).
  Future<void> upsertAssignment({
    required String salonId,
    required String weekTemplateId,
    required WeeklyScheduleAssignmentModel assignment,
    required DateTime scheduleDate,
  }) async {
    final assignmentRef = _assignments(
      salonId,
      weekTemplateId,
    ).doc(assignment.id);
    final scheduleRef = _firestore.doc(
      FirestorePaths.salonEmployeeSchedule(salonId, assignment.id),
    );
    final schedule = EmployeeScheduleFromWeeklyAssignment.build(
      assignment: assignment,
      scheduleDate: scheduleDate,
    );
    final batch = _firestore.batch()
      ..set(assignmentRef, assignment.toMap(), SetOptions(merge: true))
      ..set(scheduleRef, schedule.toMap(), SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> removeAssignment({
    required String salonId,
    required String weekTemplateId,
    required String assignmentId,
  }) async {
    final assignmentRef = _assignments(
      salonId,
      weekTemplateId,
    ).doc(assignmentId);
    final scheduleRef = _firestore.doc(
      FirestorePaths.salonEmployeeSchedule(salonId, assignmentId),
    );
    final batch = _firestore.batch()
      ..delete(assignmentRef)
      ..delete(scheduleRef);
    await batch.commit();
  }

  Future<WeeklyScheduleTemplateModel?> getWeeklyTemplate({
    required String salonId,
    required String weekTemplateId,
  }) async {
    final doc = await _weeklyTemplates(salonId).doc(weekTemplateId).get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return WeeklyScheduleTemplateModel.fromFirestore(doc);
  }

  Future<List<WeeklyScheduleAssignmentModel>> getAssignments({
    required String salonId,
    required String weekTemplateId,
  }) async {
    final snapshot = await _assignments(salonId, weekTemplateId).get();
    return snapshot.docs
        .map(WeeklyScheduleAssignmentModel.fromFirestore)
        .toList(growable: false);
  }

  Future<void> markTemplateApplied({
    required String salonId,
    required String weekTemplateId,
    required String appliedBy,
  }) async {
    await _weeklyTemplates(salonId).doc(weekTemplateId).set(<String, dynamic>{
      'status': 'applied',
      'lastAppliedAt': FieldValue.serverTimestamp(),
      'appliedBy': appliedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String buildAssignmentId({
    required String employeeId,
    required DateTime date,
  }) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${employeeId}_$y$m$d';
  }

  static String dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
