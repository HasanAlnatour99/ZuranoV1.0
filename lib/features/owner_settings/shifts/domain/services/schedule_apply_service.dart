import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../core/firestore/firestore_paths.dart';
import '../../data/models/employee_schedule_model.dart';
import '../../data/models/weekly_schedule_assignment_model.dart';
import '../../data/repositories/schedule_repository.dart';
import 'shift_time_calculator.dart';

enum ScheduleApplyRangeType { thisWeek, remainingMonth, customRange }

class ScheduleApplyRequest {
  const ScheduleApplyRequest({
    required this.salonId,
    required this.weekTemplateId,
    required this.assignments,
    required this.createdBy,
    required this.rangeType,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.repeatEveryWeek,
    required this.skipExistingAssignments,
    required this.includeOffDays,
    this.customStartDate,
    this.customEndDate,
  });

  final String salonId;
  final String weekTemplateId;
  final List<WeeklyScheduleAssignmentModel> assignments;
  final String createdBy;
  final ScheduleApplyRangeType rangeType;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final bool repeatEveryWeek;
  final bool skipExistingAssignments;
  final bool includeOffDays;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
}

class ScheduleApplyResult {
  const ScheduleApplyResult({
    required this.totalDates,
    required this.totalWrites,
    required this.skippedExisting,
  });

  final int totalDates;
  final int totalWrites;
  final int skippedExisting;
}

class ScheduleApplyService {
  ScheduleApplyService({
    required FirebaseFirestore firestore,
    required ScheduleRepository scheduleRepository,
  }) : _firestore = firestore,
       _scheduleRepository = scheduleRepository;

  final FirebaseFirestore _firestore;
  final ScheduleRepository _scheduleRepository;

  static const int _batchLimit = 450;

  Future<ScheduleApplyResult> apply(ScheduleApplyRequest request) async {
    final dates = _buildDateRange(
      rangeType: request.rangeType,
      weekStartDate: request.weekStartDate,
      weekEndDate: request.weekEndDate,
      customStartDate: request.customStartDate,
      customEndDate: request.customEndDate,
    );
    if (dates.isEmpty || request.assignments.isEmpty) {
      return const ScheduleApplyResult(
        totalDates: 0,
        totalWrites: 0,
        skippedExisting: 0,
      );
    }

    final byDay = <int, List<WeeklyScheduleAssignmentModel>>{};
    final byExactDate = <String, List<WeeklyScheduleAssignmentModel>>{};
    for (final assignment in request.assignments) {
      byDay.putIfAbsent(
        assignment.dayOfWeek,
        () => <WeeklyScheduleAssignmentModel>[],
      );
      byDay[assignment.dayOfWeek]!.add(assignment);
      byExactDate.putIfAbsent(
        assignment.date,
        () => <WeeklyScheduleAssignmentModel>[],
      );
      byExactDate[assignment.date]!.add(assignment);
    }

    final weekTemplateByStart = await _resolveTargetWeekTemplates(
      salonId: request.salonId,
      dates: dates,
      createdBy: request.createdBy,
    );

    var writes = 0;
    var skipped = 0;
    WriteBatch batch = _firestore.batch();
    var pendingOps = 0;

    for (final date in dates) {
      final dayOfWeek = date.weekday % 7;
      final assignments = request.repeatEveryWeek
          ? (byDay[dayOfWeek] ?? const <WeeklyScheduleAssignmentModel>[])
          : (byExactDate[ScheduleRepository.dateOnly(date)] ??
                const <WeeklyScheduleAssignmentModel>[]);
      for (final assignment in assignments) {
        if (assignment.shiftType == 'off' && !request.includeOffDays) {
          continue;
        }
        final scheduleId = ScheduleRepository.buildAssignmentId(
          employeeId: assignment.employeeId,
          date: date,
        );
        final scheduleRef = _firestore.doc(
          FirestorePaths.salonEmployeeSchedule(request.salonId, scheduleId),
        );
        final targetWeekStart = _weekStartSaturday(date);
        final targetWeekTemplateId =
            weekTemplateByStart[ScheduleRepository.dateOnly(targetWeekStart)];
        if (targetWeekTemplateId == null) {
          // Safety guard: skip dates that fail template resolution.
          continue;
        }
        final assignmentRef = _firestore.doc(
          FirestorePaths.salonWeeklyScheduleAssignment(
            request.salonId,
            targetWeekTemplateId,
            scheduleId,
          ),
        );

        if (request.skipExistingAssignments) {
          final existingDocs = await Future.wait([
            scheduleRef.get(),
            assignmentRef.get(),
          ]);
          if (existingDocs.any((doc) => doc.exists)) {
            skipped++;
            continue;
          }
        }

        final dateOnly = ScheduleRepository.dateOnly(date);
        final isOff = assignment.shiftType == 'off';
        DateTime? startDateTime;
        DateTime? endDateTime;
        if (!isOff &&
            assignment.startTime != null &&
            assignment.endTime != null) {
          final times = ShiftTimeCalculator.buildStartEndDateTime(
            scheduleDate: date,
            startTime: assignment.startTime!,
            endTime: assignment.endTime!,
            isOvernight: assignment.isOvernight,
          );
          startDateTime = times.startDateTime;
          endDateTime = times.endDateTime;
        }

        final schedule = EmployeeScheduleModel(
          id: scheduleId,
          salonId: request.salonId,
          employeeId: assignment.employeeId,
          employeeName: assignment.employeeName,
          scheduleDate: dateOnly,
          dayOfWeek: dayOfWeek,
          shiftTemplateId: assignment.shiftTemplateId,
          shiftName: assignment.shiftName,
          shiftType: assignment.shiftType,
          startDateTime: startDateTime,
          endDateTime: endDateTime,
          isOvernight: assignment.isOvernight,
          startTime: assignment.startTime,
          endTime: assignment.endTime,
          scheduledMinutes: assignment.durationMinutes,
          breakMinutes: assignment.breakMinutes,
          source: 'weekly_template',
          weekTemplateId: targetWeekTemplateId,
          attendanceStatus: isOff ? 'off' : 'not_started',
          payrollStatus: 'pending',
          isLocked: false,
          createdBy: request.createdBy,
        );
        final weeklyAssignment = WeeklyScheduleAssignmentModel(
          id: scheduleId,
          salonId: request.salonId,
          weekTemplateId: targetWeekTemplateId,
          employeeId: assignment.employeeId,
          employeeName: assignment.employeeName,
          date: dateOnly,
          dayOfWeek: dayOfWeek,
          shiftTemplateId: assignment.shiftTemplateId,
          shiftName: assignment.shiftName,
          shiftType: assignment.shiftType,
          startTime: assignment.startTime,
          endTime: assignment.endTime,
          isOvernight: assignment.isOvernight,
          durationMinutes: assignment.durationMinutes,
          breakMinutes: assignment.breakMinutes,
          colorHex: assignment.colorHex,
          updatedBy: request.createdBy,
        );
        batch.set(scheduleRef, schedule.toMap(), SetOptions(merge: true));
        batch.set(
          assignmentRef,
          weeklyAssignment.toMap(),
          SetOptions(merge: true),
        );
        writes++;
        pendingOps++;
        if (pendingOps >= _batchLimit) {
          await batch.commit();
          batch = _firestore.batch();
          pendingOps = 0;
        }
      }
    }

    if (pendingOps > 0) {
      await batch.commit();
    }

    await _scheduleRepository.markTemplateApplied(
      salonId: request.salonId,
      weekTemplateId: request.weekTemplateId,
      appliedBy: request.createdBy,
    );

    return ScheduleApplyResult(
      totalDates: dates.length,
      totalWrites: writes,
      skippedExisting: skipped,
    );
  }

  Future<Map<String, String>> _resolveTargetWeekTemplates({
    required String salonId,
    required List<DateTime> dates,
    required String createdBy,
  }) async {
    final weekStarts = <String, DateTime>{};
    for (final date in dates) {
      final weekStart = _weekStartSaturday(date);
      weekStarts[ScheduleRepository.dateOnly(weekStart)] = weekStart;
    }
    if (weekStarts.isEmpty) {
      return const <String, String>{};
    }

    final sortedKeys = weekStarts.keys.toList()..sort();
    final minKey = sortedKeys.first;
    final maxKey = sortedKeys.last;
    final existingSnapshot = await _firestore
        .collection(FirestorePaths.salonWeeklyScheduleTemplates(salonId))
        .where('weekStartDate', isGreaterThanOrEqualTo: minKey)
        .where('weekStartDate', isLessThanOrEqualTo: maxKey)
        .get();

    final templateByStart = <String, String>{};
    for (final doc in existingSnapshot.docs) {
      final weekStartDate = (doc.data()['weekStartDate'] as String?)?.trim();
      if (weekStartDate == null || weekStartDate.isEmpty) {
        continue;
      }
      templateByStart[weekStartDate] = doc.id;
    }

    for (final entry in weekStarts.entries) {
      if (templateByStart.containsKey(entry.key)) {
        continue;
      }
      final weekStart = entry.value;
      final weekEnd = weekStart.add(const Duration(days: 6));
      final docRef = _firestore
          .collection(FirestorePaths.salonWeeklyScheduleTemplates(salonId))
          .doc();
      await docRef.set(<String, dynamic>{
        'id': docRef.id,
        'salonId': salonId,
        'name': 'Default Weekly Schedule',
        'weekStartDate': ScheduleRepository.dateOnly(weekStart),
        'weekEndDate': ScheduleRepository.dateOnly(weekEnd),
        'status': 'draft',
        'createdBy': createdBy,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      templateByStart[entry.key] = docRef.id;
    }

    return templateByStart;
  }

  List<DateTime> _buildDateRange({
    required ScheduleApplyRangeType rangeType,
    required DateTime weekStartDate,
    required DateTime weekEndDate,
    required DateTime? customStartDate,
    required DateTime? customEndDate,
  }) {
    switch (rangeType) {
      case ScheduleApplyRangeType.thisWeek:
        return _datesBetween(weekStartDate, weekEndDate);
      case ScheduleApplyRangeType.remainingMonth:
        final monthEnd = DateTime(
          weekStartDate.year,
          weekStartDate.month + 1,
          0,
        );
        final start = weekStartDate;
        return _datesBetween(start, monthEnd);
      case ScheduleApplyRangeType.customRange:
        if (customStartDate == null || customEndDate == null) {
          return const <DateTime>[];
        }
        return _datesBetween(customStartDate, customEndDate);
    }
  }

  List<DateTime> _datesBetween(DateTime start, DateTime end) {
    final from = DateTime(start.year, start.month, start.day);
    final to = DateTime(end.year, end.month, end.day);
    if (to.isBefore(from)) {
      return const <DateTime>[];
    }
    final days = <DateTime>[];
    var cursor = from;
    while (!cursor.isAfter(to)) {
      days.add(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return days;
  }

  DateTime _weekStartSaturday(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final daysFromSaturday = (normalized.weekday + 1) % 7;
    return normalized.subtract(Duration(days: daysFromSaturday));
  }
}
