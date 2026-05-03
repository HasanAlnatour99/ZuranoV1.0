import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/formatting/booking_status_localized.dart';
import '../../../../core/motion/app_motion.dart';
import '../../../../core/motion/app_motion_widgets.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bar_leading_back.dart';
import '../../../../core/widgets/app_fade_in.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/customer_salon_streams_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.salonId,
    required this.bookingId,
  });

  final String salonId;
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final key = (salonId: salonId, bookingId: bookingId);
    final bookingAsync = ref.watch(customerBookingStreamProvider(key));
    final salonAsync = ref.watch(customerSalonStreamProvider(salonId));
    final localeTag = Localizations.localeOf(context).toString();
    final timeFmt = DateFormat.jm(localeTag);
    final dateFmt = DateFormat.yMMMd(localeTag);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLeadingBack(),
        automaticallyImplyLeading: false,
        title: Text(l10n.bookingConfirmationTitle),
      ),
      body: bookingAsync.when(
        loading: () => const Center(child: AppLoadingIndicator(size: 40)),
        error: (_, _) => Center(child: Text(l10n.genericError)),
        data: (booking) {
          if (booking == null) {
            return Center(child: Text(l10n.bookingNotFound));
          }
          final salonName = salonAsync.asData?.value?.name ?? salonId;
          final durationMin = booking.endAt
              .difference(booking.startAt)
              .inMinutes;

          return Stack(
            children: [
              AppFadeIn(
                child: AppMotionPlayback(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    children: [
                      const SizedBox(height: AppSpacing.large),
                      Center(
                        child: AppEntranceMotion(
                          motionId: '$bookingId-confirm-hero',
                          index: 0,
                          duration: AppMotion.emphasized,
                          slideOffset: AppMotion.cardSlideOffset,
                          child: Column(
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: scheme.primary.withValues(alpha: 0.1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: scheme.primary.withValues(
                                        alpha: 0.22,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AppSpacing.large,
                                  ),
                                  child:
                                      Icon(
                                            AppIcons.check_rounded,
                                            size: 64,
                                            color: scheme.primary,
                                          )
                                          .animate()
                                          .scale(
                                            duration: 600.ms,
                                            curve: Curves.elasticOut,
                                          )
                                          .then()
                                          .shimmer(
                                            duration: 1200.ms,
                                            color: scheme.onPrimaryContainer
                                                .withValues(alpha: 0.3),
                                          ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      AppEntranceMotion(
                        motionId: '$bookingId-confirm-title',
                        index: 1,
                        duration: AppMotion.cardEntrance,
                        slideOffset: AppMotion.listSlideOffset,
                        child:
                            Text(
                                  l10n.customerBookingSubmitted,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                  textAlign: TextAlign.center,
                                )
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 400.ms)
                                .slideY(begin: 0.2, end: 0),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      Text(
                        'Your appointment is secured. See you soon!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: AppSpacing.large),
                      AppEntranceMotion(
                        motionId: '$bookingId-confirm-card',
                        index: 2,
                        duration: AppMotion.cardEntrance,
                        slideOffset: AppMotion.cardSlideOffset,
                        child: AppSurfaceCard(
                          padding: const EdgeInsets.all(AppSpacing.large),
                          borderRadius: AppRadius.xlarge,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SummaryRow(
                                label: l10n.bookingSalon,
                                value: salonName,
                              ),
                              _SummaryRow(
                                label: l10n.bookingWhen,
                                value:
                                    '${dateFmt.format(booking.startAt.toLocal())} · ${timeFmt.format(booking.startAt.toLocal())}–${timeFmt.format(booking.endAt.toLocal())}',
                              ),
                              _SummaryRow(
                                label: l10n.bookingDuration,
                                value: l10n.bookingDurationMinutes(durationMin),
                              ),
                              if (booking.serviceName != null &&
                                  booking.serviceName!.isNotEmpty)
                                _SummaryRow(
                                  label: l10n.bookingService,
                                  value: booking.serviceName!,
                                ),
                              if (booking.barberName != null &&
                                  booking.barberName!.isNotEmpty)
                                _SummaryRow(
                                  label: l10n.bookingBarber,
                                  value: formatTeamMemberName(booking.barberName),
                                ),
                              _SummaryRow(
                                label: l10n.bookingStatus,
                                value: localizedBookingStatus(
                                  l10n,
                                  booking.status,
                                ),
                              ),
                              if (booking.notes != null &&
                                  booking.notes!.trim().isNotEmpty)
                                _SummaryRow(
                                  label: l10n.bookingNotes,
                                  value: booking.notes!.trim(),
                                ),
                              _SummaryRow(
                                label: l10n.bookingReference,
                                value: booking.id,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.large),
                      AppEntranceMotion(
                        motionId: '$bookingId-confirm-cta',
                        index: 3,
                        duration: AppMotion.medium,
                        slideOffset: AppMotion.listSlideOffset,
                        child: AppPrimaryButton(
                          label: l10n.customerBackHome,
                          onPressed: () => context.go(AppRoutes.customerHome),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IgnorePointer(
                child: Center(
                  child: Lottie.network(
                    'https://assets5.lottiefiles.com/packages/lf20_u4j3ucnx.json', // Sophisticated sparkle/confetti
                    repeat: false,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
