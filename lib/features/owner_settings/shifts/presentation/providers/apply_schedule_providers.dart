import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers/firebase_providers.dart';
import '../../data/models/weekly_schedule_assignment_model.dart';
import '../../data/models/weekly_schedule_template_model.dart';
import '../../domain/services/attendance_schedule_link_service.dart';
import '../../domain/services/schedule_apply_service.dart';
import 'shift_providers.dart';
import 'weekly_schedule_providers.dart';

class ApplyScheduleOptions {
  const ApplyScheduleOptions({
    required this.rangeType,
    required this.repeatEveryWeek,
    required this.skipExistingAssignments,
    required this.includeOffDays,
    this.customStartDate,
    this.customEndDate,
  });

  final ScheduleApplyRangeType rangeType;
  final bool repeatEveryWeek;
  final bool skipExistingAssignments;
  final bool includeOffDays;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  ApplyScheduleOptions copyWith({
    ScheduleApplyRangeType? rangeType,
    bool? repeatEveryWeek,
    bool? skipExistingAssignments,
    bool? includeOffDays,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return ApplyScheduleOptions(
      rangeType: rangeType ?? this.rangeType,
      repeatEveryWeek: repeatEveryWeek ?? this.repeatEveryWeek,
      skipExistingAssignments:
          skipExistingAssignments ?? this.skipExistingAssignments,
      includeOffDays: includeOffDays ?? this.includeOffDays,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
    );
  }
}

final weeklyTemplateByIdProvider = FutureProvider.autoDispose
    .family<WeeklyScheduleTemplateModel?, String>((ref, weekTemplateId) async {
      final salonId = ref.watch(activeOwnerSalonIdProvider);
      if (salonId == null) return null;
      return ref
          .watch(scheduleRepositoryProvider)
          .getWeeklyTemplate(salonId: salonId, weekTemplateId: weekTemplateId);
    });

final weeklyAssignmentsByIdProvider = FutureProvider.autoDispose
    .family<List<WeeklyScheduleAssignmentModel>, String>((
      ref,
      weekTemplateId,
    ) async {
      final salonId = ref.watch(activeOwnerSalonIdProvider);
      if (salonId == null) return const <WeeklyScheduleAssignmentModel>[];
      return ref
          .watch(scheduleRepositoryProvider)
          .getAssignments(salonId: salonId, weekTemplateId: weekTemplateId);
    });

final scheduleApplyServiceProvider = Provider<ScheduleApplyService>((ref) {
  return ScheduleApplyService(
    firestore: ref.read(firestoreProvider),
    scheduleRepository: ref.read(scheduleRepositoryProvider),
  );
});

final attendanceScheduleLinkServiceProvider =
    Provider<AttendanceScheduleLinkService>((ref) {
      return AttendanceScheduleLinkService(
        firestore: ref.read(firestoreProvider),
      );
    });
