import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart' show AppRouteNames;
import '../../../../core/constants/booking_status_machine.dart';
import '../../../../core/constants/booking_statuses.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/customer_booking_details_providers.dart';
import '../../application/customer_phone_normalizer.dart';
import '../../data/models/customer_booking_details_model.dart';
import '../widgets/customer_booking_action_panel.dart';
import '../widgets/customer_cancel_booking_sheet.dart';
import '../widgets/customer_booking_details_section_card.dart';
import '../widgets/customer_booking_status_badge.dart';
import '../widgets/customer_booking_timeline_card.dart';
import '../widgets/customer_gradient_scaffold.dart';

class CustomerBookingDetailsScreen extends ConsumerWidget {
  const CustomerBookingDetailsScreen({
    super.key,
    required this.salonId,
    required this.bookingId,
  });

  final String salonId;
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final args = (salonId: salonId, bookingId: bookingId);
    final asyncDetails = ref.watch(customerBookingDetailsProvider(args));

    return CustomerGradientScaffold(
      child: SafeArea(
        child: asyncDetails.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _ErrorBody(
            message: l10n.customerBookingLookupGenericError,
            onBack: () => context.pop(),
          ),
          data: (details) {
            if (details == null) {
              return _ErrorBody(
                message: l10n.bookingNotFound,
                onBack: () => context.pop(),
              );
            }
            return _CustomerBookingDetailsBody(
              details: details,
              detailsArgs: args,
              onRetry: () =>
                  ref.invalidate(customerBookingDetailsProvider(args)),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IconButton(
            alignment: AlignmentDirectional.centerStart,
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const Spacer(),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColorsLight.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _CustomerBookingDetailsBody extends ConsumerWidget {
  const _CustomerBookingDetailsBody({
    required this.details,
    required this.detailsArgs,
    required this.onRetry,
  });

  final CustomerBookingDetailsModel details;
  final CustomerBookingDetailsArgs detailsArgs;
  final VoidCallback onRetry;

  void _comingSoon(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.customerBookingDetailsComingSoon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final tag = locale.toString();
    final dateFmt = DateFormat.yMMMMEEEEd(tag);
    final timeFmt = DateFormat.jm(tag);
    final range =
        '${dateFmt.format(details.startAt.toLocal())} · '
        '${timeFmt.format(details.startAt.toLocal())} – '
        '${timeFmt.format(details.endAt.toLocal())}';

    final code = details.bookingCode.trim().isEmpty
        ? details.id
        : details.bookingCode;

    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.medium,
              AppSpacing.small,
              AppSpacing.medium,
              AppSpacing.small,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.small,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.customerBookingDetailsTitle,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColorsLight.textPrimary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          l10n.customerBookingDetailsSubtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppColorsLight.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatusHeroCard(
                    status: details.status,
                    bookingCode: code,
                    dateTimeLine: range,
                    codeLabel: l10n.customerBookingSuccessCode,
                    copiedMessage: l10n.customerBookingDetailsCopied,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  CustomerBookingTimelineCard(details: details, l10n: l10n),
                  const SizedBox(height: AppSpacing.medium),
                  CustomerBookingDetailsSectionCard(
                    title: l10n.customerBookingReviewSalon,
                    icon: Icons.storefront_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details.salonName.isEmpty
                              ? l10n.customerBookingReviewSalon
                              : details.salonName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColorsLight.textPrimary,
                          ),
                        ),
                        if (details.salonArea.trim().isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            '${l10n.customerBookingDetailsArea}: ${details.salonArea}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColorsLight.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.medium),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final p = details.salonPhone?.trim();
                                  ContactLauncher.callPhone(
                                    context,
                                    p,
                                    unavailableMessage: l10n
                                        .customerBookingDetailsPhoneUnavailable,
                                  );
                                },
                                icon: const Icon(Icons.call_rounded, size: 18),
                                label: Text(l10n.customerBookingDetailsCall),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.small),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final w = details.salonWhatsapp?.trim();
                                  ContactLauncher.openWhatsApp(
                                    context,
                                    w,
                                    message: l10n
                                        .customerBookingDetailsWhatsAppMessage,
                                    unavailableMessage: l10n
                                        .customerBookingDetailsPhoneUnavailable,
                                  );
                                },
                                icon: const Icon(Icons.chat_rounded, size: 18),
                                label: Text(
                                  l10n.customerBookingDetailsWhatsApp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CustomerBookingDetailsSectionCard(
                    title: l10n.customerBookingReviewServices,
                    icon: Icons.content_cut_rounded,
                    child: _ServicesBody(
                      details: details,
                      l10n: l10n,
                      currencyCode: details.currencyCode,
                    ),
                  ),
                  CustomerBookingDetailsSectionCard(
                    title: l10n.customerBookingDetailsSpecialist,
                    icon: Icons.person_rounded,
                    child: Text(
                      details.employeeName.isEmpty
                          ? l10n.customerBookingLookupAnySpecialist
                          : formatTeamMemberName(details.employeeName),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColorsLight.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  CustomerBookingDetailsSectionCard(
                    title: l10n.customerBookingReviewCustomer,
                    icon: Icons.badge_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details.customerName.isEmpty
                              ? '—'
                              : details.customerName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColorsLight.textPrimary,
                          ),
                        ),
                        if (details.customerPhone.trim().isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            CustomerPhoneNormalizer.displayPhone(
                              CustomerPhoneNormalizer.normalizePhone(
                                details.customerPhone,
                              ),
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColorsLight.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (details.customerNote.trim().isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.medium),
                          Text(
                            details.customerNote,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColorsLight.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  CustomerBookingDetailsSectionCard(
                    title: l10n.customerBookingReviewPaymentSummary,
                    icon: Icons.payments_outlined,
                    child: Column(
                      children: [
                        _PaymentRow(
                          label: l10n.customerBookingReviewSubtotal,
                          value: formatMoney(
                            details.subtotal,
                            details.currencyCode,
                            locale,
                          ),
                        ),
                        _PaymentRow(
                          label: l10n.customerBookingReviewDiscount,
                          value: formatMoney(
                            details.discountAmount,
                            details.currencyCode,
                            locale,
                          ),
                        ),
                        const Divider(height: AppSpacing.large),
                        _PaymentRow(
                          label: l10n.customerBookingReviewTotal,
                          value: formatMoney(
                            details.totalAmount,
                            details.currencyCode,
                            locale,
                          ),
                          emphasize: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  CustomerBookingActionPanel(
                    details: details,
                    onRescheduleComingSoon: () {
                      final normalized = BookingStatusMachine.normalize(
                        details.status,
                      );
                      final canReschedule =
                          normalized == BookingStatuses.pending ||
                          normalized == BookingStatuses.confirmed;
                      if (!canReschedule) {
                        _comingSoon(context);
                        return;
                      }
                      context.pushNamed(
                        AppRouteNames.customerBookingReschedule,
                        pathParameters: {
                          'salonId': details.salonId,
                          'bookingId': details.id,
                        },
                        extra: details,
                      );
                    },
                    onLeaveFeedback: () {
                      context.pushNamed(
                        AppRouteNames.customerBookingFeedback,
                        pathParameters: {
                          'salonId': details.salonId,
                          'bookingId': details.id,
                        },
                        extra: details,
                      );
                    },
                    onBookAgain: () => context.goNamed(
                      AppRouteNames.customerSalonProfile,
                      pathParameters: {'salonId': details.salonId},
                    ),
                    onCancelBooking: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await showCustomerCancelBookingSheet(
                        context: context,
                        ref: ref,
                        detailsArgs: detailsArgs,
                        scaffoldMessenger: messenger,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.large),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesBody extends StatelessWidget {
  const _ServicesBody({
    required this.details,
    required this.l10n,
    required this.currencyCode,
  });

  final CustomerBookingDetailsModel details;
  final AppLocalizations l10n;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);

    if (details.services.isEmpty) {
      final names = details.serviceNames.isNotEmpty
          ? details.serviceNames.join(', ')
          : l10n.bookingService;
      return Text(
        names,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: AppColorsLight.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Column(
      children: details.services.map((s) {
        final price = formatMoney(s.price, currencyCode, locale);
        final name = s.serviceName.isNotEmpty
            ? s.serviceName
            : l10n.bookingService;
        final meta = l10n.customerBookingDetailsDurationPrice(
          s.durationMinutes,
          price,
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.medium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColorsLight.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColorsLight.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColorsLight.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColorsLight.textPrimary,
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusHeroCard extends StatelessWidget {
  const _StatusHeroCard({
    required this.status,
    required this.bookingCode,
    required this.dateTimeLine,
    required this.codeLabel,
    required this.copiedMessage,
  });

  final String status;
  final String bookingCode;
  final String dateTimeLine;
  final String codeLabel;
  final String copiedMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomerBookingStatusBadge(status: status),
                      const SizedBox(height: AppSpacing.medium),
                      Text(
                        codeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColorsLight.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        bookingCode,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppBrandColors.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: bookingCode));
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(copiedMessage)));
                    }
                  },
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
            const Divider(height: AppSpacing.xlarge),
            Text(
              dateTimeLine,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColorsLight.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
