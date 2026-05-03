import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/booking/availability_schedule.dart';
import '../../../../core/constants/booking_statuses.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/formatting/booking_status_localized.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_modal_sheet.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/booking_operations_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/data/models/booking.dart';
import '../../../bookings/logic/booking_actions.dart';
import '../../../employees/data/models/employee.dart';
import '../../../services/data/models/service.dart';
import '../../logic/owner_bookings_notifier.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/money_currency_providers.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

bool _sameLocalCalendarDay(DateTime a, DateTime b) {
  final la = a.toLocal();
  final lb = b.toLocal();
  return la.year == lb.year && la.month == lb.month && la.day == lb.day;
}

List<Booking> _bookingsForBarberDay(
  List<Booking> all,
  String barberId,
  DateTime localDay,
) {
  return all
      .where(
        (b) =>
            b.barberId == barberId &&
            _sameLocalCalendarDay(b.startAt, localDay),
      )
      .toList(growable: false);
}

class _OwnerBookingDetailsSheet extends ConsumerStatefulWidget {
  const _OwnerBookingDetailsSheet({
    required this.salonId,
    required this.booking,
    required this.scaffoldContext,
    required this.onReload,
    required this.onReschedule,
  });

  final String salonId;
  final Booking booking;
  final BuildContext scaffoldContext;
  final Future<void> Function() onReload;
  final Future<void> Function(Booking booking) onReschedule;

  @override
  ConsumerState<_OwnerBookingDetailsSheet> createState() =>
      _OwnerBookingDetailsSheetState();
}

class _OwnerBookingDetailsSheetState
    extends ConsumerState<_OwnerBookingDetailsSheet> {
  late final TextEditingController _notesC;

  @override
  void initState() {
    super.initState();
    _notesC = TextEditingController(text: widget.booking.notes ?? '');
  }

  @override
  void dispose() {
    debugPrint('[bottom_sheet_dispose] _OwnerBookingDetailsSheet');
    _notesC.dispose();
    super.dispose();
  }

  Future<void> _reloadAndRefresh() async {
    await widget.onReload();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final b = widget.booking;
    final rootContext = widget.scaffoldContext;
    final canRescheduleOrCancel =
        b.status == BookingStatuses.pending ||
        b.status == BookingStatuses.confirmed;
    final localeTag = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(localeTag);
    final timeFmt = DateFormat.jm(localeTag);

    return AppRawBottomSheetFormBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.ownerBookingDetailsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.medium),
          SelectableText(
            '${l10n.bookingWhen}: ${dateFmt.format(b.startAt.toLocal())} · ${timeFmt.format(b.startAt.toLocal())}',
          ),
          const SizedBox(height: AppSpacing.small),
          SelectableText(
            '${l10n.bookingBarber}: ${(b.barberName?.trim().isNotEmpty == true) ? formatTeamMemberName(b.barberName) : b.barberId}',
          ),
          const SizedBox(height: AppSpacing.small),
          SelectableText('${l10n.bookingService}: ${b.serviceName ?? '—'}'),
          const SizedBox(height: AppSpacing.small),
          SelectableText(
            '${l10n.bookingStatus}: ${localizedBookingStatus(l10n, b.status)}',
          ),
          const SizedBox(height: AppSpacing.small),
          SelectableText(b.customerName ?? b.customerId),
          const SizedBox(height: AppSpacing.large),
          AppTextField(
            controller: _notesC,
            label: l10n.bookingNotes,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.medium),
          AppPrimaryButton(
            label: l10n.ownerBookingSaveNotes,
            onPressed: () async {
              try {
                await ref
                    .read(bookingRepositoryProvider)
                    .updateBooking(
                      widget.salonId,
                      Booking(
                        id: b.id,
                        salonId: b.salonId,
                        barberId: b.barberId,
                        customerId: b.customerId,
                        startAt: b.startAt,
                        endAt: b.endAt,
                        status: b.status,
                        barberName: b.barberName,
                        customerName: b.customerName,
                        serviceId: b.serviceId,
                        serviceName: b.serviceName,
                        notes: _notesC.text.trim().isEmpty
                            ? null
                            : _notesC.text.trim(),
                        slotStepMinutes: b.slotStepMinutes,
                      ),
                    );
                if (rootContext.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    SnackBar(content: Text(l10n.ownerBookingNotesSaved)),
                  );
                  await widget.onReload();
                }
              } on Object catch (_) {
                if (rootContext.mounted) {
                  ScaffoldMessenger.of(
                    rootContext,
                  ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
                }
              }
            },
          ),
          if (b.status == BookingStatuses.pending) ...[
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(bookingRepositoryProvider)
                      .updateBooking(
                        widget.salonId,
                        Booking(
                          id: b.id,
                          salonId: b.salonId,
                          barberId: b.barberId,
                          customerId: b.customerId,
                          startAt: b.startAt,
                          endAt: b.endAt,
                          status: BookingStatuses.confirmed,
                          barberName: b.barberName,
                          customerName: b.customerName,
                          serviceId: b.serviceId,
                          serviceName: b.serviceName,
                          notes: _notesC.text.trim().isEmpty
                              ? null
                              : _notesC.text.trim(),
                          slotStepMinutes: b.slotStepMinutes,
                        ),
                      );
                  if (rootContext.mounted) {
                    Navigator.pop(context);
                    await widget.onReload();
                  }
                } on Object catch (_) {
                  if (rootContext.mounted) {
                    ScaffoldMessenger.of(
                      rootContext,
                    ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
                  }
                }
              },
              child: Text(l10n.bookingStatusConfirmed),
            ),
          ],
          if (canRescheduleOrCancel) ...[
            const SizedBox(height: AppSpacing.medium),
            OutlinedButton(
              onPressed: () async {
                Navigator.pop(context);
                await widget.onReschedule(b);
              },
              child: Text(l10n.customerBookingReschedule),
            ),
            const SizedBox(height: AppSpacing.small),
            TextButton(
              onPressed: () async {
                try {
                  await ref.read(bookingActionsProvider).cancelBooking(b.id);
                  if (rootContext.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      SnackBar(content: Text(l10n.ownerBookingCancelled)),
                    );
                    await widget.onReload();
                  }
                } on Object catch (_) {
                  if (rootContext.mounted) {
                    ScaffoldMessenger.of(
                      rootContext,
                    ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
                  }
                }
              },
              child: Text(l10n.ownerBookingCancel),
            ),
          ],
          const SizedBox(height: AppSpacing.large),
          BookingOperationsBar(
            booking: b,
            onMarkArrived: () async {
              try {
                await ref.read(bookingActionsProvider).markBookingArrived(b.id);
                await _reloadAndRefresh();
              } on Object catch (_) {
                if (rootContext.mounted) {
                  ScaffoldMessenger.of(
                    rootContext,
                  ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
                }
              }
            },
            onStartService: () async {
              try {
                await ref
                    .read(bookingActionsProvider)
                    .startBookingService(b.id);
                await _reloadAndRefresh();
              } on Object catch (_) {
                if (rootContext.mounted) {
                  ScaffoldMessenger.of(
                    rootContext,
                  ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
                }
              }
            },
            onComplete: () async {
              try {
                await ref
                    .read(bookingActionsProvider)
                    .completeBookingService(b.id);
                await _reloadAndRefresh();
              } on Object catch (_) {
                if (rootContext.mounted) {
                  ScaffoldMessenger.of(
                    rootContext,
                  ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
                }
              }
            },
            onNoShowCustomer: () async {
              try {
                await ref
                    .read(bookingActionsProvider)
                    .markBookingNoShow(b.id, party: 'customer');
                await _reloadAndRefresh();
              } on Object catch (_) {
                if (rootContext.mounted) {
                  ScaffoldMessenger.of(
                    rootContext,
                  ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
                }
              }
            },
            onNoShowBarber: () async {
              try {
                await ref
                    .read(bookingActionsProvider)
                    .markBookingNoShow(b.id, party: 'barber');
                await _reloadAndRefresh();
              } on Object catch (_) {
                if (rootContext.mounted) {
                  ScaffoldMessenger.of(
                    rootContext,
                  ).showSnackBar(SnackBar(content: Text(l10n.genericError)));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class OwnerBookingsModule extends ConsumerStatefulWidget {
  const OwnerBookingsModule({super.key, required this.salonId});

  final String salonId;

  @override
  ConsumerState<OwnerBookingsModule> createState() =>
      _OwnerBookingsModuleState();
}

class _OwnerBookingsModuleState extends ConsumerState<OwnerBookingsModule> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(ownerBookingsNotifierProvider.notifier);
      notifier.setSalonId(widget.salonId);
      notifier.reload();
    });
  }

  @override
  void didUpdateWidget(covariant OwnerBookingsModule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.salonId != widget.salonId) {
      final notifier = ref.read(ownerBookingsNotifierProvider.notifier);
      notifier.setSalonId(widget.salonId);
      notifier.reload();
    }
  }

  Future<void> _reload() {
    final notifier = ref.read(ownerBookingsNotifierProvider.notifier);
    notifier.setSalonId(widget.salonId);
    return notifier.reload();
  }

  Future<void> _loadMore() {
    final notifier = ref.read(ownerBookingsNotifierProvider.notifier);
    notifier.setSalonId(widget.salonId);
    return notifier.loadMore();
  }

  Future<void> _openDetails(Booking b) async {
    final rootContext = context;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _OwnerBookingDetailsSheet(
        salonId: widget.salonId,
        booking: b,
        scaffoldContext: rootContext,
        onReload: _reload,
        onReschedule: _openReschedule,
      ),
    );
  }

  Future<void> _openReschedule(Booking b) async {
    final l10n = AppLocalizations.of(context)!;
    final root = context;
    DateTime day = DateTime(
      b.startAt.toLocal().year,
      b.startAt.toLocal().month,
      b.startAt.toLocal().day,
    );
    DateTime? slotUtc;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final salonAsync = ref.watch(sessionSalonStreamProvider);
            final employeesAsync = ref.watch(employeesStreamProvider);
            final servicesAsync = ref.watch(servicesStreamProvider);
            final bookingsAsync = ref.watch(bookingsStreamProvider);
            final locale = Localizations.localeOf(context);
            final localeTag = locale.toString();
            final timeFmt = DateFormat.jm(localeTag);

            return StatefulBuilder(
              builder: (context, setModal) {
                return AppRawBottomSheetFormBody(
                  child: salonAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => Text(l10n.genericError),
                    data: (salon) {
                      if (salon == null) {
                        return Text(l10n.genericError);
                      }
                      SalonService? svc;
                      Employee? barber;
                      final sv = servicesAsync.asData?.value;
                      final ev = employeesAsync.asData?.value;
                      if (sv != null && b.serviceId != null) {
                        for (final s in sv) {
                          if (s.id == b.serviceId) {
                            svc = s;
                            break;
                          }
                        }
                      }
                      if (ev != null) {
                        for (final e in ev) {
                          if (e.id == b.barberId) {
                            barber = e;
                            break;
                          }
                        }
                      }
                      var duration = b.endAt.difference(b.startAt).inMinutes;
                      if (duration <= 0) {
                        duration = 30;
                      }
                      if (svc != null) {
                        duration = svc.durationMinutes;
                      }
                      final allBookings = bookingsAsync.asData?.value ?? [];
                      final dayBusy = _bookingsForBarberDay(
                        allBookings,
                        b.barberId,
                        day,
                      ).where((x) => x.id != b.id).toList();

                      final slots = svc != null && barber != null
                          ? CustomerSlotPlanner.candidateStartsUtc(
                              selectedLocalDay: day,
                              serviceDurationMinutes: duration,
                              existingBookings: dayBusy,
                              barberId: b.barberId,
                              salon: salon,
                              barber: barber,
                              slotStepMinutes:
                                  b.slotStepMinutes ?? kCustomerSlotStepMinutes,
                            )
                          : <DateTime>[];

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.customerRescheduleTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: day,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setModal(() {
                                  day = picked;
                                  slotUtc = null;
                                });
                              }
                            },
                            icon: const Icon(AppIcons.calendar_today_outlined),
                            label: Text(
                              DateFormat.yMMMd(localeTag).format(day),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          if (slots.isEmpty)
                            Text(
                              l10n.customerNoSlots,
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          else
                            Wrap(
                              spacing: AppSpacing.small,
                              runSpacing: AppSpacing.small,
                              children: slots.map((utc) {
                                final local = utc.toLocal();
                                final selected = slotUtc == utc;
                                return ChoiceChip(
                                  label: Text(timeFmt.format(local)),
                                  selected: selected,
                                  onSelected: (_) =>
                                      setModal(() => slotUtc = utc),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: AppSpacing.large),
                          AppPrimaryButton(
                            label: l10n.customerRescheduleSubmit,
                            onPressed: slotUtc == null
                                ? null
                                : () async {
                                    final start = slotUtc!;
                                    final end = start.add(
                                      Duration(minutes: duration),
                                    );
                                    try {
                                      await ref
                                          .read(bookingActionsProvider)
                                          .rescheduleBooking(
                                            bookingId: b.id,
                                            startAt: start,
                                            endAt: end,
                                            slotStepMinutes:
                                                b.slotStepMinutes ??
                                                kCustomerSlotStepMinutes,
                                          );
                                      if (root.mounted) {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(root).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              l10n.ownerBookingRescheduled,
                                            ),
                                          ),
                                        );
                                        await _reload();
                                      }
                                    } on Object catch (_) {
                                      if (root.mounted) {
                                        ScaffoldMessenger.of(root).showSnackBar(
                                          SnackBar(
                                            content: Text(l10n.genericError),
                                          ),
                                        );
                                      }
                                    }
                                  },
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _openCreateBooking() async {
    final l10n = AppLocalizations.of(context)!;
    final root = context;
    await showOwnerNewBookingSheet(
      context,
      salonId: widget.salonId,
      onCreated: () async {
        if (root.mounted) {
          ScaffoldMessenger.of(
            root,
          ).showSnackBar(SnackBar(content: Text(l10n.ownerBookingCreated)));
          await _reload();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final localeTag = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(localeTag);
    final timeFmt = DateFormat.jm(localeTag);

    final state = ref.watch(ownerBookingsNotifierProvider);
    final notifier = ref.read(ownerBookingsNotifierProvider.notifier);
    final hasMore = state.lastPage?.hasMore ?? false;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _reload,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.large,
                  AppSpacing.large,
                  AppSpacing.large,
                  AppSpacing.small,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l10n.ownerBookingsListTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                ),
                sliver: SliverToBoxAdapter(
                  child: Wrap(
                    spacing: AppSpacing.small,
                    runSpacing: AppSpacing.small,
                    children: [
                      ChoiceChip(
                        label: Text(l10n.ownerFilterAll),
                        selected: state.statusFilter.isEmpty,
                        onSelected: (_) => notifier.setStatusFilter(''),
                      ),
                      ChoiceChip(
                        label: Text(
                          localizedBookingStatus(l10n, BookingStatuses.pending),
                        ),
                        selected: state.statusFilter == BookingStatuses.pending,
                        onSelected: (_) =>
                            notifier.setStatusFilter(BookingStatuses.pending),
                      ),
                      ChoiceChip(
                        label: Text(
                          localizedBookingStatus(
                            l10n,
                            BookingStatuses.confirmed,
                          ),
                        ),
                        selected:
                            state.statusFilter == BookingStatuses.confirmed,
                        onSelected: (_) =>
                            notifier.setStatusFilter(BookingStatuses.confirmed),
                      ),
                      ChoiceChip(
                        label: Text(
                          localizedBookingStatus(
                            l10n,
                            BookingStatuses.completed,
                          ),
                        ),
                        selected:
                            state.statusFilter == BookingStatuses.completed,
                        onSelected: (_) =>
                            notifier.setStatusFilter(BookingStatuses.completed),
                      ),
                      ChoiceChip(
                        label: Text(
                          localizedBookingStatus(
                            l10n,
                            BookingStatuses.cancelled,
                          ),
                        ),
                        selected:
                            state.statusFilter == BookingStatuses.cancelled,
                        onSelected: (_) =>
                            notifier.setStatusFilter(BookingStatuses.cancelled),
                      ),
                      ChoiceChip(
                        label: Text(
                          localizedBookingStatus(l10n, BookingStatuses.noShow),
                        ),
                        selected: state.statusFilter == BookingStatuses.noShow,
                        onSelected: (_) =>
                            notifier.setStatusFilter(BookingStatuses.noShow),
                      ),
                      ChoiceChip(
                        label: Text(
                          localizedBookingStatus(
                            l10n,
                            BookingStatuses.rescheduled,
                          ),
                        ),
                        selected:
                            state.statusFilter == BookingStatuses.rescheduled,
                        onSelected: (_) => notifier.setStatusFilter(
                          BookingStatuses.rescheduled,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.large),
              ),
              if (state.isLoading)
                const SliverToBoxAdapter(child: BookingsListSkeleton())
              else if (state.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: AppEmptyState(
                      title: l10n.ownerBookingsListTitle,
                      message: l10n.ownerOverviewSubtitle,
                      icon: AppIcons.event_outlined,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final b = state.items[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.large,
                        vertical: AppSpacing.small,
                      ),
                      child: Card(
                        child: InkWell(
                          onTap: () => _openDetails(b),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.small,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ListTile(
                                  title: Text(b.customerName ?? b.customerId),
                                  subtitle: Text(
                                    '${dateFmt.format(b.startAt.toLocal())} · ${timeFmt.format(b.startAt.toLocal())} · ${b.serviceName ?? ''}',
                                  ),
                                  trailing: Icon(
                                    AppIcons.chevron_right,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: state.items.length),
                ),
              if (!state.isLoading && hasMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: Center(
                      child: state.isLoadingMore
                          ? const CircularProgressIndicator()
                          : TextButton(
                              onPressed: _loadMore,
                              child: Text(l10n.ownerBookingsLoadMore),
                            ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
        PositionedDirectional(
          end: AppSpacing.large,
          bottom: AppSpacing.large,
          child: FloatingActionButton(
            heroTag: 'owner_bookings_add_fab',
            onPressed: widget.salonId.isEmpty
                ? null
                : () => _openCreateBooking(),
            child: const Icon(AppIcons.add),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet that captures everything needed to create a new owner-side
/// booking (customer info, service, barber, time slot). Exposed as a public
/// widget so the Owner overview quick action can open the exact same form via
/// [showOwnerNewBookingSheet].
class OwnerNewBookingSheet extends ConsumerStatefulWidget {
  const OwnerNewBookingSheet({
    super.key,
    required this.salonId,
    required this.onCreated,
  });

  final String salonId;
  final VoidCallback onCreated;

  @override
  ConsumerState<OwnerNewBookingSheet> createState() =>
      _OwnerNewBookingSheetState();
}

/// Opens [OwnerNewBookingSheet] as a modal bottom sheet. The optional
/// [onCreated] callback fires after Firestore confirms the booking.
Future<void> showOwnerNewBookingSheet(
  BuildContext context, {
  required String salonId,
  VoidCallback? onCreated,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => OwnerNewBookingSheet(
      salonId: salonId,
      onCreated: () {
        if (Navigator.canPop(ctx)) {
          Navigator.pop(ctx);
        }
        onCreated?.call();
      },
    ),
  );
}

class _OwnerNewBookingSheetState extends ConsumerState<OwnerNewBookingSheet> {
  final _customerUidC = TextEditingController();
  final _customerNameC = TextEditingController();
  final _notesC = TextEditingController();
  DateTime _day = DateTime.now();
  SalonService? _service;
  Employee? _barber;
  DateTime? _slotUtc;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    debugPrint('[bottom_sheet_dispose] _OwnerNewBookingSheet');
    _customerUidC.dispose();
    _customerNameC.dispose();
    _notesC.dispose();
    super.dispose();
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _day = picked;
        _slotUtc = null;
      });
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final uid = _customerUidC.text.trim();
    if (uid.isEmpty) {
      setState(() => _error = l10n.ownerBookingCustomerUidInvalid);
      return;
    }
    if (_service == null || _barber == null || _slotUtc == null) {
      setState(() => _error = l10n.customerBookingIncomplete);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final start = _slotUtc!;
    final end = start.add(Duration(minutes: _service!.durationMinutes));
    try {
      await ref
          .read(bookingActionsProvider)
          .createBooking(
            Booking(
              id: '',
              salonId: widget.salonId,
              barberId: _barber!.id,
              customerId: uid,
              startAt: start,
              endAt: end,
              status: BookingStatuses.pending,
              barberName: _barber!.name,
              customerName: _customerNameC.text.trim().isEmpty
                  ? null
                  : _customerNameC.text.trim(),
              serviceId: _service!.id,
              serviceName: _service!.serviceName,
              notes: _notesC.text.trim().isEmpty ? null : _notesC.text.trim(),
            ),
            slotStepMinutes: kCustomerSlotStepMinutes,
          );
      widget.onCreated();
    } on Object catch (e) {
      setState(() {
        _submitting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final salonAsync = ref.watch(sessionSalonStreamProvider);
    final servicesAsync = ref.watch(servicesStreamProvider);
    final barbersAsync = ref.watch(employeesStreamProvider);
    final bookingsAsync = ref.watch(bookingsStreamProvider);
    final locale = Localizations.localeOf(context);
    final localeTag = locale.toString();
    final timeFmt = DateFormat.jm(localeTag);
    final dateFmt = DateFormat.yMMMd(localeTag);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    final servicesList = servicesAsync.asData?.value;
    final activeServices = servicesList == null
        ? const <SalonService>[]
        : servicesList.where((s) => s.isActive).toList();

    final employeesList = barbersAsync.asData?.value;
    final barbers = employeesList == null
        ? const <Employee>[]
        : employeesList.where((e) => e.isActive).toList();

    final salon = salonAsync.asData?.value;
    final allBookings = bookingsAsync.asData?.value ?? [];
    final dayBusy = _barber != null
        ? _bookingsForBarberDay(allBookings, _barber!.id, _day)
        : const <Booking>[];

    final slots = salon != null && _service != null && _barber != null
        ? CustomerSlotPlanner.candidateStartsUtc(
            selectedLocalDay: _day,
            serviceDurationMinutes: _service!.durationMinutes,
            existingBookings: dayBusy,
            barberId: _barber!.id,
            salon: salon,
            barber: _barber,
            slotStepMinutes: kCustomerSlotStepMinutes,
          )
        : <DateTime>[];

    return AppRawBottomSheetFormBody(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.ownerBookingNewTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.medium),
          AppTextField(
            label: l10n.ownerBookingCustomerUid,
            controller: _customerUidC,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            l10n.ownerBookingCustomerUidHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          AppTextField(
            label: l10n.ownerBookingCustomerNameOptional,
            controller: _customerNameC,
          ),
          const SizedBox(height: AppSpacing.large),
          Text(
            l10n.customerSelectDate,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          OutlinedButton.icon(
            onPressed: _pickDay,
            icon: const Icon(AppIcons.calendar_today_outlined),
            label: Text(dateFmt.format(_day)),
          ),
          const SizedBox(height: AppSpacing.large),
          Text(
            l10n.customerSelectService,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          if (activeServices.isEmpty)
            Text(
              l10n.customerNoServicesListed,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          else
            ...activeServices.map((s) {
              final selected = _service?.id == s.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.small),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected ? scheme.primary : scheme.outline,
                    ),
                  ),
                  title: Text(s.serviceName),
                  subtitle: Text(
                    l10n.customerServiceMeta(
                      s.durationMinutes,
                      formatAppMoney(s.price, currencyCode, locale),
                    ),
                  ),
                  trailing: selected
                      ? Icon(AppIcons.check_circle, color: scheme.primary)
                      : null,
                  onTap: () => setState(() {
                    _service = s;
                    _slotUtc = null;
                  }),
                ),
              );
            }),
          const SizedBox(height: AppSpacing.large),
          Text(
            l10n.customerSelectBarber,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          if (barbers.isEmpty)
            Text(
              l10n.customerNoBarbers,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: barbers.map((b) {
                final selected = _barber?.id == b.id;
                return ChoiceChip(
                  label: TeamMemberNameText(b.name),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _barber = b;
                    _slotUtc = null;
                  }),
                );
              }).toList(),
            ),
          if (_service != null && _barber != null && salon != null) ...[
            const SizedBox(height: AppSpacing.large),
            Text(
              l10n.customerSelectTime,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            if (slots.isEmpty)
              Text(
                l10n.customerNoSlots,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.small,
                runSpacing: AppSpacing.small,
                children: slots.map((utc) {
                  final local = utc.toLocal();
                  final selected = _slotUtc == utc;
                  return ChoiceChip(
                    label: Text(timeFmt.format(local)),
                    selected: selected,
                    onSelected: (_) => setState(() => _slotUtc = utc),
                  );
                }).toList(),
              ),
          ],
          const SizedBox(height: AppSpacing.large),
          AppTextField(
            controller: _notesC,
            label: l10n.customerNotes,
            maxLines: 3,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.medium),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ],
          const SizedBox(height: AppSpacing.large),
          AppPrimaryButton(
            label: l10n.ownerBookingCreate,
            isLoading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class BookingsListSkeleton extends StatelessWidget {
  const BookingsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (i) => const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.large,
            vertical: AppSpacing.small,
          ),
          child: AppSkeletonBlock(height: 80),
        ),
      ),
    );
  }
}
