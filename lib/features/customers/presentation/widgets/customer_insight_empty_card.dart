import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

const _primaryPurple = Color(0xFF7B2FF7);
const _surfacePurple = Color(0xFFF0E7FF);
const _textPrimary = Color(0xFF21143D);
const _textSecondary = Color(0xFF7A728C);
const _borderPurple = Color(0xFFEDE5FF);

class CustomerInsightEmptyCard extends StatelessWidget {
  const CustomerInsightEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 12, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFFCF9FF)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderPurple),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withValues(alpha: 0.075),
            blurRadius: 28,
            spreadRadius: -8,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _surfacePurple,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: _primaryPurple,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.customersInsightsEmpty,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.customersInsightsEmptySubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const _FadedChartIllustration(),
        ],
      ),
    );
  }
}

class _FadedChartIllustration extends StatelessWidget {
  const _FadedChartIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 54,
      child: CustomPaint(
        painter: _MiniChartPainter(),
      ),
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  const _MiniChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _primaryPurple.withValues(alpha: 0.055);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _primaryPurple.withValues(alpha: 0.18);

    for (var i = 1; i < 4; i += 1) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path()
      ..moveTo(0, size.height * 0.74)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.42,
        size.width * 0.38,
        size.height * 0.80,
        size.width * 0.58,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.24,
        size.width * 0.86,
        size.height * 0.36,
        size.width,
        size.height * 0.16,
      );
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
