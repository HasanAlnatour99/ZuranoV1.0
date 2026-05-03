import 'package:flutter/material.dart';

import '../../../../../core/formatting/app_money_format.dart';
import '../../../../../core/utils/currency_for_country.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../features/team_member_profile/presentation/theme/team_member_profile_colors.dart';
import '../../../data/models/assigned_barber_service_model.dart';

class AssignedServiceCard extends StatelessWidget {
  const AssignedServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  final AssignedBarberServiceModel service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final title = service.localizedName(lang);
    final displayName =
        title.trim().isNotEmpty ? title : l10n.teamServicesUnnamedService;

    final priceText = formatAppMoney(
      service.price.toDouble(),
      resolvedSalonMoneyCurrency(
        salonCurrencyCode: service.resolvedCurrencyCode,
        salonCountryIso: null,
      ),
      Localizations.localeOf(context),
    );

    final statusActive =
        service.assignmentIsActive && service.catalogIsActive;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: TeamMemberProfileColors.card,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: TeamMemberProfileColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: TeamMemberProfileColors.softPurple,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: TeamMemberProfileColors.border,
                  ),
                ),
                child: Icon(
                  Icons.content_cut_rounded,
                  color: TeamMemberProfileColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: TeamMemberProfileColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        _MiniInfo(
                          icon: Icons.schedule_rounded,
                          text: l10n.bookingDurationMinutes(
                            service.durationMinutes,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 18,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        _MiniInfo(
                          icon: Icons.sell_outlined,
                          text: priceText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusBadge(
                    isActive: statusActive,
                    activeLabel: l10n.teamServicesServiceActive,
                    inactiveLabel: l10n.teamServicesServiceInactive,
                  ),
                  const SizedBox(height: 12),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.outline,
                    size: 28,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: TeamMemberProfileColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: TeamMemberProfileColors.textPrimary.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isActive,
    required this.activeLabel,
    required this.inactiveLabel,
  });

  final bool isActive;
  final String activeLabel;
  final String inactiveLabel;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isActive ? const Color(0xFFDDFCE8) : const Color(0xFFF3F4F6);
    final textColor =
        isActive ? const Color(0xFF047857) : const Color(0xFF6B7280);
    final dotColor =
        isActive ? const Color(0xFF22C55E) : const Color(0xFF9CA3AF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? activeLabel : inactiveLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
