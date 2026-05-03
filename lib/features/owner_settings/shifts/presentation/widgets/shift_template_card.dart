import 'package:flutter/material.dart';

import '../../data/models/shift_template_model.dart';
import 'shift_ui/shift_design_tokens.dart';
import 'shift_ui/shift_glass_card.dart';
import 'shift_ui/shift_meta_chip.dart';

class ShiftTemplateCard extends StatelessWidget {
  const ShiftTemplateCard({
    super.key,
    required this.template,
    required this.durationLabel,
    required this.breakLabel,
    required this.employeesLabel,
    required this.overnightLabel,
    required this.offDayLabel,
    required this.onEdit,
    required this.onDeactivate,
  });

  final ShiftTemplateModel template;
  final String durationLabel;
  final String breakLabel;
  final String employeesLabel;
  final String overnightLabel;
  final String offDayLabel;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    final baseColor = _parseHexColor(template.colorHex);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 132),
      child: ShiftGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        radius: 20,
        child: Row(
          children: [
            const _DragHandleDots(),
            const SizedBox(width: 10),
            _ShiftIconCircle(color: baseColor, iconKey: template.iconKey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    template.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: ShiftDesignTokens.textDark,
                    ),
                  ),
                  if (template.isOvernight) ...[
                    const SizedBox(height: 4),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: ShiftDesignTokens.softPurple,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          overnightLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: ShiftDesignTokens.deepPurple,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    _timeRange(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: ShiftDesignTokens.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      ShiftMetaChip(
                        label:
                            '$durationLabel: ${template.durationMinutes ~/ 60}h',
                      ),
                      ShiftMetaChip(
                        label: '$breakLabel: ${template.breakMinutes}m',
                      ),
                      ShiftMetaChip(
                        label: '$employeesLabel: 0',
                        foreground: ShiftDesignTokens.textDark,
                        background: ShiftDesignTokens.offGray,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SquareIconAction(icon: Icons.edit_outlined, onTap: onEdit),
                const SizedBox(height: 6),
                _SquareIconAction(
                  icon: Icons.delete_outline,
                  onTap: onDeactivate,
                  iconColor: ShiftDesignTokens.danger,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeRange() {
    final start = template.startTime;
    final end = template.endTime;
    if (start == null || end == null || template.type == 'off') {
      return offDayLabel;
    }
    return '$start - $end';
  }

  Color _parseHexColor(String hex) {
    final clean = hex.replaceAll('#', '').trim();
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return ShiftDesignTokens.primary;
  }
}

class _DragHandleDots extends StatelessWidget {
  const _DragHandleDots();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: ShiftDesignTokens.textMuted,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _ShiftIconCircle extends StatelessWidget {
  const _ShiftIconCircle({required this.color, required this.iconKey});

  final Color color;
  final String iconKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Icon(_iconData(iconKey), color: color, size: 30),
    );
  }

  IconData _iconData(String key) {
    switch (key) {
      case 'sun':
        return Icons.wb_sunny_outlined;
      case 'moon':
        return Icons.nights_stay_outlined;
      case 'off':
        return Icons.block_outlined;
      default:
        return Icons.schedule_outlined;
    }
  }
}

class _SquareIconAction extends StatelessWidget {
  const _SquareIconAction({
    required this.icon,
    required this.onTap,
    this.iconColor = ShiftDesignTokens.textDark,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: ShiftDesignTokens.softPurple,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ShiftDesignTokens.border),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}
