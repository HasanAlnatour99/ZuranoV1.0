import 'package:flutter/material.dart';

/// Dark purple mesh gradient used behind the employee premium hero card.
class HeroMeshBackground extends StatelessWidget {
  const HeroMeshBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF16002E),
            Color(0xFF2D0B68),
            Color(0xFF5B21B6),
            Color(0xFF7C3AED),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.65, -0.65),
                  radius: 0.9,
                  colors: [
                    const Color(0xFFE879F9).withValues(alpha: 0.42),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.8, 0.9),
                  radius: 0.8,
                  colors: [
                    const Color(0xFF9333EA).withValues(alpha: 0.36),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
