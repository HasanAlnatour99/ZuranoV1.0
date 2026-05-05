import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/navigation/zurano_floating_bottom_nav.dart';
import '../../../employee/attendance/data/services/employee_live_worked_minutes.dart';
import '../../../employee/presentation/widgets/employee_streaming_hero_header.dart';
import '../../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../../../employee_dashboard/presentation/widgets/employee_bottom_nav_bar.dart';
import '../../../employee_dashboard/presentation/widgets/employee_quick_action_fab.dart';
import '../../../employee_today/providers/employee_today_providers.dart';
import '../../application/employee_attendance_providers.dart';
import '../widgets/attendance_actions_card.dart';
import '../widgets/attendance_request_sheet.dart';
import '../widgets/attendance_timeline_list.dart';
import '../widgets/today_attendance_summary_card.dart';

class EmployeeAttendanceScreen extends ConsumerStatefulWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  ConsumerState<EmployeeAttendanceScreen> createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends ConsumerState<EmployeeAttendanceScreen> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final path = GoRouterState.of(context).uri.path;
    final now = DateTime.now();

    final scope = ref.watch(employeeWorkspaceScopeProvider);
    if (scope == null) {
      return Scaffold(
        body: Center(child: Text(l10n.employeeHeroWorkspaceLinkMissing)),
      );
    }

    final profileAsync = ref.watch(employeeAttendanceProfileProvider);
    final todayAsync = ref.watch(todayEmployeeAttendanceProvider);
    final historyAsync = ref.watch(employeeAttendanceHistoryProvider);
    final day = ref.watch(etTodayAttendanceDayProvider);
    final punches = ref.watch(etTodayPunchesProvider);

    final live = computeEmployeeLiveWorkedMinutes(
      day: day.asData?.value,
      punches: punches.asData?.value ?? const [],
      now: now,
    );

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFAF8FF),
      floatingActionButtonLocation: zuranoEmployeeCenterDockedFabLocation,
      floatingActionButton: const EmployeeQuickActionFab(),
      body: profileAsync.when(
        loading: () => const _AttendanceLoadingView(),
        error: (e, _) => _AttendanceErrorView(
          message: l10n.employeeAttendanceTabErrorLoadProfile,
          onRetry: () {
            ref.invalidate(employeeAttendanceProfileProvider);
            ref.invalidate(todayEmployeeAttendanceProvider);
            ref.invalidate(employeeAttendanceHistoryProvider);
          },
        ),
        data: (profile) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(employeeAttendanceProfileProvider);
              ref.invalidate(todayEmployeeAttendanceProvider);
              ref.invalidate(employeeAttendanceHistoryProvider);
              ref.invalidate(etTodayAttendanceDayProvider);
              ref.invalidate(etTodayPunchesProvider);
              await ref.read(todayEmployeeAttendanceProvider.future);
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
              SliverToBoxAdapter(
                child: EmployeeStreamingHeroHeader(
                  onWorkspaceLinkRetry: () {
                    ref.invalidate(employeeAttendanceProfileProvider);
                    ref.invalidate(todayEmployeeAttendanceProvider);
                    ref.invalidate(employeeAttendanceHistoryProvider);
                    ref.invalidate(workspaceEmployeeProvider);
                    ref.invalidate(etTodayAttendanceDayProvider);
                    ref.invalidate(etTodayPunchesProvider);
                  },
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    AttendanceActionsCard(
                      onRequestTap: () => showAttendanceRequestSheet(context),
                    ),
                    const SizedBox(height: 16),
                    todayAsync.when(
                      loading: () => const TodayAttendanceSummarySkeleton(),
                      error: (error, _) => _SmallErrorCard(
                        text: l10n.employeeAttendanceTabErrorToday,
                        onRetry: () =>
                            ref.invalidate(todayEmployeeAttendanceProvider),
                      ),
                      data: (today) => TodayAttendanceSummaryCard(
                        today: today,
                        displayWorkedMinutes: live,
                      ),
                    ),
                    const SizedBox(height: 20),
                    historyAsync.when(
                      loading: () => const AttendanceTimelineSkeleton(),
                      error: (error, _) => _SmallErrorCard(
                        text: l10n.employeeAttendanceTabErrorHistory,
                        onRetry: () => ref.invalidate(
                          employeeAttendanceHistoryProvider,
                        ),
                      ),
                      data: (records) => AttendanceTimelineList(
                        records: records,
                      ),
                    ),
                  ]),
                ),
              ),
            ],
            ),
          );
        },
      ),
      bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
    );
  }
}

class _AttendanceLoadingView extends StatelessWidget {
  const _AttendanceLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _AttendanceErrorView extends StatelessWidget {
  const _AttendanceErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(l10n.employeeAttendanceTabRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallErrorCard extends StatelessWidget {
  const _SmallErrorCard({required this.text, required this.onRetry});

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7D8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(text),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: onRetry,
              child: Text(l10n.employeeAttendanceTabRetry),
            ),
          ),
        ],
      ),
    );
  }
}
