import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/formatting/booking_status_localized.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import '../../../bookings/data/models/booking.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/money_currency_providers.dart';
import '../widgets/booking_status_action_sheet.dart';

class OwnerBookingDetailsScreen extends ConsumerWidget {
  const OwnerBookingDetailsScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(sessionUserProvider).asData?.value;
    final salonId = user?.salonId?.trim() ?? '';
    final localeTag = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(localeTag);
    final timeFmt = DateFormat.jm(localeTag);

    if (salonId.isEmpty || bookingId.trim().isEmpty) {
      return Scaffold(
        backgroundColor: FinanceDashboardColors.background,
        appBar: AppBar(title: Text(l10n.ownerBookingDetailsTitle)),
        body: Center(child: Text(l10n.genericError)),
      );
    }

    final repo = ref.watch(bookingRepositoryProvider);
    return Scaffold(
      backgroundColor: FinanceDashboardColors.background,
      appBar: AppBar(
        backgroundColor: FinanceDashboardColors.background,
        foregroundColor: FinanceDashboardColors.textPrimary,
        elevation: 0,
        title: Text(l10n.ownerBookingDetailsTitle),
      ),
      body: StreamBuilder<Booking?>(
        stream: repo.watchBooking(salonId, bookingId),
        builder: (context, snap) {
          final booking = snap.data;
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: FinanceDashboardColors.primaryPurple,
              ),
            );
          }
          if (booking == null) {
            return Center(child: Text(l10n.genericError));
          }

          final when =
              '${dateFmt.format(booking.startAt.toLocal())} · ${timeFmt.format(booking.startAt.toLocal())}';
          final amount = booking.totalAmount;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: FinanceDashboardColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: FinanceDashboardColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.bookingWhen,
                      style: const TextStyle(
                        color: FinanceDashboardColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      when,
                      style: const TextStyle(
                        color: FinanceDashboardColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      '${l10n.bookingStatus}: ${localizedBookingStatus(l10n, booking.status)}',
                      style: const TextStyle(
                        color: FinanceDashboardColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${l10n.customerNameLabel}: ${booking.customerName ?? booking.customerId}',
                      style: const TextStyle(
                        color: FinanceDashboardColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.bookingBarber}: ${booking.barberName ?? booking.barberId}',
                      style: const TextStyle(
                        color: FinanceDashboardColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.bookingCodeLabel}: ${booking.bookingCode ?? '—'}',
                      style: const TextStyle(
                        color: FinanceDashboardColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      '${l10n.bookingTotalAmountLabel}: ${formatSalonMoneyWithCode(amount, ref.watch(sessionSalonMoneyCurrencyCodeProvider), Localizations.localeOf(context))}',
                      style: const TextStyle(
                        color: FinanceDashboardColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => BookingStatusActionSheet(
                      salonId: salonId,
                      booking: booking,
                    ),
                  );
                },
                child: Text(l10n.ownerBookingManageStatus),
              ),
            ],
          );
        },
      ),
    );
  }
}

