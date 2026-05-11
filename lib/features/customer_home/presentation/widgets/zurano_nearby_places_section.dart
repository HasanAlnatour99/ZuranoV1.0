import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart'
    show AppRoutes, AppRouteNames;
import '../../../../core/firebase/firestore_index_building.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/public_salon_model.dart';
import '../controllers/customer_home_canonical_providers.dart';
import '../controllers/customer_home_providers.dart'
    show customerDiscoveryCountryNameProvider, customerSearchTextProvider;
import '../controllers/customer_location_providers.dart';
import '../utils/customer_salon_query.dart';
import 'customer_empty_state.dart';
import 'customer_error_state.dart';
import 'customer_loading_state.dart';
import '../theme/zurano_customer_home_design_tokens.dart';
import 'zurano_nearby_place_card.dart';

const int _kHomeNearbyLimit = 2;

/// Nearby salons with Zurano card chrome (max two rows on home).
class ZuranoNearbyPlacesSection extends ConsumerWidget {
  const ZuranoNearbyPlacesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final salonsAsync = ref.watch(nearbySalonsProvider);
    final positionAsync = ref.watch(customerCurrentPositionProvider);
    final query = ref.watch(customerSearchTextProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  l10n.zuranoNearbyTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ZuranoCustomerHomeColors.darkText,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _onViewMapTap(context, ref, salonsAsync, l10n),
                  icon: const Icon(
                    Icons.location_on_rounded,
                    size: 18,
                    color: ZuranoCustomerHomeColors.primary,
                  ),
                  label: Text(
                    l10n.zuranoNearbyViewMap,
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
            child: salonsAsync.when(
              data: (raw) {
                final filtered = filterPublicSalonsForQuery(raw, query);
                final userPosition = positionAsync.maybeWhen(
                  data: (p) => p,
                  orElse: () => null,
                );
                final display =
                    filtered.take(_kHomeNearbyLimit).toList(growable: false);
                if (display.isEmpty) {
                  final countryName = ref.watch(
                    customerDiscoveryCountryNameProvider,
                  );
                  return CustomerCompactEmptyState(
                    icon: Icons.map_outlined,
                    message: l10n.zuranoDiscoverNearbyEmptyInCountry(countryName),
                  );
                }
                return Column(
                  children: display
                      .map(
                        (s) => ZuranoNearbyPlaceCard(
                          salon: s,
                          userPosition: userPosition,
                          onBookNow: () {
                            context.push(
                              '${AppRoutes.customerBook}/${s.salonId}/services',
                            );
                          },
                          onOpenDetail: () {
                            context.pushNamed(
                              AppRouteNames.customerSalonProfile,
                              pathParameters: {'salonId': s.salonId},
                            );
                          },
                        ),
                      )
                      .toList(growable: false),
                );
              },
              loading: () => const SizedBox(
                height: 160,
                child: CustomerNearbyListSkeleton(),
              ),
              error: (e, _) {
                if (isFirestoreIndexBuilding(e)) {
                  return const SizedBox(
                    height: 160,
                    child: CustomerNearbyListSkeleton(),
                  );
                }
                return CustomerDiscoverError(
                  message: l10n.zuranoDiscoverSectionLoadFailed,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onViewMapTap(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<PublicSalonModel>> salonsAsync,
    AppLocalizations l10n,
  ) {
    final list = salonsAsync.maybeWhen(
      data: (l) => l,
      orElse: () => const <PublicSalonModel>[],
    );
    final hasValid = list.any((s) => s.hasValidLocation);
    if (!hasValid) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.customerHomeMapNoValidLocations)),
        );
      return;
    }
    context.push(AppRoutes.customerNearbyMap);
  }
}
