import 'package:flutter/material.dart';

/// Circular glass-style control for purple hero headers and similar surfaces.
class ZuranoHeaderIconButton extends StatelessWidget {
  const ZuranoHeaderIconButton({
    super.key,
    required this.tooltip,
    required this.onTap,
    required this.icon,
    this.compact = false,
    this.highlighted = false,
  });

  final String tooltip;
  final VoidCallback onTap;
  final Widget icon;
  final bool compact;
  final bool highlighted;

  static const double _defaultSize = 52;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 46.0 : _defaultSize;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: highlighted
                  ? Colors.white.withValues(alpha: 0.26)
                  : Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}
