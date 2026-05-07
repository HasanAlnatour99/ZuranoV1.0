import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/firestore_index_building.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/customer_home_providers.dart';
import '../utils/customer_salon_query.dart';
import 'customer_empty_state.dart';
import 'customer_error_state.dart';
import 'customer_loading_state.dart';
import 'customer_section_header.dart';
import '../../data/models/customer_salon_preview_model.dart';
import 'premium_recommended_salon_card.dart';

class RecommendedSalonsSection extends ConsumerWidget {
  const RecommendedSalonsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final salonsAsync = ref.watch(recommendedSalonPreviewsProvider);
    final query = ref.watch(customerSearchTextProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ZuranoSectionHeaderL10n(
          title: l10n.zuranoDiscoverRecommendedTitle,
          actionLabel: l10n.zuranoDiscoverSeeAll,
          leading: Icons.star_rounded,
          onAction: () => context.go(AppRoutes.customerSalonDiscovery),
        ),
        const SizedBox(height: 14),
        salonsAsync.when(
          data: (raw) {
            final salons = filterSalonPreviewsForQuery(raw, query);
            if (salons.isEmpty) {
              return CustomerDiscoverEmpty(
                icon: Icons.storefront_rounded,
                message: l10n.zuranoDiscoverRecommendedEmpty,
              );
            }
            return _RecommendedSalonsPager(salons: salons);
          },
          loading: () => const SizedBox(
            height: 240,
            child: CustomerHorizontalCardSkeleton(),
          ),
          error: (e, st) {
            if (isFirestoreIndexBuilding(e)) {
              return const SizedBox(
                height: 240,
                child: CustomerHorizontalCardSkeleton(),
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

class _RecommendedSalonsPager extends StatefulWidget {
  const _RecommendedSalonsPager({required this.salons});

  final List<CustomerSalonPreviewModel> salons;

  @override
  State<_RecommendedSalonsPager> createState() =>
      _RecommendedSalonsPagerState();
}

class _RecommendedSalonsPagerState extends State<_RecommendedSalonsPager> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.96);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.salons.length,
        itemBuilder: (context, index) {
          final s = widget.salons[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PremiumRecommendedSalonCard(
              salon: s,
              onOpen: () {
                context.pushNamed(
                  AppRouteNames.customerSalonProfile,
                  pathParameters: {'salonId': s.salonId},
                );
              },
            ),
          );
        },
      ),
    );
  }
}
