import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart'
    show AppRouteNames, AppRoutes;
import '../../../../core/session/app_session_status.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import '../../application/customer_salon_providers.dart';
import '../widgets/customer_gradient_scaffold.dart';
import '../widgets/salon_public_card.dart';

class SalonDiscoveryScreen extends ConsumerStatefulWidget {
  const SalonDiscoveryScreen({super.key, this.showBottomNavigationBar = true});

  final bool showBottomNavigationBar;

  @override
  ConsumerState<SalonDiscoveryScreen> createState() =>
      _SalonDiscoveryScreenState();
}

class _SalonDiscoveryScreenState extends ConsumerState<SalonDiscoveryScreen> {
  final _searchController = TextEditingController();
  final _bookmarked = <String>{};

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(customerSalonSearchQueryProvider);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    ref
        .read(customerSalonSearchQueryProvider.notifier)
        .setQuery(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFilter(
    CustomerSalonDiscoveryFilters Function(CustomerSalonDiscoveryFilters) next,
  ) {
    final current = ref.read(customerSalonDiscoveryFiltersProvider);
    ref
        .read(customerSalonDiscoveryFiltersProvider.notifier)
        .setFilters(next(current));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final salonsAsync = ref.watch(filteredPublicSalonsProvider);
    final filters = ref.watch(customerSalonDiscoveryFiltersProvider);
    final session = ref.watch(appSessionBootstrapProvider);

    return CustomerGradientScaffold(
      bottomNavigationBar: widget.showBottomNavigationBar
          ? _CustomerDiscoveryBottomBar(session: session, l10n: l10n)
          : null,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.medium,
                  AppSpacing.large,
                  AppSpacing.small,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.customerSalonDiscoveryTitle,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColorsLight.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.customerSalonDiscoverySubtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColorsLight.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.customerNotificationsTooltip,
                      onPressed: () {},
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                  vertical: AppSpacing.small,
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.customerSalonDiscoverySearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: scheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.large),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.large),
                      borderSide: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.medium,
                      vertical: AppSpacing.small,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.large,
                  ),
                  children: [
                    _FilterChip(
                      label: l10n.customerSalonFilterNearby,
                      selected: filters.nearby,
                      onTap: () =>
                          _toggleFilter((f) => f.copyWith(nearby: !f.nearby)),
                    ),
                    _FilterChip(
                      label: l10n.customerSalonFilterOpenNow,
                      selected: filters.openNow,
                      onTap: () =>
                          _toggleFilter((f) => f.copyWith(openNow: !f.openNow)),
                    ),
                    _FilterChip(
                      label: l10n.customerSalonFilterTopRated,
                      selected: filters.topRated,
                      onTap: () => _toggleFilter(
                        (f) => f.copyWith(topRated: !f.topRated),
                      ),
                    ),
                    _FilterChip(
                      label: l10n.customerSalonFilterOffers,
                      selected: filters.offers,
                      onTap: () =>
                          _toggleFilter((f) => f.copyWith(offers: !f.offers)),
                    ),
                    _FilterChip(
                      label: l10n.customerSalonFilterLadies,
                      selected: filters.ladies,
                      onTap: () =>
                          _toggleFilter((f) => f.copyWith(ladies: !f.ladies)),
                    ),
                    _FilterChip(
                      label: l10n.customerSalonFilterMen,
                      selected: filters.men,
                      onTap: () =>
                          _toggleFilter((f) => f.copyWith(men: !f.men)),
                    ),
                    _FilterChip(
                      label: l10n.customerSalonFilterUnisex,
                      selected: filters.unisex,
                      onTap: () =>
                          _toggleFilter((f) => f.copyWith(unisex: !f.unisex)),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.large,
                  AppSpacing.large,
                  AppSpacing.small,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.customerSalonDiscoveryNearYou,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(l10n.customerSeeAll),
                    ),
                  ],
                ),
              ),
            ),
            salonsAsync.when(
              data: (salons) {
                if (salons.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xlarge),
                        child: Text(
                          l10n.customerSalonDiscoveryEmpty,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColorsLight.textSecondary),
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.large,
                    0,
                    AppSpacing.large,
                    AppSpacing.xlarge,
                  ),
                  sliver: SliverList.separated(
                    itemCount: salons.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.medium),
                    itemBuilder: (context, i) {
                      final s = salons[i];
                      return SalonPublicCard(
                        salon: s,
                        bookmarked: _bookmarked.contains(s.id),
                        onBookmarkTap: () {
                          setState(() {
                            if (_bookmarked.contains(s.id)) {
                              _bookmarked.remove(s.id);
                            } else {
                              _bookmarked.add(s.id);
                            }
                          });
                        },
                        onTap: () {
                          context.pushNamed(
                            AppRouteNames.customerSalonProfile,
                            pathParameters: {'salonId': s.id},
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                ),
                sliver: SliverList.separated(
                  itemCount: 5,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.medium),
                  itemBuilder: (_, _) => const _SalonCardSkeleton(),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: _DiscoveryError(
                  message: _errorMessage(context, e),
                  onRetry: () => ref.invalidate(publicSalonsProvider),
                  l10n: l10n,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _errorMessage(BuildContext context, Object e) {
    if (e is FirebaseException && e.code == 'permission-denied') {
      return AppLocalizations.of(
        context,
      )!.customerSalonDiscoveryErrorPermission;
    }
    return AppLocalizations.of(context)!.genericError;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.small),
      child: Material(
        color: selected
            ? AppBrandColors.primary.withValues(alpha: 0.12)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected
                    ? AppBrandColors.primary
                    : AppColorsLight.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SalonCardSkeleton extends StatelessWidget {
  const _SalonCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 108,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.xlarge),
      ),
    );
  }
}

class _DiscoveryError extends StatelessWidget {
  const _DiscoveryError({
    required this.message,
    required this.onRetry,
    required this.l10n,
  });

  final String message;
  final VoidCallback onRetry;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xlarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.large),
            FilledButton(
              style: CustomerPrimaryButtonStyle.filled(context),
              onPressed: onRetry,
              child: Text(l10n.customerSalonDiscoveryRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerDiscoveryBottomBar extends StatelessWidget {
  const _CustomerDiscoveryBottomBar({
    required this.session,
    required this.l10n,
  });

  final AppSessionState session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 64,
      selectedIndex: 0,
      onDestinationSelected: (i) {
        if (i == 0) {
          return;
        }
        if (i == 1) {
          context.go(AppRoutes.customerMyBooking);
          return;
        }
        if (i == 2) {
          final authed =
              session.status == AppSessionStatus.ready && session.user != null;
          context.go(authed ? AppRoutes.customerHome : AppRoutes.customerAuth);
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.explore_outlined),
          selectedIcon: const Icon(Icons.explore),
          label: l10n.customerSalonDiscoveryNavDiscover,
        ),
        NavigationDestination(
          icon: const Icon(Icons.event_note_outlined),
          selectedIcon: const Icon(Icons.event_note),
          label: l10n.customerSalonDiscoveryNavBookings,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: l10n.customerSalonDiscoveryNavAccount,
        ),
      ],
    );
  }
}
