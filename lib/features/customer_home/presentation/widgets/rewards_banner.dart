import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/ui/zurano_responsive.dart';
import '../controllers/customer_home_providers.dart';
import '../theme/zurano_customer_colors.dart';

class RewardsBanner extends ConsumerWidget {
  const RewardsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final banners = ref.watch(activeBannersProvider);
    final title = banners.maybeWhen(
      data: (b) => b.isNotEmpty ? b.first.title : null,
      orElse: () => null,
    );
    final subtitle = banners.maybeWhen(
      data: (b) => b.isNotEmpty ? b.first.subtitle : null,
      orElse: () => null,
    );
    final cta = banners.maybeWhen(
      data: (b) => b.isNotEmpty ? b.first.ctaText : null,
      orElse: () => null,
    );

    final displayTitle = title == null || title.trim().isEmpty
        ? l10n.zuranoRewardsBannerTitle
        : title;
    final displaySubtitle = subtitle == null || subtitle.trim().isEmpty
        ? l10n.zuranoRewardsBannerSubtitle
        : subtitle;
    final displayCta = cta == null || cta.trim().isEmpty
        ? l10n.zuranoRewardsBannerCta
        : cta;

    return SizedBox(
      height: ZuranoResponsive.v(context, 112),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFFC084FC), ZuranoCustomerColors.primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: ZuranoCustomerColors.primary.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              CircleAvatar(
                radius: ZuranoResponsive.s(context, 20),
                backgroundColor: Colors.white24,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: ZuranoResponsive.s(context, 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ZuranoResponsive.font(context, 16),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displaySubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: ZuranoResponsive.font(context, 13),
                        height: 1.25,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: () {
                  context.go(AppRoutes.customerSalonDiscovery);
                },
                child: Text(
                  displayCta,
                  style: TextStyle(
                    fontSize: ZuranoResponsive.font(context, 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
