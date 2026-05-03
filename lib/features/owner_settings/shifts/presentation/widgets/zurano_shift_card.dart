import 'package:flutter/material.dart';

import 'zurano_shift_page.dart';

class ZuranoShiftCard extends StatelessWidget {
  const ZuranoShiftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = kZuranoCardRadius,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: ZuranoShiftColors.border),
        boxShadow: zuranoSoftShadow,
      ),
      // TextField, DropdownButtonFormField, etc. require a Material ancestor.
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}
