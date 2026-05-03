import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/customer_booking_currency.dart';
import '../../data/models/customer_booking_lookup_model.dart';
import 'customer_booking_status_badge.dart';
import 'customer_gradient_scaffold.dart';

class CustomerBookingLookupCard extends ConsumerWidget {
  const CustomerBookingLookupCard({super.key, required this.booking});

  final CustomerBookingLookupModel booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context);
    final dateFormatter = DateFormat.yMMMMEEEEd(locale.toString());
    final timeFormatter = DateFormat.jm(locale.toString());
    final serviceNames = booking.serviceNames.isEmpty
        ? l10n.bookingService
        : booking.serviceNames.join(', ');
    final salonName = booking.salonName.isEmpty
        ? l10n.customerBookingReviewSalon
        : booking.salonName;
    final specialistName = booking.employeeName.isEmpty
        ? l10n.customerBookingLookupAnySpecialist
        : formatTeamMemberName(booking.employeeName);
    final moneyCode = watchCustomerSalonMoneyCode(ref, booking.salonId);

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.xlarge),
      elevation: 0,
      shadowColor: AppBrandColors.primary.withValues(alpha: 0.12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xlarge),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppBrandColors.primary.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salonName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColorsLight.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.bookingCode.isEmpty
                              ? booking.id
                              : booking.bookingCode,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppBrandColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomerBookingStatusBadge(status: booking.status),
                ],
              ),
              const SizedBox(height: AppSpacing.medium),
              _InfoRow(
                icon: Icons.calendar_month_rounded,
                text:
                    '${dateFormatter.format(booking.startAt.toLocal())} · '
                    '${timeFormatter.format(booking.startAt.toLocal())} - '
                    '${timeFormatter.format(booking.endAt.toLocal())}',
              ),
              const SizedBox(height: AppSpacing.small),
              _InfoRow(icon: Icons.content_cut_rounded, text: serviceNames),
              const SizedBox(height: AppSpacing.small),
              _InfoRow(icon: Icons.person_rounded, text: specialistName),
              const SizedBox(height: AppSpacing.small),
              _InfoRow(
                icon: Icons.payments_rounded,
                text: formatMoney(booking.totalAmount, moneyCode, locale),
              ),
              const SizedBox(height: AppSpacing.large),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: CustomerPrimaryButtonStyle.filled(context),
                  onPressed: () {
                    context.pushNamed(
                      AppRouteNames.customerBookingDetails,
                      pathParameters: {
                        'salonId': booking.salonId,
                        'bookingId': booking.id,
                      },
                    );
                  },
                  child: Text(l10n.customerBookingLookupViewDetails),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppBrandColors.primary),
        const SizedBox(width: AppSpacing.small),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColorsLight.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
