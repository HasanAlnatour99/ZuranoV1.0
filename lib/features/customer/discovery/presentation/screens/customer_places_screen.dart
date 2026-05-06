import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_routes.dart' show AppRouteNames;
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../customer_home/presentation/controllers/customer_location_providers.dart';
import '../../providers/customer_places_provider.dart';
import '../../utils/distance_utils.dart';
import '../widgets/premium_place_card.dart';

/// Standalone “Places” list — same cards as the Discover tab; useful for deep links
/// and embedding in other shells.
class CustomerPlacesScreen extends ConsumerWidget {
  const CustomerPlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final placesAsync = ref.watch(customerPlacesProvider);
    final positionAsync = ref.watch(customerCurrentPositionProvider);

    return Scaffold(
      backgroundColor: PlaceDiscoveryColors.background,
      body: SafeArea(
        child: placesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.customerPlacesLoadError,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (places) {
            if (places.isEmpty) {
              return Center(child: Text(l10n.customerPlacesEmpty));
            }

            final user = positionAsync.maybeWhen(
              data: (p) => p,
              orElse: () => null,
            );

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    l10n.customerPlacesScreenTitle,
                                    style: AppTextStyles.placesScreenTitle(
                                      PlaceDiscoveryColors.textPrimary,
                                      locale: locale,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: PlaceDiscoveryColors.primary,
                                    size: 25,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                l10n.customerPlacesScreenSubtitle,
                                style: const TextStyle(
                                  color: PlaceDiscoveryColors.textSecondary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tooltip(
                          message: l10n.customerPlacesFilterTooltip,
                          child: Material(
                            color: PlaceDiscoveryColors.primarySoft,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                // TODO: open discovery filter sheet (shared with Discover tab).
                              },
                              child: const SizedBox(
                                height: 52,
                                width: 52,
                                child: Icon(
                                  Icons.tune_rounded,
                                  color: PlaceDiscoveryColors.primary,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    final parts = DistanceUtils.distancePartsForCard(
                      salonLocation: place.location,
                      user: user,
                      l10n: l10n,
                    );
                    final showDist =
                        parts.overlayLine != l10n.placeCardDistanceUnavailable;
                    final isClosed = !place.isOpenNowEffective;

                    return PremiumPlaceCard.compact(
                      place: place,
                      distanceOverlayLine: parts.overlayLine,
                      distanceMetaTitle: parts.metaKmTitle,
                      showDistanceOverlay: showDist,
                      isClosed: isClosed,
                      isFavorite: false,
                      onTap: () {
                        context.pushNamed(
                          AppRouteNames.customerSalonProfile,
                          pathParameters: {'salonId': place.id},
                        );
                      },
                      onFavoriteTap: () {
                        // TODO: persist favorite (local first, then sync on login).
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
