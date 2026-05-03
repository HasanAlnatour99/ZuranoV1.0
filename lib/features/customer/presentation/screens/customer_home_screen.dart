import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/utils/currency_for_country.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bar_leading_back.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_fade_in.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_notification_badge.dart';
import '../../../../core/widgets/customer_discovery_header.dart';
import '../../../../core/widgets/customer_discovery_search_field.dart';
import '../../../../core/widgets/customer_discovery_shell.dart';
import '../../../../core/widgets/customer_home_ambient_background.dart';
import '../../../../core/widgets/customer_home_skeleton.dart';
import '../../../../core/widgets/customer_promo_banner_card.dart';
import '../../../../core/widgets/customer_quick_service_tile.dart';
import '../../../../core/widgets/customer_salon_highlight_card.dart';
import '../../../../core/widgets/customer_section_row_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/customer_salon_streams_provider.dart';
import '../../../../providers/notification_providers.dart';
import '../../../../providers/auth_session_actions.dart';
import '../../../../providers/session_provider.dart';
import '../../../salon/data/models/salon.dart';
import '../../../services/data/models/service.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

String _customerTimeGreeting(AppLocalizations l10n) {
  final h = DateTime.now().hour;
  if (h < 12) {
    return l10n.customerDiscoveryGoodMorning;
  }
  if (h < 17) {
    return l10n.customerDiscoveryGoodAfternoon;
  }
  return l10n.customerDiscoveryGoodEvening;
}

bool _isPermissionDeniedError(Object error) {
  return error is FirebaseException && error.code == 'permission-denied';
}

enum _CustomerHomeMenuAction { settings, myBookings, signOut }

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  final _searchController = TextEditingController();
  String? _categoryFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _distinctCategories(List<Salon> salons) {
    final set = <String>{};
    for (final s in salons) {
      final c = s.category?.trim();
      if (c != null && c.isNotEmpty) {
        set.add(c);
      }
    }
    final out = set.toList()..sort();
    return out;
  }

  List<Widget> _quickServiceSlivers(
    AppLocalizations l10n,
    List<Salon> salonsForCurrency,
  ) {
    final servicesAsync = ref.watch(customerDiscoveryServicesProvider);
    final locale = Localizations.localeOf(context);
    /// Discovery lists multiple salons; the user's address/onboarding country
    /// must not drive per-salon prices (e.g. CA → CAD for a non‑Canadian salon).
    const unknownSalonCurrencyFallback = 'USD';
    final currencyBySalon = <String, String>{};
    for (final s in salonsForCurrency) {
      final code = resolvedSalonMoneyCurrency(
        salonCurrencyCode: s.currencyCode,
        salonCountryIso: s.countryCode,
      );
      currencyBySalon[s.id] = code;
      final sid = s.salonId.trim();
      if (sid.isNotEmpty) {
        currencyBySalon[sid] = code;
      }
    }

    return servicesAsync.when(
      data: (services) {
        if (services.isEmpty) {
          return const <Widget>[];
        }
        return [
          SliverToBoxAdapter(
            child: CustomerSectionRowHeader(
              title: l10n.customerSectionQuickServices,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 232,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                ),
                children: _interleaveQuickTiles(
                  services,
                  l10n,
                  locale,
                  currencyBySalon,
                  unknownSalonCurrencyFallback,
                ),
              ),
            ),
          ),
        ];
      },
      loading: () => [
        SliverToBoxAdapter(
          child: CustomerSectionRowHeader(
            title: l10n.customerSectionQuickServices,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 120,
            child: Center(child: AppLoadingIndicator(size: 36)),
          ),
        ),
      ],
      error: (_, _) => const <Widget>[],
    );
  }

  List<Widget> _interleaveQuickTiles(
    List<SalonService> services,
    AppLocalizations l10n,
    Locale locale,
    Map<String, String> currencyBySalon,
    String fallbackCurrencyCode,
  ) {
    final out = <Widget>[];
    for (var i = 0; i < services.length; i++) {
      if (i > 0) {
        out.add(const SizedBox(width: AppSpacing.medium));
      }
      final s = services[i];
      final code =
          currencyBySalon[s.salonId.trim()] ?? fallbackCurrencyCode;
      out.add(
        CustomerQuickServiceTile(
          title: s.serviceName,
          priceLabel: formatAppMoney(s.price, code, locale),
          durationLabel: l10n.bookingDurationMinutes(s.durationMinutes),
          icon: AppIcons.spa_outlined,
          onTap: () => context.push(AppRoutes.customerSalon(s.salonId)),
        ),
      );
    }
    return out;
  }

  List<Salon> _filteredSalons(List<Salon> salons, String qLower) {
    var filtered = qLower.isEmpty
        ? salons
        : salons
              .where(
                (s) =>
                    s.name.toLowerCase().contains(qLower) ||
                    s.address.toLowerCase().contains(qLower),
              )
              .toList(growable: false);
    if (_categoryFilter != null) {
      filtered = filtered
          .where((s) => (s.category ?? '').trim() == _categoryFilter)
          .toList(growable: false);
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionUserProvider);
    final salonsAsync = ref.watch(activeSalonsStreamProvider);
    final servicesAsync = ref.watch(customerDiscoveryServicesProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final q = _searchController.text.trim().toLowerCase();

    return sessionAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: AppLoadingIndicator(size: 40))),
      error: (_, _) => Scaffold(body: Center(child: Text(l10n.genericError))),
      data: (user) {
        if (user == null) {
          return const Scaffold(body: SizedBox.shrink());
        }

        final displayName = user.name.trim().isEmpty
            ? l10n.customerGuestName
            : user.name.trim();
        final salonsForPromo = salonsAsync.asData?.value ?? const <Salon>[];
        final salonCount = salonsForPromo.length;

        return Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            leading: const AppBarLeadingBack(),
            automaticallyImplyLeading: false,
            backgroundColor: CustomerHomeAmbientBackground.appBarTint(scheme),
            surfaceTintColor: Colors.transparent,
            foregroundColor: scheme.onSurface,
            iconTheme: IconThemeData(color: scheme.onSurface),
            titleTextStyle: theme.textTheme.titleLarge?.copyWith(
              color: scheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            title: Text(l10n.customerDiscoverTitle),
            actions: [
              PopupMenuButton<_CustomerHomeMenuAction>(
                tooltip: l10n.customerHomeMenuTooltip,
                icon: const Icon(AppIcons.more_horiz_rounded),
                onSelected: (action) async {
                  switch (action) {
                    case _CustomerHomeMenuAction.settings:
                      if (!context.mounted) {
                        return;
                      }
                      await context.push(AppRoutes.settings);
                    case _CustomerHomeMenuAction.myBookings:
                      if (!context.mounted) {
                        return;
                      }
                      await context.push(AppRoutes.customerMyBookings);
                    case _CustomerHomeMenuAction.signOut:
                      if (!context.mounted) {
                        return;
                      }
                      await performAppSignOut(context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _CustomerHomeMenuAction.settings,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        AppIcons.settings_outlined,
                        color: scheme.onSurface,
                      ),
                      title: Text(l10n.appSettingsTitle),
                    ),
                  ),
                  PopupMenuItem(
                    value: _CustomerHomeMenuAction.myBookings,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        AppIcons.event_note_outlined,
                        color: scheme.onSurface,
                      ),
                      title: Text(l10n.customerMyBookings),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: _CustomerHomeMenuAction.signOut,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        AppIcons.logout_rounded,
                        color: scheme.error,
                      ),
                      title: Text(
                        l10n.customerSignOut,
                        style: TextStyle(
                          color: scheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: CustomerHomeAmbientBackground(
            child: AppFadeIn(
              child: CustomerDiscoveryShell(
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: CustomerDiscoveryHeader(
                        timeGreeting: _customerTimeGreeting(l10n),
                        headline: l10n.customerDiscoveryNameWave(displayName),
                        brandInitial: displayName,
                        trailing: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: scheme.primaryContainer,
                            foregroundColor: scheme.onPrimaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.large,
                              ),
                            ),
                          ),
                          tooltip: l10n.customerNotificationsTooltip,
                          onPressed: () =>
                              context.push(AppRoutes.notifications),
                          icon: Builder(
                            builder: (context) {
                              final n = ref.watch(
                                unreadNotificationCountProvider,
                              );
                              return AppNotificationBadge(
                                count: n,
                                child: const Icon(
                                  AppIcons.notifications_outlined,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.large,
                          AppSpacing.small,
                          AppSpacing.large,
                          AppSpacing.medium,
                        ),
                        child: CustomerDiscoverySearchField(
                          controller: _searchController,
                          hintText: l10n.customerSearchHint,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: salonsAsync.maybeWhen(
                        data: (salons) {
                          final filtered = _filteredSalons(salons, q);
                          return CustomerPromoBannerCard(
                            eyebrow: l10n.customerPromoSalonEyebrow(salonCount),
                            title: servicesAsync.when(
                              data: (list) =>
                                  l10n.customerPromoServicesTitle(list.length),
                              loading: () => l10n.loadingPlaceholder,
                              error: (_, _) => l10n.genericError,
                            ),
                            ctaLabel: l10n.customerPromoCta,
                            onCtaPressed: filtered.isNotEmpty
                                ? () => context.push(
                                    AppRoutes.customerSalon(filtered.first.id),
                                  )
                                : null,
                          );
                        },
                        orElse: () => CustomerPromoBannerCard(
                          eyebrow: l10n.customerPromoSalonEyebrow(salonCount),
                          title: servicesAsync.when(
                            data: (list) =>
                                l10n.customerPromoServicesTitle(list.length),
                            loading: () => l10n.loadingPlaceholder,
                            error: (_, _) => l10n.genericError,
                          ),
                          ctaLabel: l10n.customerPromoCta,
                          onCtaPressed: null,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.medium),
                    ),
                    ..._quickServiceSlivers(l10n, salonsForPromo),
                    SliverToBoxAdapter(
                      child: salonsAsync.maybeWhen(
                        data: (salons) {
                          final cats = _distinctCategories(salons);
                          if (cats.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.large,
                              AppSpacing.medium,
                              AppSpacing.large,
                              AppSpacing.small,
                            ),
                            child: SizedBox(
                              height: 44,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      end: AppSpacing.small,
                                    ),
                                    child: FilterChip(
                                      label: Text(l10n.customerCategoryAll),
                                      selected: _categoryFilter == null,
                                      onSelected: (_) => setState(() {
                                        _categoryFilter = null;
                                      }),
                                    ),
                                  ),
                                  ...cats.map(
                                    (c) => Padding(
                                      padding: const EdgeInsetsDirectional.only(
                                        end: AppSpacing.small,
                                      ),
                                      child: FilterChip(
                                        label: Text(c),
                                        selected: _categoryFilter == c,
                                        onSelected: (_) => setState(() {
                                          _categoryFilter = c;
                                        }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: CustomerSectionRowHeader(
                        title: l10n.customerSectionNearbySalons,
                      ),
                    ),
                    ...salonsAsync.when<List<Widget>>(
                      data: (salons) {
                        final filtered = _filteredSalons(salons, q);
                        if (filtered.isEmpty) {
                          return [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.large),
                                child: AppEmptyState(
                                  title: l10n.customerHomeEmptyTitle,
                                  message: l10n.customerNoSalons,
                                  icon: AppIcons.storefront_outlined,
                                  centerContent: true,
                                  compactTypography: true,
                                  primaryActionLabel:
                                      q.isNotEmpty || _categoryFilter != null
                                      ? l10n.customerHomeResetFilters
                                      : null,
                                  onPrimaryAction:
                                      q.isNotEmpty || _categoryFilter != null
                                      ? () => setState(() {
                                          _searchController.clear();
                                          _categoryFilter = null;
                                        })
                                      : null,
                                ),
                              ),
                            ),
                          ];
                        }
                        return [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.large,
                              AppSpacing.small,
                              AppSpacing.large,
                              AppSpacing.large,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                i,
                              ) {
                                final s = filtered[i];
                                final isLast = i == filtered.length - 1;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: isLast ? 0 : AppSpacing.medium,
                                  ),
                                  child: CustomerSalonHighlightCard(
                                    salon: s,
                                    badgeLabel: s.isActive
                                        ? l10n.customerSalonBadgeOpen
                                        : null,
                                    metadataLine: s.phone.trim().isNotEmpty
                                        ? s.phone.trim()
                                        : null,
                                    onTap: () => context.push(
                                      AppRoutes.customerSalon(s.id),
                                    ),
                                  ),
                                );
                              }, childCount: filtered.length),
                            ),
                          ),
                        ];
                      },
                      loading: () => [
                        const SliverFillRemaining(
                          child: CustomerHomeSkeleton(),
                        ),
                      ],
                      error: (error, _) => [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.large,
                              AppSpacing.small,
                              AppSpacing.large,
                              AppSpacing.large,
                            ),
                            child: AppEmptyState(
                              title: l10n.customerHomeEmptyTitle,
                              message: _isPermissionDeniedError(error)
                                  ? l10n.customerNoSalons
                                  : l10n.genericError,
                              icon: AppIcons.storefront_outlined,
                              centerContent: true,
                              compactTypography: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height:
                            MediaQuery.paddingOf(context).bottom +
                            AppSpacing.large,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
