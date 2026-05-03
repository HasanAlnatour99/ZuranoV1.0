import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/firebase_providers.dart';
import '../../data/dev_seed/customer_home_seed.dart';
import '../controllers/customer_home_providers.dart';
import '../controllers/customer_location_providers.dart';
import '../theme/zurano_customer_colors.dart';
import '../widgets/customer_bottom_nav.dart';
import '../widgets/customer_category_scroller.dart';
import '../widgets/customer_home_header.dart';
import '../widgets/customer_search_bar.dart';
import '../widgets/nearby_salons_section.dart';
import '../widgets/recommended_salons_section.dart';
import '../widgets/rewards_banner.dart';
import '../widgets/trending_services_section.dart';

/// Guest-friendly discovery hub backed by Firestore streams ([CustomerHomeRepository]).
class ZuranoCustomerHomeScreen extends ConsumerStatefulWidget {
  const ZuranoCustomerHomeScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

  @override
  ConsumerState<ZuranoCustomerHomeScreen> createState() =>
      _ZuranoCustomerHomeScreenState();
}

class _ZuranoCustomerHomeScreenState
    extends ConsumerState<ZuranoCustomerHomeScreen> {
  static bool _debugCountsLogged = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.invalidate(customerCurrentPositionProvider);
      ref.invalidate(customerHomeResolvedPlaceProvider);
    });
    if (kDebugMode && !_debugCountsLogged) {
      _debugCountsLogged = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        try {
          await ref
              .read(customerHomeRepositoryProvider)
              .debugCustomerHomeCounts(
                discoveryCountryName: ref.read(
                  customerDiscoveryCountryNameProvider,
                ),
              );
        } catch (e, st) {
          debugPrint('[CUSTOMER_HOME_COUNT] run failed: $e\n$st');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final textFactor = mq.textScaler.scale(14) / 14;
    return MediaQuery(
      data: mq.copyWith(
        textScaler: TextScaler.linear(textFactor.clamp(0.92, 1.08)),
      ),
      child: Scaffold(
        backgroundColor: ZuranoCustomerColors.background,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: CustomerHomeHeader(),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: CustomerSearchBar(),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  const SliverToBoxAdapter(child: CustomerCategoryScroller()),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  const SliverToBoxAdapter(child: RecommendedSalonsSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: RewardsBanner(),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  const SliverToBoxAdapter(child: TrendingServicesSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  const SliverToBoxAdapter(child: NearbySalonsSection()),
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
              if (widget.showBottomNav)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CustomerBottomNav(),
                ),
              if (kDebugMode) ...[
                Positioned(
                  right: 16,
                  bottom: 170,
                  child: FloatingActionButton.small(
                    heroTag: 'seedCustomerHomeData',
                    backgroundColor: ZuranoCustomerColors.primary,
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await seedCustomerHomeDemoData(
                          ref.read(firestoreProvider),
                        );
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Debug: seedCustomerHomeDemoData finished.',
                            ),
                          ),
                        );
                        await ref
                            .read(customerHomeRepositoryProvider)
                            .debugCustomerHomeCounts(
                              discoveryCountryName: ref.read(
                                customerDiscoveryCountryNameProvider,
                              ),
                            );
                      } catch (e, st) {
                        debugPrint('[CUSTOMER_HOME_SEED] failed: $e\n$st');
                        if (context.mounted) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Debug seed failed: $e')),
                          );
                        }
                      }
                    },
                    child: const Icon(
                      Icons.cloud_upload_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 110,
                  child: FloatingActionButton.small(
                    heroTag: 'repairCustomerHomeData',
                    backgroundColor: ZuranoCustomerColors.textStrong,
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await ref
                            .read(customerHomeRepositoryProvider)
                            .repairCustomerHomeSalonFields();
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Debug: repairCustomerHomeSalonFields finished.',
                            ),
                          ),
                        );
                        await ref
                            .read(customerHomeRepositoryProvider)
                            .debugCustomerHomeCounts(
                              discoveryCountryName: ref.read(
                                customerDiscoveryCountryNameProvider,
                              ),
                            );
                      } catch (e, st) {
                        debugPrint('[CUSTOMER_HOME_REPAIR] failed: $e\n$st');
                        if (context.mounted) {
                          messenger.showSnackBar(
                            SnackBar(content: Text('Debug repair failed: $e')),
                          );
                        }
                      }
                    },
                    child: const Icon(Icons.build_rounded, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
