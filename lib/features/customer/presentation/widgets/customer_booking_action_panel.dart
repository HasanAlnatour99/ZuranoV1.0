import 'package:flutter/material.dart';

import '../../../../core/constants/booking_status_machine.dart';
import '../../../../core/constants/booking_statuses.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/customer_booking_details_model.dart';
import '../../data/models/customer_booking_settings.dart';
import '../../domain/customer_online_cancel_eligibility.dart';
import 'customer_gradient_scaffold.dart';

class CustomerBookingActionPanel extends StatelessWidget {
  const CustomerBookingActionPanel({
    super.key,
    required this.details,
    required this.onRescheduleComingSoon,
    required this.onBookAgain,
    this.onCancelBooking,
    this.onLeaveFeedback,
  });

  final CustomerBookingDetailsModel details;
  final VoidCallback onRescheduleComingSoon;
  final VoidCallback onBookAgain;
  final VoidCallback? onCancelBooking;
  final VoidCallback? onLeaveFeedback;

  static int _policyDisplayHours(CustomerBookingSettings s) {
    if (s.cancellationNoticeHours > 0) {
      return s.cancellationNoticeHours;
    }
    final m = s.cancellationCutoffMinutes;
    if (m <= 0) {
      return 0;
    }
    return (m / 60).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final status = details.status.trim();
    final normalized = BookingStatusMachine.normalize(status);

    final isPendingOrConfirmed =
        normalized == BookingStatuses.pending ||
        normalized == BookingStatuses.confirmed;
    final isCheckedIn = status == 'checkedIn' || status == 'checked_in';
    final showsUpcomingActions = isPendingOrConfirmed || isCheckedIn;

    final isCompleted = status == BookingStatuses.completed;
    final isCancelledLike =
        status == BookingStatuses.cancelled ||
        status == BookingStatuses.noShow ||
        status == 'noShow' ||
        status == BookingStatuses.rescheduled;

    final cancelEligibility = resolveCustomerOnlineCancelEligibility(
      details: details,
      settings: details.customerBookingSettings,
    );

    if (!showsUpcomingActions && !isCompleted && !isCancelledLike) {
      return const SizedBox.shrink();
    }

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.customerBookingDetailsActionsTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: ZuranoTokens.textDark,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            if (showsUpcomingActions) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ZuranoTokens.primary,
                    side: const BorderSide(color: ZuranoTokens.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ZuranoTokens.radiusButton,
                      ),
                    ),
                  ),
                  onPressed: onRescheduleComingSoon,
                  child: Text(l10n.customerBookingDetailsReschedule),
                ),
              ),
              if (isPendingOrConfirmed) ...[
                const SizedBox(height: AppSpacing.small),
                if (cancelEligibility ==
                        CustomerOnlineCancelEligibility.eligible &&
                    onCancelBooking != null) ...[
                  Builder(
                    builder: (context) {
                      final h = _policyDisplayHours(
                        details.customerBookingSettings,
                      );
                      if (h <= 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.small),
                        child: Text(
                          l10n.customerBookingDetailsCancelPolicyNotice(h),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ZuranoTokens.textGray,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: CustomerPrimaryButtonStyle.filled(context),
                      onPressed: onCancelBooking,
                      child: Text(l10n.customerBookingDetailsCancelBooking),
                    ),
                  ),
                ] else if (cancelEligibility ==
                        CustomerOnlineCancelEligibility.ineligibleNotAllowed ||
                    cancelEligibility ==
                        CustomerOnlineCancelEligibility
                            .ineligibleTooClose) ...[
                  _CustomerCancelPolicyBanner(
                    message: cancelEligibility ==
                            CustomerOnlineCancelEligibility.ineligibleNotAllowed
                        ? l10n.customerCancelBookingCannotCancelOnline
                        : l10n.customerCancelBookingTooCloseToStart,
                  ),
                ],
              ],
            ] else if (isCompleted) ...[
              if (details.feedbackSubmitted) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: ZuranoTokens.lightPurple.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    border: Border.all(
                      color: ZuranoTokens.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    child: Row(
                      children: [
                        Icon(
                          Icons.mark_chat_read_outlined,
                          color: ZuranoTokens.primary,
                          size: 22,
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Expanded(
                          child: Text(
                            l10n.customerFeedbackSubmittedBadge,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: ZuranoTokens.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (onLeaveFeedback != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: CustomerPrimaryButtonStyle.filled(context),
                    onPressed: onLeaveFeedback,
                    child: Text(l10n.customerBookingDetailsLeaveFeedback),
                  ),
                ),
              ],
            ] else if (isCancelledLike) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: CustomerPrimaryButtonStyle.filled(context),
                  onPressed: onBookAgain,
                  child: Text(l10n.customerBookingDetailsBookAgain),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomerCancelPolicyBanner extends StatelessWidget {
  const _CustomerCancelPolicyBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ZuranoTokens.lightPurple,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: ZuranoTokens.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: ZuranoTokens.primary,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ZuranoTokens.textDark,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
