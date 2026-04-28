import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/constants/app_routes.dart' show AppRoutes;
import '../../../../core/formatting/app_money_format.dart';
import '../../../../core/text/personalized_greeting.dart';
import '../../../../core/widgets/app_notification_badge.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/notification_providers.dart';
import '../../../../providers/salon_streams_provider.dart';
import '../../../../providers/session_provider.dart';
import '../../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../../../employee_dashboard/application/employee_punch_controller.dart';
import '../../../employee_dashboard/application/employee_today_attendance_ui_provider.dart';
import '../../../employee_dashboard/data/models/attendance_event_model.dart';
import '../../../employee_dashboard/presentation/widgets/employee_bottom_nav_bar.dart';
import '../../../employee_dashboard/presentation/widgets/employee_quick_action_fab.dart';
import '../../../employee_dashboard/presentation/widgets/today_activity_timeline.dart';
import '../../../employee_dashboard/presentation/widgets/today_attendance_card.dart';
import '../../providers/employee_today_providers.dart';
import '../employee_today_theme.dart';
import '../widgets/attendance_request_card.dart';
import '../widgets/employee_today_section_error.dart';
import '../widgets/employee_today_skeletons.dart';
import '../widgets/employee_today_widgets.dart';

class EmployeeTodayScreen extends ConsumerStatefulWidget {
  const EmployeeTodayScreen({super.key});

  @override
  ConsumerState<EmployeeTodayScreen> createState() =>
      _EmployeeTodayScreenState();
}

class _EmployeeTodayScreenState extends ConsumerState<EmployeeTodayScreen> {
  void _invalidateTodayPage() {
    ref.invalidate(workspaceEmployeeProvider);
    ref.invalidate(etAttendanceSettingsProvider);
    ref.invalidate(etTodayAttendanceDayProvider);
    ref.invalidate(etTodayPunchesProvider);
    ref.invalidate(employeeTodaySummaryProvider);
    ref.invalidate(employeeWorkplaceLocationSnapshotProvider);
    ref.invalidate(etEmployeeCorrectionRequestsProvider);
    ref.invalidate(employeeTodayAttendanceProvider);
    ref.invalidate(employeePunchControllerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final dayAsync = ref.watch(etTodayAttendanceDayProvider);
    final punchesAsync = ref.watch(etTodayPunchesProvider);
    final summaryAsync = ref.watch(employeeTodaySummaryProvider);
    final correctionsAsync = ref.watch(etEmployeeCorrectionRequestsProvider);
    final empAsync = ref.watch(workspaceEmployeeProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final media = MediaQuery.of(context);
    final bottomInset = media.padding.bottom;
    const bottomNavBarApprox = 88.0;
    const fabDockClearance = 88.0;
    final scrollBottomPadding =
        bottomInset + bottomNavBarApprox + fabDockClearance + 24;

    final salon = ref.watch(sessionSalonStreamProvider).asData?.value;
    final sessionUser = ref.watch(sessionUserProvider).asData?.value;
    final salonCurrency = salon?.currencyCode ?? 'USD';
    final salonDisplayName = salon?.name.trim().isNotEmpty == true
        ? salon!.name.trim()
        : l10n.employeeTodaySalonLabel;

    return Scaffold(
      backgroundColor: EmployeeTodayColors.backgroundSoft,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const EmployeeQuickActionFab(),
      bottomNavigationBar: EmployeeBottomNavBar(currentPath: path),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _invalidateTodayPage();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 8),
                  child: empAsync.when(
                    data: (e) => _EmployeeTodayHeroHeader(
                      displayName: e?.name.trim().isNotEmpty == true
                          ? e!.name.trim()
                          : l10n.employeeTodayTeamMemberFallback,
                      photoUrl: _resolveEmployeeHeaderPhotoUrl(
                        userPhotoUrl: sessionUser?.photoUrl,
                        employeePhotoUrl: e?.avatarUrl,
                      ),
                      salonDisplayName: salonDisplayName,
                      localeTag: locale.toString(),
                    ),
                    loading: () => const EtTodayHeaderSkeleton(),
                    error: (_, _) =>
                        EtSectionErrorCard(onRetry: _invalidateTodayPage),
                  ),
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
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                  child: correctionsAsync.when(
                    data: (list) {
                      final pending = list
                          .where((r) => r.status == 'pending')
                          .length;
                      return AttendanceRequestCard(
                        pendingCount: pending,
                        loading: false,
                        onSubmitCorrection: () => context.push(
                          AppRoutes.employeeAttendanceCorrectionNested,
                        ),
                      );
                    },
                    loading: () => AttendanceRequestCard(
                      pendingCount: 0,
                      loading: true,
                      onSubmitCorrection: () {},
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: summaryAsync.when(
                    data: (sum) {
                      final hours = dayAsync.maybeWhen(
                        data: (d) => d == null
                            ? '0.0'
                            : (d.workedMinutes / 60).toStringAsFixed(1),
                        orElse: () => '0.0',
                      );
                      final salesText = formatAppMoney(
                        sum.salesTotal,
                        salonCurrency,
                        locale,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.employeeTodayStatsTitle,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: EmployeeTodayColors.deepText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final narrow = constraints.maxWidth < 380;
                              final hoursCard = EtPremiumCard(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.schedule,
                                      size: 20,
                                      color: EmployeeTodayColors.primaryPurple,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.employeeTodayHoursLabel(hours),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                        color: EmployeeTodayColors.deepText,
                                      ),
                                    ),
                                    Text(
                                      l10n.employeeTodayStatsHoursLabel,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: EmployeeTodayColors.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              final salesCard = EtPremiumCard(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 20,
                                      color: Color(0xFF16A34A),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      salesText,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: EmployeeTodayColors.deepText,
                                      ),
                                    ),
                                    Text(
                                      l10n.employeeTodayStatsSalesLabel,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: EmployeeTodayColors.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              final servicesCard = EtPremiumCard(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.content_cut,
                                      size: 20,
                                      color: EmployeeTodayColors.primaryPurple,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${sum.servicesCount}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17,
                                        color: EmployeeTodayColors.deepText,
                                      ),
                                    ),
                                    Text(
                                      l10n.employeeSalesKpiServices,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: EmployeeTodayColors.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (narrow) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    hoursCard,
                                    const SizedBox(height: 10),
                                    salesCard,
                                    const SizedBox(height: 10),
                                    servicesCard,
                                  ],
                                );
                              }
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: hoursCard),
                                  const SizedBox(width: 10),
                                  Expanded(child: salesCard),
                                  const SizedBox(width: 10),
                                  Expanded(child: servicesCard),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    },
                    loading: () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppSkeletonBlock(height: 18, width: 120),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 380) {
                              return const EtTodayStatsSkeletonNarrow();
                            }
                            return const EtTodayStatsSkeleton();
                          },
                        ),
                      ],
                    ),
                    error: (err, _) =>
                        EtSectionErrorCard(onRetry: _invalidateTodayPage),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    20,
                    0,
                    20,
                    scrollBottomPadding,
                  ),
                  child: EtPremiumCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: EmployeeTodayColors.primaryPurple.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.employeeTodayPrivacyNote,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 13,
                              color: EmployeeTodayColors.mutedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _resolveEmployeeHeaderPhotoUrl({
  required String? userPhotoUrl,
  required String? employeePhotoUrl,
}) {
  final userPhoto = userPhotoUrl?.trim();
  if (userPhoto != null && userPhoto.isNotEmpty) {
    return userPhoto;
  }
  final employeePhoto = employeePhotoUrl?.trim();
  if (employeePhoto != null && employeePhoto.isNotEmpty) {
    return employeePhoto;
  }
  return '';
}

String _employeeHeaderInitials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  final first = parts.first.isNotEmpty ? parts.first.substring(0, 1) : '';
  final last = parts.last.isNotEmpty ? parts.last.substring(0, 1) : '';
  final value = '$first$last'.trim();
  return value.isNotEmpty ? value.toUpperCase() : '?';
}

class _EmployeeTodayHeroHeader extends ConsumerWidget {
  const _EmployeeTodayHeroHeader({
    required this.displayName,
    required this.photoUrl,
    required this.salonDisplayName,
    required this.localeTag,
  });

  final String displayName;
  final String photoUrl;
  final String salonDisplayName;
  final String localeTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final unread = ref.watch(unreadNotificationCountProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final align = isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = isRtl ? TextAlign.right : TextAlign.left;
    final hasPhoto = photoUrl.isNotEmpty;
    final greeting = '${getGreeting(l10n)}, $displayName';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B2BE0), Color(0xFF7B3FF2), Color(0xFFA77BFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withValues(alpha: 0.22),
                backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                child: hasPhoto
                    ? null
                    : Text(
                        _employeeHeaderInitials(displayName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: align,
                  children: [
                    Text(
                      greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: textAlign,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      salonDisplayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: textAlign,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      intl.DateFormat.yMMMEd(localeTag).format(DateTime.now()),
                      textAlign: textAlign,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => context.push(AppRoutes.settings),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => context.push(AppRoutes.notifications),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: AppNotificationBadge(
                      count: unread,
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
