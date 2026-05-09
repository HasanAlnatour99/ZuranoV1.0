import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/booking_statuses.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/data/models/booking.dart';
import '../../../bookings/logic/booking_actions.dart';

class BookingStatusActionSheet extends ConsumerWidget {
  const BookingStatusActionSheet({
    super.key,
    required this.salonId,
    required this.booking,
  });

  final String salonId;
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    Future<void> run(Future<void> Function() action) async {
      try {
        await action();
        if (context.mounted) Navigator.of(context).pop();
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.genericError)),
        );
      }
    }

    final status = booking.status;
    final canConfirm = status == BookingStatuses.pending;
    final canCancel =
        status == BookingStatuses.pending || status == BookingStatuses.confirmed;
    final canCheckIn = status == BookingStatuses.confirmed;
    final canComplete = status == BookingStatuses.confirmed;
    final canNoShow = status == BookingStatuses.confirmed;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.ownerBookingManageStatus,
              style: const TextStyle(
                color: FinanceDashboardColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            if (canConfirm)
              FilledButton(
                onPressed: () => run(
                  () => ref.read(bookingActionsProvider).updateBookingStatus(
                        bookingId: booking.id,
                        nextStatus: BookingStatuses.confirmed,
                      ),
                ),
                child: Text(l10n.bookingStatusConfirmed),
              ),
            if (canCheckIn) ...[
              const SizedBox(height: AppSpacing.small),
              FilledButton(
                onPressed: () => run(
                  () => ref.read(bookingActionsProvider).markBookingArrived(
                        booking.id,
                      ),
                ),
                child: Text(l10n.ownerBookingMarkCheckedIn),
              ),
            ],
            if (canComplete) ...[
              const SizedBox(height: AppSpacing.small),
              FilledButton(
                onPressed: () => run(
                  () => ref.read(bookingActionsProvider).completeBookingService(
                        booking.id,
                      ),
                ),
                child: Text(l10n.ownerBookingMarkCompleted),
              ),
            ],
            if (canNoShow) ...[
              const SizedBox(height: AppSpacing.small),
              OutlinedButton(
                onPressed: () => run(
                  () => ref.read(bookingActionsProvider).markBookingNoShow(
                        booking.id,
                        party: 'customer',
                      ),
                ),
                child: Text(l10n.ownerBookingMarkNoShow),
              ),
            ],
            if (canCancel) ...[
              const SizedBox(height: AppSpacing.small),
              TextButton(
                onPressed: () => run(
                  () => ref.read(bookingActionsProvider).cancelBooking(booking.id),
                ),
                child: Text(l10n.ownerBookingCancel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

