import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/customer_team_member_public_model.dart';

class CustomerTeamMemberCard extends StatelessWidget {
  const CustomerTeamMemberCard({super.key, required this.member});

  final CustomerTeamMemberPublicModel member;

  static const double _avatarSize = 76;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final specialtyLine = member.specialties
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ZuranoTokens.radiusCard),
          color: ZuranoTokens.surface,
          border: Border.all(
            color: ZuranoTokens.sectionBorder,
            width: 1,
          ),
          boxShadow: ZuranoTokens.softCardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _TeamAvatar(member: member),
              const SizedBox(width: AppSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      member.displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: ZuranoTokens.textDark,
                            letterSpacing: -0.2,
                            height: 1.2,
                          ),
                    ),
                    if (specialtyLine.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        specialtyLine,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ZuranoTokens.textGray,
                              height: 1.35,
                            ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    _RatingRow(
                      l10n: l10n,
                      member: member,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({required this.member});

  final CustomerTeamMemberPublicModel member;

  @override
  Widget build(BuildContext context) {
    final url = member.profileImageUrl?.trim();

    Widget fallback() {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppBrandColors.secondary,
              AppBrandColors.secondary.withValues(alpha: 0.72),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppBrandColors.primary.withValues(alpha: 0.12),
            width: 1.5,
          ),
        ),
        child: Icon(
          Icons.person_rounded,
          color: AppBrandColors.primary.withValues(alpha: 0.45),
          size: 36,
        ),
      );
    }

    return SizedBox(
      width: CustomerTeamMemberCard._avatarSize,
      height: CustomerTeamMemberCard._avatarSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppBrandColors.primary.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
        ),
        child: ClipOval(
          child: url != null && url.isNotEmpty
              ? AppNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: ZuranoTokens.lightPurple,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppBrandColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: fallback(),
                )
              : fallback(),
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({
    required this.l10n,
    required this.member,
  });

  final AppLocalizations l10n;
  final CustomerTeamMemberPublicModel member;

  @override
  Widget build(BuildContext context) {
    final hasReviews = member.ratingCount > 0 && member.ratingAverage > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ZuranoTokens.searchFill,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: ZuranoTokens.border.withValues(alpha: 0.85),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              hasReviews ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 18,
              color: hasReviews
                  ? Colors.amber.shade700
                  : AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              hasReviews
                  ? l10n.customerTeamSelectionRating(
                      member.ratingAverage.toStringAsFixed(1),
                      member.ratingCount,
                    )
                  : l10n.customerSalonRatingNew,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: hasReviews
                        ? ZuranoTokens.textDark
                        : AppColorsLight.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
