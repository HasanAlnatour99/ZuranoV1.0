import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/zurano_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/customer_booking_cancel_providers.dart';
import '../../application/customer_booking_cancel_service.dart';
import '../../application/customer_booking_details_providers.dart';
import '../../data/repositories/customer_booking_cancel_repository.dart';
import 'customer_gradient_scaffold.dart';
import 'customer_text_field.dart';

Future<void> showCustomerCancelBookingSheet({
  required BuildContext context,
  required WidgetRef ref,
  required CustomerBookingDetailsArgs detailsArgs,
  required ScaffoldMessengerState scaffoldMessenger,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: CustomerCancelBookingSheet(
          detailsArgs: detailsArgs,
          scaffoldMessenger: scaffoldMessenger,
        ),
      );
    },
  );
  ref.invalidate(customerBookingCancelControllerProvider);
}

class CustomerCancelBookingSheet extends ConsumerStatefulWidget {
  const CustomerCancelBookingSheet({
    super.key,
    required this.detailsArgs,
    required this.scaffoldMessenger,
  });

  final CustomerBookingDetailsArgs detailsArgs;
  final ScaffoldMessengerState scaffoldMessenger;

  @override
  ConsumerState<CustomerCancelBookingSheet> createState() =>
      _CustomerCancelBookingSheetState();
}

class _CustomerCancelBookingSheetState
    extends ConsumerState<CustomerCancelBookingSheet> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _messageForFailure(
    AppLocalizations l10n,
    CustomerBookingCancelFailure failure,
  ) {
    return switch (failure) {
      CustomerBookingCancelFailure.cutoffExpired =>
        l10n.customerCancelBookingTooCloseToStart,
      CustomerBookingCancelFailure.reasonTooLong =>
        l10n.customerCancelBookingReasonTooLong,
      CustomerBookingCancelFailure.notFound => l10n.bookingNotFound,
      CustomerBookingCancelFailure.invalidStatus ||
      CustomerBookingCancelFailure.permissionDenied =>
        l10n.customerCancelBookingCannotCancelOnline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final asyncCancel = ref.watch(customerBookingCancelControllerProvider);

    ref.listen(customerBookingCancelControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (value) {
          if (prev is! AsyncLoading<Object?>) {
            return;
          }
          if (!identical(value, customerBookingCancelSuccess)) {
            return;
          }
          if (!context.mounted) {
            return;
          }
          Navigator.of(context).pop();
          ref.invalidate(customerBookingDetailsProvider(widget.detailsArgs));
          widget.scaffoldMessenger.showSnackBar(
            SnackBar(content: Text(l10n.customerCancelBookingSuccess)),
          );
        },
        error: (e, _) {
          if (prev is! AsyncLoading<Object?>) {
            return;
          }
          if (e is CustomerBookingCancelException) {
            widget.scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(_messageForFailure(l10n, e.failure))),
            );
          } else {
            widget.scaffoldMessenger.showSnackBar(
              SnackBar(content: Text(l10n.customerBookingLookupGenericError)),
            );
          }
        },
      );
    });

    return Material(
      color: ZuranoTokens.surface,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ZuranoTokens.radiusSection),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          AppSpacing.medium,
          AppSpacing.large,
          AppSpacing.large,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ZuranoTokens.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            Text(
              l10n.customerCancelBookingTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: ZuranoTokens.textDark,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Text(
              l10n.customerCancelBookingConfirmMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: ZuranoTokens.textGray,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            CustomerTextField(
              controller: _reasonController,
              label: l10n.customerCancelBookingReasonLabel,
              hint: l10n.customerCancelBookingReasonHint,
              maxLength: CustomerBookingCancelService.maxCancelReasonLength,
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.large),
            Row(
              children: [
                Expanded(
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
                    onPressed: asyncCancel.isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(l10n.customerCancelBookingKeep),
                  ),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: FilledButton(
                    style: CustomerPrimaryButtonStyle.filled(context),
                    onPressed: asyncCancel.isLoading
                        ? null
                        : () async {
                            final details = await ref.read(
                              customerBookingDetailsProvider(
                                widget.detailsArgs,
                              ).future,
                            );
                            if (!context.mounted) {
                              return;
                            }
                            if (details == null) {
                              widget.scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text(l10n.bookingNotFound)),
                              );
                              return;
                            }
                            final phone =
                                details.customerPhoneNormalized
                                    .trim()
                                    .isNotEmpty
                                ? details.customerPhoneNormalized.trim()
                                : details.customerPhone.replaceAll(
                                    RegExp(r'\D'),
                                    '',
                                  );
                            final code = details.bookingCode.trim();
                            if (phone.isEmpty || code.isEmpty) {
                              widget.scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.customerCancelBookingCannotCancelOnline,
                                  ),
                                ),
                              );
                              return;
                            }
                            await ref
                                .read(
                                  customerBookingCancelControllerProvider
                                      .notifier,
                                )
                                .cancel(
                                  salonId: widget.detailsArgs.salonId,
                                  bookingId: widget.detailsArgs.bookingId,
                                  cancelReason: _reasonController.text,
                                  phoneNormalized: phone,
                                  bookingCode: code,
                                );
                          },
                    child: asyncCancel.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.customerCancelBookingConfirm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
