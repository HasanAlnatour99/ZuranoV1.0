import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/booking_statuses.dart';
import '../../../../core/widgets/booking_operations_bar.dart';
import '../../../../core/constants/sale_reporting.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/formatting/sale_payment_method_localized.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bar_leading_back.dart';
import '../../../../core/widgets/app_fade_in.dart';
import '../../../../core/widgets/app_glow_navigation_bar.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_notification_badge.dart';
import '../../../../core/widgets/app_select_field.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../core/widgets/luxury_kpi_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../attendance/data/models/attendance_record.dart';
import '../../../bookings/data/models/booking.dart';
import '../../../sales/data/models/sale.dart';
import '../../../services/data/models/service.dart';
import '../../../users/data/models/app_user.dart';
import '../../../../providers/notification_providers.dart';
import '../../../../providers/auth_session_actions.dart';
import '../../../../providers/repository_providers.dart';
import '../../../bookings/logic/booking_actions.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/session_provider.dart';
import '../../../../providers/money_currency_providers.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

class BarberDashboardScreen extends ConsumerStatefulWidget {
  const BarberDashboardScreen({super.key});

  @override
  ConsumerState<BarberDashboardScreen> createState() =>
      _BarberDashboardScreenState();
}

class _BarberDashboardScreenState extends ConsumerState<BarberDashboardScreen> {
  int _index = 0;

  bool _isTodayBooking(Booking b) {
    if (b.status == BookingStatuses.cancelled ||
        b.status == BookingStatuses.rescheduled) {
      return false;
    }
    final local = b.startAt.toLocal();
    final n = DateTime.now();
    return local.year == n.year && local.month == n.month && local.day == n.day;
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionUserProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return sessionAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: AppLoadingIndicator(size: 40))),
      error: (_, _) => Scaffold(body: Center(child: Text(l10n.genericError))),
      data: (user) {
        if (user == null) {
          return const Scaffold(body: SizedBox.shrink());
        }
        final eid = user.employeeId ?? '';
        final bookingsAsync = ref.watch(bookingsByBarberStreamProvider(eid));
        final attendanceAsync = ref.watch(
          barberAttendanceForDayStreamProvider((day: DateTime.now())),
        );

        Widget body;
        switch (_index) {
          case 0:
            body = bookingsAsync.when(
              loading: () => const Center(child: AppLoadingIndicator(size: 40)),
              error: (_, _) => Center(child: Text(l10n.genericError)),
              data: (bookings) {
                if (eid.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.large),
                      child: Text(
                        l10n.barberNoEmployee,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final today = bookings.where(_isTodayBooking).toList()
                  ..sort((a, b) => a.startAt.compareTo(b.startAt));
                final locale = Localizations.localeOf(context);
                final tf = DateFormat.jm(locale.toString());
                final now = DateTime.now();
                Booking? nextAppt;
                for (final b in today) {
                  if (b.startAt.toLocal().isAfter(now)) {
                    nextAppt = b;
                    break;
                  }
                }
                nextAppt ??= today.isNotEmpty ? today.first : null;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.large,
                          AppSpacing.large,
                          AppSpacing.large,
                          AppSpacing.medium,
                        ),
                        child: _BarberTodaySummary(
                          user: user,
                          todayCount: today.length,
                          nextAppointmentLabel: nextAppt != null
                              ? tf.format(nextAppt.startAt.toLocal())
                              : l10n.barberNextNone,
                          attendanceAsync: attendanceAsync,
                          onQuickSale: () => setState(() => _index = 1),
                        ),
                      ),
                    ),
                    if (today.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.large),
                            child: Text(
                              l10n.barberTodaySubtitle,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.large,
                        ),
                        sliver: SliverList.separated(
                          itemCount: today.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.medium),
                          itemBuilder: (context, i) {
                            final b = today[i];
                            return AppSurfaceCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ListTile(
                                    title: Text(
                                      b.customerName ?? b.customerId,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    subtitle: Text(
                                      '${tf.format(b.startAt.toLocal())} · ${b.serviceName ?? ''}',
                                    ),
                                    trailing: Text(
                                      b.status,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(color: scheme.primary),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.medium,
                                    ),
                                    child: BookingOperationsBar(
                                      booking: b,
                                      onMarkArrived: () async {
                                        try {
                                          await ref
                                              .read(bookingActionsProvider)
                                              .markBookingArrived(b.id);
                                        } on Object catch (_) {}
                                      },
                                      onStartService: () async {
                                        try {
                                          await ref
                                              .read(bookingActionsProvider)
                                              .startBookingService(b.id);
                                        } on Object catch (_) {}
                                      },
                                      onComplete: () async {
                                        try {
                                          await ref
                                              .read(bookingActionsProvider)
                                              .completeBookingService(b.id);
                                        } on Object catch (_) {}
                                      },
                                      onNoShowCustomer: () async {
                                        try {
                                          await ref
                                              .read(bookingActionsProvider)
                                              .markBookingNoShow(
                                                b.id,
                                                party: 'customer',
                                              );
                                        } on Object catch (_) {}
                                      },
                                      onNoShowBarber: () async {
                                        try {
                                          await ref
                                              .read(bookingActionsProvider)
                                              .markBookingNoShow(
                                                b.id,
                                                party: 'barber',
                                              );
                                        } on Object catch (_) {}
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.large),
                    ),
                  ],
                );
              },
            );
            break;
          case 1:
            body = _BarberSaleTab(userSalonId: user.salonId ?? '', user: user);
            break;
          default:
            body = attendanceAsync.when(
              loading: () => const Center(child: AppLoadingIndicator(size: 40)),
              error: (_, _) => Center(child: Text(l10n.genericError)),
              data: (records) {
                if (eid.isEmpty) {
                  return Center(child: Text(l10n.barberNoEmployee));
                }
                return _BarberAttendanceBody(
                  records: records,
                  salonId: user.salonId ?? '',
                  employeeId: eid,
                  employeeName: user.name,
                );
              },
            );
        }

        return Scaffold(
          appBar: AppBar(
            leading: const AppBarLeadingBack(),
            automaticallyImplyLeading: false,
            title: Text(user.name.isNotEmpty ? user.name : l10n.barberTabToday),
            actions: [
              IconButton(
                tooltip: l10n.appSettingsTitle,
                onPressed: () => context.push(AppRoutes.settings),
                icon: const Icon(AppIcons.settings_outlined),
              ),
              IconButton(
                tooltip: l10n.notificationsInboxTooltip,
                onPressed: () => context.push(AppRoutes.notifications),
                icon: Builder(
                  builder: (context) {
                    final n = ref.watch(unreadNotificationCountProvider);
                    return AppNotificationBadge(
                      count: n,
                      child: const Icon(AppIcons.notifications_outlined),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () => performAppSignOut(context),
                child: Text(
                  l10n.customerSignOut,
                  style: TextStyle(color: scheme.primary),
                ),
              ),
            ],
          ),
          body: AppFadeIn(child: body),
          bottomNavigationBar: AppGlowNavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              NavigationDestination(
                icon: const Icon(AppIcons.today_outlined),
                label: l10n.barberTabToday,
              ),
              NavigationDestination(
                icon: const Icon(AppIcons.point_of_sale_outlined),
                label: l10n.barberTabSale,
              ),
              NavigationDestination(
                icon: const Icon(AppIcons.access_time_outlined),
                label: l10n.barberTabAttendance,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BarberTodaySummary extends ConsumerWidget {
  const _BarberTodaySummary({
    required this.user,
    required this.todayCount,
    required this.nextAppointmentLabel,
    required this.attendanceAsync,
    required this.onQuickSale,
  });

  final AppUser user;
  final int todayCount;
  final String nextAppointmentLabel;
  final AsyncValue<List<AttendanceRecord>> attendanceAsync;
  final VoidCallback onQuickSale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final salesAsync = ref.watch(salesStreamProvider);
    final eid = user.employeeId ?? '';
    final now = DateTime.now();
    final code = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    final monthTotal = salesAsync.maybeWhen(
      data: (sales) {
        return sales
            .where(
              (s) =>
                  s.employeeId == eid &&
                  s.status == SaleStatuses.completed &&
                  s.reportYear == now.year &&
                  s.reportMonth == now.month,
            )
            .fold<double>(0, (a, s) => a + s.total);
      },
      orElse: () => -1.0,
    );

    final earningsLabel = monthTotal < 0
        ? l10n.loadingPlaceholder
        : formatAppMoney(monthTotal, code, locale);

    final attLabel = attendanceAsync.maybeWhen(
      data: (records) {
        if (records.isEmpty) {
          return l10n.barberAttendanceNone;
        }
        final sorted = [...records]
          ..sort((a, b) {
            final ba = b.checkInAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final aa = a.checkInAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return ba.compareTo(aa);
          });
        final r = sorted.first;
        if (r.checkOutAt != null) {
          return l10n.barberAttendanceOut;
        }
        if (r.checkInAt != null) {
          return l10n.barberAttendanceIn;
        }
        return l10n.barberAttendanceNone;
      },
      orElse: () => l10n.loadingPlaceholder,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final cross = w >= 560 ? 2 : 1;
            final kpis = [
              LuxuryKpiCard(
                label: l10n.barberSummaryTitle,
                value: l10n.barberSummaryAppointments(todayCount),
                icon: AppIcons.event_available_outlined,
              ),
              LuxuryKpiCard(
                label: l10n.barberNextAppointment,
                value: nextAppointmentLabel,
                icon: AppIcons.schedule_outlined,
              ),
              LuxuryKpiCard(
                label: l10n.barberEarningsMonth,
                value: earningsLabel,
                icon: AppIcons.savings_outlined,
              ),
              LuxuryKpiCard(
                label: l10n.barberAttendanceCardTitle,
                value: attLabel,
                icon: AppIcons.how_to_reg_outlined,
              ),
            ];
            return GridView.count(
              crossAxisCount: cross,
              mainAxisSpacing: AppSpacing.medium,
              crossAxisSpacing: AppSpacing.medium,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: cross == 2 ? 1.5 : 1.4,
              children: kpis,
            );
          },
        ),
        const SizedBox(height: AppSpacing.medium),
        OutlinedButton.icon(
          onPressed: onQuickSale,
          icon: const Icon(AppIcons.point_of_sale_outlined),
          label: Text(l10n.barberQuickSale),
        ),
      ],
    );
  }
}

class _BarberSaleTab extends ConsumerStatefulWidget {
  const _BarberSaleTab({required this.userSalonId, required this.user});

  final String userSalonId;
  final AppUser user;

  @override
  ConsumerState<_BarberSaleTab> createState() => _BarberSaleTabState();
}

class _BarberSaleTabState extends ConsumerState<_BarberSaleTab> {
  SalonService? _service;
  int _qty = 1;
  String _payment = SalePaymentMethods.cash;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);
    final servicesAsync = ref.watch(servicesStreamProvider);
    final uid = widget.user.uid;
    final name = widget.user.name;
    final eid = widget.user.employeeId;

    if (widget.userSalonId.isEmpty || (eid == null || eid.isEmpty)) {
      return Center(child: Text(l10n.barberNoEmployee));
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.large),
      children: [
        Text(
          l10n.barberRecordSaleTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.large),
        Text(
          l10n.barberSaleService,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.small),
        servicesAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => Text(l10n.genericError),
          data: (services) {
            if (services.isEmpty) {
              return Text(l10n.customerNoServicesListed);
            }
            return Column(
              children: services.where((s) => s.isActive).map((s) {
                final sel = _service?.id == s.id;
                return ListTile(
                  title: Text(s.serviceName),
                  subtitle: Text(
                    formatAppMoney(s.price.toDouble(), currencyCode, locale),
                  ),
                  trailing: sel
                      ? Icon(
                          AppIcons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => setState(() => _service = s),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: AppSpacing.large),
        AppSelectField<String>(
          label: l10n.barberSalePayment,
          value: _payment,
          onChanged: (value) {
            if (value != null) {
              setState(() => _payment = value);
            }
          },
          options: [
            AppSelectOption(
              value: SalePaymentMethods.cash,
              label: localizedSalePaymentMethod(l10n, SalePaymentMethods.cash),
            ),
            AppSelectOption(
              value: SalePaymentMethods.card,
              label: localizedSalePaymentMethod(l10n, SalePaymentMethods.card),
            ),
            AppSelectOption(
              value: SalePaymentMethods.digitalWallet,
              label: localizedSalePaymentMethod(
                l10n,
                SalePaymentMethods.digitalWallet,
              ),
            ),
            AppSelectOption(
              value: SalePaymentMethods.other,
              label: localizedSalePaymentMethod(l10n, SalePaymentMethods.other),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        Row(
          children: [
            IconButton(
              onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
              icon: const Icon(AppIcons.remove),
            ),
            Text('$_qty'),
            IconButton(
              onPressed: () => setState(() => _qty++),
              icon: const Icon(AppIcons.add),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.large),
        FilledButton(
          onPressed: _busy || _service == null
              ? null
              : () async {
                  setState(() => _busy = true);
                  final line = SaleLineItem.withComputedTotal(
                    serviceId: _service!.id,
                    serviceName: _service!.serviceName,
                    employeeId: eid,
                    employeeName: name,
                    quantity: _qty,
                    unitPrice: _service!.price,
                  );
                  final sale = Sale.create(
                    salonId: widget.userSalonId,
                    employeeId: eid,
                    employeeName: name,
                    lineItems: [line],
                    paymentMethod: _payment,
                    soldAt: DateTime.now(),
                    createdByUid: uid,
                    createdByName: name,
                  );
                  try {
                    await ref
                        .read(salesRepositoryProvider)
                        .createSale(widget.userSalonId, sale);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.barberSaleSuccess)),
                      );
                      setState(() {
                        _busy = false;
                        _service = null;
                        _qty = 1;
                      });
                    }
                  } on Object catch (_) {
                    if (context.mounted) {
                      setState(() => _busy = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.genericError)),
                      );
                    }
                  }
                },
          child: Text(l10n.barberSaleSubmit),
        ),
      ],
    );
  }
}

class _BarberAttendanceBody extends ConsumerStatefulWidget {
  const _BarberAttendanceBody({
    required this.records,
    required this.salonId,
    required this.employeeId,
    required this.employeeName,
  });

  final List<AttendanceRecord> records;
  final String salonId;
  final String employeeId;
  final String employeeName;

  @override
  ConsumerState<_BarberAttendanceBody> createState() =>
      _BarberAttendanceBodyState();
}

class _BarberAttendanceBodyState extends ConsumerState<_BarberAttendanceBody> {
  bool _busy = false;

  AttendanceRecord? get _openRecord {
    for (final r in widget.records) {
      if (r.checkOutAt == null) {
        return r;
      }
    }
    return null;
  }

  Future<void> _checkIn() async {
    final l10n = AppLocalizations.of(context)!;
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    final now = DateTime.now();
    final workDate = DateTime(now.year, now.month, now.day);
    final record = AttendanceRecord(
      id: '',
      salonId: widget.salonId,
      employeeId: widget.employeeId,
      employeeName: widget.employeeName,
      workDate: workDate,
      status: 'present',
      checkInAt: now,
    );
    try {
      await ref
          .read(attendanceRepositoryProvider)
          .createAttendanceRecord(widget.salonId, record);
      if (mounted) {
        setState(() => _busy = false);
      }
    } on Object catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    }
  }

  Future<void> _checkOut() async {
    final l10n = AppLocalizations.of(context)!;
    final open = _openRecord;
    if (open == null || _busy) {
      return;
    }
    setState(() => _busy = true);
    final updated = AttendanceRecord(
      id: open.id,
      salonId: open.salonId,
      employeeId: open.employeeId,
      employeeName: open.employeeName,
      workDate: open.workDate,
      status: open.status,
      checkInAt: open.checkInAt,
      checkOutAt: DateTime.now(),
      notes: open.notes,
      approvalStatus: open.approvalStatus,
      approvedByUid: open.approvedByUid,
      approvedByName: open.approvedByName,
      approvedAt: open.approvedAt,
      rejectionReason: open.rejectionReason,
      createdAt: open.createdAt,
      updatedAt: open.updatedAt,
    );
    try {
      await ref
          .read(attendanceRepositoryProvider)
          .updateAttendanceRecord(widget.salonId, updated);
      if (mounted) {
        setState(() => _busy = false);
      }
    } on Object catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final open = _openRecord;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.large),
      children: [
        Text(l10n.barberAttendanceTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.small),
        Text(
          l10n.barberAttendanceSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        Row(
          children: [
            FilledButton(
              onPressed: open != null || _busy ? null : _checkIn,
              child: Text(l10n.barberCheckIn),
            ),
            const SizedBox(width: AppSpacing.medium),
            OutlinedButton(
              onPressed: open == null || _busy ? null : _checkOut,
              child: Text(l10n.barberCheckOut),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.large),
        if (widget.records.isEmpty)
          Text(l10n.barberNoAttendance)
        else
          ...widget.records.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.medium),
              child: AppSurfaceCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  title: Text(_barberAttendanceStatusLabel(l10n, r.status)),
                  subtitle: Text(
                    l10n.barberAttendanceInOutLine(
                      r.checkInAt != null
                          ? DateFormat.jm(
                              Localizations.localeOf(context).toString(),
                            ).format(r.checkInAt!.toLocal())
                          : '—',
                      r.checkOutAt != null
                          ? DateFormat.jm(
                              Localizations.localeOf(context).toString(),
                            ).format(r.checkOutAt!.toLocal())
                          : '—',
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

String _barberAttendanceStatusLabel(AppLocalizations l10n, String status) {
  switch (status.toLowerCase()) {
    case 'present':
      return l10n.barberAttendanceStatusPresent;
    case 'absent':
      return l10n.barberAttendanceStatusAbsent;
    case 'late':
      return l10n.barberAttendanceStatusLate;
    case 'leave':
      return l10n.barberAttendanceStatusLeave;
    default:
      return status;
  }
}
