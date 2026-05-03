import 'package:flutter/material.dart';

import '../../data/models/shift_template_model.dart';
import 'shift_template_drag_chip.dart';
import 'shift_ui/shift_design_tokens.dart';
import 'shift_ui/shift_glass_card.dart';

/// Horizontal strip: helper copy + [LongPressDraggable] chips.
class DraggableShiftStrip extends StatelessWidget {
  const DraggableShiftStrip({
    super.key,
    required this.templates,
    required this.helperBody,
  });

  final List<ShiftTemplateModel> templates;

  /// Localized copy (may include a line break).
  final String helperBody;

  @override
  Widget build(BuildContext context) {
    return ShiftGlassCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      radius: 22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              helperBody,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ShiftDesignTokens.textDark,
                height: 1.25,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final template in templates) ...[
                    LongPressDraggable<ShiftTemplateModel>(
                      data: template,
                      feedback: Material(
                        color: Colors.transparent,
                        child: ShiftTemplateDragChip(
                          template: template,
                          floating: true,
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.35,
                        child: ShiftTemplateDragChip(template: template),
                      ),
                      child: ShiftTemplateDragChip(template: template),
                    ),
                    const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
