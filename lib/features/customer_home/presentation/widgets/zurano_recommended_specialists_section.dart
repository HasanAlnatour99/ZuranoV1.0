import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/firestore_index_building.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/public_specialist_discovery_model.dart';
import '../controllers/customer_home_canonical_providers.dart';
import '../theme/zurano_customer_home_design_tokens.dart';
import '../utils/customer_home_ui_mappers.dart';
import 'customer_error_state.dart';
import 'customer_loading_state.dart';
import 'zurano_specialist_card.dart';

/// Horizontal specialists from `customerSearchIndex` (same source as search).
class ZuranoRecommendedSpecialistsSection extends ConsumerWidget {
  const ZuranoRecommendedSpecialistsSection({super.key});

  static const double _listHeight = 112;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final specialistsAsync = ref.watch(recommendedSpecialistsProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  l10n.zuranoRecommendedSpecialistsTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ZuranoCustomerHomeColors.darkText,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      context.push(AppRoutes.customerSalonDiscovery),
                  child: Text(
                    l10n.zuranoDiscoverSeeAll,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ZuranoCustomerHomeColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: _listHeight,
            child: specialistsAsync.when(
              data: (list) {
                final visible =
                    list.where((s) => s.isReadyForCustomerHome).toList();
                if (visible.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _CompactSpecialistsEmpty(message: l10n.zuranoRecommendedSpecialistsEmpty),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final s = visible[i];
                    final ui = mapDiscoverySpecialistToUi(s);
                    return ZuranoSpecialistCard(
                      specialist: ui,
                      onTap: () => _openSpecialist(context, s),
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CustomerHorizontalCardSkeleton(),
              ),
              error: (e, _) {
                if (isFirestoreIndexBuilding(e)) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CustomerHorizontalCardSkeleton(),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: CustomerDiscoverError(
                      message: l10n.zuranoDiscoverSectionLoadFailed,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openSpecialist(
    BuildContext context,
    PublicSpecialistDiscoveryModel s,
  ) {
    context.push(AppRoutes.customerBookTeamPath(s.salonId));
  }
}

class _CompactSpecialistsEmpty extends StatelessWidget {
  const _CompactSpecialistsEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 22,
            color: ZuranoCustomerHomeColors.mutedText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.25,
                color: ZuranoCustomerHomeColors.mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
