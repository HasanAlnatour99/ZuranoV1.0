import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart'
    show AppRouteNames, AppRoutes;
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/firebase_providers.dart';
import '../../../../providers/session_provider.dart';
import '../../application/customer_booking_availability_providers.dart';
import '../../application/customer_booking_currency.dart';
import '../../application/customer_booking_create_providers.dart';
import '../../application/customer_booking_create_service.dart';
import '../../application/customer_booking_draft_provider.dart';
import '../../application/customer_salon_profile_providers.dart';
import '../widgets/booking_review_section_card.dart';
import '../widgets/booking_review_service_line.dart';
import '../widgets/customer_booking_confirm_button.dart';
import '../widgets/customer_booking_progress_header.dart';
import '../widgets/customer_gradient_scaffold.dart';

class BookingReviewScreen extends ConsumerStatefulWidget {
  const BookingReviewScreen({super.key, required this.salonId});

  final String salonId;

  @override
  ConsumerState<BookingReviewScreen> createState() =>
      _BookingReviewScreenState();
}

class _BookingReviewScreenState extends ConsumerState<BookingReviewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardDraft());
  }

  Future<void> _guardDraft() async {
    if (!mounted) {
      return;
    }
    final draft = ref.read(customerBookingDraftProvider);
    if (draft.salonId != widget.salonId || !draft.hasServices) {
      context.goNamed(
        AppRouteNames.customerServiceSelection,
        pathParameters: {'salonId': widget.salonId},
      );
      return;
    }
    if (!draft.hasTeamSelection || draft.selectedEmployeeId == null) {
      context.goNamed(
        AppRouteNames.customerTeamSelection,
        pathParameters: {'salonId': widget.salonId},
      );
      return;
    }
    if (!draft.hasDateTime) {
      context.goNamed(
        AppRouteNames.customerDateTimeSelection,
        pathParameters: {'salonId': widget.salonId},
      );
      return;
    }
    final settings = await ref.read(
      customerPublicBookingFlowSettingsProvider(widget.salonId).future,
    );
    if (!mounted) {
      return;
    }
    if (!settings.customerDetailsSatisfied(
      customerName: draft.customerName,
      customerPhoneNormalized: draft.customerPhoneNormalized,
    )) {
      context.goNamed(
        AppRouteNames.customerDetails,
        pathParameters: {'salonId': widget.salonId},
      );
      return;
    }
    final isAnonymous =
        ref.read(firebaseAuthProvider).currentUser?.isAnonymous == true;
    if (isAnonymous && !draft.hasGuestNickname) {
      context.goNamed(
        AppRouteNames.customerGuestNickname,
        pathParameters: {'salonId': widget.salonId},
      );
      return;
    }
  }

  Future<void> _confirm(AppLocalizations l10n) async {
    final draft = ref.read(customerBookingDraftProvider);
    if (draft.selectedEmployeeId == null) {
      _showError(l10n.customerBookingReviewChooseSpecialistAgain);
      return;
    }
    final customerUiLanguageCode = Localizations.localeOf(context).languageCode;
    final settings = await ref.read(
      customerPublicBookingFlowSettingsProvider(widget.salonId).future,
    );
    final user = ref.read(sessionUserProvider).asData?.value;
    if (user == null) {
      if (mounted) {
        _showError(l10n.customerBookingSignInRequired);
        context.push(AppRoutes.customerAuth);
      }
      return;
    }
    final isAnonymous =
        ref.read(firebaseAuthProvider).currentUser?.isAnonymous == true;
    if (isAnonymous && !draft.hasGuestNickname) {
      if (mounted) {
        _showError(l10n.customerBookingReviewMissingGuestNickname);
        context.pushNamed(
          AppRouteNames.customerGuestNickname,
          pathParameters: {'salonId': widget.salonId},
        );
      }
      return;
    }
    final result = await ref
        .read(customerBookingCreateControllerProvider.notifier)
        .create(
          salonId: widget.salonId,
          draft: draft,
          bookingSettings: settings,
          customerUiLanguageCode: customerUiLanguageCode,
        );
    if (!mounted) {
      return;
    }
    if (result == null) {
      final error = ref.read(customerBookingCreateControllerProvider).error;
      _showError(_friendlyError(l10n, error));
      return;
    }
    context.goNamed(
      AppRouteNames.customerBookingSuccess,
      pathParameters: {
        'salonId': widget.salonId,
        'bookingId': result.bookingId,
      },
      extra: result,
    );
  }

  String _friendlyError(AppLocalizations l10n, Object? error) {
    if (error is CustomerBookingCreateException) {
      return switch (error.code) {
        'slot_unavailable' => l10n.customerBookingReviewSlotUnavailable,
        'missing_specialist' => l10n.customerBookingReviewChooseSpecialistAgain,
        'missing_guest_nickname' =>
          l10n.customerBookingReviewMissingGuestNickname,
        _ => l10n.customerBookingReviewGenericError,
      };
    }
    return l10n.customerBookingReviewGenericError;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.watch(customerBookingDraftProvider);
    final salonAsync = ref.watch(customerSalonProfileProvider(widget.salonId));
    final createState = ref.watch(customerBookingCreateControllerProvider);
    final isLoading = createState.isLoading;
    final locale = Localizations.localeOf(context);
    final dateFormatter = DateFormat.yMMMMd(locale.toString());
    final timeFormatter = DateFormat.jm(locale.toString());
    final moneyCode = watchCustomerSalonMoneyCode(ref, widget.salonId);
    final subtotal = formatMoney(draft.subtotal, moneyCode, locale);
    final discount = formatMoney(draft.discountAmount, moneyCode, locale);
    final total = formatMoney(draft.totalAmount, moneyCode, locale);

    return CustomerGradientScaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          0,
          AppSpacing.large,
          AppSpacing.medium,
        ),
        child: CustomerBookingConfirmButton(
          label: l10n.customerBookingReviewConfirm,
          isLoading: isLoading,
          onPressed: () => _confirm(l10n),
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
                            l10n.customerBookingReviewTitle,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColorsLight.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.customerBookingReviewSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColorsLight.textSecondary),
                          ),
                        ],
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
                ),
                child: CustomerBookingProgressHeader(
                  stepLabel: l10n.customerBookingReviewStepLabel,
                  title: l10n.customerBookingReviewProgressTitle,
                  progress: 1,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.large,
                  AppSpacing.large,
                  120,
                ),
                child: Column(
                  children: [
                    salonAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (salon) => BookingReviewSectionCard(
                        title: l10n.customerBookingReviewSalon,
                        icon: Icons.storefront_rounded,
                        child: _KeyValueLines(
                          lines: [
                            if (salon != null)
                              (salon.salonName, salon.area)
                            else
                              (widget.salonId, ''),
                          ],
                        ),
                      ),
                    ),
                    BookingReviewSectionCard(
                      title: l10n.customerBookingReviewServices,
                      icon: Icons.spa_outlined,
                      child: Column(
                        children: [
                          for (final service in draft.selectedServices)
                            BookingReviewServiceLine(
                              service: service,
                              currencyCode: moneyCode,
                            ),
                        ],
                      ),
                    ),
                    BookingReviewSectionCard(
                      title: l10n.customerBookingReviewSpecialist,
                      icon: Icons.person_outline,
                      child: _KeyValueLines(
                        lines: [(draft.selectedEmployeeName ?? '', '')],
                      ),
                    ),
                    BookingReviewSectionCard(
                      title: l10n.customerBookingReviewDateTime,
                      icon: Icons.event_available_outlined,
                      child: _KeyValueLines(
                        lines: [
                          (
                            dateFormatter.format(draft.selectedStartAt!),
                            '${timeFormatter.format(draft.selectedStartAt!)} - ${timeFormatter.format(draft.selectedEndAt!)}',
                          ),
                        ],
                      ),
                    ),
                    BookingReviewSectionCard(
                      title: l10n.customerBookingReviewCustomer,
                      icon: Icons.badge_outlined,
                      child: _KeyValueLines(
                        lines: [
                          (draft.customerName ?? '', draft.customerPhone ?? ''),
                          if (draft.guestDisplayName?.isNotEmpty == true)
                            (
                              l10n.guestNicknameSuggestedLabel,
                              draft.guestDisplayName!,
                            ),
                          if (draft.customerGender?.isNotEmpty == true)
                            (l10n.customerDetailsGender, draft.customerGender!),
                          if (draft.customerNote?.isNotEmpty == true)
                            (l10n.customerDetailsNotes, draft.customerNote!),
                        ],
                      ),
                    ),
                    BookingReviewSectionCard(
                      title: l10n.customerBookingReviewPaymentSummary,
                      icon: Icons.receipt_long_outlined,
                      child: _PaymentLines(
                        subtotalLabel: l10n.customerBookingReviewSubtotal,
                        discountLabel: l10n.customerBookingReviewDiscount,
                        totalLabel: l10n.customerBookingReviewTotal,
                        subtotal: subtotal,
                        discount: discount,
                        total: total,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyValueLines extends StatelessWidget {
  const _KeyValueLines({required this.lines});

  final List<(String, String)> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.small),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    line.$1,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColorsLight.textPrimary,
                    ),
                  ),
                ),
                if (line.$2.isNotEmpty)
                  Expanded(
                    child: Text(
                      line.$2,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColorsLight.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PaymentLines extends StatelessWidget {
  const _PaymentLines({
    required this.subtotalLabel,
    required this.discountLabel,
    required this.totalLabel,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  final String subtotalLabel;
  final String discountLabel;
  final String totalLabel;
  final String subtotal;
  final String discount;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _line(context, subtotalLabel, subtotal),
        _line(context, discountLabel, discount),
        const Divider(height: AppSpacing.large),
        _line(context, totalLabel, total, totalLine: true),
      ],
    );
  }

  Widget _line(
    BuildContext context,
    String label,
    String value, {
    bool totalLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: totalLine
                    ? AppColorsLight.textPrimary
                    : AppColorsLight.textSecondary,
                fontWeight: totalLine ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: totalLine
                  ? AppBrandColors.primary
                  : AppColorsLight.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
