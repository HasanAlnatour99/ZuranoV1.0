import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/booking_status_machine.dart';
import '../../../../core/constants/booking_statuses.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../core/widgets/app_bar_leading_back.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/customer_booking_details_providers.dart';
import '../../application/customer_feedback_providers.dart';
import '../../application/customer_salon_profile_providers.dart';
import '../../data/customer_feedback_submit_service.dart';
import '../../data/models/customer_booking_details_model.dart';

class CustomerFeedbackScreen extends ConsumerStatefulWidget {
  const CustomerFeedbackScreen({
    super.key,
    required this.salonId,
    required this.bookingId,
    this.initialBooking,
  });

  final String salonId;
  final String bookingId;
  final CustomerBookingDetailsModel? initialBooking;

  @override
  ConsumerState<CustomerFeedbackScreen> createState() =>
      _CustomerFeedbackScreenState();
}

class _CustomerFeedbackScreenState extends ConsumerState<CustomerFeedbackScreen> {
  final _commentCtrl = TextEditingController();
  int _rating = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(CustomerBookingDetailsModel details) async {
    final l10n = AppLocalizations.of(context)!;
    if (_rating < 1 || _rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.customerFeedbackRatingRequired)),
      );
      return;
    }
    final comment = _commentCtrl.text.trim();
    if (comment.length > 2000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.customerFeedbackCommentTooLong)),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(customerFeedbackSubmitServiceProvider).submit(
            salonId: widget.salonId,
            bookingId: widget.bookingId,
            rating: _rating,
            comment: comment,
            phoneNormalized: details.customerPhoneNormalized,
            bookingCode: details.bookingCode,
          );
      final sid = widget.salonId.trim();
      final bid = widget.bookingId.trim();
      ref.invalidate(customerBookingDetailsProvider((salonId: sid, bookingId: bid)));
      ref.invalidate(customerSalonProfileProvider(sid));
      ref.invalidate(customerSalonReviewsProvider(sid));
      if (!mounted) {
        return;
      }
      await _showThankYou(context);
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) {
        return;
      }
      final reason = CustomerFeedbackSubmitService.reasonFromException(e);
      final msg = reason == 'booking_not_completed'
          ? l10n.customerFeedbackOnlyCompleted
          : l10n.customerFeedbackGenericError;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } on Object {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.customerFeedbackGenericError)),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _showThankYou(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.customerFeedbackThankYouTitle),
        content: Text(l10n.customerFeedbackThankYouSubtitle),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: Text(l10n.customerFeedbackBackToDetails),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final args = (salonId: widget.salonId, bookingId: widget.bookingId);
    final asyncDetails = ref.watch(customerBookingDetailsProvider(args));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const AppBarLeadingBack(),
        title: Text(l10n.customerFeedbackTitle),
      ),
      body: asyncDetails.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, _) => Center(child: Text(l10n.customerFeedbackGenericError)),
        data: (details) {
          final d = details ?? widget.initialBooking;
          if (d == null) {
            return Center(child: Text(l10n.bookingNotFound));
          }
          if (d.feedbackSubmitted) {
            return _AlreadySubmittedBody(
              onClose: () => context.pop(),
            );
          }
          final normalized = BookingStatusMachine.normalize(d.status);
          if (normalized != BookingStatuses.completed) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Text(
                  l10n.customerFeedbackOnlyCompleted,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.customerFeedbackSubtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: ZuranoTokens.textDark,
                      ),
                ),
                const SizedBox(height: AppSpacing.large),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: ZuranoTokens.surface,
                    borderRadius:
                        BorderRadius.circular(ZuranoTokens.radiusCard),
                    border: Border.all(color: ZuranoTokens.sectionBorder),
                    boxShadow: ZuranoTokens.softCardShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.customerFeedbackRatingSection,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: ZuranoTokens.textGray,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (i) {
                            final value = i + 1;
                            final selected = value <= _rating;
                            return InkWell(
                              onTap: () => setState(() => _rating = value),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.medium),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  selected
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 36,
                                  color: selected
                                      ? Colors.amber.shade700
                                      : ZuranoTokens.border,
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          _ratingLabel(l10n),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: ZuranoTokens.textGray,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.large),
                        AppTextField(
                          label: l10n.customerFeedbackCommentLabel,
                          controller: _commentCtrl,
                          hintText: l10n.customerFeedbackCommentHint,
                          maxLines: 4,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2000),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                AppPrimaryButton(
                  label: l10n.customerFeedbackSubmit,
                  onPressed: () => _submit(d),
                  isLoading: _submitting,
                  isDisabled: _submitting,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _ratingLabel(AppLocalizations l10n) {
    return switch (_rating) {
      1 => l10n.customerFeedbackRatingPoor,
      2 => l10n.customerFeedbackRatingFair,
      3 => l10n.customerFeedbackRatingGood,
      4 => l10n.customerFeedbackRatingVeryGood,
      5 => l10n.customerFeedbackRatingExcellent,
      _ => '',
    };
  }
}

class _AlreadySubmittedBody extends StatelessWidget {
  const _AlreadySubmittedBody({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_chat_read_rounded,
              size: 56, color: AppBrandColors.primary),
          const SizedBox(height: AppSpacing.large),
          Text(
            l10n.customerFeedbackAlreadySubmittedTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            l10n.customerFeedbackAlreadySubmittedSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColorsLight.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.large),
          AppPrimaryButton(label: l10n.customerFeedbackBackToDetails, onPressed: onClose),
        ],
      ),
    );
  }
}
