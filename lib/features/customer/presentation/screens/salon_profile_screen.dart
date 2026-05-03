import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart' show AppRouteNames;
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/customer_booking_availability_providers.dart';
import '../../application/customer_salon_profile_providers.dart';
import '../../data/repositories/customer_salon_profile_repository.dart';
import '../../data/models/customer_review_model.dart';
import '../../data/models/customer_service_public_model.dart';
import '../../data/models/customer_team_member_public_model.dart';
import '../../data/models/salon_public_model.dart';
import '../widgets/customer_gradient_scaffold.dart';
import '../widgets/customer_review_card.dart';
import '../widgets/customer_service_list_tile.dart';
import '../widgets/customer_team_member_card.dart';
import '../widgets/salon_profile_header.dart';
import '../widgets/salon_quick_action_row.dart';

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
  ) {
    final map = <String, List<CustomerServicePublicModel>>{};
    for (final s in list) {
      map.putIfAbsent(s.category, () => []).add(s);
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }

  String _genderLabel(AppLocalizations l10n, String? raw) {
    final g = raw?.trim();
    if (g == null || g.isEmpty) {
      return '—';
    }
    final pretty = g.length == 1
        ? g.toUpperCase()
        : '${g[0].toUpperCase()}${g.substring(1).toLowerCase()}';
    return l10n.customerProfileGenderValue(pretty);
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

    return CustomerGradientScaffold(
      bottomNavigationBar: profileAsync.maybeWhen(
        data: (salon) {
          if (salon == null) {
            return null;
          }
          final bookingOpen = bookingPolicyAsync.maybeWhen(
            data: (p) => p.enabled,
            orElse: () => true,
          );
          return SafeArea(
            minimum: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              0,
              AppSpacing.large,
              AppSpacing.medium,
            ),
            child: FilledButton(
              style: CustomerPrimaryButtonStyle.filled(context),
              onPressed: bookingOpen
                  ? () {
                      context.pushNamed(
                        AppRouteNames.customerServiceSelection,
                        pathParameters: {'salonId': sid},
                      );
                    }
                  : null,
              child: Text(
                bookingOpen
                    ? l10n.customerProfileBookAppointment
                    : l10n.customerBookingClosedTitle,
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
    final scheme = Theme.of(context).colorScheme;

    void share() => repo.shareSalon(salon);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 232,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 220,
                  child: SalonProfileHeader(
                    coverImageUrl: salon.coverImageUrl,
                    favoriteSelected: _favoriteLocal,
                    onBack: () => context.pop(),
                    onFavoriteTap: () {
                      setState(() => _favoriteLocal = !_favoriteLocal);
                    },
                    onShareTap: share,
                  ),
                ),
                Positioned(
                  left: AppSpacing.large,
                  right: AppSpacing.large,
                  bottom: 0,
                  child: _ProfileSummaryCard(
                    salon: salon,
                    l10n: l10n,
                    locale: locale,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.large),
            child: SalonQuickActionRow(
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
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.large,
              AppSpacing.large,
              AppSpacing.small,
            ),
            child: Material(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.large),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppBrandColors.primary,
                labelColor: AppBrandColors.primary,
                unselectedLabelColor: AppColorsLight.textSecondary,
                tabs: [
                  Tab(text: l10n.customerProfileTabServices),
                  Tab(text: l10n.customerProfileTabTeam),
                  Tab(text: l10n.customerProfileTabReviews),
                  Tab(text: l10n.customerProfileTabAbout),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.medium,
              AppSpacing.large,
              100,
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
              return Text(
                l10n.customerProfileEmptyServices,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColorsLight.textSecondary,
                ),
              );
            }
            final grouped = _groupServices(list);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in grouped.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.small),
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  ...entry.value.map(
                    (s) => CustomerServiceListTile(
                      service: s,
                      currencyCode: salon.currencyCode,
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
              return Text(
                l10n.customerProfileEmptyTeam,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColorsLight.textSecondary,
                ),
              );
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
              return Text(
                l10n.customerProfileEmptyReviews,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColorsLight.textSecondary,
                ),
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

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.salon,
    required this.l10n,
    required this.locale,
  });

  final SalonPublicModel salon;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fromPrice = formatMoney(salon.startingPrice, salon.currencyCode, locale);

    return Material(
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: salon.isOpen
                        ? const Color(0xFFDCFCE7)
                        : AppColorsLight.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    salon.isOpen
                        ? l10n.customerSalonOpenNowBadge
                        : l10n.customerSalonClosedBadge,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: salon.isOpen
                          ? const Color(0xFF166534)
                          : AppColorsLight.textSecondary,
                    ),
                  ),
                ),
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
                      '${salon.ratingAverage.toStringAsFixed(1)} (${salon.ratingCount})',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
              l10n.customerSalonStartingFrom(fromPrice),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppBrandColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        _aboutRow(context, l10n.customerProfileAboutArea, salon.area),
        _aboutRow(
          context,
          l10n.customerProfileAboutPhone,
          salon.phone?.trim().isNotEmpty == true ? salon.phone! : '—',
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

  Widget _aboutRow(BuildContext context, String label, String value) {
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
