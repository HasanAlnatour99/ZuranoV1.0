import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/customer_review_model.dart';

class CustomerReviewCard extends StatelessWidget {
  const CustomerReviewCard({super.key, required this.review});

  final CustomerReviewModel review;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = review.createdAt != null
        ? DateFormat.yMMMd(locale).format(review.createdAt!.toLocal())
        : l10n.customerProfileReviewDateUnknown;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ZuranoTokens.surface,
          borderRadius: BorderRadius.circular(ZuranoTokens.radiusCard),
          border: Border.all(color: ZuranoTokens.sectionBorder),
          boxShadow: ZuranoTokens.softCardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.customerName,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: ZuranoTokens.textDark,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateLabel,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: ZuranoTokens.textGray,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  _Stars(rating: review.rating),
                ],
              ),
              if (review.comment != null &&
                  review.comment!.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.small),
                Text(
                  review.comment!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColorsLight.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final full = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < full ? Icons.star_rounded : Icons.star_border_rounded,
          size: 20,
          color: i < full ? Colors.amber.shade700 : ZuranoTokens.border,
        );
      }),
    );
  }
}
