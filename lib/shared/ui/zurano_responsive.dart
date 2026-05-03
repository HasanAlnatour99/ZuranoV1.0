import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Responsive sizing for compact phone layouts (discovery / customer home).
class ZuranoResponsive {
  ZuranoResponsive._();

  static double screenWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  /// Design reference width ~390; clamp so narrow phones stay compact.
  static double scale(BuildContext context) {
    final width = screenWidth(context);
    return (width / 390).clamp(0.86, 1.0);
  }

  /// Slightly tighter vertical rhythm on short phones / emulators.
  static double compactScale(BuildContext context) {
    final height = screenHeight(context);
    if (height < 700) return 0.82;
    if (height < 780) return 0.90;
    return 1.0;
  }

  static double s(BuildContext context, double value) {
    return value * scale(context);
  }

  static double v(BuildContext context, double value) {
    return value * compactScale(context);
  }

  static double font(BuildContext context, double value) {
    final widthScale = scale(context);
    final heightScale = compactScale(context);
    return value * math.min(widthScale, heightScale);
  }
}
