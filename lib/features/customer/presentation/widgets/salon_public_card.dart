import 'package:flutter/material.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/salon_public_model.dart';

/// Premium horizontal card for public salon discovery lists.
class SalonPublicCard extends StatelessWidget {
  const SalonPublicCard({
    super.key,
    required this.salon,
    this.distanceLabel,
    this.onTap,
    this.onBookmarkTap,
    this.bookmarked = false,
  });

  final SalonPublicModel salon;
  final String? distanceLabel;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final bool bookmarked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final price = formatMoney(salon.startingPrice, salon.currencyCode, locale);

    return Material(
      color: scheme.surface,
      elevation: 0,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xlarge),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xlarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            color: scheme.surface,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.small),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Cover(url: salon.coverImageUrl),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              salon.salonName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColorsLight.textPrimary,
                                  ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: l10n.customerSalonBookmarkTooltip,
                            onPressed: onBookmarkTap,
                            icon: Icon(
                              bookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline,
                              color: bookmarked
                                  ? AppBrandColors.primary
                                  : AppColorsLight.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        salon.area,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColorsLight.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Wrap(
                        spacing: AppSpacing.small,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _OpenBadge(isOpen: salon.isOpen, l10n: l10n),
                          _RatingRow(
                            rating: salon.ratingAverage,
                            count: salon.ratingCount,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.customerSalonStartingFrom(price),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: AppBrandColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          if (distanceLabel != null &&
                              distanceLabel!.trim().isNotEmpty)
                            Text(
                              distanceLabel!,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColorsLight.textSecondary,
                                  ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final u = url?.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: SizedBox(
        width: 92,
        height: 92,
        child: u != null && u.isNotEmpty
            ? Image.network(
                u,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _CoverPlaceholder(),
              )
            : const _CoverPlaceholder(),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppBrandColors.secondary,
      child: Icon(
        Icons.storefront_rounded,
        color: AppBrandColors.primary.withValues(alpha: 0.45),
        size: 36,
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  const _OpenBadge({required this.isOpen, required this.l10n});

  final bool isOpen;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? const Color(0xFFDCFCE7)
            : AppColorsLight.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isOpen ? l10n.customerSalonOpenNowBadge : l10n.customerSalonClosedBadge,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isOpen
              ? const Color(0xFF166534)
              : AppColorsLight.textSecondary,
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating, required this.count});

  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 18, color: Colors.amber.shade700),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColorsLight.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
