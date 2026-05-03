import 'package:flutter/material.dart';

/// Center-docked owner shell FAB: white circle with transparent [zurano_icon.png].
class ZuranoCenterFab extends StatelessWidget {
  const ZuranoCenterFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const double _fabDiameter = 55;

  /// Ring thickness used by owner shell bottom nav / customer nav layout math.
  static const double whiteBorderWidth = 3;

  static const double outerSize = _fabDiameter + 2 * whiteBorderWidth;

  static double get outerRadius => outerSize / 2;

  static const String _iconAsset = 'assets/branding/zurano_icon.png';

  /// Most of the white circle; light scale after tight-crop [zurano_icon.png].
  static double get _iconViewport => outerSize * 0.88;

  static const double _markScale = 1.45;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7B61FF);
    final viewport = _iconViewport;

    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.2),
            blurRadius: 14,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.white,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: ClipOval(
              child: SizedBox(
                width: viewport,
                height: viewport,
                child: Transform.scale(
                  alignment: Alignment.center,
                  scale: _markScale,
                  child: Image.asset(
                    _iconAsset,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
