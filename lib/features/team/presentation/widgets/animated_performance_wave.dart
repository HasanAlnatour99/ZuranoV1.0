import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/team_card_palette.dart';

/// Animated performance wash on the side of the card.
///
/// In **LTR** the wave sits on the **physical right**; in **RTL (Arabic)** it sits on
/// the **physical left** and is **mirrored horizontally** so the curve reads correctly.
class AnimatedPerformanceWave extends StatefulWidget {
  const AnimatedPerformanceWave({
    super.key,
    required this.rating,
    this.hasPerformanceData = true,
    this.mirrorHorizontally = false,
  });

  final double rating;
  final bool hasPerformanceData;

  /// When true (Arabic / RTL placement on the left), flips the painter and feathers
  /// the edge that faces the card content.
  final bool mirrorHorizontally;

  @override
  State<AnimatedPerformanceWave> createState() =>
      _AnimatedPerformanceWaveState();
}

class _AnimatedPerformanceWaveState extends State<AnimatedPerformanceWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Color get waveColor => TeamCardPalette.waveColorFor(
    widget.hasPerformanceData,
    widget.rating,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (Rect bounds) {
          if (widget.mirrorHorizontally) {
            // Inner edge is on the right of the strip after flip — soften there.
            return const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment(-0.42, 0),
              colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
              stops: [0.0, 0.55],
            ).createShader(bounds);
          }
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment(0.42, 0),
            colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
            stops: [0.0, 0.55],
          ).createShader(bounds);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final paint = CustomPaint(
                painter: _PerformanceWavePainter(
                  progress: _controller.value,
                  color: waveColor,
                ),
                size: Size.infinite,
              );
              if (widget.mirrorHorizontally) {
                return Transform.flip(flipX: true, child: paint);
              }
              return paint;
            },
          ),
        ),
      ),
    );
  }
}

class _PerformanceWavePainter extends CustomPainter {
  _PerformanceWavePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final mainPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.05),
          color.withValues(alpha: 0.20),
          color.withValues(alpha: 0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    _drawWave(
      canvas: canvas,
      size: size,
      paint: mainPaint,
      startXFactor: 0.25,
      amplitude: 14,
      frequency: 34,
      phaseOffset: 0,
    );

    final secondPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.04),
          color.withValues(alpha: 0.14),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(rect);

    _drawWave(
      canvas: canvas,
      size: size,
      paint: secondPaint,
      startXFactor: 0.42,
      amplitude: 10,
      frequency: 42,
      phaseOffset: math.pi,
    );

    final dotPaint = Paint()..color = color.withValues(alpha: 0.26);

    for (var x = size.width * 0.73; x < size.width * 0.96; x += 9) {
      for (var y = size.height * 0.20; y < size.height * 0.76; y += 9) {
        canvas.drawCircle(Offset(x, y), 1.05, dotPaint);
      }
    }
  }

  void _drawWave({
    required Canvas canvas,
    required Size size,
    required Paint paint,
    required double startXFactor,
    required double amplitude,
    required double frequency,
    required double phaseOffset,
  }) {
    final path = Path();
    final phase = progress * math.pi * 2 + phaseOffset;

    path.moveTo(size.width * startXFactor, 0);

    for (var y = 0.0; y <= size.height; y += 2) {
      final x =
          size.width * startXFactor +
          math.sin((y / frequency) + phase) * amplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PerformanceWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
