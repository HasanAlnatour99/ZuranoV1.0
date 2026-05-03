import 'package:flutter/material.dart';

import '../../theme/zurano_tokens.dart';

class ZuranoGradientButton extends StatelessWidget {
  const ZuranoGradientButton({
    super.key,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.onPressed,
    this.height = 64,
    this.fontSize = 16,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;

    return Semantics(
      button: true,
      enabled: !disabled,
      label: label,
      child: GestureDetector(
        onTap: disabled ? null : onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: disabled ? 0.65 : 1,
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: ZuranoTokens.primaryGradient,
              borderRadius: BorderRadius.circular(ZuranoTokens.radiusButton),
              boxShadow: [
                BoxShadow(
                  color: ZuranoTokens.primary.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
