import 'package:flutter/material.dart';

/// Swipe from the **start** screen edge (left in LTR, right in RTL) to trigger
/// [onBack] — same pattern as the system back gesture, without replacing the
/// visible back button.
class EdgeSwipeBack extends StatefulWidget {
  const EdgeSwipeBack({
    super.key,
    required this.child,
    required this.onBack,
    this.edgeWidth = 40,
  });

  final Widget child;
  final VoidCallback onBack;

  /// Hit target width from the [Directional] start edge.
  final double edgeWidth;

  @override
  State<EdgeSwipeBack> createState() => _EdgeSwipeBackState();
}

class _EdgeSwipeBackState extends State<EdgeSwipeBack> {
  double _dragPrimary = 0;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          width: widget.edgeWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (_) {
              _dragPrimary = 0;
            },
            onHorizontalDragUpdate: (details) {
              final dx = details.primaryDelta ?? 0;
              if (!isRtl) {
                _dragPrimary += dx;
              } else {
                _dragPrimary -= dx;
              }
            },
            onHorizontalDragEnd: (details) {
              final v = details.primaryVelocity ?? 0;
              const velOk = 220.0;
              const distOk = 40.0;
              final fastSwipe = !isRtl ? v > velOk : v < -velOk;
              final longSwipe = _dragPrimary > distOk;
              if (fastSwipe || longSwipe) {
                widget.onBack();
              }
              _dragPrimary = 0;
            },
          ),
        ),
      ],
    );
  }
}
