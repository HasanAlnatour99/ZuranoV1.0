import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import '../../../owner/presentation/widgets/add_barber/add_barber_header.dart';
import '../../domain/customer_type_resolver.dart';
import '../../logic/customer_providers.dart';
import '../providers/customer_details_providers.dart';
import '../widgets/customer_permission_error.dart';
import 'customer_details/widgets/customer_action_grid.dart';
import 'customer_details/widgets/customer_notes_card.dart';
import 'customer_details/widgets/customer_profile_card.dart';
import 'customer_details/widgets/customer_sales_section.dart';
import 'customer_details/widgets/customer_upcoming_bookings_card.dart';
import 'customer_details/widgets/customer_vip_banner.dart';
import '../../../../providers/money_currency_providers.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

class CustomerDetailsScreen extends ConsumerWidget {
  const CustomerDetailsScreen({super.key, required this.customerId});

  final String customerId;

  void _popOrCustomers(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      if (router.canPop()) {
        router.pop();
      } else {
        router.go(AppRoutes.ownerCustomers);
      }
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final sessionAsync = ref.watch(sessionUserProvider);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    return sessionAsync.when(
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFFAF9FF),
        body: const Center(
          child: CircularProgressIndicator(
            color: FinanceDashboardColors.primaryPurple,
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: const Color(0xFFFAF9FF),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.customersGenericLoadError,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (user) {
        final salonId = user?.salonId?.trim() ?? '';
        final canManageBookings =
            user != null && (user.role == 'owner' || user.role == 'admin');

        if (customerId.isEmpty || salonId.isEmpty) {
          return _notFoundScaffold(context, l10n);
        }

        if (kDebugMode) {
          debugPrint(
            '[CUSTOMER_DETAILS] customerId=$customerId salonId=$salonId',
          );
        }

        final customerAsync = ref.watch(
          customerDetailsProvider(
            CustomerDetailsArgs(salonId: salonId, customerId: customerId),
          ),
        );
        final salesAsync = ref.watch(customerDetailSalesProvider(customerId));
        final bookingsAsync = ref.watch(
          customerDetailUpcomingBookingsProvider(customerId),
        );

        return customerAsync.when(
          loading: () => Scaffold(
            backgroundColor: const Color(0xFFFAF9FF),
            body: const SafeArea(
              child: Center(
                child: CircularProgressIndicator(
                  color: FinanceDashboardColors.primaryPurple,
                ),
              ),
            ),
          ),
          error: (error, _) {
            if (isCustomerPermissionDenied(error)) {
              return Scaffold(
                backgroundColor: const Color(0xFFFAF9FF),
                body: const SafeArea(child: CustomerPermissionError()),
              );
            }
            return Scaffold(
              backgroundColor: const Color(0xFFFAF9FF),
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.customersGenericLoadError,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _popOrCustomers(context),
                          icon: const Icon(AppIcons.arrow_back_ios_new_rounded),
                          label: Text(l10n.customerBackToCustomers),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          data: (customer) {
            if (customer == null) {
              return _notFoundScaffold(context, l10n);
            }

            final sales = salesAsync.asData?.value ?? const [];
            final bookings = bookingsAsync.asData?.value ?? const [];
            final createdAt = customer.createdAt ?? DateTime.now();
            final resolved = resolveCustomerType(
              isVip: customer.isVip,
              createdAt: createdAt,
              lastVisitAt: customer.lastVisitAt,
              totalVisits: customer.totalVisits,
              now: DateTime.now(),
            );

            return Scaffold(
              backgroundColor: const Color(0xFFFAF9FF),
              body: SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AddBarberHeader(
                              title: l10n.customerDetailsTitle,
                              subtitle: customer.visibleDisplayName,
                              compact: true,
                              onBack: () => _popOrCustomers(context),
                            ),
                            if (customer.isVip) ...[
                              const SizedBox(height: 18),
                              CustomerVipBanner(l10n: l10n),
                            ],
                            const SizedBox(height: 16),
                            CustomerProfileCard(
                              customer: customer,
                              resolvedType: resolved,
                              l10n: l10n,
                              locale: locale,
                              currencyCode: currencyCode,
                            ),
                            const SizedBox(height: 14),
                            CustomerActionGrid(
                              customer: customer,
                              l10n: l10n,
                              canManageBookings: canManageBookings,
                            ),
                            const SizedBox(height: 18),
                            CustomerSalesSection(
                              customer: customer,
                              sales: sales,
                              l10n: l10n,
                              locale: locale,
                              currencyCode: currencyCode,
                            ),
                            const SizedBox(height: 18),
                            CustomerUpcomingBookingsCard(
                              bookings: bookings,
                              l10n: l10n,
                              locale: locale,
                            ),
                            const SizedBox(height: 18),
                            CustomerNotesCard(
                              notes: customer.notes,
                              l10n: l10n,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _notFoundScaffold(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_off_outlined,
                  size: 56,
                  color: FinanceDashboardColors.primaryPurple,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.customerNotFound,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.customerNotFoundSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: FinanceDashboardColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => _popOrCustomers(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(l10n.customerBackToCustomers),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
