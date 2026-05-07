import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/zurano_tokens.dart';

class CustomerBookingDetailsSectionCard extends StatelessWidget {
  const CustomerBookingDetailsSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Container(
        decoration: BoxDecoration(
          color: ZuranoTokens.surface,
          borderRadius: BorderRadius.circular(ZuranoTokens.radiusCard),
          border: Border.all(color: ZuranoTokens.sectionBorder),
          boxShadow: ZuranoTokens.softCardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: ZuranoTokens.primary),
                    const SizedBox(width: AppSpacing.small),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: ZuranoTokens.textDark,
                      ),
                    ),
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
