import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'shift_design_tokens.dart';

/// Dashed rounded rectangle stroke for empty roster cells.
class DashedRoundedRectPainter extends CustomPainter {
  DashedRoundedRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.radius = 16,
    this.dash = 5,
    this.gap = 4,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dash, metric.length);
        final extract = metric.extractPath(distance, next);
        canvas.drawPath(extract, paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.dash != dash ||
        oldDelegate.gap != gap;
  }
}

/// Empty cell with dashed border and optional “active” (drag hover) stroke.
class DashedEmptyCell extends StatelessWidget {
  const DashedEmptyCell({super.key, required this.active, this.child});

  final bool active;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final borderColor = active
        ? ShiftDesignTokens.primary
        : ShiftDesignTokens.border.withValues(alpha: 0.9);
    return CustomPaint(
      painter: DashedRoundedRectPainter(
        color: borderColor,
        radius: ShiftDesignTokens.smallRadius,
      ),
      child: Center(
        child:
            child ??
            Icon(
              Icons.add_rounded,
              size: 22,
              color: active
                  ? ShiftDesignTokens.primary
                  : ShiftDesignTokens.textMuted,
            ),
      ),
    );
  }
}
