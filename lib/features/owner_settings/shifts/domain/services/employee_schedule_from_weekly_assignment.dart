import '../../data/models/employee_schedule_model.dart';
import '../../data/models/weekly_schedule_assignment_model.dart';
import 'shift_time_calculator.dart';

/// Builds [EmployeeScheduleModel] for `employeeSchedules/{assignmentId}` from a
/// weekly grid cell, matching [ScheduleApplyService] field semantics.
class EmployeeScheduleFromWeeklyAssignment {
  const EmployeeScheduleFromWeeklyAssignment._();

  static String _dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static EmployeeScheduleModel build({
    required WeeklyScheduleAssignmentModel assignment,
    required DateTime scheduleDate,
  }) {
    final localDay = DateTime(
      scheduleDate.year,
      scheduleDate.month,
      scheduleDate.day,
    );
    final dateOnly = _dateOnly(localDay);
    final dayOfWeek = localDay.weekday % 7;
    final isOff = assignment.shiftType == 'off';
    DateTime? startDateTime;
    DateTime? endDateTime;
    if (!isOff &&
        assignment.startTime != null &&
        assignment.endTime != null) {
      final times = ShiftTimeCalculator.buildStartEndDateTime(
        scheduleDate: localDay,
        startTime: assignment.startTime!,
        endTime: assignment.endTime!,
        isOvernight: assignment.isOvernight,
      );
      startDateTime = times.startDateTime;
      endDateTime = times.endDateTime;
    }

    return EmployeeScheduleModel(
      id: assignment.id,
      salonId: assignment.salonId,
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
      source: 'weekly_grid',
      weekTemplateId: assignment.weekTemplateId,
      attendanceStatus: isOff ? 'off' : 'not_started',
      payrollStatus: 'pending',
      isLocked: false,
      createdBy: assignment.updatedBy,
    );
  }
}
