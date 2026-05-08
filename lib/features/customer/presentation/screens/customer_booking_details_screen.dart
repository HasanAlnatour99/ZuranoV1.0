import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart'
    show AppRouteNames, AppRoutes;
import '../../../../core/constants/booking_status_machine.dart';
import '../../../../core/constants/booking_statuses.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/customer_booking_details_providers.dart';
import '../../application/customer_phone_normalizer.dart';
import '../../data/models/customer_booking_details_model.dart';
import '../../domain/customer_online_cancel_eligibility.dart';
import '../widgets/customer_booking_action_panel.dart';
import '../widgets/customer_cancel_booking_sheet.dart';
import '../widgets/customer_booking_details_section_card.dart';
import '../widgets/customer_booking_status_badge.dart';
import '../widgets/customer_booking_timeline_card.dart';
import '../widgets/customer_gradient_scaffold.dart';

void _exitCustomerBookingDetails(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.customerHome);
  }
}

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
            onBack: () => _exitCustomerBookingDetails(context),
          ),
          data: (details) {
            if (details == null) {
              return _ErrorBody(
                message: l10n.bookingNotFound,
                onBack: () => _exitCustomerBookingDetails(context),
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

  static int _policyHoursFromMinutes(int minutes, {int fallback = 0}) {
    if (minutes <= 0) return fallback;
    return (minutes / 60).ceil();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final hasPhone = details.salonPhone?.trim().isNotEmpty == true;
    final hasWhatsApp = details.salonWhatsapp?.trim().isNotEmpty == true;
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

    final normalizedForMenu =
        BookingStatusMachine.normalize(details.status.trim());
    final menuRescheduleEnabled =
        normalizedForMenu == BookingStatuses.pending ||
        normalizedForMenu == BookingStatuses.confirmed;
    final cancelEligibility = resolveCustomerOnlineCancelEligibility(
      details: details,
      settings: details.customerBookingSettings,
    );
    final menuCancelEnabled =
        cancelEligibility == CustomerOnlineCancelEligibility.eligible;

    final rescheduleCutoff = details.customerBookingSettings.rescheduleCutoffMinutes;
    final minsUntilStart = details.startAt.difference(DateTime.now()).inMinutes;
    final policyRescheduleAllowed = menuRescheduleEnabled &&
        (rescheduleCutoff <= 0 || minsUntilStart > rescheduleCutoff);

    void handleOverflowReschedule() {
      context.pushNamed(
        AppRouteNames.customerBookingReschedule,
        pathParameters: {
          'salonId': details.salonId,
          'bookingId': details.id,
        },
        extra: details,
      );
    }

    Future<void> handleOverflowCancel() async {
      final messenger = ScaffoldMessenger.of(context);
      await showCustomerCancelBookingSheet(
        context: context,
        ref: ref,
        detailsArgs: detailsArgs,
        scaffoldMessenger: messenger,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.medium,
              AppSpacing.small,
              AppSpacing.medium,
              AppSpacing.small,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => _exitCustomerBookingDetails(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: ZuranoTokens.textDark,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        top: 4,
                        end: AppSpacing.small,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.customerBookingDetailsTitle,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: ZuranoTokens.textDark,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ),
                              _BookingDetailsOverflowMenu(
                                l10n: l10n,
                                rescheduleEnabled: policyRescheduleAllowed,
                                cancelEnabled: menuCancelEnabled,
                                onReschedule: handleOverflowReschedule,
                                onCancel: handleOverflowCancel,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            l10n.customerBookingDetailsSubtitle,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: ZuranoTokens.textGray,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
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
                                onPressed: hasPhone
                                    ? () {
                                  final p = details.salonPhone?.trim();
                                  ContactLauncher.callPhone(
                                    context,
                                    p,
                                    unavailableMessage: l10n
                                        .customerBookingDetailsPhoneUnavailable,
                                  );
                                }
                                    : null,
                                icon: const Icon(Icons.call_rounded, size: 18),
                                label: Text(l10n.customerBookingDetailsCall),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.small),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: hasWhatsApp
                                    ? () {
                                  final w = details.salonWhatsapp?.trim();
                                  ContactLauncher.openWhatsApp(
                                    context,
                                    w,
                                    message: l10n
                                        .customerBookingDetailsWhatsAppMessage,
                                    unavailableMessage: l10n
                                        .customerBookingDetailsPhoneUnavailable,
                                  );
                                }
                                    : null,
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
                            details.customerPhoneNormalized.trim().isNotEmpty
                                ? details.customerPhoneNormalized.trim()
                                : CustomerPhoneNormalizer.normalizePhone(
                                  details.customerPhone,
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
                          label: l10n.customerBookingPaymentStatusLabel,
                          value: switch (details.paymentStatus.trim().toLowerCase()) {
                            'paid' => l10n.customerBookingPaymentStatusPaid,
                            'partial' || 'partially_paid' =>
                              l10n.customerBookingPaymentStatusPartial,
                            _ => l10n.customerBookingPaymentStatusUnpaid,
                          },
                        ),
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
                  Builder(
                    builder: (context) {
                      final s = details.customerBookingSettings;
                      final cancelHours =
                          s.allowCustomerCancellation ? (s.cancellationNoticeHours > 0 ? s.cancellationNoticeHours : _policyHoursFromMinutes(s.cancellationCutoffMinutes)) : 0;
                      final rescheduleHours = _policyHoursFromMinutes(
                        s.rescheduleCutoffMinutes,
                        fallback: 0,
                      );
                      if (cancelHours <= 0 && rescheduleHours <= 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.small),
                        child: CustomerBookingDetailsSectionCard(
                          title: l10n.customerBookingDetailsPolicyTitle,
                          icon: Icons.policy_outlined,
                          child: Text(
                            l10n.customerBookingDetailsPolicyBody(
                              cancelHours,
                              rescheduleHours,
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColorsLight.textSecondary,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  CustomerBookingActionPanel(
                    details: details,
                    onRescheduleComingSoon: () {
                      final normalized = BookingStatusMachine.normalize(
                        details.status,
                      );
                      final canReschedule =
                          normalized == BookingStatuses.pending ||
                          normalized == BookingStatuses.confirmed;
                      final cutoff =
                          details.customerBookingSettings.rescheduleCutoffMinutes;
                      final mins = details.startAt
                          .difference(DateTime.now())
                          .inMinutes;
                      final allowed = canReschedule &&
                          (cutoff <= 0 || mins > cutoff);
                      if (!allowed) {
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
    return Container(
      decoration: BoxDecoration(
        color: ZuranoTokens.surface,
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusCard),
        border: Border.all(color: ZuranoTokens.sectionBorder),
        boxShadow: ZuranoTokens.softCardShadow,
      ),
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
                          color: ZuranoTokens.textGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SelectableText(
                        bookingCode,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: ZuranoTokens.primary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: ZuranoTokens.lightPurple,
                    foregroundColor: ZuranoTokens.primary,
                  ),
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
            Divider(height: AppSpacing.xlarge, color: ZuranoTokens.sectionBorder),
            Text(
              dateTimeLine,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: ZuranoTokens.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _BookingOverflowAction { reschedule, cancel }

class _BookingDetailsOverflowMenu extends StatelessWidget {
  const _BookingDetailsOverflowMenu({
    required this.l10n,
    required this.rescheduleEnabled,
    required this.cancelEnabled,
    required this.onReschedule,
    required this.onCancel,
  });

  final AppLocalizations l10n;
  final bool rescheduleEnabled;
  final bool cancelEnabled;
  final VoidCallback onReschedule;
  final Future<void> Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_BookingOverflowAction>(
      tooltip: l10n.customerBookingDetailsOverflowTooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      offset: const Offset(0, 40),
      color: ZuranoTokens.surface,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ZuranoTokens.radiusCard),
        side: const BorderSide(color: ZuranoTokens.sectionBorder),
      ),
      onSelected: (action) {
        switch (action) {
          case _BookingOverflowAction.reschedule:
            onReschedule();
            break;
          case _BookingOverflowAction.cancel:
            onCancel();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_BookingOverflowAction>(
          value: _BookingOverflowAction.reschedule,
          enabled: rescheduleEnabled,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
            vertical: AppSpacing.small,
          ),
          child: _OverflowMenuRow(
            icon: Icons.event_repeat_rounded,
            label: l10n.customerBookingDetailsReschedule,
            enabled: rescheduleEnabled,
          ),
        ),
        PopupMenuItem<_BookingOverflowAction>(
          value: _BookingOverflowAction.cancel,
          enabled: cancelEnabled,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
            vertical: AppSpacing.small,
          ),
          child: _OverflowMenuRow(
            icon: Icons.event_busy_rounded,
            label: l10n.customerBookingDetailsCancelBooking,
            enabled: cancelEnabled,
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.small),
        child: Icon(
          Icons.more_vert_rounded,
          color: ZuranoTokens.textDark,
        ),
      ),
    );
  }
}

class _OverflowMenuRow extends StatelessWidget {
  const _OverflowMenuRow({
    required this.icon,
    required this.label,
    required this.enabled,
  });

  final IconData icon;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final accent = enabled ? ZuranoTokens.primary : ZuranoTokens.textGray;
    final textColor = enabled ? ZuranoTokens.textDark : ZuranoTokens.textGray;
    return Row(
      children: [
        Icon(icon, size: 22, color: accent),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
