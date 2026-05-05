import 'package:flutter/material.dart';

/// Animated neon curve that sweeps across the hero card (purely decorative).
class AnimatedHeroLightWave extends StatefulWidget {
  const AnimatedHeroLightWave({super.key});

  @override
  State<AnimatedHeroLightWave> createState() => _AnimatedHeroLightWaveState();
}

class _AnimatedHeroLightWaveState extends State<AnimatedHeroLightWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _LightWavePainter(progress: _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _LightWavePainter extends CustomPainter {
  _LightWavePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final wavePath = Path();

    final yBase = size.height * 0.68;
    final xOffset = (progress * size.width * 1.4) - size.width * 0.35;

    wavePath.moveTo(-size.width * 0.2 + xOffset, yBase);

    wavePath.cubicTo(
      size.width * 0.20 + xOffset,
      size.height * 0.88,
      size.width * 0.58 + xOffset,
      size.height * 0.48,
      size.width * 1.18 + xOffset,
      size.height * 0.42,
    );

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          Color(0xFFE879F9),
          Color(0xFF8B5CF6),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [
          Colors.transparent,
          Color(0xFFF0ABFC),
          Color(0xFFC084FC),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(wavePath, glowPaint);
    canvas.drawPath(wavePath, linePaint);

    final sparklePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final sparkleX = (size.width * progress * 1.2) % size.width;
    canvas.drawCircle(
      Offset(sparkleX, size.height * 0.48),
      2.2,
      sparklePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LightWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
