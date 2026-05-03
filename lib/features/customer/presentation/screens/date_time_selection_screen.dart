import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart' show AppRouteNames;
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/customer_booking_availability_providers.dart';
import '../../application/customer_booking_currency.dart';
import '../../application/customer_booking_draft_provider.dart';
import '../../data/models/customer_booking_slot.dart';
import '../widgets/booking_summary_bar.dart';
import '../widgets/customer_action_button.dart';
import '../widgets/customer_booking_progress_header.dart';
import '../widgets/customer_date_chip.dart';
import '../widgets/customer_gradient_scaffold.dart';
import '../widgets/time_slot_group_section.dart';

class DateTimeSelectionScreen extends ConsumerStatefulWidget {
  const DateTimeSelectionScreen({super.key, required this.salonId});

  final String salonId;

  @override
  ConsumerState<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState
    extends ConsumerState<DateTimeSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardDraft());
  }

  void _guardDraft() {
    if (!mounted) {
      return;
    }
    final draft = ref.read(customerBookingDraftProvider);
    if (draft.salonId != widget.salonId || !draft.hasServices) {
      context.goNamed(
        AppRouteNames.customerServiceSelection,
        pathParameters: {'salonId': widget.salonId},
      );
      return;
    }
    if (!draft.hasTeamSelection) {
      context.goNamed(
        AppRouteNames.customerTeamSelection,
        pathParameters: {'salonId': widget.salonId},
      );
    }
  }

  void _selectSlot(CustomerBookingSlot slot) {
    final notifier = ref.read(customerBookingDraftProvider.notifier);
    final draft = ref.read(customerBookingDraftProvider);
    if (draft.anyAvailableEmployee &&
        slot.employeeId != null &&
        slot.employeeName != null) {
      notifier.setTeamMember(
        employeeId: slot.employeeId!,
        employeeName: slot.employeeName!,
        keepAnyAvailable: true,
      );
    }
    notifier.setDateTime(startAt: slot.startAt, endAt: slot.endAt);
  }

  void _continue(AppLocalizations l10n) {
    final draft = ref.read(customerBookingDraftProvider);
    if (!draft.hasDateTime) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.customerDateTimeRequiredSnack)),
      );
      return;
    }
    context.pushNamed(
      AppRouteNames.customerDetails,
      pathParameters: {'salonId': widget.salonId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.listen(customerPublicBookingFlowSettingsProvider(widget.salonId), (
      prev,
      next,
    ) {
      next.whenData((settings) {
        final today = DateUtils.dateOnly(DateTime.now());
        final selected = ref.read(selectedCustomerBookingDateProvider);
        if (!settings.allowSameDayBooking &&
            DateUtils.isSameDay(selected, today)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) {
              return;
            }
            ref
                .read(selectedCustomerBookingDateProvider.notifier)
                .setDate(today.add(const Duration(days: 1)));
          });
        }
      });
    });
    final draft = ref.watch(customerBookingDraftProvider);
    final selectedDate = ref.watch(selectedCustomerBookingDateProvider);
    final settingsAsync = ref.watch(
      customerPublicBookingFlowSettingsProvider(widget.salonId),
    );
    final slotsAsync = ref.watch(customerBookingSlotsProvider(widget.salonId));
    final moneyCode = watchCustomerSalonMoneyCode(ref, widget.salonId);
    final total = formatMoney(
      draft.totalAmount,
      moneyCode,
      Localizations.localeOf(context),
    );
    final teamLabel = draft.selectedEmployeeName?.trim().isNotEmpty == true
        ? draft.selectedEmployeeName!
        : l10n.customerTeamSelectionAnyTitle;

    return CustomerGradientScaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          0,
          AppSpacing.large,
          AppSpacing.medium,
        ),
        child: BookingSummaryBar(
          title: l10n.customerDateTimeSummaryTitle(
            draft.serviceCount,
            teamLabel,
          ),
          subtitle: l10n.customerDateTimeSummarySubtitle(
            draft.durationMinutes,
            total,
          ),
          trailing: CustomerActionButton(
            label: l10n.customerServiceSelectionContinue,
            onPressed: draft.hasDateTime ? () => _continue(l10n) : null,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.small,
                  AppSpacing.small,
                  AppSpacing.large,
                  AppSpacing.medium,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.customerDateTimeTitle,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColorsLight.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.customerDateTimeSubtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColorsLight.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                ),
                child: CustomerBookingProgressHeader(
                  stepLabel: l10n.customerDateTimeStepLabel,
                  title: l10n.customerDateTimeProgressTitle,
                  progress: 0.6,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.large)),
            SliverToBoxAdapter(
              child: settingsAsync.when(
                loading: () => const SizedBox(
                  height: 78,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
                error: (_, _) => const SizedBox.shrink(),
                data: (settings) => _DateScroller(
                  selectedDate: selectedDate,
                  maxAdvanceBookingDays: settings.maxAdvanceBookingDays,
                  allowSameDayBooking: settings.allowSameDayBooking,
                  onSelected: (date) => ref
                      .read(selectedCustomerBookingDateProvider.notifier)
                      .setDate(date),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.large)),
            slotsAsync.when(
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.large,
                ),
                sliver: SliverList.separated(
                  itemCount: 3,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.medium),
                  itemBuilder: (_, _) => const _SlotSkeleton(),
                ),
              ),
              error: (_, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: _SlotsEmptyState(
                  title: l10n.genericError,
                  subtitle: l10n.customerSalonDiscoveryRetry,
                ),
              ),
              data: (slots) {
                final available = slots.where((s) => s.isAvailable).toList();
                if (available.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _SlotsEmptyState(
                      title: l10n.customerDateTimeEmpty,
                      subtitle: l10n.customerDateTimeChooseAnotherDate,
                    ),
                  );
                }
                final groups = _groupSlots(slots);
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.large,
                    0,
                    AppSpacing.large,
                    140,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TimeSlotGroupSection(
                          title: l10n.customerDateTimeMorning,
                          slots: groups.morning,
                          selectedStartAt: draft.selectedStartAt,
                          onSlotTap: _selectSlot,
                        ),
                        TimeSlotGroupSection(
                          title: l10n.customerDateTimeAfternoon,
                          slots: groups.afternoon,
                          selectedStartAt: draft.selectedStartAt,
                          onSlotTap: _selectSlot,
                        ),
                        TimeSlotGroupSection(
                          title: l10n.customerDateTimeEvening,
                          slots: groups.evening,
                          selectedStartAt: draft.selectedStartAt,
                          onSlotTap: _selectSlot,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  _SlotGroups _groupSlots(List<CustomerBookingSlot> slots) {
    final morning = <CustomerBookingSlot>[];
    final afternoon = <CustomerBookingSlot>[];
    final evening = <CustomerBookingSlot>[];
    for (final slot in slots) {
      final hour = slot.startAt.hour;
      if (hour < 12) {
        morning.add(slot);
      } else if (hour < 17) {
        afternoon.add(slot);
      } else {
        evening.add(slot);
      }
    }
    return _SlotGroups(morning, afternoon, evening);
  }
}

class _DateScroller extends StatelessWidget {
  const _DateScroller({
    required this.selectedDate,
    required this.maxAdvanceBookingDays,
    required this.allowSameDayBooking,
    required this.onSelected,
  });

  final DateTime selectedDate;
  final int maxAdvanceBookingDays;
  final bool allowSameDayBooking;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dayFormatter = DateFormat.E(locale);
    final dateFormatter = DateFormat.MMMd(locale);
    final today = DateUtils.dateOnly(DateTime.now());
    final firstOffset = allowSameDayBooking ? 0 : 1;
    final span = maxAdvanceBookingDays.clamp(1, 90);
    final count = span;

    return SizedBox(
      height: 72,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
        scrollDirection: Axis.horizontal,
        itemCount: count,
        itemBuilder: (context, index) {
          final date = today.add(Duration(days: firstOffset + index));
          final dayDelta = date.difference(today).inDays;
          final title = dayDelta == 0
              ? l10n.customerDateTimeToday
              : dayDelta == 1
              ? l10n.customerDateTimeTomorrow
              : dayFormatter.format(date);
          return CustomerDateChip(
            title: title,
            subtitle: dateFormatter.format(date),
            selected: DateUtils.isSameDay(selectedDate, date),
            onTap: () => onSelected(date),
          );
        },
      ),
    );
  }
}

class _SlotSkeleton extends StatelessWidget {
  const _SlotSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.xlarge),
      ),
    );
  }
}

class _SlotsEmptyState extends StatelessWidget {
  const _SlotsEmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 48,
              color: AppColorsLight.textSecondary,
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColorsLight.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColorsLight.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotGroups {
  const _SlotGroups(this.morning, this.afternoon, this.evening);

  final List<CustomerBookingSlot> morning;
  final List<CustomerBookingSlot> afternoon;
  final List<CustomerBookingSlot> evening;
}
