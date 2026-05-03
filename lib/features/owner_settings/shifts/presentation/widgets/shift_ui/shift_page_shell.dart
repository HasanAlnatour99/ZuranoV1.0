import 'package:flutter/material.dart';

import 'shift_design_tokens.dart';

class ShiftPageShell extends StatelessWidget {
  const ShiftPageShell({
    super.key,
    required this.child,
    this.bottomBar,
    this.scrollPadding = const EdgeInsets.fromLTRB(20, 12, 20, 120),
  });

  final Widget child;
  final Widget? bottomBar;
  final EdgeInsets scrollPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShiftDesignTokens.background,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(top: -80, right: -80, child: _SoftPurpleGlow()),
          SafeArea(
            child: SingleChildScrollView(padding: scrollPadding, child: child),
          ),
          if (bottomBar != null)
            Positioned(
              left: ShiftDesignTokens.pagePadding,
              right: ShiftDesignTokens.pagePadding,
              bottom: 20,
              child: SafeArea(top: false, child: bottomBar!),
            ),
        ],
      ),
    );
  }
}

class _SoftPurpleGlow extends StatelessWidget {
  const _SoftPurpleGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              ShiftDesignTokens.softPurple.withValues(alpha: 0.65),
              ShiftDesignTokens.softPurple.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}
