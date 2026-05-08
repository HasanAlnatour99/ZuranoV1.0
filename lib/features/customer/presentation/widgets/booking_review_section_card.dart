import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

class BookingReviewSectionCard extends StatelessWidget {
  const BookingReviewSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.onEdit,
    this.editLabel,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final VoidCallback? onEdit;
  final String? editLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xlarge),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: AppBrandColors.primary),
                    const SizedBox(width: AppSpacing.small),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColorsLight.textPrimary,
                          ),
                    ),
                  ),
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle:
                            const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(editLabel ?? 'Edit'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
