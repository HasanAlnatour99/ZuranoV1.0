import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart' show AppRoutes, AppRouteNames;
import '../../../../l10n/app_localizations.dart';
import '../../data/models/last_booked_model.dart';
import '../../data/models/recently_viewed_salon_model.dart';
import '../controllers/customer_home_providers.dart';
import '../theme/zurano_customer_home_design_tokens.dart';
import '../../../../core/widgets/app_network_image.dart';

/// Last booking + optional recently viewed salons for the Zurano home layout.
class ZuranoRecentActivitySection extends ConsumerWidget {
  const ZuranoRecentActivitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final lastBookedAsync = ref.watch(lastBookedProvider);
    final recentlyViewedAsync = ref.watch(recentlyViewedSalonsProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  l10n.zuranoRecentActivityTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ZuranoCustomerHomeColors.darkText,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go(AppRoutes.customerMyBooking),
                  child: Text(
                    l10n.zuranoRecentActivityViewAll,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ZuranoCustomerHomeColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: lastBookedAsync.when(
              data: (last) {
                if (last != null) {
                  return _LastBookingZuranoCard(
                    model: last,
                    viewLabel: l10n.zuranoLastBookedViewBooking,
                    codeLabel: l10n.zuranoLastBookedCodeLabel,
                    onView: () => _openBooking(context, last),
                  );
                }
                return recentlyViewedAsync.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return Text(
                        l10n.zuranoRecentActivityEmpty,
                        style: const TextStyle(
                          color: ZuranoCustomerHomeColors.mutedText,
                          height: 1.35,
                        ),
                      );
                    }
                    return SizedBox(
                      height: 104,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final s = list[i];
                          return _RecentlyViewedMiniCard(
                            model: s,
                            onTap: () {
                              context.pushNamed(
                                AppRouteNames.customerSalonProfile,
                                pathParameters: {'salonId': s.salonId},
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  void _openBooking(BuildContext context, LastBookedModel last) {
    final bookingId = last.bookingId?.trim();
    if (bookingId != null && bookingId.isNotEmpty) {
      context.pushNamed(
        AppRouteNames.customerBookingDetails,
        pathParameters: {
          'salonId': last.salonId,
          'bookingId': bookingId,
        },
      );
    } else {
      context.go(AppRoutes.customerMyBooking);
    }
  }
}

class _LastBookingZuranoCard extends StatelessWidget {
  const _LastBookingZuranoCard({
    required this.model,
    required this.onView,
    required this.viewLabel,
    required this.codeLabel,
  });

  final LastBookedModel model;
  final VoidCallback onView;
  final String viewLabel;
  final String codeLabel;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if (model.serviceName?.trim().isNotEmpty == true)
        model.serviceName!.trim(),
      if (model.bookingDateText.trim().isNotEmpty) model.bookingDateText.trim(),
    ];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onView,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: ZuranoCustomerHomeColors.lavender,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: ZuranoCustomerHomeColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.salonName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: ZuranoCustomerHomeColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitleParts.isEmpty ? '—' : subtitleParts.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.25,
                        color: ZuranoCustomerHomeColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$codeLabel: ${model.bookingCode}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: ZuranoCustomerHomeColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 108,
                child: TextButton(
                  onPressed: onView,
                  child: Text(
                    viewLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w800),
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

class _RecentlyViewedMiniCard extends StatelessWidget {
  const _RecentlyViewedMiniCard({
    required this.model,
    required this.onTap,
  });

  final RecentlyViewedSalonModel model;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final coverUrl = model.coverImageUrl?.trim();

    return SizedBox(
      width: 220,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 88,
                child: coverUrl != null && coverUrl.isNotEmpty
                    ? AppNetworkImage(imageUrl: coverUrl, fit: BoxFit.cover)
                    : const ColoredBox(
                        color: ZuranoCustomerHomeColors.lavender,
                        child: Icon(
                          Icons.storefront_rounded,
                          color: ZuranoCustomerHomeColors.primary,
                        ),
                      ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        model.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: ZuranoCustomerHomeColors.darkText,
                        ),
                      ),
                      if (model.area?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          model.area!.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ZuranoCustomerHomeColors.mutedText,
                          ),
                        ),
                      ],
                    ],
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
