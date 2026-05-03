import 'package:flutter/material.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/service.dart';
import '../../data/service_category_helpers.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';
import 'package:barber_shop_app/shared/widgets/zurano_service_category_icon.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    required this.currencyCode,
    required this.locale,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  final SalonService service;
  final String currencyCode;
  final Locale locale;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  String get _displayName =>
      service.localizedTitleForLanguageCode(locale.languageCode);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final thumb = _ServiceThumbnail(
      imageUrl: service.imageUrl,
      isActive: service.isActive,
      categoryKey: service.categoryKey,
      iconKey: service.iconKey,
    );

    final meta = [
      l10n.bookingDurationMinutes(service.durationMinutes),
      formatAppMoney(service.price, currencyCode, locale),
    ].join(' · ');

    final categoryLine = displayCategoryLineForService(service, l10n);

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.medium),
      borderRadius: AppRadius.large,
      showShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              thumb,
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
                            _displayName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.small),
                        _StatusPill(
                          active: service.isActive,
                          activeLabel: l10n.ownerServiceStatusActive,
                          inactiveLabel: l10n.ownerServiceStatusInactive,
                        ),
                      ],
                    ),
                    if (categoryLine != null && categoryLine.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        categoryLine,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.primary.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      meta,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          _AnalyticsLine(
            l10n: l10n,
            service: service,
            currencyCode: currencyCode,
            locale: locale,
          ),
          const SizedBox(height: AppSpacing.small),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            alignment: WrapAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(AppIcons.edit_outlined, size: 18),
                label: Text(l10n.ownerServiceActionEdit),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(AppIcons.delete_outline_rounded, size: 18),
                label: Text(l10n.ownerServiceActionDelete),
                style: TextButton.styleFrom(foregroundColor: scheme.error),
              ),
              FilledButton.tonalIcon(
                onPressed: onToggleActive,
                icon: Icon(
                  service.isActive
                      ? AppIcons.visibility_off_outlined
                      : AppIcons.visibility_outlined,
                  size: 18,
                ),
                label: Text(
                  service.isActive ? l10n.ownerDeactivate : l10n.ownerActivate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsLine extends StatelessWidget {
  const _AnalyticsLine({
    required this.l10n,
    required this.service,
    required this.currencyCode,
    required this.locale,
  });

  final AppLocalizations l10n;
  final SalonService service;
  final String currencyCode;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant);

    final hasTimes = service.timesUsed != null;
    final hasRevenue =
        service.totalRevenue != null && service.totalRevenue! > 0;

    if (!hasTimes && !hasRevenue) {
      return Text(l10n.ownerServiceAnalyticsPlaceholder, style: style);
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        if (hasTimes)
          Text(
            l10n.ownerServiceTimesUsed(service.timesUsed!),
            style: style?.copyWith(fontWeight: FontWeight.w600),
          ),
        if (hasTimes && hasRevenue) Text('·', style: style),
        if (hasRevenue)
          Text(
            l10n.ownerServiceTotalRevenue(
              formatAppMoney(service.totalRevenue!, currencyCode, locale),
            ),
            style: style?.copyWith(fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.active,
    required this.activeLabel,
    required this.inactiveLabel,
  });

  final bool active;
  final String activeLabel;
  final String inactiveLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = active
        ? scheme.tertiary.withValues(alpha: 0.35)
        : scheme.surfaceContainerHighest;
    final fg = active ? scheme.onTertiaryContainer : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Text(
        active ? activeLabel : inactiveLabel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ServiceThumbnail extends StatelessWidget {
  const _ServiceThumbnail({
    required this.imageUrl,
    required this.isActive,
    required this.categoryKey,
    required this.iconKey,
  });

  final String? imageUrl;
  final bool isActive;
  final String? categoryKey;
  final String? iconKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const size = 52.0;
    final url = imageUrl?.trim();

    final child = url != null && url.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: SizedBox(
              width: size,
              height: size,
              child: AppNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: _placeholder(context),
              ),
            ),
          )
        : _placeholder(context);

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: scheme.outline.withValues(alpha: isActive ? 0.25 : 0.45),
          ),
        ),
        child: Opacity(opacity: isActive ? 1 : 0.55, child: child),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.9),
      child: Center(
        child: ZuranoServiceCategoryIcon(
          categoryKey: categoryKey,
          iconKey: iconKey,
          size: 44,
          iconSize: 22,
          backgroundColor: scheme.surfaceContainerHigh.withValues(alpha: 0.5),
          iconColor: scheme.primary.withValues(alpha: 0.9),
          borderRadius: 12,
        ),
      ),
    );
  }
}
