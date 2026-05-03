import 'package:flutter/material.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/zurano_service_category_icon.dart';
import '../../data/models/customer_service_public_model.dart';

class CustomerServiceListTile extends StatelessWidget {
  const CustomerServiceListTile({
    super.key,
    required this.service,
    required this.currencyCode,
  });

  final CustomerServicePublicModel service;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode;
    final price = formatMoney(service.price, currencyCode, locale);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.large),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ZuranoServiceCategoryIcon(
                  categoryKey: service.resolvedCategoryKeyForIcon,
                  iconKey: service.iconKey,
                  size: 44,
                  iconSize: 22,
                  borderRadius: 12,
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.localizedTitleForLanguageCode(lang),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColorsLight.textPrimary,
                        ),
                      ),
                      if (service.description != null &&
                          service.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          service.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColorsLight.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10n.customerProfileMinutesShort(service.durationMinutes),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColorsLight.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
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
