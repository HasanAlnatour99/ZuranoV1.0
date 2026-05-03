import 'package:flutter/material.dart';

/// Clips the top edge of a bottom bar with a smooth center scoop so the bar
/// curves around the docked center FAB. Pass the FAB outer half-width and scoop
/// depth (often from shared FAB metrics such as `outerRadius`).
class NavBarTopNotchClipper extends CustomClipper<Path> {
  const NavBarTopNotchClipper({
    required this.notchHalfWidth,
    required this.scoopDepth,
    this.topCornerRadius = 20,
  });

  /// Half-width of the notch at the top edge (match the center FAB half-width).
  final double notchHalfWidth;

  /// How far the scoop dips into the bar (positive = downward in widget coords).
  final double scoopDepth;

  final double topCornerRadius;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final c = topCornerRadius;

    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, c)
      ..quadraticBezierTo(0, 0, c, 0)
      ..lineTo(cx - notchHalfWidth, 0)
      ..quadraticBezierTo(cx, scoopDepth, cx + notchHalfWidth, 0)
      ..lineTo(w - c, 0)
      ..quadraticBezierTo(w, 0, w, c)
      ..lineTo(w, h)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant NavBarTopNotchClipper oldClipper) {
    return oldClipper.notchHalfWidth != notchHalfWidth ||
        oldClipper.scoopDepth != scoopDepth ||
        oldClipper.topCornerRadius != topCornerRadius;
  }
}
