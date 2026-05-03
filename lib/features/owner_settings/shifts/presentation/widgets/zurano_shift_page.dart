import 'package:flutter/material.dart';

class ZuranoShiftColors {
  static const Color primary = Color(0xFF6D3CEB);
  static const Color deepPrimary = Color(0xFF4F2BC8);
  static const Color softPrimary = Color(0xFFF3EDFF);
  static const Color border = Color(0xFFE8E5EF);
  static const Color textDark = Color(0xFF090A1F);
  static const Color textMuted = Color(0xFF707386);
  static const Color background = Color(0xFFFFFFFF);
  static const Color danger = Color(0xFFE53935);
}

class ZuranoShiftPage extends StatelessWidget {
  const ZuranoShiftPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: ZuranoShiftColors.background, child: child);
  }
}

const kZuranoCardRadius = 24.0;
const kZuranoSmallRadius = 16.0;
const kZuranoSectionGap = 24.0;

List<BoxShadow> zuranoSoftShadow = const <BoxShadow>[
  BoxShadow(color: Color(0x14090A1F), blurRadius: 24, offset: Offset(0, 8)),
];
