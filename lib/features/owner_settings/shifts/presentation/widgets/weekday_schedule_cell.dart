import 'package:flutter/material.dart';

import '../../data/models/shift_template_model.dart';
import '../../data/models/weekly_schedule_assignment_model.dart';
import 'shift_assignment_chip.dart';
import 'shift_ui/dashed_border_painter.dart';
import 'shift_ui/shift_design_tokens.dart';

class WeekdayScheduleCell extends StatelessWidget {
  const WeekdayScheduleCell({
    super.key,
    required this.width,
    required this.height,
    required this.assignment,
    required this.onDrop,
    required this.onTap,
    required this.emptyLabel,
  });

  final double width;
  final double height;
  final WeeklyScheduleAssignmentModel? assignment;
  final ValueChanged<ShiftTemplateModel> onDrop;
  final VoidCallback onTap;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return DragTarget<ShiftTemplateModel>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty;
        return SizedBox(
          width: width,
          height: height,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: hovering
                      ? ShiftDesignTokens.softPurple
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: assignment == null
                    ? Padding(
                        padding: const EdgeInsets.all(4),
                        child: Semantics(
                          label: emptyLabel,
                          child: DashedEmptyCell(active: hovering),
                        ),
                      )
                    : Center(
                        child: ShiftAssignmentChip(assignment: assignment!),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
