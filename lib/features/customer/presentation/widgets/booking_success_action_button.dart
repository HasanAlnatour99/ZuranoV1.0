import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import 'customer_gradient_scaffold.dart';

class BookingSuccessActionButton extends StatelessWidget {
  const BookingSuccessActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: AppSpacing.small),
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );

    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: CustomerPrimaryButtonStyle.filled(context),
          onPressed: onPressed,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.large,
            vertical: AppSpacing.medium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
        ),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
