import 'package:flutter/material.dart';

import '../../data/models/shift_template_model.dart';
import '../../data/models/weekly_schedule_assignment_model.dart';
import '../../data/repositories/schedule_repository.dart';
import 'employee_fixed_column.dart';
import 'shift_ui/shift_design_tokens.dart';
import 'shift_ui/shift_glass_card.dart';
import 'weekday_schedule_cell.dart';

class WeeklyRosterGrid extends StatelessWidget {
  const WeeklyRosterGrid({
    super.key,
    required this.employees,
    required this.days,
    required this.assignmentsByKey,
    required this.onDrop,
    required this.onTapCell,
    required this.emptyCellLabel,
    required this.employeeHeaderLabel,
    required this.weekdayLabelBuilder,
  });

  final List<ScheduleEmployeeItem> employees;
  final List<DateTime> days;
  final Map<String, WeeklyScheduleAssignmentModel> assignmentsByKey;
  final void Function(
    ScheduleEmployeeItem employee,
    DateTime date,
    ShiftTemplateModel shift,
  )
  onDrop;
  final void Function(
    ScheduleEmployeeItem employee,
    DateTime date,
    WeeklyScheduleAssignmentModel? assignment,
  )
  onTapCell;
  final String emptyCellLabel;
  final String employeeHeaderLabel;
  final String Function(DateTime date) weekdayLabelBuilder;

  static const _dayColWidth = 88.0;
  static const _headerHeight = 76.0;
  static const _rowHeight = 142.0;
  static const _dividerColor = Color(0xFFD8D3E5);

  double _employeeColWidth(double screenWidth) {
    return (screenWidth * 0.24).clamp(94.0, 112.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final leftW = _employeeColWidth(screenW);
    final gridWidth = _dayColWidth * days.length;

    return ShiftGlassCard(
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: leftW,
              child: Column(
                children: [
                  _EmployeeHeader(label: employeeHeaderLabel, width: leftW),
                  for (final employee in employees)
                    EmployeeFixedColumn(
                      employee: employee,
                      width: leftW,
                      height: _rowHeight,
                    ),
                ],
              ),
            ),
            Container(width: 1.5, color: _dividerColor),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: gridWidth,
                  child: Column(
                    children: [
                      _DaysHeader(
                        days: days,
                        weekdayLabelBuilder: weekdayLabelBuilder,
                      ),
                      for (final employee in employees)
                        Row(
                          children: [
                            for (final date in days)
                              WeekdayScheduleCell(
                                width: _dayColWidth,
                                height: _rowHeight,
                                assignment:
                                    assignmentsByKey[_cellKey(
                                      employee.id,
                                      date,
                                    )],
                                emptyLabel: emptyCellLabel,
                                onDrop: (shift) =>
                                    onDrop(employee, date, shift),
                                onTap: () => onTapCell(
                                  employee,
                                  date,
                                  assignmentsByKey[_cellKey(employee.id, date)],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeHeader extends StatelessWidget {
  const _EmployeeHeader({required this.label, required this.width});

  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: WeeklyRosterGrid._headerHeight,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 14, end: 8),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: ShiftDesignTokens.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _DaysHeader extends StatelessWidget {
  const _DaysHeader({required this.days, required this.weekdayLabelBuilder});

  final List<DateTime> days;
  final String Function(DateTime date) weekdayLabelBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: WeeklyRosterGrid._headerHeight,
      child: Row(
        children: [
          for (final date in days)
            SizedBox(
              width: WeeklyRosterGrid._dayColWidth,
              child: Center(
                child: Text(
                  weekdayLabelBuilder(date),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: ShiftDesignTokens.textDark,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _cellKey(String employeeId, DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${employeeId}_$y$m$d';
}
