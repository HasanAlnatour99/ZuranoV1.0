import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import '../../../../providers/repository_providers.dart';
import '../../../bookings/data/models/booking.dart';
import '../../../../core/formatting/booking_status_localized.dart';
import '../../../../core/constants/booking_statuses.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../providers/money_currency_providers.dart';
import '../../../../core/constants/app_routes.dart';

/// Full-screen salon bookings list (filters, FAB, detail sheets).
class OwnerBookingsScreen extends ConsumerStatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  ConsumerState<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends ConsumerState<OwnerBookingsScreen> {
  DateTime _day = DateTime.now();
  String _status = 'all';
  final String _barberId = 'all';

  DateTime get _dayStartLocal =>
      DateTime(_day.year, _day.month, _day.day, 0, 0, 0);
  DateTime get _dayEndLocal =>
      DateTime(_day.year, _day.month, _day.day, 23, 59, 59);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(sessionUserProvider).asData?.value;
    final salonId = user?.salonId?.trim() ?? '';
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    final bookingsStream = salonId.isEmpty
        ? Stream.value(const <Booking>[])
        : ref.watch(bookingRepositoryProvider).watchBookingsBySalon(
              salonId,
              startFrom: _dayStartLocal.toUtc(),
              startTo: _dayEndLocal.toUtc(),
              limit: 250,
            );

    return Scaffold(
      backgroundColor: FinanceDashboardColors.background,
      appBar: AppBar(
        backgroundColor: FinanceDashboardColors.background,
        foregroundColor: FinanceDashboardColors.textPrimary,
        elevation: 0,
        title: Text(l10n.ownerBookingsListTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: salonId.isEmpty
          ? Center(child: Text(l10n.ownerServicesWaitingForSalon))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              initialDate: _day,
                            );
                            if (picked == null) return;
                            setState(() => _day = picked);
                          },
                          child: Text(
                            MaterialLocalizations.of(context).formatMediumDate(
                              _day,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _status,
                        items: [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text(l10n.ownerBookingsFilterAll),
                          ),
                          const DropdownMenuItem(
                            value: BookingStatuses.pending,
                            child: Text('pending'),
                          ),
                          const DropdownMenuItem(
                            value: BookingStatuses.confirmed,
                            child: Text('confirmed'),
                          ),
                          const DropdownMenuItem(
                            value: 'checkedIn',
                            child: Text('checkedIn'),
                          ),
                          const DropdownMenuItem(
                            value: BookingStatuses.completed,
                            child: Text('completed'),
                          ),
                          const DropdownMenuItem(
                            value: BookingStatuses.cancelled,
                            child: Text('cancelled'),
                          ),
                          const DropdownMenuItem(
                            value: BookingStatuses.noShow,
                            child: Text('no_show'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _status = v ?? 'all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<List<Booking>>(
                      stream: bookingsStream,
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: FinanceDashboardColors.primaryPurple,
                            ),
                          );
                        }
                        final all = snap.data ?? <Booking>[];
                        final filtered = all.where((b) {
                          if (_barberId != 'all' &&
                              b.barberId.trim() != _barberId) {
                            return false;
                          }
                          if (_status == 'all') return true;
                          if (_status == 'checkedIn') {
                            return b.operationalState
                                    .toLowerCase()
                                    .contains('arrived') ||
                                b.operationalState
                                    .toLowerCase()
                                    .contains('customer_arrived');
                          }
                          return b.status == _status;
                        }).toList()
                          ..sort((a, b) => a.startAt.compareTo(b.startAt));

                        if (filtered.isEmpty) {
                          return Center(child: Text(l10n.ownerBookingsEmpty));
                        }

                        return ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final b = filtered[i];
                            final time = MaterialLocalizations.of(context)
                                .formatTimeOfDay(
                              TimeOfDay.fromDateTime(b.startAt.toLocal()),
                            );
                            final total = b.totalAmount;
                            final status = localizedBookingStatus(l10n, b.status);
                            final code = (b.bookingCode ?? '').trim();
                            final pay = (b.paymentStatus ?? '').trim();

                            return InkWell(
                              onTap: () => context.push(
                                AppRoutes.ownerBookingDetails(b.id),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: FinanceDashboardColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border:
                                      Border.all(color: FinanceDashboardColors.border),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 64,
                                      child: Text(
                                        time,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: FinanceDashboardColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            b.customerName ?? b.customerId,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color:
                                                  FinanceDashboardColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            b.serviceName ??
                                                (b.serviceNames.join(', ').trim().isEmpty
                                                    ? '—'
                                                    : b.serviceNames.join(', ')),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: FinanceDashboardColors.textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${b.barberName ?? b.barberId} • $status',
                                            style: const TextStyle(
                                              color: FinanceDashboardColors.textSecondary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          formatSalonMoneyWithCode(
                                            total,
                                            currencyCode,
                                            Localizations.localeOf(context),
                                          ),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: FinanceDashboardColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          pay.isEmpty ? '—' : pay,
                                          style: const TextStyle(
                                            color: FinanceDashboardColors.textSecondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (code.isNotEmpty)
                                          Text(
                                            code,
                                            style: const TextStyle(
                                              color: FinanceDashboardColors.textSecondary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
