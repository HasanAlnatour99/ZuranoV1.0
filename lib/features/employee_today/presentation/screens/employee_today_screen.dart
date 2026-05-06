import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart' show AppRoutes;
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/session_provider.dart';
import '../../../employee/performance/presentation/widgets/employee_today_performance_section.dart';
import '../../../employee/performance/providers/employee_today_performance_provider.dart';
import '../../../employee/presentation/widgets/employee_streaming_hero_header.dart';
import '../../../employee/providers/employee_header_provider.dart';
import '../../../employee/attendance/providers/employee_attendance_card_provider.dart';
import '../../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../../../employee_dashboard/application/employee_punch_controller.dart';
import '../../../employee_dashboard/application/employee_today_attendance_ui_provider.dart';
import '../../../employee_dashboard/data/models/attendance_event_model.dart';
import '../../../employee_dashboard/presentation/widgets/employee_bottom_nav_bar.dart';
import '../../../employee_dashboard/presentation/widgets/employee_quick_action_fab.dart';
import '../../../employee_dashboard/presentation/widgets/today_activity_timeline.dart';
import '../../../employee_dashboard/presentation/widgets/today_attendance_card.dart';
import '../../../bookings/presentation/widgets/bookings_preview_container.dart';
import '../../../employee_bookings/application/employee_bookings_providers.dart';
import '../../providers/employee_today_providers.dart';
import '../employee_today_theme.dart';
import '../widgets/employee_today_section_error.dart';
import '../widgets/employee_today_skeletons.dart';
import '../widgets/employee_today_widgets.dart';
import '../../../../providers/money_currency_providers.dart';
import '../../../../shared/navigation/zurano_floating_bottom_nav.dart';

class EmployeeTodayScreen extends ConsumerStatefulWidget {
  const EmployeeTodayScreen({super.key});

  @override
  ConsumerState<EmployeeTodayScreen> createState() =>
      _EmployeeTodayScreenState();
}

class _EmployeeTodayScreenState extends ConsumerState<EmployeeTodayScreen> {
  void _invalidateTodayPage() {
    ref.invalidate(workspaceEmployeeProvider);
    ref.invalidate(employeeHeaderStreamProvider);
    ref.invalidate(employeeWeekAttendanceRollupProvider);
    ref.invalidate(etAttendanceSettingsProvider);
    ref.invalidate(etTodayAttendanceDayProvider);
    ref.invalidate(etTodayPunchesProvider);
    ref.invalidate(employeeTodayPerformanceProvider);
    ref.invalidate(employeeWorkplaceLocationSnapshotProvider);
    ref.invalidate(employeeTodayAttendanceProvider);
    ref.invalidate(employeePunchControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final punchesAsync = ref.watch(etTodayPunchesProvider);
    final performanceAsync = ref.watch(employeeTodayPerformanceProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final localeName = locale.toString();
    const fabDockClearance = 88.0;
    final scrollBottomPadding =
        ZuranoFloatingBottomNav.scrollBottomPadding(context) +
            fabDockClearance +
            24;

    final salonCurrency = ref.watch(sessionSalonMoneyCurrencyCodeProvider);

    return Scaffold(
      backgroundColor: EmployeeTodayColors.backgroundSoft,
      extendBody: true,
      floatingActionButtonLocation: zuranoEmployeeCenterDockedFabLocation,
      floatingActionButton: const EmployeeQuickActionFab(),
      bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            _invalidateTodayPage();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: EmployeeStreamingHeroHeader(
                  onWorkspaceLinkRetry: _invalidateTodayPage,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TodayAttendanceCard(onRetry: _invalidateTodayPage),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: ref
                      .watch(employeeBookingsNext7DaysProvider)
                      .when(
                        data: (bookings) {
                          final preview = bookings.take(3).toList();
                          if (preview.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return BookingsPreviewContainer(
                            title: l10n.bookingsPreviewSectionTitle,
                            bookings: preview,
                            l10n: l10n,
                            localeName: localeName,
                            maxVisible: 3,
                            useEmployeePalette: true,
                            onViewAll: () =>
                                context.push(AppRoutes.employeeBookings),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (Object error, StackTrace stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: performanceAsync.when(
                    data: (perf) => EmployeeTodayPerformanceSection(
                      data: perf,
                      currencyCode: salonCurrency,
                      locale: locale,
                      onAddSale: () {
                        final scope = ref.read(employeeWorkspaceScopeProvider);
                        if (scope == null) return;
                        context.push(
                          AppRoutes.addSalePrefill(
                            employeeId: scope.employeeId,
                            staffEmployeeEntry: true,
                          ),
                        );
                      },
                    ),
                    loading: () => const EtTodayPerformanceSkeleton(),
                    error: (err, _) =>
                        EtSectionErrorCard(onRetry: _invalidateTodayPage),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: punchesAsync.when(
                    data: (punches) {
                      final uid =
                          ref.read(sessionUserProvider).asData?.value?.uid ??
                          '';
                      if (punches.isEmpty) {
                        return EtPremiumCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.event_available_outlined,
                                size: 32,
                                color: EmployeeTodayColors.primaryPurple
                                    .withValues(alpha: 0.75),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.employeeTodayNoActivityTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: EmployeeTodayColors.deepText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.employeeTodayNoActivityBody,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: EmployeeTodayColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final events = punches
                          .map(
                            (p) => AttendanceEventModel(
                              eventId: p.id,
                              salonId: p.salonId,
                              attendanceId: p.attendanceDayId,
                              employeeId: p.employeeId,
                              employeeUid: uid,
                              type: p.type,
                              createdAt: p.punchTime,
                              location: AttendanceEventLocation(
                                latitude: p.latitude ?? 0,
                                longitude: p.longitude ?? 0,
                                accuracy: 0,
                              ),
                              distanceMeters: p.distanceFromSalonMeters ?? 0,
                              insideZone: p.insideZone,
                              source: p.source,
                            ),
                          )
                          .toList();
                      return EtPremiumCard(
                        child: TodayActivityTimeline(events: events),
                      );
                    },
                    loading: () => const EtTodayTimelineSkeleton(),
                    error: (err, _) =>
                        EtSectionErrorCard(onRetry: _invalidateTodayPage),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: SizedBox(height: scrollBottomPadding),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
