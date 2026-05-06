import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/booking_statuses.dart';
import '../../../../core/formatting/booking_status_localized.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/data/models/booking.dart';
import '../../../bookings/logic/booking_actions.dart';
import '../../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../../../employee_dashboard/application/employee_workspace_scope.dart';
import '../../../employee_today/presentation/employee_today_theme.dart';
import '../../application/employee_bookings_providers.dart';

class EmployeeBookingsScreen extends ConsumerWidget {
  const EmployeeBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(locale);
    final timeFmt = DateFormat.jm(locale);
    final bookingsAsync = ref.watch(employeeBookingsNext7DaysProvider);
    final scope = ref.watch(employeeWorkspaceScopeProvider);

    return Scaffold(
      backgroundColor: EmployeeTodayColors.backgroundSoft,
      appBar: AppBar(
        backgroundColor: EmployeeTodayColors.backgroundSoft,
        foregroundColor: EmployeeTodayColors.deepText,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.employeeBookingsTitle),
            Text(
              l10n.employeeBookingsSubtitle,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: EmployeeTodayColors.mutedText,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: scope == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openBookingCodeDialog(context, ref, scope),
              backgroundColor: EmployeeTodayColors.primaryPurple,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.receipt_long_rounded),
              label: Text(l10n.employeeBookingsAddSaleByCode),
            ),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            Center(child: Text(l10n.genericError)),
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.employeeBookingsEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: EmployeeTodayColors.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: bookings.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final b = bookings[index];
              return _EmployeeBookingTile(
                booking: b,
                l10n: l10n,
                dateFmt: dateFmt,
                timeFmt: timeFmt,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openBookingCodeDialog(
    BuildContext context,
    WidgetRef ref,
    EmployeeWorkspaceScope scope,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addSaleBookingCodeFieldLabel),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: l10n.addSaleBookingCodeExample,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.addSaleRetrieveBooking),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!context.mounted || code == null || code.isEmpty) return;
    await context.push(
      AppRoutes.addSalePrefill(
        employeeId: scope.employeeId,
        staffEmployeeEntry: true,
        bookingCode: code,
      ),
    );
  }
}

class _EmployeeBookingTile extends ConsumerStatefulWidget {
  const _EmployeeBookingTile({
    required this.booking,
    required this.l10n,
    required this.dateFmt,
    required this.timeFmt,
  });

  final Booking booking;
  final AppLocalizations l10n;
  final DateFormat dateFmt;
  final DateFormat timeFmt;

  @override
  ConsumerState<_EmployeeBookingTile> createState() => _EmployeeBookingTileState();
}

class _EmployeeBookingTileState extends ConsumerState<_EmployeeBookingTile> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.l10n.employeeBookingActionSaved)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.l10n.genericError)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final l10n = widget.l10n;
    final canAct = (b.status == BookingStatuses.pending ||
            b.status == BookingStatuses.confirmed) &&
        b.endAt.isAfter(DateTime.now());

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    b.customerName?.trim().isNotEmpty == true
                        ? b.customerName!.trim()
                        : l10n.bookingsPreviewGuestLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: EmployeeTodayColors.deepText,
                    ),
                  ),
                ),
                Text(
                  localizedBookingStatus(l10n, b.status),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: EmployeeTodayColors.primaryPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.dateFmt.format(b.startAt.toLocal())} · ${widget.timeFmt.format(b.startAt.toLocal())}',
              style: const TextStyle(
                color: EmployeeTodayColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              b.serviceName?.trim().isNotEmpty == true
                  ? b.serviceName!.trim()
                  : (b.barberName != null
                        ? formatTeamMemberName(b.barberName)
                        : ''),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: EmployeeTodayColors.deepText,
              ),
            ),
            if (canAct) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _run(() async {
                                await ref
                                    .read(bookingActionsProvider)
                                    .markBookingNoShow(b.id, party: 'customer');
                              }),
                      child: Text(l10n.employeeBookingNotAttended),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy
                          ? null
                          : () => _run(() async {
                                await ref
                                    .read(bookingActionsProvider)
                                    .completeBookingService(b.id);
                              }),
                      style: FilledButton.styleFrom(
                        backgroundColor: EmployeeTodayColors.primaryPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l10n.employeeBookingMarkCompleted),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
