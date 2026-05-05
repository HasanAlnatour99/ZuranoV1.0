import 'package:flutter/material.dart';

/// Soft circular glow used behind premium attendance surfaces.
class AttendanceBlobGlow extends StatelessWidget {
  const AttendanceBlobGlow({
    super.key,
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
