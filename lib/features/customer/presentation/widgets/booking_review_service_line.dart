import 'package:flutter/material.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/zurano_service_category_icon.dart';
import '../../data/models/customer_service_public_model.dart';

class BookingReviewServiceLine extends StatelessWidget {
  const BookingReviewServiceLine({
    super.key,
    required this.service,
    required this.currencyCode,
  });

  final CustomerServicePublicModel service;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final price = formatMoney(
      service.price,
      currencyCode,
      Localizations.localeOf(context),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ZuranoServiceCategoryIcon(
            categoryKey: service.resolvedCategoryKeyForIcon,
            iconKey: service.iconKey,
            size: 40,
            iconSize: 20,
            borderRadius: 12,
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.localizedTitleForLanguageCode(lang),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColorsLight.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.customerProfileMinutesShort(service.durationMinutes),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColorsLight.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppBrandColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
