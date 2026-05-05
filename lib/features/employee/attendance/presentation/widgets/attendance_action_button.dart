import 'package:flutter/material.dart';

class AttendanceActionButton extends StatelessWidget {
  /// Light purple rim when enabled (matches premium attendance card border).
  static const Color _punchTileBorderEnabled = Color(0xFFE9D5FF);
  static const Color _disabledBorder = Color(0xFFE5E7EB);
  static const Color _disabledMuted = Color(0xFFCBD5E1);
  static const Color _disabledFill = Color(0xFFF9FAFB);

  const AttendanceActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.loading,
    required this.color,
    required this.availableLabel,
    required this.disabledLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final bool loading;
  final Color color;
  final String availableLabel;
  final String disabledLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = color;
    final iconBgAlpha = enabled ? 0.18 : 0.16;
    final iconFgAlpha = enabled ? 1.0 : 0.88;

    final fillColor = enabled ? Colors.white : _disabledFill;
    final borderColor = enabled ? _punchTileBorderEnabled : _disabledBorder;
    final iconWellColor = enabled
        ? accent.withValues(alpha: iconBgAlpha)
        : _disabledMuted.withValues(alpha: 0.28);
    final iconPaint = enabled
        ? accent.withValues(alpha: iconFgAlpha)
        : _disabledMuted;
    final progressColor = enabled ? accent : _disabledMuted;

    return SizedBox(
      height: 118,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled && !loading ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: double.infinity,
            height: 118,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 4,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF1A2C29,
                  ).withValues(alpha: enabled ? 0.06 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                      maxHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: iconWellColor,
                          ),
                          child: Center(
                            child: loading
                                ? SizedBox(
                                    width: 17,
                                    height: 17,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        progressColor,
                                      ),
                                    ),
                                  )
                                : Icon(icon, color: iconPaint, size: 20),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: enabled
                                ? const Color(0xFF64748B)
                                : const Color(0xFF94A3B8),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: enabled
                                ? accent.withValues(alpha: 0.14)
                                : _disabledBorder.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: enabled
                              ? Text(
                                  availableLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: accent.withValues(alpha: 0.95),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                              : FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 11,
                                        color: _disabledMuted,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        disabledLabel,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          color: _disabledMuted,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
