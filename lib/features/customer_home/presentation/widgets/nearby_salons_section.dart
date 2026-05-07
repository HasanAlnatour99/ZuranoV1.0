import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart'
    show AppRoutes, AppRouteNames;
import '../../../../core/firebase/firestore_index_building.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/ui/zurano_responsive.dart';
import '../controllers/customer_home_providers.dart'
    show
        customerDiscoveryCountryNameProvider,
        customerSearchTextProvider,
        nearbySalonPreviewsProvider;
import '../controllers/customer_location_providers.dart'
    show customerCurrentPositionProvider;
import '../utils/customer_salon_query.dart';
import 'customer_empty_state.dart';
import 'customer_error_state.dart';
import 'customer_loading_state.dart';
import 'customer_section_header.dart';
import 'nearby_salon_list_card.dart';

const int _kNearbyDisplayLimit = 5;

class NearbySalonsSection extends ConsumerWidget {
  const NearbySalonsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final salonsAsync = ref.watch(nearbySalonPreviewsProvider);
    final positionAsync = ref.watch(customerCurrentPositionProvider);
    final query = ref.watch(customerSearchTextProvider);
    final skelH = ZuranoResponsive.v(context, 160);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZuranoSectionHeaderL10n(
          title: l10n.zuranoNearbyTitle,
          actionLabel: l10n.zuranoNearbyViewMap,
          leading: Icons.location_on_rounded,
          onAction: () {
            context.push(AppRoutes.customerNearbyMap);
          },
        ),
        const SizedBox(height: 14),
        salonsAsync.when(
          data: (raw) {
            final filtered = filterSalonPreviewsForQuery(raw, query);
            final userPosition = positionAsync.maybeWhen(
              data: (p) => p,
              orElse: () => null,
            );
            final display = filtered.take(_kNearbyDisplayLimit).toList();
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
                    (s) => NearbySalonListCard(
                      salon: s,
                      userPosition: userPosition,
                      onBookNow: () {
                        context.push(
                          '${AppRoutes.customerBook}/${s.salonId}/services',
                        );
                      },
                      onOpen: () {
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
          loading: () => SizedBox(
            height: skelH,
            child: const CustomerNearbyListSkeleton(),
          ),
          error: (e, st) {
            if (isFirestoreIndexBuilding(e)) {
              return SizedBox(
                height: skelH,
                child: const CustomerNearbyListSkeleton(),
              );
            }
            return CustomerDiscoverError(
              message: l10n.zuranoDiscoverSectionLoadFailed,
            );
          },
        ),
      ],
    );
  }
}
