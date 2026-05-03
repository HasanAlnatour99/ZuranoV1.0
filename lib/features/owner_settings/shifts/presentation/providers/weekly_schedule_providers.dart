import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/text/team_member_name.dart';
import '../../../../../providers/firebase_providers.dart';
import '../../../../../providers/session_provider.dart';
import '../../data/models/shift_template_model.dart';
import '../../data/models/weekly_schedule_assignment_model.dart';
import '../../data/models/weekly_schedule_template_model.dart';
import '../../data/repositories/schedule_repository.dart';
import 'shift_providers.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(firestore: ref.read(firestoreProvider));
});

final selectedWeekStartProvider =
    NotifierProvider<SelectedWeekStartNotifier, DateTime>(
      SelectedWeekStartNotifier.new,
    );

class SelectedWeekStartNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    return _weekStartSaturday(DateTime.now());
  }

  void previousWeek() => state = state.subtract(const Duration(days: 7));
  void nextWeek() => state = state.add(const Duration(days: 7));
  void thisWeek() => state = _weekStartSaturday(DateTime.now());
  void setWeekStart(DateTime date) => state = _weekStartSaturday(date);

  DateTime _weekStartSaturday(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final daysFromSaturday = (normalized.weekday + 1) % 7;
    return normalized.subtract(Duration(days: daysFromSaturday));
  }
}

final weeklyTemplateProvider =
    FutureProvider.autoDispose<WeeklyScheduleTemplateModel?>((ref) async {
      final salonId = ref.watch(activeOwnerSalonIdProvider);
      final weekStart = ref.watch(selectedWeekStartProvider);
      final user = ref.watch(sessionUserProvider).asData?.value;
      if (salonId == null || user == null) {
        return null;
      }
      return ref
          .watch(scheduleRepositoryProvider)
          .ensureWeeklyTemplate(
            salonId: salonId,
            weekStartDate: weekStart,
            createdBy: user.uid,
          );
    });

final weeklyAssignmentsProvider =
    StreamProvider.autoDispose<List<WeeklyScheduleAssignmentModel>>((ref) {
      final salonId = ref.watch(activeOwnerSalonIdProvider);
      final weeklyTemplate = ref.watch(weeklyTemplateProvider).asData?.value;
      if (salonId == null || weeklyTemplate == null) {
        return const Stream<List<WeeklyScheduleAssignmentModel>>.empty();
      }
      return ref
          .watch(scheduleRepositoryProvider)
          .streamAssignments(
            salonId: salonId,
            weekTemplateId: weeklyTemplate.id,
          );
    });

final activeEmployeesProvider =
    StreamProvider.autoDispose<List<ScheduleEmployeeItem>>((ref) {
      final salonId = ref.watch(activeOwnerSalonIdProvider);
      if (salonId == null) {
        return const Stream<List<ScheduleEmployeeItem>>.empty();
      }
      return ref
          .watch(scheduleRepositoryProvider)
          .streamActiveEmployees(salonId);
    });

final shiftTemplatesForWeeklyProvider =
    StreamProvider.autoDispose<List<ShiftTemplateModel>>((ref) {
      final salonId = ref.watch(activeOwnerSalonIdProvider);
      if (salonId == null) {
        return const Stream<List<ShiftTemplateModel>>.empty();
      }
      return ref.watch(shiftRepositoryProvider).streamShiftTemplates(salonId);
    });

final weeklyScheduleAssignmentsControllerProvider =
    AsyncNotifierProvider<WeeklyScheduleAssignmentsController, void>(
      WeeklyScheduleAssignmentsController.new,
    );

class WeeklyScheduleAssignmentsController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> assignShift({
    required ScheduleEmployeeItem employee,
    required DateTime date,
    required ShiftTemplateModel shift,
  }) async {
    final salonId = ref.read(activeOwnerSalonIdProvider);
    final weekTemplate = ref.read(weeklyTemplateProvider).asData?.value;
    final user = ref.read(sessionUserProvider).asData?.value;
    if (salonId == null || weekTemplate == null || user == null) return;
    final assignmentId = ScheduleRepository.buildAssignmentId(
      employeeId: employee.id,
      date: date,
    );
    final assignment = WeeklyScheduleAssignmentModel(
      id: assignmentId,
      salonId: salonId,
      weekTemplateId: weekTemplate.id,
      employeeId: employee.id,
      employeeName: formatTeamMemberName(employee.name),
      date: ScheduleRepository.dateOnly(date),
      dayOfWeek: date.weekday % 7,
      shiftTemplateId: shift.id,
      shiftName: shift.name,
      shiftType: shift.type,
      startTime: shift.startTime,
      endTime: shift.endTime,
      isOvernight: shift.isOvernight,
      durationMinutes: shift.durationMinutes,
      breakMinutes: shift.breakMinutes,
      colorHex: shift.colorHex,
      updatedBy: user.uid,
    );
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(scheduleRepositoryProvider)
          .upsertAssignment(
            salonId: salonId,
            weekTemplateId: weekTemplate.id,
            assignment: assignment,
            scheduleDate: date,
          ),
    );
  }

  Future<void> markOff({
    required ScheduleEmployeeItem employee,
    required DateTime date,
  }) async {
    final salonId = ref.read(activeOwnerSalonIdProvider);
    final weekTemplate = ref.read(weeklyTemplateProvider).asData?.value;
    final user = ref.read(sessionUserProvider).asData?.value;
    if (salonId == null || weekTemplate == null || user == null) return;
    final assignmentId = ScheduleRepository.buildAssignmentId(
      employeeId: employee.id,
      date: date,
    );
    final assignment = WeeklyScheduleAssignmentModel(
      id: assignmentId,
      salonId: salonId,
      weekTemplateId: weekTemplate.id,
      employeeId: employee.id,
      employeeName: formatTeamMemberName(employee.name),
      date: ScheduleRepository.dateOnly(date),
      dayOfWeek: date.weekday % 7,
      shiftTemplateId: null,
      shiftName: 'Off Day',
      shiftType: 'off',
      startTime: null,
      endTime: null,
      isOvernight: false,
      durationMinutes: 0,
      breakMinutes: 0,
      colorHex: '#E5E7EB',
      updatedBy: user.uid,
    );
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(scheduleRepositoryProvider)
          .upsertAssignment(
            salonId: salonId,
            weekTemplateId: weekTemplate.id,
            assignment: assignment,
            scheduleDate: date,
          ),
    );
  }

  Future<void> remove({required String assignmentId}) async {
    final salonId = ref.read(activeOwnerSalonIdProvider);
    final weekTemplate = ref.read(weeklyTemplateProvider).asData?.value;
    if (salonId == null || weekTemplate == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(scheduleRepositoryProvider)
          .removeAssignment(
            salonId: salonId,
            weekTemplateId: weekTemplate.id,
            assignmentId: assignmentId,
          ),
    );
  }
}
