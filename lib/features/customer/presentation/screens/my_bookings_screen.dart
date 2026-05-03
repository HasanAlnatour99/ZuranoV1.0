import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/booking_statuses.dart';
import '../../../../core/firestore/firestore_page.dart';
import '../../../../core/formatting/booking_status_localized.dart';
import '../../../../core/text/team_member_name.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bar_leading_back.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../bookings/data/models/booking.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/session_provider.dart';
import 'package:barber_shop_app/core/ui/app_icons.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  final List<Booking> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _pageError;
  FirestorePage<Booking>? _lastPage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reload();
    });
  }

  Future<void> _reload() async {
    final uid = ref.read(sessionUserProvider).asData?.value?.uid ?? '';
    if (!mounted) {
      return;
    }
    if (uid.isEmpty) {
      setState(() {
        _items.clear();
        _loading = false;
        _lastPage = null;
        _pageError = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _pageError = null;
    });
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final page = await repo.getCustomerBookingsPage(uid, limit: 25);
      if (!mounted) {
        return;
      }
      setState(() {
        _items
          ..clear()
          ..addAll(page.items);
        _lastPage = page;
        _loading = false;
      });
    } on Object catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _pageError = 'error';
      });
    }
  }

  Future<void> _loadMore() async {
    final uid = ref.read(sessionUserProvider).asData?.value?.uid ?? '';
    final prev = _lastPage;
    if (uid.isEmpty || prev == null || !prev.hasMore || _loadingMore) {
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final repo = ref.read(bookingRepositoryProvider);
      final page = await repo.getCustomerBookingsNextPage(uid, prev);
      if (!mounted) {
        return;
      }
      setState(() {
        _items.addAll(page.items);
        _lastPage = FirestorePage(
          items: page.items,
          limit: page.limit,
          lastDocument: page.lastDocument,
        );
        _loadingMore = false;
      });
    } on Object catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _loadingMore = false);
    }
  }

  bool _isUpcoming(Booking b) {
    if (b.startAt.isBefore(DateTime.now())) {
      return false;
    }
    return b.status == BookingStatuses.pending ||
        b.status == BookingStatuses.confirmed;
  }

  bool _canCustomerChangeBooking(Booking b) {
    return (b.status == BookingStatuses.pending ||
            b.status == BookingStatuses.confirmed) &&
        b.endAt.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final localeTag = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(localeTag);
    final timeFmt = DateFormat.jm(localeTag);

    final upcoming = _items.where(_isUpcoming).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    final past = _items.where((b) => !_isUpcoming(b)).toList()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));

    final hasMore = _lastPage?.hasMore ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBarLeadingBack(),
        automaticallyImplyLeading: false,
        title: Text(l10n.customerMyBookings),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.large),
                children: const [
                  AppSkeletonBlock(height: 88),
                  SizedBox(height: AppSpacing.medium),
                  AppSkeletonBlock(height: 88),
                  SizedBox(height: AppSpacing.medium),
                  AppSkeletonBlock(height: 88),
                ],
              )
            : _pageError != null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.large),
                children: [Center(child: Text(l10n.genericError))],
              )
            : _items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.large),
                children: [
                  AppEmptyState(
                    title: l10n.customerMyBookings,
                    message: l10n.customerMyBookingsEmpty,
                    icon: AppIcons.event_note_outlined,
                    primaryActionLabel: l10n.customerDiscoverTitle,
                    onPrimaryAction: () => context.go(AppRoutes.customerHome),
                  ),
                ],
              )
            : CustomScrollView(
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
                        l10n.customerMyBookingsSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.large,
                      AppSpacing.small,
                      AppSpacing.large,
                      AppSpacing.small,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        l10n.customerBookingsUpcoming,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (upcoming.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.large,
                        0,
                        AppSpacing.large,
                        AppSpacing.medium,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          l10n.customerBookingsUpcomingEmpty,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.large,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, i) {
                          final b = upcoming[i];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.medium,
                            ),
                            child: _BookingRow(
                              booking: b,
                              dateFmt: dateFmt,
                              timeFmt: timeFmt,
                              l10n: l10n,
                              showActions: _canCustomerChangeBooking(b),
                              onOpen: () => context.push(
                                AppRoutes.customerBookingConfirm(
                                  b.salonId,
                                  b.id,
                                ),
                              ),
                              onCancel: () async {
                                try {
                                  await ref
                                      .read(bookingRepositoryProvider)
                                      .cancelBooking(
                                        salonId: b.salonId,
                                        bookingId: b.id,
                                      );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.customerBookingCancelledToast,
                                        ),
                                      ),
                                    );
                                    await _reload();
                                  }
                                } on Object catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.genericError),
                                      ),
                                    );
                                  }
                                }
                              },
                              onReschedule: () {
                                context.push(
                                  AppRoutes.customerSalonBook(b.salonId),
                                  extra: b,
                                );
                              },
                            ),
                          );
                        }, childCount: upcoming.length),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.large,
                      AppSpacing.large,
                      AppSpacing.large,
                      AppSpacing.small,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        l10n.customerBookingsPast,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (past.isEmpty)
                    SliverPadding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.large,
                        0,
                        AppSpacing.large,
                        AppSpacing.medium,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          l10n.customerBookingsPastEmpty,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.large,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, i) {
                          final b = past[i];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.medium,
                            ),
                            child: _BookingRow(
                              booking: b,
                              dateFmt: dateFmt,
                              timeFmt: timeFmt,
                              l10n: l10n,
                              showActions: _canCustomerChangeBooking(b),
                              onOpen: () => context.push(
                                AppRoutes.customerBookingConfirm(
                                  b.salonId,
                                  b.id,
                                ),
                              ),
                              onCancel: () async {
                                try {
                                  await ref
                                      .read(bookingRepositoryProvider)
                                      .cancelBooking(
                                        salonId: b.salonId,
                                        bookingId: b.id,
                                      );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.customerBookingCancelledToast,
                                        ),
                                      ),
                                    );
                                    await _reload();
                                  }
                                } on Object catch (_) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.genericError),
                                      ),
                                    );
                                  }
                                }
                              },
                              onReschedule: () {
                                context.push(
                                  AppRoutes.customerSalonBook(b.salonId),
                                  extra: b,
                                );
                              },
                            ),
                          );
                        }, childCount: past.length),
                      ),
                    ),
                  if (hasMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.large),
                        child: Center(
                          child: _loadingMore
                              ? const AppLoadingIndicator(size: 32)
                              : TextButton(
                                  onPressed: _loadMore,
                                  child: Text(l10n.listLoadMore),
                                ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.large),
                  ),
                ],
              ),
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  const _BookingRow({
    required this.booking,
    required this.dateFmt,
    required this.timeFmt,
    required this.l10n,
    required this.showActions,
    required this.onOpen,
    required this.onCancel,
    required this.onReschedule,
  });

  final Booking booking;
  final DateFormat dateFmt;
  final DateFormat timeFmt;
  final AppLocalizations l10n;
  final bool showActions;
  final VoidCallback onOpen;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;

  Color _statusColor(ColorScheme scheme) {
    return switch (booking.status) {
      BookingStatuses.pending => scheme.secondary,
      BookingStatuses.confirmed => scheme.primary,
      BookingStatuses.completed => scheme.tertiary,
      BookingStatuses.cancelled => scheme.error,
      BookingStatuses.noShow => scheme.outline,
      BookingStatuses.rescheduled => scheme.outlineVariant,
      _ => scheme.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor = _statusColor(scheme);

    return AppSurfaceCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  booking.serviceName ?? l10n.bookingService,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  localizedBookingStatus(l10n, booking.status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                side: BorderSide(color: statusColor.withValues(alpha: 0.5)),
                backgroundColor: statusColor.withValues(alpha: 0.12),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            '${dateFmt.format(booking.startAt.toLocal())} · ${timeFmt.format(booking.startAt.toLocal())}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (booking.barberName != null &&
              booking.barberName!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.small),
            Text(
              formatTeamMemberName(booking.barberName),
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.primary),
            ),
          ],
          if (showActions) ...[
            const SizedBox(height: AppSpacing.medium),
            Wrap(
              spacing: AppSpacing.small,
              alignment: WrapAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: Text(l10n.customerBookingCancel),
                ),
                FilledButton.tonal(
                  onPressed: onReschedule,
                  child: Text(l10n.customerBookingReschedule),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
