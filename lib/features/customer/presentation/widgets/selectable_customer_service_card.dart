import 'package:flutter/material.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/zurano_service_category_icon.dart';
import '../../data/models/customer_service_public_model.dart';

class SelectableCustomerServiceCard extends StatelessWidget {
  const SelectableCustomerServiceCard({
    super.key,
    required this.service,
    required this.selected,
    required this.onTap,
    required this.currencyCode,
  });

  final CustomerServicePublicModel service;
  final bool selected;
  final VoidCallback onTap;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode;
    final price = formatMoney(service.price, currencyCode, locale);
    final image = service.imageUrl?.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Material(
        color: selected
            ? AppBrandColors.primary.withValues(alpha: 0.07)
            : scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xlarge),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xlarge),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(AppSpacing.medium),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xlarge),
              border: Border.all(
                color: selected
                    ? AppBrandColors.primary
                    : scheme.outlineVariant.withValues(alpha: 0.45),
                width: selected ? 1.6 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: selected ? 0.08 : 0.04),
                  blurRadius: selected ? 18 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ServiceIcon(imageUrl: image, service: service),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.localizedTitleForLanguageCode(lang),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColorsLight.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.customerProfileMinutesShort(
                          service.durationMinutes,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColorsLight.textSecondary,
                        ),
                      ),
                      if (service.description != null &&
                          service.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          service.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColorsLight.textSecondary,
                                height: 1.3,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? AppBrandColors.primary : Colors.white,
                        border: Border.all(
                          color: selected
                              ? AppBrandColors.primary
                              : AppColorsLight.border,
                        ),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      price,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppBrandColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon({required this.imageUrl, required this.service});

  final String? imageUrl;
  final CustomerServicePublicModel service;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: SizedBox(
        width: 52,
        height: 52,
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _ServiceIconFallback(service: service),
              )
            : _ServiceIconFallback(service: service),
      ),
    );
  }
}

class _ServiceIconFallback extends StatelessWidget {
  const _ServiceIconFallback({required this.service});

  final CustomerServicePublicModel service;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppBrandColors.secondary,
      child: Center(
        child: ZuranoServiceCategoryIcon(
          categoryKey: service.resolvedCategoryKeyForIcon,
          iconKey: service.iconKey,
          size: 48,
          iconSize: 24,
          backgroundColor: Colors.white.withValues(alpha: 0.35),
          iconColor: AppBrandColors.primary.withValues(alpha: 0.85),
          borderRadius: 14,
        ),
      ),
    );
  }
}
