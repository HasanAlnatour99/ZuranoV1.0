import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart'
    show AppRouteNames, AppRoutes;
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/slide_to_book_button.dart';
import '../../../../shared/widgets/zurano_service_category_icon.dart';
import '../../application/customer_booking_availability_providers.dart';
import '../../application/customer_salon_profile_providers.dart';
import '../../data/models/customer_booking_settings.dart';
import '../../data/repositories/customer_salon_profile_repository.dart';
import '../../data/models/customer_review_model.dart';
import '../../data/models/customer_service_public_model.dart';
import '../../data/models/customer_team_member_public_model.dart';
import '../../data/models/salon_public_model.dart';
import '../widgets/customer_gradient_scaffold.dart';
import '../widgets/customer_review_card.dart';
import '../widgets/customer_team_member_card.dart';

/// Two-letter initials for the salon summary tile (e.g. "Golden Xx" → GX).
String _salonInitials(String salonName) {
  final name = salonName.trim();
  if (name.isEmpty) {
    return '?';
  }
  final parts = name
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .toList(growable: false);
  String headUpper(String s) {
    if (s.isEmpty) {
      return '';
    }
    final r = s.runes.first;
    return String.fromCharCode(r).toUpperCase();
  }

  if (parts.length >= 2) {
    return '${headUpper(parts[0])}${headUpper(parts[1])}';
  }
  final w = parts.first;
  final runes = w.runes.toList();
  if (runes.length >= 2) {
    return '${String.fromCharCode(runes[0]).toUpperCase()}'
        '${String.fromCharCode(runes[1]).toUpperCase()}';
  }
  return String.fromCharCode(runes.first).toUpperCase();
}

/// Prefer denormalized `salon.startingPrice`; if unset, use lowest priced
/// active customer-visible service from `publicSalons/{salonId}/services`.
double resolveStartingPrice(
  SalonPublicModel salon,
  List<CustomerServicePublicModel> services,
) {
  if (salon.startingPrice > 0) {
    return salon.startingPrice;
  }

  final prices = services
      .where((s) => s.isActive && s.isCustomerVisible && s.price > 0)
      .map((s) => s.price)
      .toList();

  if (prices.isEmpty) {
    return 0;
  }

  prices.sort();
  return prices.first;
}

class SalonProfileScreen extends ConsumerStatefulWidget {
  const SalonProfileScreen({super.key, required this.salonId});

  final String salonId;

  @override
  ConsumerState<SalonProfileScreen> createState() => _SalonProfileScreenState();
}

class _SalonProfileScreenState extends ConsumerState<SalonProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _favoriteLocal = false;
  String? _selectedServiceId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        return;
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<String, List<CustomerServicePublicModel>> _groupServices(
    List<CustomerServicePublicModel> list,
    AppLocalizations l10n,
  ) {
    final map = <String, List<CustomerServicePublicModel>>{};
    for (final s in list) {
      final key = _categoryGroupKey(s, l10n);
      map.putIfAbsent(key, () => []).add(s);
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }

  String _categoryGroupKey(
    CustomerServicePublicModel s,
    AppLocalizations l10n,
  ) {
    final label = s.categoryLabel.trim();
    if (label.isNotEmpty) {
      return label;
    }
    final cat = s.category.trim();
    if (cat.isNotEmpty) {
      return cat;
    }
    return l10n.ownerServiceCategoryOther;
  }

  String _genderLabel(AppLocalizations l10n, String? raw) {
    final g = raw?.trim().toLowerCase();
    if (g == null || g.isEmpty) {
      return l10n.placeCardDistanceUnavailable;
    }
    switch (g) {
      case 'men':
      case 'male':
      case 'gentlemen':
        return l10n.ownerCustomerBookingGenderMen;
      case 'ladies':
      case 'women':
      case 'female':
        return l10n.ownerCustomerBookingGenderLadies;
      case 'unisex':
        return l10n.ownerCustomerBookingGenderUnisex;
      default:
        final pretty = g.length == 1
            ? g.toUpperCase()
            : '${g[0].toUpperCase()}${g.substring(1)}';
        return l10n.customerProfileGenderValue(pretty);
    }
  }

  bool _bookingEnabled(AsyncValue<CustomerBookingSettings> bookingPolicyAsync) {
    return bookingPolicyAsync.maybeWhen(
      data: (p) => p.enabled,
      orElse: () => false,
    );
  }

  bool _hasVisibleServices(
    AsyncValue<List<CustomerServicePublicModel>> servicesAsync,
  ) {
    return servicesAsync.maybeWhen(
      data: (list) => list.isNotEmpty,
      orElse: () => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sid = widget.salonId.trim();
    final profileAsync = ref.watch(customerSalonProfileProvider(sid));
    final bookingPolicyAsync = ref.watch(
      customerPublicBookingFlowSettingsProvider(sid),
    );
    final servicesAsync = ref.watch(customerVisibleServicesProvider(sid));
    final teamAsync = ref.watch(customerBookableTeamMembersProvider(sid));
    final reviewsAsync = ref.watch(customerSalonReviewsProvider(sid));
    final repo = ref.watch(customerSalonProfileRepositoryProvider);

    final ctaEnabled = profileAsync.maybeWhen(
      data: (salon) =>
          salon != null &&
          _bookingEnabled(bookingPolicyAsync) &&
          _hasVisibleServices(servicesAsync),
      orElse: () => false,
    );

    return CustomerGradientScaffold(
      bottomNavigationBar: profileAsync.maybeWhen(
        data: (salon) {
          if (salon == null) {
            return null;
          }
          final bookingOpen = _bookingEnabled(bookingPolicyAsync);
          return _StickyBookingBar(
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: AppSpacing.medium),
              child: SlideToBookButton(
                enabled: ctaEnabled,
                text: bookingOpen
                    ? l10n.customerProfileSlideToBookAppointment
                    : l10n.customerBookingClosedTitle,
                loadingText: l10n.customerProfileOpeningBooking,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                ),
                onCompleted: () async {
                  context.pushNamed(
                    AppRouteNames.customerServiceSelection,
                    pathParameters: {'salonId': sid},
                    queryParameters: _selectedServiceId == null
                        ? {}
                        : {'serviceId': _selectedServiceId!},
                  );
                },
              ),
            ),
          );
        },
        orElse: () => null,
      ),
      child: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Text(l10n.genericError),
          ),
        ),
        data: (salon) {
          if (salon == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.customerProfileSalonNotFound,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.large),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: Text(l10n.customerBackHome),
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildBody(
            context,
            l10n,
            salon,
            servicesAsync,
            teamAsync,
            reviewsAsync,
            repo,
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    SalonPublicModel salon,
    AsyncValue<List<CustomerServicePublicModel>> servicesAsync,
    AsyncValue<List<CustomerTeamMemberPublicModel>> teamAsync,
    AsyncValue<List<CustomerReviewModel>> reviewsAsync,
    CustomerSalonProfileRepository repo,
  ) {
    final locale = Localizations.localeOf(context);

    void share() => repo.shareSalon(salon);

    void onBack() {
      if (context.canPop()) {
        context.pop();
        return;
      }
      context.go(AppRoutes.customerSalonDiscovery);
    }

    final servicesList = servicesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => <CustomerServicePublicModel>[],
    );
    final resolvedStartingPrice = resolveStartingPrice(salon, servicesList);

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: _PremiumHeroSection(
            salon: salon,
            resolvedStartingPrice: resolvedStartingPrice,
            l10n: l10n,
            locale: locale,
            favoriteSelected: _favoriteLocal,
            onBack: onBack,
            onFavoriteTap: () {
              setState(() => _favoriteLocal = !_favoriteLocal);
            },
            onShareTap: share,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.medium),
            child: _PremiumQuickActionsRow(
              callLabel: l10n.customerProfileActionCall,
              whatsappLabel: l10n.customerProfileActionWhatsApp,
              mapLabel: l10n.customerProfileActionMap,
              shareLabel: l10n.customerProfileActionShare,
              onCall: () => repo.openPhone(salon.phone),
              onWhatsApp: () =>
                  repo.openWhatsApp(salon.whatsapp ?? salon.phone),
              onMap: () {
                final lat = salon.latitude;
                final lng = salon.longitude;
                if (lat != null && lng != null) {
                  repo.openMap(lat, lng);
                }
              },
              onShare: share,
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabsHeaderDelegate(
            tabController: _tabController,
            tabs: [
              Tab(text: l10n.customerProfileTabServices),
              Tab(text: l10n.customerProfileTabTeam),
              Tab(text: l10n.customerProfileTabReviews),
              Tab(text: l10n.customerProfileTabAbout),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.medium,
              AppSpacing.large,
              170,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey<int>(_tabController.index),
                child: _tabBody(
                  context,
                  l10n,
                  salon,
                  servicesAsync,
                  teamAsync,
                  reviewsAsync,
                  locale,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabBody(
    BuildContext context,
    AppLocalizations l10n,
    SalonPublicModel salon,
    AsyncValue<List<CustomerServicePublicModel>> servicesAsync,
    AsyncValue<List<CustomerTeamMemberPublicModel>> teamAsync,
    AsyncValue<List<CustomerReviewModel>> reviewsAsync,
    Locale locale,
  ) {
    switch (_tabController.index) {
      case 0:
        return servicesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.large),
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (_, _) => Text(l10n.genericError),
          data: (list) {
            if (list.isEmpty) {
              return _PremiumEmptyState(
                message: l10n.customerProfileEmptyServices,
              );
            }
            final grouped = _groupServices(list, l10n);
            final lang = locale.languageCode;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in grouped.entries) ...[
                  _CategoryTitle(title: entry.key),
                  ...entry.value.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
                      child: _PremiumServiceCard(
                        service: s,
                        currencyCode: salon.currencyCode,
                        locale: locale,
                        languageCode: lang,
                        selected: _selectedServiceId == s.id,
                        onTap: () {
                          setState(() {
                            _selectedServiceId = _selectedServiceId == s.id
                                ? null
                                : s.id;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                ],
              ],
            );
          },
        );
      case 1:
        return teamAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.large),
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (_, _) => Text(l10n.genericError),
          data: (list) {
            if (list.isEmpty) {
              return _PremiumEmptyState(message: l10n.customerProfileEmptyTeam);
            }
            return Column(
              children: [
                for (final m in list) CustomerTeamMemberCard(member: m),
              ],
            );
          },
        );
      case 2:
        return reviewsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.large),
            child: Center(child: CircularProgressIndicator.adaptive()),
          ),
          error: (_, _) => Text(l10n.genericError),
          data: (list) {
            if (list.isEmpty) {
              return _PremiumEmptyState(
                message: l10n.customerProfileEmptyReviews,
              );
            }
            return Column(
              children: [for (final r in list) CustomerReviewCard(review: r)],
            );
          },
        );
      default:
        return _AboutTab(
          l10n: l10n,
          salon: salon,
          genderLabel: _genderLabel(l10n, salon.genderTarget),
        );
    }
  }
}

// --- Hero & summary ---------------------------------------------------------

class _PremiumHeroSection extends StatelessWidget {
  const _PremiumHeroSection({
    required this.salon,
    required this.resolvedStartingPrice,
    required this.l10n,
    required this.locale,
    required this.favoriteSelected,
    required this.onBack,
    required this.onFavoriteTap,
    required this.onShareTap,
  });

  final SalonPublicModel salon;
  final double resolvedStartingPrice;
  final AppLocalizations l10n;
  final Locale locale;
  final bool favoriteSelected;
  final VoidCallback onBack;
  final VoidCallback onFavoriteTap;
  final VoidCallback onShareTap;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: topInset + 390,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 120,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.xlarge),
              ),
              child: _HeroImage(url: salon.coverImageUrl),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundHeroButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: onBack,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RoundHeroButton(
                        icon: favoriteSelected
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        onPressed: onFavoriteTap,
                      ),
                      const SizedBox(width: AppSpacing.small),
                      _RoundHeroButton(
                        icon: Icons.share_rounded,
                        onPressed: onShareTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.large,
            right: AppSpacing.large,
            bottom: 0,
            child: _PremiumSummaryCard(
              salon: salon,
              resolvedStartingPrice: resolvedStartingPrice,
              initials: _salonInitials(salon.salonName),
              l10n: l10n,
              locale: locale,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final u = url?.trim();
    if (u != null && u.isNotEmpty) {
      return Image.network(
        u,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const _HeroFallback(),
      );
    }
    return const _HeroFallback();
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B2FF7), Color(0xFF9B51E0), Color(0xFFB794F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.storefront_rounded,
        size: 72,
        color: Colors.white.withValues(alpha: 0.85),
      ),
    );
  }
}

class _RoundHeroButton extends StatelessWidget {
  const _RoundHeroButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: AppColorsLight.textPrimary),
        ),
      ),
    );
  }
}

class _PremiumSummaryCard extends StatelessWidget {
  const _PremiumSummaryCard({
    required this.salon,
    required this.resolvedStartingPrice,
    required this.initials,
    required this.l10n,
    required this.locale,
  });

  final SalonPublicModel salon;
  final double resolvedStartingPrice;
  final String initials;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final formattedFromPrice = resolvedStartingPrice > 0
        ? formatMoney(resolvedStartingPrice, salon.currencyCode, locale)
        : '';

    return Material(
      elevation: 8,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(AppRadius.profileCard),
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LogoTile(initials: initials),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    salon.salonName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppBrandColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    salon.area,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColorsLight.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Wrap(
                    spacing: AppSpacing.small,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _StatusChip(
                        open: salon.isOpen,
                        openLabel: l10n.customerSalonOpenNowBadge,
                        closedLabel: l10n.customerSalonClosedBadge,
                      ),
                      if (salon.ratingAverage > 0)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              salon.ratingAverage.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        )
                      else
                        Text(
                          l10n.customerSalonRatingNew,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColorsLight.textSecondary,
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.customerProfileWorkingHoursPlaceholder,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColorsLight.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resolvedStartingPrice <= 0
                        ? l10n.customerSalonPricesAppearSoon
                        : l10n.customerSalonStartingFrom(formattedFromPrice),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppBrandColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoTile extends StatelessWidget {
  const _LogoTile({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final label = initials.trim().isEmpty ? '?' : initials.trim();
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFC4B5FD).withValues(alpha: 0.35),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label.length > 2 ? label.substring(0, 2) : label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: const Color(0xFFE9D5FF),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.open,
    required this.openLabel,
    required this.closedLabel,
  });

  final bool open;
  final String openLabel;
  final String closedLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: open
            ? const Color(0xFFDCFCE7)
            : AppColorsLight.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        open ? openLabel : closedLabel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: open ? const Color(0xFF166534) : AppColorsLight.textSecondary,
        ),
      ),
    );
  }
}

// --- Quick actions ----------------------------------------------------------

class _PremiumQuickActionsRow extends StatelessWidget {
  const _PremiumQuickActionsRow({
    required this.callLabel,
    required this.whatsappLabel,
    required this.mapLabel,
    required this.shareLabel,
    required this.onCall,
    required this.onWhatsApp,
    required this.onMap,
    required this.onShare,
  });

  final String callLabel;
  final String whatsappLabel;
  final String mapLabel;
  final String shareLabel;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onMap;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickAction(
            icon: Icons.call_outlined,
            label: callLabel,
            onTap: onCall,
          ),
          _QuickAction(
            icon: Icons.chat_outlined,
            label: whatsappLabel,
            onTap: onWhatsApp,
          ),
          _QuickAction(icon: Icons.map_outlined, label: mapLabel, onTap: onMap),
          _QuickAction(
            icon: Icons.ios_share_rounded,
            label: shareLabel,
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppBrandColors.secondary,
                border: Border.all(
                  color: AppBrandColors.primary.withValues(alpha: 0.12),
                ),
              ),
              child: Icon(icon, color: AppBrandColors.primary, size: 27),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColorsLight.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Tabs -------------------------------------------------------------------

class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabsHeaderDelegate({required this.tabController, required this.tabs});

  final TabController tabController;
  final List<Tab> tabs;

  static const double _height = 56;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColorsLight.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
      alignment: Alignment.center,
      child: TabBar(
        controller: tabController,
        dividerColor: Colors.transparent,
        indicatorColor: AppBrandColors.primary,
        indicatorWeight: 3,
        labelColor: AppBrandColors.primary,
        unselectedLabelColor: AppColorsLight.textSecondary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        tabs: tabs,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate oldDelegate) {
    return tabController != oldDelegate.tabController;
  }
}

// --- Services ---------------------------------------------------------------

class _CategoryTitle extends StatelessWidget {
  const _CategoryTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColorsLight.textPrimary,
        ),
      ),
    );
  }
}

class _PremiumServiceCard extends StatelessWidget {
  const _PremiumServiceCard({
    required this.service,
    required this.currencyCode,
    required this.locale,
    required this.languageCode,
    required this.selected,
    required this.onTap,
  });

  final CustomerServicePublicModel service;
  final String currencyCode;
  final Locale locale;
  final String languageCode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final price = formatMoney(service.price, currencyCode, locale);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: selected
              ? AppBrandColors.primary
              : AppColorsLight.outlineVariant,
          width: selected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ZuranoServiceCategoryIcon(
                  categoryKey: service.resolvedCategoryKeyForIcon,
                  iconKey: service.iconKey,
                  size: 48,
                  iconSize: 24,
                  borderRadius: AppRadius.medium,
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.localizedTitleForLanguageCode(languageCode),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColorsLight.textPrimary,
                        ),
                      ),
                      if (service.description != null &&
                          service.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          service.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColorsLight.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: AppColorsLight.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.customerProfileMinutesShort(
                            service.durationMinutes,
                          ),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColorsLight.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppBrandColors.primary,
                      ),
                    ),
                  ],
                ),
                if (selected)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppBrandColors.primary,
                      size: 26,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumEmptyState extends StatelessWidget {
  const _PremiumEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.large),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColorsLight.textSecondary),
        ),
      ),
    );
  }
}

// --- Bottom bar -------------------------------------------------------------

class _StickyBookingBar extends StatelessWidget {
  const _StickyBookingBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColorsLight.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// --- About ------------------------------------------------------------------

class _AboutTab extends StatelessWidget {
  const _AboutTab({
    required this.l10n,
    required this.salon,
    required this.genderLabel,
  });

  final AppLocalizations l10n;
  final SalonPublicModel salon;
  final String genderLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PremiumInfoRow(
          label: l10n.customerProfileAboutArea,
          value: salon.area,
        ),
        _PremiumInfoRow(
          label: l10n.customerProfileAboutPhone,
          value: salon.phone?.trim().isNotEmpty == true ? salon.phone! : '—',
        ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          l10n.customerProfileAboutGender,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColorsLight.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(genderLabel, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.large),
        Text(
          l10n.customerProfileMapPreviewPlaceholder,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColorsLight.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.small),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.map_outlined,
            size: 40,
            color: AppColorsLight.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PremiumInfoRow extends StatelessWidget {
  const _PremiumInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColorsLight.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
