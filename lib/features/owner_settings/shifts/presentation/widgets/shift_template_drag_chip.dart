import 'package:flutter/material.dart';

import '../../data/models/shift_template_model.dart';
import 'shift_ui/shift_design_tokens.dart';

class ShiftTemplateDragChip extends StatelessWidget {
  const ShiftTemplateDragChip({
    super.key,
    required this.template,
    this.floating = false,
  });

  final ShiftTemplateModel template;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(template.colorHex);
    final textColor = color.computeLuminance() > 0.45 || template.type == 'off'
        ? ShiftDesignTokens.textDark
        : Colors.white;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: template.type == 'off' ? ShiftDesignTokens.offGray : color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: template.type == 'off'
              ? ShiftDesignTokens.border
              : color.withValues(alpha: 0.35),
        ),
        boxShadow: floating
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.drag_indicator_rounded,
            size: 18,
            color: template.type == 'off'
                ? ShiftDesignTokens.textMuted
                : textColor.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 6),
          Text(
            template.name,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String raw) {
    final clean = raw.replaceAll('#', '').trim();
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return ShiftDesignTokens.primary;
  }
}
