import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Icon-only quick action on a customer card (call, message, profile).
class CustomerCardActionButton extends StatelessWidget {
  const CustomerCardActionButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Material(
        color: FinanceDashboardColors.lightPurple.withValues(alpha: 0.45),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          style: IconButton.styleFrom(
            foregroundColor: FinanceDashboardColors.primaryPurple,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(40, 40),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
        ),
      ),
    );
  }
}
