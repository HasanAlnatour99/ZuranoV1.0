import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../features/debug/presentation/screens/google_maps_test_screen.dart';
import '../core/constants/user_roles.dart';
import '../core/motion/app_page_transitions.dart';
import '../core/session/app_session_status.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/auth/presentation/screens/customer_login_screen.dart';
import '../features/auth/presentation/screens/owner_login_screen.dart';
import '../features/auth/presentation/screens/staff_login_screen.dart';
import '../features/auth/presentation/screens/role_selection_screen.dart';
import '../features/auth/presentation/screens/user_selection_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import '../features/auth/presentation/screens/first_time_role_selection_screen.dart';
import '../features/auth/presentation/screens/change_temporary_password_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/employee_dashboard/presentation/screens/attendance_request_screen.dart';
import '../features/employee_dashboard/presentation/screens/employee_main_swipe_shell_screen.dart';
import '../features/payroll/presentation/screens/payslip_details_screen.dart';
import '../features/payroll/presentation/screens/payslip_history_screen.dart';
import '../features/employee_attendance/presentation/screens/employee_attendance_calendar_screen.dart';
import '../features/employee_attendance/presentation/screens/employee_attendance_details_screen.dart';
import '../features/employee_today/presentation/screens/attendance_correction_screen.dart';
import '../features/employee_today/presentation/screens/attendance_policy_screen.dart';
import '../features/bookings/data/models/booking.dart';
import '../features/customer/presentation/screens/booking_confirmation_screen.dart';
import '../features/customer/presentation/screens/booking_success_screen.dart';
import '../features/customer/data/models/customer_booking_details_model.dart';
import '../features/customer/presentation/screens/customer_booking_details_screen.dart';
import '../features/customer/presentation/screens/customer_booking_reschedule_screen.dart';
import '../features/customer/presentation/screens/customer_feedback_screen.dart';
import '../features/customer/presentation/screens/customer_booking_screen.dart';
import '../features/customer_home/presentation/screens/customer_main_swipe_shell_screen.dart';
import '../features/customer/presentation/screens/customer_details_screen.dart';
import '../features/customer/presentation/screens/customer_guest_nickname_screen.dart';
import '../features/customer/presentation/screens/date_time_selection_screen.dart';
import '../features/customer/presentation/screens/my_bookings_screen.dart';
import '../features/customer/presentation/screens/salon_detail_screen.dart';
import '../features/customer/presentation/screens/salon_profile_screen.dart';
import '../features/customer/presentation/screens/service_selection_screen.dart';
import '../features/customer/presentation/screens/team_member_selection_screen.dart';
import '../features/customer/presentation/screens/booking_review_screen.dart';
import '../features/customer/data/models/customer_booking_create_result.dart';
import '../features/notifications/presentation/screens/notification_preferences_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../features/notifications/presentation/screens/role_notification_screen.dart';
import '../features/notifications/domain/enums/notification_role_scope.dart';
import '../features/onboarding/presentation/screens/customer_onboarding_screen.dart';
import '../features/onboarding/presentation/screens/select_country_screen.dart';
import '../features/onboarding/presentation/screens/select_language_screen.dart';
import '../features/salon/presentation/screens/account_profile_bootstrap_screen.dart';
import '../features/salon/presentation/screens/create_salon_screen.dart';
import '../features/settings/presentation/screens/app_settings_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../providers/firebase_providers.dart';
import '../providers/onboarding_providers.dart';
import '../providers/session_provider.dart';
import 'owner_routes.dart';
import 'router_guards.dart';
import 'router_navigation_keys.dart';
import 'router_page_key.dart';

/// Drives [GoRouter.refreshListenable] so [redirect] re-runs when auth, session,
/// or onboarding prefs change — without replacing the [GoRouter] instance.
///
/// Replacing [GoRouter] on every Riverpod rebuild often fails to re-evaluate
/// redirects after sign-out; this matches go_router's recommended auth pattern.
final appRouterRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  void bump() => notifier.value++;

  ref.onDispose(notifier.dispose);

  ref.listen(appSessionBootstrapProvider, (prev, next) => bump());
  ref.listen<AsyncValue<String?>>(
    firebaseAuthUidProvider,
    (prev, next) => bump(),
  );
  ref.listen<OnboardingPrefsState>(
    onboardingPrefsProvider,
    (prev, next) => bump(),
  );

  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(appRouterRefreshProvider);

  return GoRouter(
    navigatorKey: appRootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshListenable,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('خطأ')),
      body: Center(child: Text('الصفحة غير موجودة: ${state.uri}')),
    ),
    routes: [
      GoRoute(path: '/auth', redirect: (_, _) => AppRoutes.login),
      GoRoute(path: AppRoutes.legacyRoot, redirect: (_, _) => AppRoutes.splash),
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            appFadePage(key: goRouterPageKey(state), child: const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboardingLanguage,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const SelectLanguageScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingCountry,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const SelectCountryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        redirect: (_, _) => AppRoutes.roleSelection,
      ),
      GoRoute(
        path: AppRoutes.legacyRoleSelection,
        redirect: (_, _) => AppRoutes.roleSelection,
      ),
      GoRoute(
        path: AppRoutes.roleSelection,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const RoleSelectionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.userSelection,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const UserSelectionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.preAuthCustomerOnboarding,
        redirect: (_, _) => AppRoutes.customerOnboarding,
      ),
      GoRoute(
        path: AppRoutes.customerOnboarding,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const CustomerOnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerProfileSetup,
        redirect: (_, _) => AppRoutes.customerAuth,
      ),
      GoRoute(
        path: AppRoutes.customerAuth,
        pageBuilder: (context, state) =>
            appFadePage(key: goRouterPageKey(state), child: const CustomerLoginScreen()),
      ),
      GoRoute(
        name: AppRouteNames.customerSalonDiscovery,
        path: AppRoutes.customerSalonDiscovery,
        pageBuilder: (context, state) => appFadePage(
          key: goRouterPageKey(state),
          child: CustomerMainSwipeShellScreen(
            currentPath: state.matchedLocation,
          ),
        ),
      ),
      GoRoute(
        name: AppRouteNames.customerSalonProfile,
        path: '${AppRoutes.customerSalonDiscovery}/:salonId',
        pageBuilder: (context, state) {
          final id = state.pathParameters['salonId'] ?? '';
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: SalonProfileScreen(salonId: id),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.customerServiceSelection,
        path: '${AppRoutes.customerBook}/:salonId/services',
        pageBuilder: (context, state) {
          final id = state.pathParameters['salonId'] ?? '';
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: ServiceSelectionScreen(salonId: id),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.customerTeamSelection,
        path: '${AppRoutes.customerBook}/:salonId/team',
        pageBuilder: (context, state) {
          final id = state.pathParameters['salonId'] ?? '';
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: TeamMemberSelectionScreen(salonId: id),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.customerDateTimeSelection,
        path: '${AppRoutes.customerBook}/:salonId/time',
        pageBuilder: (context, state) {
          final id = state.pathParameters['salonId'] ?? '';
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: DateTimeSelectionScreen(salonId: id),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.customerDetails,
        path: '${AppRoutes.customerBook}/:salonId/details',
        pageBuilder: (context, state) {
          final id = state.pathParameters['salonId'] ?? '';
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: CustomerDetailsScreen(salonId: id),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.customerGuestNickname,
        path: '${AppRoutes.customerBook}/:salonId/guest-nickname',
        pageBuilder: (context, state) {
          final id = state.pathParameters['salonId'] ?? '';
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: CustomerGuestNicknameScreen(salonId: id),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.customerBookingReview,
        path: '${AppRoutes.customerBook}/:salonId/review',
        pageBuilder: (context, state) {
          final id = state.pathParameters['salonId'] ?? '';
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: BookingReviewScreen(salonId: id),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.customerBookingSuccess,
        path: '${AppRoutes.customerBook}/:salonId/success/:bookingId',
        pageBuilder: (context, state) {
          final salonId = state.pathParameters['salonId'] ?? '';
          final bookingId = state.pathParameters['bookingId'] ?? '';
          final extra = state.extra;
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: BookingSuccessScreen(
              salonId: salonId,
              bookingId: bookingId,
              result: extra is CustomerBookingCreateResult ? extra : null,
            ),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.customerBookingFeedback,
        path: '${AppRoutes.customerBooking}/:salonId/:bookingId/feedback',
        pageBuilder: (context, state) {
          final salonId = state.pathParameters['salonId'] ?? '';
          final bookingId = state.pathParameters['bookingId'] ?? '';
          final extra = state.extra;
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: CustomerFeedbackScreen(
              salonId: salonId,
              bookingId: bookingId,
              initialBooking: extra is CustomerBookingDetailsModel
                  ? extra
                  : null,
            ),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.customerBookingReschedule,
        path: '${AppRoutes.customerBooking}/:salonId/:bookingId/reschedule',
        pageBuilder: (context, state) {
          final salonId = state.pathParameters['salonId'] ?? '';
          final bookingId = state.pathParameters['bookingId'] ?? '';
          final extra = state.extra;
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: CustomerBookingRescheduleScreen(
              salonId: salonId,
              bookingId: bookingId,
              initialBooking: extra is CustomerBookingDetailsModel
                  ? extra
                  : null,
            ),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.customerBookingDetails,
        path: '${AppRoutes.customerBooking}/:salonId/:bookingId',
        pageBuilder: (context, state) {
          final salonId = state.pathParameters['salonId'] ?? '';
          final bookingId = state.pathParameters['bookingId'] ?? '';
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: CustomerBookingDetailsScreen(
              salonId: salonId,
              bookingId: bookingId,
            ),
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.customerMyBooking,
        path: AppRoutes.customerMyBooking,
        pageBuilder: (context, state) => appFadePage(
          key: goRouterPageKey(state),
          child: CustomerMainSwipeShellScreen(
            currentPath: state.matchedLocation,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerLogin,
        redirect: (_, _) => AppRoutes.customerAuth,
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const AppSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.ownerHrSettings,
        redirect: (_, _) =>
            '${AppRoutes.ownerAttendanceSettings}?section=violations',
      ),
      GoRoute(
        path: AppRoutes.login,
        redirect: (context, state) {
          assert(state.matchedLocation.isNotEmpty);
          final onboarding = ref.read(onboardingPrefsProvider);
          if (!onboarding.hasAuthIntent) {
            return AppRoutes.roleSelection;
          }
          return AppRoutes.loginRouteForIntent(onboarding.selectedAuthRole);
        },
      ),
      GoRoute(
        path: AppRoutes.legacyOwnerLogin,
        redirect: (_, _) => AppRoutes.ownerLogin,
      ),
      GoRoute(
        path: AppRoutes.ownerLogin,
        pageBuilder: (context, state) =>
            appFadePage(key: goRouterPageKey(state), child: const OwnerLoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.staffLogin,
        pageBuilder: (context, state) =>
            appFadePage(key: goRouterPageKey(state), child: const StaffLoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.ownerSignup,
        redirect: (context, state) =>
            '${AppRoutes.signup}?${AppRoutes.registerFlowQueryKey}=${AppRoutes.registerFlowSalonOwner}',
      ),
      GoRoute(
        path: AppRoutes.register,
        redirect: (context, state) {
          final query = state.uri.query;
          return query.isEmpty
              ? AppRoutes.signup
              : '${AppRoutes.signup}?$query';
        },
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) =>
            appFadePage(key: goRouterPageKey(state), child: const SignUpScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => appFadePage(
          key: goRouterPageKey(state),
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        name: AppRouteNames.changeTemporaryPassword,
        path: AppRoutes.changeTemporaryPassword,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const ChangeTemporaryPasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerSignup,
        redirect: (_, _) => AppRoutes.signup,
      ),
      GoRoute(
        path: AppRoutes.salonOwnerSignup,
        redirect: (_, _) => AppRoutes.signup,
      ),
      GoRoute(
        path: AppRoutes.createSalon,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const CreateSalonScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.firstTimeRoleSelection,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const FirstTimeRoleSelectionScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.legacyAccountProfileBootstrapPath,
        redirect: (_, _) => AppRoutes.accountProfileBootstrap,
      ),
      GoRoute(
        path: AppRoutes.accountProfileBootstrap,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const AccountProfileBootstrapScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notificationPreferences,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const NotificationPreferencesScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.customerNotificationsBase}/:salonId',
        pageBuilder: (context, state) {
          final salonId = state.pathParameters['salonId'] ?? '';
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: RoleNotificationScreen(
              salonId: salonId,
              scope: NotificationRoleScope.customer,
            ),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.employeeNotificationsBase}/:salonId',
        pageBuilder: (context, state) {
          final salonId = state.pathParameters['salonId'] ?? '';
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: RoleNotificationScreen(
              salonId: salonId,
              scope: NotificationRoleScope.employee,
            ),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.ownerNotificationsBase}/:salonId',
        pageBuilder: (context, state) {
          final salonId = state.pathParameters['salonId'] ?? '';
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: RoleNotificationScreen(
              salonId: salonId,
              scope: NotificationRoleScope.ownerAdmin,
            ),
          );
        },
      ),
      GoRoute(
        path: '${AppRoutes.notificationsSettingsBase}/:salonId',
        pageBuilder: (context, state) {
          final salonId = state.pathParameters['salonId'] ?? '';
          final userId =
              ref.read(sessionUserProvider).asData?.value?.uid ??
              ref.read(firebaseAuthProvider).currentUser?.uid ??
              '';
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: NotificationSettingsScreen(salonId: salonId, userId: userId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customerHome,
        pageBuilder: (context, state) => appFadePage(
          key: goRouterPageKey(state),
          child: CustomerMainSwipeShellScreen(
            currentPath: state.matchedLocation,
          ),
        ),
        routes: [
          GoRoute(
            path: 'my-bookings',
            pageBuilder: (context, state) => appFadeThroughPage(
              key: goRouterPageKey(state),
              child: const MyBookingsScreen(),
            ),
          ),
          GoRoute(
            path: 'salon/:salonId',
            pageBuilder: (context, state) {
              final id = state.pathParameters['salonId'] ?? '';
              return appFadeThroughPage(
                key: goRouterPageKey(state),
                child: SalonDetailScreen(salonId: id),
              );
            },
            routes: [
              GoRoute(
                path: 'book',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['salonId'] ?? '';
                  final extra = state.extra;
                  final reschedule = extra is Booking ? extra : null;
                  return appFadeThroughPage(
                    key: goRouterPageKey(state),
                    child: CustomerBookingScreen(
                      salonId: id,
                      rescheduleBooking: reschedule,
                    ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'booking/:salonId/:bookingId',
            pageBuilder: (context, state) {
              final salonId = state.pathParameters['salonId'] ?? '';
              final bookingId = state.pathParameters['bookingId'] ?? '';
              return appFadeThroughPage(
                key: goRouterPageKey(state),
                child: BookingConfirmationScreen(
                  salonId: salonId,
                  bookingId: bookingId,
                ),
              );
            },
          ),
        ],
      ),
      ...ownerRoutes,
      // Employee shell (tabs): /employee/today, /employee/sales, /employee/attendance,
      // /employee/payroll; profile opens shared /settings (no /employee/profile route).
      GoRoute(
        path: AppRoutes.staffHome,
        redirect: (_, _) => AppRoutes.employeeToday,
      ),
      GoRoute(
        path: AppRoutes.employeeDashboard,
        redirect: (_, _) => AppRoutes.employeeToday,
      ),
      GoRoute(
        path: AppRoutes.employeeSales,
        pageBuilder: (context, state) => appFadePage(
          key: goRouterPageKey(state),
          child: EmployeeMainSwipeShellScreen(
            currentPath: state.matchedLocation,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.employeePayrollHistory,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const PayslipHistoryScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.employeePayroll}/:payslipId',
        pageBuilder: (context, state) {
          final id = state.pathParameters['payslipId'] ?? '';
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: PayslipDetailsScreen(payslipId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.employeePayroll,
        pageBuilder: (context, state) => appFadePage(
          key: goRouterPageKey(state),
          child: EmployeeMainSwipeShellScreen(
            currentPath: state.matchedLocation,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.employeeAttendanceCalendar,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const EmployeeAttendanceCalendarScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.employeeAttendanceCorrectionNested,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const AttendanceCorrectionScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.employeeAttendance}/:attendanceDayId',
        pageBuilder: (context, state) {
          final id = state.pathParameters['attendanceDayId'] ?? '';
          return appFadeThroughPage(
            key: goRouterPageKey(state),
            child: EmployeeAttendanceDetailsScreen(attendanceDayId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.employeeAttendance,
        pageBuilder: (context, state) => appFadePage(
          key: goRouterPageKey(state),
          child: EmployeeMainSwipeShellScreen(
            currentPath: state.matchedLocation,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.employeeToday,
        pageBuilder: (context, state) => appFadePage(
          key: goRouterPageKey(state),
          child: EmployeeMainSwipeShellScreen(
            currentPath: state.matchedLocation,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.employeeAttendanceCorrection,
        redirect: (_, _) => AppRoutes.employeeAttendanceCorrectionNested,
      ),
      GoRoute(
        path: AppRoutes.employeeAttendancePolicy,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const EmployeeAttendancePolicyScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.employeeAttendanceRequest,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const AttendanceRequestScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.salonAttendanceZoneSettings,
        name: AppRouteNames.attendanceZoneSettings,
        redirect: (context, state) =>
            '${AppRoutes.ownerAttendanceSettings}?section=zone',
      ),
      GoRoute(
        path: AppRoutes.debugMaps,
        name: AppRouteNames.debugMaps,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const GoogleMapsTestScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        pageBuilder: (context, state) => appFadeThroughPage(
          key: goRouterPageKey(state),
          child: const AdminDashboardScreen(),
        ),
      ),
    ],
    redirect: (_, state) {
      final loc = state.matchedLocation;
      if (loc == AppRoutes.legacyUserLogin) {
        return AppRoutes.customerAuth;
      }
      if (loc == AppRoutes.legacyBarberDashboard) {
        return AppRoutes.employeeToday;
      }
      if (loc == AppRoutes.legacyCustomerHome ||
          loc.startsWith('${AppRoutes.legacyCustomerHome}/')) {
        final q = state.uri.hasQuery ? '?${state.uri.query}' : '';
        return loc.replaceFirst(
              AppRoutes.legacyCustomerHome,
              AppRoutes.customerHome,
            ) +
            q;
      }

      final auth = ref.read(firebaseAuthProvider);
      final authUid = auth.currentUser?.uid;
      var sessionState = ref.read(appSessionBootstrapProvider);

      if (authUid == null &&
          sessionState.status != AppSessionStatus.unauthenticated &&
          sessionState.status != AppSessionStatus.initializing &&
          sessionState.status != AppSessionStatus.error) {
        sessionState = const AppSessionState(
          status: AppSessionStatus.unauthenticated,
        );
      }

      if (authUid != null &&
          sessionState.status == AppSessionStatus.unauthenticated) {
        if (isAuthSessionStagingPath(loc)) {
          return null;
        }
        return loc == AppRoutes.splash || loc == AppRoutes.legacyRoot
            ? null
            : AppRoutes.splash;
      }

      if (sessionState.status == AppSessionStatus.ready &&
          sessionState.user != null) {
        final u = sessionState.user!;
        if (u.role.trim() == UserRoles.owner) {
          final sid = u.salonId?.trim();
          if (sid != null && sid.isNotEmpty && loc == AppRoutes.createSalon) {
            return AppRoutes.ownerDashboard;
          }
        }
      }

      final onboarding = ref.read(onboardingPrefsProvider);
      return resolveRedirect(
        location: loc,
        fullUri: state.uri,
        sessionState: sessionState,
        onboarding: onboarding,
      );
    },
  );
});
