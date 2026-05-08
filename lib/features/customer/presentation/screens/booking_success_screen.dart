import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/customer_booking_draft_provider.dart';
import '../../application/customer_salon_profile_providers.dart';
import '../../data/models/customer_booking_create_result.dart';
import '../../../customer_home/presentation/controllers/customer_home_providers.dart'
    show customerRecentActivityRepositoryProvider, lastBookedProvider;
import '../../../customer_home/data/models/last_booked_model.dart';
import '../widgets/booking_success_action_button.dart';
import '../widgets/booking_success_summary_card.dart';
import '../widgets/customer_gradient_scaffold.dart';

class BookingSuccessScreen extends ConsumerStatefulWidget {
  const BookingSuccessScreen({
    super.key,
    required this.salonId,
    required this.bookingId,
    this.result,
  });

  final String salonId;
  final String bookingId;
  final CustomerBookingCreateResult? result;

  @override
  ConsumerState<BookingSuccessScreen> createState() =>
      _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends ConsumerState<BookingSuccessScreen> {
  bool _savedLastBooked = false;
  String _draftPhone = '';
  String? _draftServiceName;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(customerBookingDraftProvider);
    final normalizedPhone = draft.customerPhoneNormalized?.trim() ?? '';
    final rawPhone = draft.customerPhone?.trim() ?? '';
    _draftPhone = normalizedPhone.isNotEmpty ? normalizedPhone : rawPhone;
    _draftServiceName = draft.selectedServices.isNotEmpty
        ? draft.selectedServices.first.displayTitle.trim()
        : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(customerBookingDraftProvider.notifier).reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = widget.result;
    final locale = Localizations.localeOf(context);
    final dateFormatter = DateFormat.yMMMMd(locale.toString());
    final timeFormatter = DateFormat.jm(locale.toString());
    final salonAsync = ref.watch(customerSalonProfileProvider(widget.salonId));
    final salonName = salonAsync.maybeWhen(
      data: (salon) => salon?.salonName ?? '',
      orElse: () => '',
    );
    final bookingCode = result?.bookingCode ?? widget.bookingId;
    final status = result?.status ?? l10n.customerBookingSuccessStatusFallback;
    final date = result == null
        ? l10n.customerBookingSuccessFallback
        : dateFormatter.format(result.startAt.toLocal());
    final time = result == null
        ? l10n.customerBookingSuccessFallback
        : '${timeFormatter.format(result.startAt.toLocal())} - ${timeFormatter.format(result.endAt.toLocal())}';

    if (!_savedLastBooked && result != null) {
      _savedLastBooked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await ref.read(customerRecentActivityRepositoryProvider).saveLastBooked(
                LastBookedModel(
                  bookingCode: result.bookingCode,
                  customerPhone: _draftPhone,
                  salonId: widget.salonId,
                  salonName: salonName,
                  serviceName: _draftServiceName,
                  bookingDateText: '$date · $time',
                  bookingId: widget.bookingId,
                  savedAt: DateTime.now(),
                ),
              );
          ref.invalidate(lastBookedProvider);
        } catch (_) {}
      });
    }

    return CustomerGradientScaffold(
      child: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _SuccessMark(),
                    const SizedBox(height: AppSpacing.large),
                    Text(
                      l10n.customerBookingSuccessTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColorsLight.textPrimary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      l10n.customerBookingSuccessSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColorsLight.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xlarge),
                    BookingSuccessSummaryCard(
                      bookingCodeLabel: l10n.customerBookingSuccessCode,
                      statusLabel: l10n.customerBookingSuccessStatus,
                      dateLabel: l10n.customerBookingSuccessDate,
                      timeLabel: l10n.customerBookingSuccessTime,
                      salonLabel: l10n.customerBookingReviewSalon,
                      bookingCode: bookingCode,
                      status: status,
                      date: date,
                      time: time,
                      salonName: salonName,
                      copyMessage: l10n.customerBookingSuccessCodeCopied,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    _InfoCard(message: l10n.customerBookingSuccessSaveCodeInfo),
                    const SizedBox(height: AppSpacing.xlarge),
                    BookingSuccessActionButton(
                      label: l10n.customerBookingSuccessViewBooking,
                      icon: Icons.receipt_long_rounded,
                      isPrimary: true,
                      onPressed: () => context.goNamed(
                        AppRouteNames.customerBookingDetails,
                        pathParameters: {
                          'salonId': widget.salonId,
                          'bookingId': widget.bookingId,
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    BookingSuccessActionButton(
                      label: l10n.customerBookingSuccessCopyCode,
                      icon: Icons.copy_rounded,
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: bookingCode),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.customerBookingSuccessCodeCopied),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.small),
                    BookingSuccessActionButton(
                      label: l10n.customerBookingSuccessShareBooking,
                      icon: Icons.share_outlined,
                      onPressed: () {
                        SharePlus.instance.share(
                          ShareParams(
                            text: l10n.customerBookingSuccessPlaceholder(
                              bookingCode,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.small),
                    BookingSuccessActionButton(
                      label: l10n.customerBookingSuccessAddToCalendar,
                      icon: Icons.event_available_outlined,
                      onPressed: result == null
                          ? null
                          : () async {
                              try {
                                final serviceName =
                                    (_draftServiceName?.trim().isNotEmpty == true)
                                        ? _draftServiceName!.trim()
                                        : l10n.customerBookingReviewServices;
                                final salon = salonAsync.asData?.value;
                                final name = salon?.salonName.trim().isNotEmpty == true
                                    ? salon!.salonName.trim()
                                    : salonName.trim();
                                final title = '$serviceName at ${name.isEmpty ? widget.salonId : name}';

                                final locationParts = <String>[
                                  if (salon?.formattedAddress?.trim().isNotEmpty ==
                                      true)
                                    salon!.formattedAddress!.trim(),
                                  if (salon?.area.trim().isNotEmpty == true)
                                    salon!.area.trim(),
                                ];
                                final location = locationParts.toSet().join(' · ');

                                final contactParts = <String>[
                                  if (salon?.phone?.trim().isNotEmpty == true)
                                    'Phone: ${salon!.phone!.trim()}',
                                  if (salon?.whatsapp?.trim().isNotEmpty == true)
                                    'WhatsApp: ${salon!.whatsapp!.trim()}',
                                ];

                                final description = [
                                  'Booking code: $bookingCode',
                                  'Status: $status',
                                  if (contactParts.isNotEmpty) ...contactParts,
                                ].join('\n');

                                final event = Event(
                                  title: title,
                                  description: description,
                                  location: location.isEmpty ? null : location,
                                  startDate: result.startAt.toLocal(),
                                  endDate: result.endAt.toLocal(),
                                );

                                await Add2Calendar.addEvent2Cal(event);
                              } catch (_) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.customerBookingSuccessCalendarFailed,
                                    ),
                                  ),
                                );
                              }
                            },
                    ),
                    const SizedBox(height: AppSpacing.small),
                    BookingSuccessActionButton(
                      label: l10n.customerBookingSuccessBookAnother,
                      icon: Icons.add_circle_outline_rounded,
                      onPressed: () {
                        ref.read(customerBookingDraftProvider.notifier).reset();
                        context.goNamed(AppRouteNames.customerSalonDiscovery);
                      },
                    ),
                    const SizedBox(height: AppSpacing.small),
                    BookingSuccessActionButton(
                      label: l10n.customerBookingSuccessBackToSalon,
                      icon: Icons.storefront_rounded,
                      onPressed: () => context.goNamed(
                        AppRouteNames.customerSalonProfile,
                        pathParameters: {'salonId': widget.salonId},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: const Color(0xFFEFFDF5),
        borderRadius: BorderRadius.circular(AppRadius.xlarge),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withValues(alpha: 0.14),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: const Icon(
        Icons.check_circle_rounded,
        color: Color(0xFF16A34A),
        size: 56,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppBrandColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppBrandColors.primary),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColorsLight.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
