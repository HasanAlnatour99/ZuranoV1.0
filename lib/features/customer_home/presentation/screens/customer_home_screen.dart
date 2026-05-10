import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/customer_location_providers.dart';
import '../theme/zurano_customer_home_design_tokens.dart';
import '../widgets/zurano_available_today_banner.dart';
import '../widgets/zurano_categories_section.dart';
import '../widgets/zurano_customer_bottom_nav.dart';
import '../widgets/zurano_customer_home_header.dart';
import '../widgets/zurano_home_search_bar.dart';
import '../widgets/zurano_nearby_places_section.dart';
import '../widgets/zurano_quick_filter_strip.dart';
import '../widgets/zurano_recent_activity_section.dart';
import '../widgets/zurano_recommended_specialists_section.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final textFactor = mq.textScaler.scale(14) / 14;
    final bottomReserve =
        mq.padding.bottom + (widget.showBottomNav ? 96 : 24) + 24;

    return MediaQuery(
      data: mq.copyWith(
        textScaler: TextScaler.linear(textFactor.clamp(0.92, 1.08)),
      ),
      child: Scaffold(
        backgroundColor: ZuranoCustomerHomeColors.background,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: ZuranoCustomerHomeHeader()),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  const SliverToBoxAdapter(child: ZuranoHomeSearchBar()),
                  const SliverToBoxAdapter(child: ZuranoQuickFilterStrip()),
                  const SliverToBoxAdapter(child: ZuranoCategoriesSection()),
                  const SliverToBoxAdapter(child: ZuranoNearbyPlacesSection()),
                  const SliverToBoxAdapter(child: ZuranoAvailableTodayBanner()),
                  const SliverToBoxAdapter(
                    child: ZuranoRecommendedSpecialistsSection(),
                  ),
                  const SliverToBoxAdapter(child: ZuranoRecentActivitySection()),
                  SliverToBoxAdapter(child: SizedBox(height: bottomReserve)),
                ],
              ),
              if (widget.showBottomNav)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ZuranoCustomerBottomNav(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
