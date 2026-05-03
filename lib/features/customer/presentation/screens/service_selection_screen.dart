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
import '../../application/customer_booking_currency.dart';
import '../../application/customer_booking_draft_provider.dart';
import '../../application/customer_salon_profile_providers.dart';
import '../../data/models/customer_service_public_model.dart';
import '../widgets/booking_summary_bar.dart';
import '../widgets/customer_action_button.dart';
import '../widgets/customer_booking_progress_header.dart';
import '../widgets/customer_gradient_scaffold.dart';
import '../widgets/selectable_customer_service_card.dart';

class ServiceSelectionScreen extends ConsumerStatefulWidget {
  const ServiceSelectionScreen({super.key, required this.salonId});

  final String salonId;

  @override
  ConsumerState<ServiceSelectionScreen> createState() =>
      _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState
    extends ConsumerState<ServiceSelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_ensureDraftForSalon);
  }

  @override
  void didUpdateWidget(covariant ServiceSelectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.salonId != widget.salonId) {
      Future.microtask(_ensureDraftForSalon);
    }
  }

  void _ensureDraftForSalon() {
    if (!mounted) {
      return;
    }
    ref
        .read(customerBookingDraftProvider.notifier)
        .startForSalon(widget.salonId);
  }

  Map<String, List<CustomerServicePublicModel>> _groupServices(
    List<CustomerServicePublicModel> services,
  ) {
    final map = <String, List<CustomerServicePublicModel>>{};
    for (final service in services) {
      map.putIfAbsent(service.category, () => []).add(service);
    }
    final keys = map.keys.toList()..sort();
    return {for (final key in keys) key: map[key]!};
  }

  void _continue(AppLocalizations l10n) {
    final draft = ref.read(customerBookingDraftProvider);
    if (!draft.hasServices) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.customerServiceSelectionRequiredSnack)),
      );
      return;
    }
    context.pushNamed(
      AppRouteNames.customerTeamSelection,
      pathParameters: {'salonId': widget.salonId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bookingPolicyAsync = ref.watch(
      customerPublicBookingFlowSettingsProvider(widget.salonId),
    );
    final servicesAsync = ref.watch(
      customerVisibleServicesProvider(widget.salonId),
    );
    final draft = ref.watch(customerBookingDraftProvider);
    final selectedIds = draft.selectedServices.map((s) => s.id).toSet();
    final moneyCode = watchCustomerSalonMoneyCode(ref, widget.salonId);
    final total = formatMoney(
      draft.totalAmount,
      moneyCode,
      Localizations.localeOf(context),
    );

    return CustomerGradientScaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          0,
          AppSpacing.large,
          AppSpacing.medium,
        ),
        child: BookingSummaryBar(
          title: l10n.customerServiceSelectionSelectedCount(draft.serviceCount),
          subtitle: l10n.customerServiceSelectionSummary(
            draft.durationMinutes,
            total,
          ),
          trailing: CustomerActionButton(
            label: l10n.customerServiceSelectionContinue,
            onPressed:
                bookingPolicyAsync.maybeWhen(
                  data: (p) => p.enabled && draft.hasServices,
                  orElse: () => false,
                )
                ? () => _continue(l10n)
                : null,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.small,
                  AppSpacing.small,
                  AppSpacing.large,
                  AppSpacing.medium,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.customerServiceSelectionTitle,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColorsLight.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.customerServiceSelectionSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColorsLight.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (draft.hasServices)
                      TextButton(
                        onPressed: () => ref
                            .read(customerBookingDraftProvider.notifier)
                            .clearServices(),
                        child: Text(l10n.customerServiceSelectionClear),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                ),
                child: CustomerBookingProgressHeader(
                  stepLabel: l10n.customerServiceSelectionStepLabel,
                  title: l10n.customerServiceSelectionProgressTitle,
                  progress: 0.2,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.large)),
            bookingPolicyAsync.when(
              loading: () => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColorsLight.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              error: (_, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: _ServiceSelectionError(
                  message: l10n.genericError,
                  retryLabel: l10n.customerSalonDiscoveryRetry,
                  onRetry: () => ref.invalidate(
                    customerPublicBookingFlowSettingsProvider(widget.salonId),
                  ),
                ),
              ),
              data: (policy) {
                if (!policy.enabled) {
                  final msg = policy.publicBookingMessage.trim().isNotEmpty
                      ? policy.publicBookingMessage.trim()
                      : l10n.customerBookingClosedMessage;
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.large),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_rounded,
                            size: 52,
                            color: AppColorsLight.textSecondary,
                          ),
                          const SizedBox(height: AppSpacing.large),
                          Text(
                            l10n.customerBookingClosedTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColorsLight.textPrimary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            msg,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppColorsLight.textSecondary,
                                  height: 1.35,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return servicesAsync.when(
                  loading: () => SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.large,
                    ),
                    sliver: SliverList.separated(
                      itemCount: 5,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.small),
                      itemBuilder: (_, _) => const _ServiceSkeletonCard(),
                    ),
                  ),
                  error: (_, _) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ServiceSelectionError(
                      message: l10n.genericError,
                      retryLabel: l10n.customerSalonDiscoveryRetry,
                      onRetry: () => ref.invalidate(
                        customerVisibleServicesProvider(widget.salonId),
                      ),
                    ),
                  ),
                  data: (services) {
                    if (services.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.large),
                            child: Text(
                              l10n.customerServiceSelectionEmpty,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppColorsLight.textSecondary,
                                  ),
                            ),
                          ),
                        ),
                      );
                    }
                    final grouped = _groupServices(services);
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.large,
                        0,
                        AppSpacing.large,
                        140,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          for (final entry in grouped.entries) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.small,
                              ),
                              child: Text(
                                entry.key,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColorsLight.textPrimary,
                                    ),
                              ),
                            ),
                            for (final service in entry.value)
                              SelectableCustomerServiceCard(
                                service: service,
                                selected: selectedIds.contains(service.id),
                                currencyCode: moneyCode,
                                onTap: () => ref
                                    .read(customerBookingDraftProvider.notifier)
                                    .toggleService(service),
                              ),
                            const SizedBox(height: AppSpacing.medium),
                          ],
                        ]),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceSkeletonCard extends StatelessWidget {
  const _ServiceSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.xlarge),
      ),
    );
  }
}

class _ServiceSelectionError extends StatelessWidget {
  const _ServiceSelectionError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.medium),
            FilledButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
