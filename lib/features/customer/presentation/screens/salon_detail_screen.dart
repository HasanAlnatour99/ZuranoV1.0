import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/utils/currency_for_country.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bar_leading_back.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_fade_in.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../core/widgets/customer_barber_card.dart';
import '../../../../core/widgets/customer_service_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/customer_salon_streams_provider.dart';
import '../../../bookings/data/models/barber_metrics.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

class SalonDetailScreen extends ConsumerWidget {
  const SalonDetailScreen({super.key, required this.salonId});

  final String salonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final salonAsync = ref.watch(customerSalonStreamProvider(salonId));
    final servicesAsync = ref.watch(
      customerSalonServicesStreamProvider(salonId),
    );
    final barbersAsync = ref.watch(customerSalonBarbersStreamProvider(salonId));
    final barberMetricsAsync = ref.watch(
      customerSalonBarberMetricsMapProvider(salonId),
    );
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLeadingBack(),
        automaticallyImplyLeading: false,
        title: Text(l10n.customerSalonDetails),
      ),
      body: salonAsync.when(
        loading: () => const Center(child: AppLoadingIndicator(size: 40)),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: AppEmptyState(
              title: l10n.customerSalonDetails,
              message: l10n.genericError,
              icon: AppIcons.cloud_off_outlined,
            ),
          ),
        ),
        data: (salon) {
          if (salon == null) {
            return Center(child: Text(l10n.customerSalonNotFound));
          }
          final moneyCode = resolvedSalonMoneyCurrency(
            salonCurrencyCode: salon.currencyCode,
            salonCountryIso: salon.countryCode,
          );
          return AppFadeIn(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.large),
              children: [
                AppSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        salon.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        salon.address,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      if (salon.phone.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.medium),
                        Row(
                          children: [
                            Icon(
                              AppIcons.phone_outlined,
                              size: 20,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.small),
                            Text(
                              salon.phone,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.large),
                      AppPrimaryButton(
                        label: l10n.customerBook,
                        onPressed: () =>
                            context.push(AppRoutes.customerSalonBook(salonId)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                Text(
                  l10n.customerServicesPreview,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                servicesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => Text(l10n.genericError),
                  data: (services) {
                    final active = services.where((s) => s.isActive).take(12);
                    if (active.isEmpty) {
                      return Text(
                        l10n.customerNoServicesListed,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      );
                    }
                    return Column(
                      children: active
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.medium,
                              ),
                              child: CustomerServiceCard(
                                title: s.serviceName,
                                subtitle: l10n.customerServiceMeta(
                                  s.durationMinutes,
                                  formatAppMoney(s.price, moneyCode, locale),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.large),
                Text(
                  l10n.customerSectionBarbers,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                barbersAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => Text(l10n.genericError),
                  data: (barbers) {
                    if (barbers.isEmpty) {
                      return Text(
                        l10n.customerNoBarbersDetail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      );
                    }
                    final Map<String, BarberMetrics> metrics =
                        barberMetricsAsync.asData?.value ??
                        <String, BarberMetrics>{};
                    return Column(
                      children: barbers
                          .map(
                            (b) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.medium,
                              ),
                              child: CustomerBarberCard(
                                name: formatTeamMemberName(b.name),
                                subtitle: b.role,
                                showVerifiedBadge: true,
                                completedAppointments:
                                    metrics[b.id]?.completedCount ?? 0,
                                distinctServicesCompleted:
                                    metrics[b.id]?.serviceCompletedCounts.values
                                        .where((v) => v > 0)
                                        .length ??
                                    0,
                                onBookPressed: () => context.push(
                                  AppRoutes.customerSalonBook(salonId),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
