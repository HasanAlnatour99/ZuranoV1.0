import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/booking/availability_schedule.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/motion/app_motion_widgets.dart';
import '../../../../core/widgets/app_bar_leading_back.dart';
import '../../../../core/widgets/app_fade_in.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/keyboard_safe_form_scaffold.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/customer_salon_streams_provider.dart';
import '../../../bookings/data/models/booking.dart';
import '../../../employees/data/models/employee.dart';
import '../../logic/customer_booking_controller.dart';
import '../../logic/customer_booking_state.dart';
import '../customer_booking_error_messages.dart';
import '../widgets/booking_recommendations_section.dart';
import '../widgets/customer_booking_section_header.dart';
import '../widgets/customer_booking_summary_card.dart';
import '../widgets/customer_day_scroller.dart';
import '../../../../providers/money_currency_providers.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

class CustomerBookingScreen extends ConsumerStatefulWidget {
  const CustomerBookingScreen({
    super.key,
    required this.salonId,
    this.rescheduleBooking,
  });

  final String salonId;

  /// When set, saving calls [BookingRepository.rescheduleBooking] instead of create.
  final Booking? rescheduleBooking;

  @override
  ConsumerState<CustomerBookingScreen> createState() =>
      _CustomerBookingScreenState();
}

class _CustomerBookingScreenState extends ConsumerState<CustomerBookingScreen> {
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(customerBookingControllerProvider(widget.salonId).notifier)
          .setRescheduleBooking(widget.rescheduleBooking);
    });
  }

  @override
  void didUpdateWidget(covariant CustomerBookingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rescheduleBooking != widget.rescheduleBooking ||
        oldWidget.salonId != widget.salonId) {
      ref
          .read(customerBookingControllerProvider(widget.salonId).notifier)
          .setRescheduleBooking(widget.rescheduleBooking);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDay(DateTime day) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: day,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      ref
          .read(customerBookingControllerProvider(widget.salonId).notifier)
          .setSelectedDay(picked);
    }
  }

  Future<void> _submit(bool isRescheduleFlow) async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(
      customerBookingControllerProvider(widget.salonId).notifier,
    );
    if (isRescheduleFlow) {
      final ok = await notifier.submitReschedule();
      if (!mounted) {
        return;
      }
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.customerBookingRescheduledToast)),
        );
        context.go(AppRoutes.customerMyBookings);
      }
      return;
    }

    final id = await notifier.submitNewBooking();
    if (!mounted || id == null) {
      return;
    }
    context.go(AppRoutes.customerBookingConfirm(widget.salonId, id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bookingState = ref.watch(
      customerBookingControllerProvider(widget.salonId),
    );
    final day = bookingState.selectedDay ?? DateTime.now();
    final service = bookingState.service;
    final barber = bookingState.barber;
    final slotStartUtc = bookingState.slotStartUtc;
    final dayKey = (
      salonId: widget.salonId,
      day: day,
      barberId: barber?.id ?? '',
    );
    final bookingsAsync = barber != null && barber.id.isNotEmpty
        ? ref.watch(customerBarberDayBookingsStreamProvider(dayKey))
        : const AsyncValue<List<Booking>>.data([]);

    ref.listen<CustomerBookingState>(
      customerBookingControllerProvider(widget.salonId),
      (prev, next) {
        if (prev?.notes != next.notes && _notesController.text != next.notes) {
          _notesController.value = TextEditingValue(
            text: next.notes,
            selection: TextSelection.collapsed(offset: next.notes.length),
          );
        }
      },
    );

    final salonAsync = ref.watch(customerSalonStreamProvider(widget.salonId));
    final servicesAsync = ref.watch(
      customerSalonServicesStreamProvider(widget.salonId),
    );
    final barbersAsync = ref.watch(
      customerSalonBarbersStreamProvider(widget.salonId),
    );

    final locale = Localizations.localeOf(context);
    final localeTag = locale.toString();
    final timeFmt = DateFormat.jm(localeTag);
    final currencyCode = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    final isReschedule = bookingState.isRescheduleFlow;
    final errText = customerBookingSubmissionMessage(
      l10n,
      bookingState.submissionErrorCode,
    );

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLeadingBack(),
        automaticallyImplyLeading: false,
        title: Text(
          isReschedule
              ? l10n.customerRescheduleTitle
              : l10n.customerBookAppointment,
        ),
      ),
      body: AppFadeIn(
        child: AppMotionPlayback(
          child: KeyboardSafeScrollForm(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                salonAsync.when(
                  loading: () => AppSurfaceCard(
                    borderRadius: AppRadius.large,
                    showShadow: false,
                    child: const SizedBox(
                      height: 56,
                      child: Center(child: AppLoadingIndicator(size: 32)),
                    ),
                  ),
                  error: (_, _) => AppSurfaceCard(
                    borderRadius: AppRadius.large,
                    child: Row(
                      children: [
                        Icon(AppIcons.cloud_off_outlined, color: scheme.error),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: Text(
                            l10n.genericError,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  data: (salon) {
                    if (salon == null) {
                      return AppSurfaceCard(
                        borderRadius: AppRadius.large,
                        child: Text(
                          l10n.customerSalonNotFound,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }
                    return AppEntranceMotion(
                      motionId: '${widget.salonId}-salon-hero',
                      index: 0,
                      duration: AppMotion.cardEntrance,
                      child: AppSurfaceCard(
                        borderRadius: AppRadius.large,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              salon.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (salon.address.trim().isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.small),
                              Text(
                                salon.address,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  l10n.customerBookingScreenHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                CustomerBookingSectionHeader(
                  icon: AppIcons.calendar_month_rounded,
                  label: l10n.customerSelectDate,
                ),
                const SizedBox(height: AppSpacing.small),
                AppEntranceMotion(
                  motionId: '${widget.salonId}-date-picker',
                  index: 1,
                  duration: AppMotion.cardEntrance,
                  child: Column(
                    children: [
                      CustomerDayScroller(
                        selectedDay: day,
                        onDaySelected: (d) => ref
                            .read(
                              customerBookingControllerProvider(
                                widget.salonId,
                              ).notifier,
                            )
                            .setSelectedDay(d),
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton.icon(
                          onPressed: () => _pickDay(day),
                          icon: const Icon(AppIcons.event_outlined, size: 18),
                          label: Text(l10n.customerBookingMoreDays),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                CustomerBookingSectionHeader(
                  icon: AppIcons.spa_outlined,
                  label: l10n.customerSelectService,
                ),
                const SizedBox(height: AppSpacing.small),
                servicesAsync.when(
                  loading: () => const SizedBox(
                    height: 100,
                    child: Center(child: AppLoadingIndicator(size: 32)),
                  ),
                  error: (_, _) => Text(l10n.genericError),
                  data: (list) {
                    if (list.isEmpty) {
                      return AppSurfaceCard(
                        borderRadius: AppRadius.large,
                        showShadow: false,
                        child: Text(
                          l10n.customerNoServicesListed,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (var i = 0; i < list.length; i++)
                          AppEntranceMotion(
                            motionId: '${widget.salonId}-service-$i',
                            index: i.clamp(0, AppMotion.maxStaggerSteps),
                            duration: AppMotion.listEntrance,
                            slideOffset: AppMotion.listSlideOffset,
                            child: Builder(
                              builder: (context) {
                                final s = list[i];
                                final selected = service?.id == s.id;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.small,
                                  ),
                                  child: AppSurfaceCard(
                                    borderRadius: AppRadius.large,
                                    onTap: () => ref
                                        .read(
                                          customerBookingControllerProvider(
                                            widget.salonId,
                                          ).notifier,
                                        )
                                        .selectService(s),
                                    color: selected
                                        ? scheme.primary.withValues(alpha: 0.08)
                                        : scheme.surfaceContainer,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: scheme.primary.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.medium,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Icon(
                                              AppIcons.content_cut_outlined,
                                              size: 22,
                                              color: scheme.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: AppSpacing.medium,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                s.serviceName,
                                                style: theme
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(
                                                height: AppSpacing.small,
                                              ),
                                              Text(
                                                l10n.customerServiceMeta(
                                                  s.durationMinutes,
                                                  formatAppMoney(
                                                    s.price,
                                                    currencyCode,
                                                    locale,
                                                  ),
                                                ),
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: scheme
                                                          .onSurfaceVariant,
                                                      height: 1.35,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (selected)
                                          Icon(
                                            AppIcons.check_circle_rounded,
                                            color: scheme.primary,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
                if (service != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  AppEntranceMotion(
                    motionId: '${widget.salonId}-smart-picks',
                    index: 2,
                    duration: AppMotion.sectionExpand,
                    child: AppSurfaceCard(
                      borderRadius: AppRadius.large,
                      child: barbersAsync.when(
                        loading: () => const SizedBox(
                          height: 48,
                          child: Center(child: AppLoadingIndicator(size: 28)),
                        ),
                        error: (_, _) => const SizedBox.shrink(),
                        data: (barbers) => BookingRecommendationsSection(
                          salonId: widget.salonId,
                          serviceId: service.id,
                          selectedLocalDay: day,
                          preferredBarberId: barber?.id,
                          onPick: (barberId, slot) {
                            Employee? emp;
                            for (final b in barbers) {
                              if (b.id == barberId) {
                                emp = b;
                                break;
                              }
                            }
                            if (emp == null) {
                              return;
                            }
                            ref
                                .read(
                                  customerBookingControllerProvider(
                                    widget.salonId,
                                  ).notifier,
                                )
                                .pickRecommendation(barber: emp, slotUtc: slot);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.large),
                CustomerBookingSectionHeader(
                  icon: AppIcons.face_retouching_natural_outlined,
                  label: l10n.customerSelectBarber,
                ),
                const SizedBox(height: AppSpacing.small),
                barbersAsync.when(
                  loading: () => const SizedBox(
                    height: 100,
                    child: Center(child: AppLoadingIndicator(size: 32)),
                  ),
                  error: (_, _) => Text(l10n.genericError),
                  data: (list) {
                    if (list.isEmpty) {
                      return AppSurfaceCard(
                        borderRadius: AppRadius.large,
                        showShadow: false,
                        child: Text(
                          l10n.customerNoBarbers,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }
                    return AppSurfaceCard(
                      borderRadius: AppRadius.large,
                      child: Wrap(
                        spacing: AppSpacing.small,
                        runSpacing: AppSpacing.small,
                        children: [
                          for (var i = 0; i < list.length; i++)
                            AppEntranceMotion(
                              motionId: '${widget.salonId}-barber-chip-$i',
                              index: i.clamp(0, AppMotion.maxStaggerSteps),
                              duration: AppMotion.listEntrance,
                              slideOffset: AppMotion.listSlideOffset,
                              child: Builder(
                                builder: (context) {
                                  final b = list[i];
                                  final selected = barber?.id == b.id;
                                  return FilterChip(
                                    label: TeamMemberNameText(b.name),
                                    selected: selected,
                                    showCheckmark: true,
                                    selectedColor: scheme.primary.withValues(
                                      alpha: 0.18,
                                    ),
                                    checkmarkColor: scheme.primary,
                                    onSelected: (_) => ref
                                        .read(
                                          customerBookingControllerProvider(
                                            widget.salonId,
                                          ).notifier,
                                        )
                                        .selectBarber(b),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                if (service != null && barber != null) ...[
                  const SizedBox(height: AppSpacing.large),
                  CustomerBookingSectionHeader(
                    icon: AppIcons.schedule_rounded,
                    label: l10n.customerSelectTime,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  salonAsync.when(
                    loading: () => const SizedBox(
                      height: 100,
                      child: Center(child: AppLoadingIndicator(size: 32)),
                    ),
                    error: (_, _) => Text(l10n.genericError),
                    data: (salon) {
                      if (salon == null) {
                        return AppSurfaceCard(
                          borderRadius: AppRadius.large,
                          showShadow: false,
                          child: Text(
                            l10n.customerSalonNotFound,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }
                      return bookingsAsync.when(
                        loading: () => const SizedBox(
                          height: 100,
                          child: Center(child: AppLoadingIndicator(size: 32)),
                        ),
                        error: (_, _) => Text(l10n.genericError),
                        data: (existing) {
                          final slots = CustomerSlotPlanner.candidateStartsUtc(
                            selectedLocalDay: day,
                            serviceDurationMinutes: service.durationMinutes,
                            existingBookings: existing,
                            barberId: barber.id,
                            salon: salon,
                            barber: barber,
                            slotStepMinutes: kCustomerSlotStepMinutes,
                          );
                          if (slots.isEmpty) {
                            return AppSurfaceCard(
                              borderRadius: AppRadius.large,
                              showShadow: false,
                              child: Text(
                                l10n.customerNoSlots,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            );
                          }
                          return AppSurfaceCard(
                            borderRadius: AppRadius.large,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.small,
                              horizontal: AppSpacing.small,
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (var i = 0; i < slots.length; i++) ...[
                                    if (i > 0)
                                      const SizedBox(width: AppSpacing.small),
                                    AppEntranceMotion(
                                      motionId:
                                          '${widget.salonId}-slot-$i-${slots[i].millisecondsSinceEpoch}',
                                      index: i.clamp(
                                        0,
                                        AppMotion.maxStaggerSteps,
                                      ),
                                      duration: AppMotion.short,
                                      slideOffset: AppMotion.listSlideOffset,
                                      child: Builder(
                                        builder: (context) {
                                          final utc = slots[i];
                                          final local = utc.toLocal();
                                          final selected = slotStartUtc == utc;
                                          return ChoiceChip(
                                            label: Text(timeFmt.format(local)),
                                            selected: selected,
                                            selectedColor:
                                                scheme.primaryContainer,
                                            labelStyle: theme
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  color: selected
                                                      ? scheme
                                                            .onPrimaryContainer
                                                      : scheme.onSurface,
                                                  fontWeight: selected
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                ),
                                            onSelected: (_) => ref
                                                .read(
                                                  customerBookingControllerProvider(
                                                    widget.salonId,
                                                  ).notifier,
                                                )
                                                .selectSlotUtc(utc),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
                if (service != null &&
                    barber != null &&
                    slotStartUtc != null) ...[
                  const SizedBox(height: AppSpacing.large),
                  AppEntranceMotion(
                    motionId: '${widget.salonId}-summary',
                    index: 0,
                    duration: AppMotion.emphasized,
                    slideOffset: AppMotion.cardSlideOffset,
                    child: CustomerBookingSummaryCard(
                      l10n: l10n,
                      service: service,
                      barber: barber,
                      slotStartUtc: slotStartUtc,
                      localeTag: localeTag,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.large),
                AppTextField(
                  controller: _notesController,
                  label: l10n.customerNotes,
                  textInputAction: TextInputAction.done,
                  maxLines: 3,
                  onChanged: (v) => ref
                      .read(
                        customerBookingControllerProvider(
                          widget.salonId,
                        ).notifier,
                      )
                      .updateNotes(v),
                ),
                if (errText.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.medium),
                  AppSurfaceCard(
                    borderRadius: AppRadius.large,
                    showShadow: false,
                    color: scheme.error.withValues(alpha: 0.08),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          AppIcons.error_outline_rounded,
                          color: scheme.error,
                        ),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: Text(
                            errText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.error,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.large),
                AppPrimaryButton(
                  label: isReschedule
                      ? l10n.customerRescheduleSubmit
                      : l10n.customerConfirmBooking,
                  isLoading: bookingState.isSubmitting,
                  onPressed: bookingState.isSubmitting
                      ? null
                      : () => _submit(bookingState.isRescheduleFlow),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
