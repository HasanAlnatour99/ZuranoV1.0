import '../core/boot/app_boot_log.dart';
import '../core/debug/agent_session_log.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/user_roles.dart';
import '../core/session/app_session_status.dart';
import '../features/users/data/models/app_user.dart';
import '../providers/onboarding_providers.dart';

/// Salon-provisioned accounts must rotate password before other routes.
///
/// While `true`, [resolveRedirect] only allows [AppRoutes.changeTemporaryPassword]
/// for authenticated users; everything else (settings, dashboards, etc.)
/// redirects there until the flag clears. Sign-out runs from that screen.
bool requiresMandatoryTemporaryPasswordChange(AppUser user) {
  return user.mustChangePassword == true && UserRoles.isStaffRole(user.role);
}

String? bootstrapLoggedOut(OnboardingPrefsState onboarding) {
  if (!onboarding.languageCompleted) {
    return AppRoutes.onboardingLanguage;
  }
  if (!onboarding.countryCompleted) {
    return AppRoutes.onboardingCountry;
  }
  if (!onboarding.hasAuthIntent) {
    return AppRoutes.roleSelection;
  }
  return AppRoutes.loginRouteForIntent(onboarding.selectedAuthRole);
}

/// Salon owner workspace routes (after salon exists).
String? redirectAuthenticatedOwner(
  AppUser session,
  String location,
  bool notificationPath,
) {
  final noSalon = session.salonId == null || session.salonId!.trim().isEmpty;
  if (noSalon) {
    return location == AppRoutes.createSalon ? null : AppRoutes.createSalon;
  }
  if (notificationPath) {
    return null;
  }
  final onOwnerSettingsBranch =
      location == AppRoutes.ownerSettings ||
      location.startsWith('${AppRoutes.ownerSettings}/');

  final allowedOwnerPaths = {
    AppRoutes.ownerDashboard,
    AppRoutes.ownerOverview,
    AppRoutes.ownerBentoDashboard,
    AppRoutes.ownerServices,
    AppRoutes.ownerTeam,
    AppRoutes.ownerTeamStack,
    AppRoutes.ownerAddTeamMember,
    AppRoutes.ownerCustomers,
    AppRoutes.ownerMoney,
    AppRoutes.ownerSettings,
    AppRoutes.customers,
    AppRoutes.customerNew,
    AppRoutes.bookingsNew,
    AppRoutes.ownerDashboardAssistant,
    AppRoutes.ownerAddSale,
    AppRoutes.ownerSales,
    AppRoutes.ownerSalesAdd,
    AppRoutes.ownerExpenses,
    AppRoutes.ownerExpensesAdd,
    AppRoutes.ownerPayroll,
    AppRoutes.ownerQuickPay,
    AppRoutes.ownerPayrollRunReview,
    AppRoutes.ownerPayrollReverse,
    AppRoutes.attendanceRequestsReview,
    AppRoutes.attendanceRequestsAdmin,
    AppRoutes.salonAttendanceZoneSettings,
    AppRoutes.debugMaps,
  };
  return allowedOwnerPaths.contains(location) ||
          onOwnerSettingsBranch ||
          location.startsWith('${AppRoutes.ownerCustomers}/') ||
          location.startsWith('${AppRoutes.customers}/') ||
          location.startsWith('${AppRoutes.ownerSaleDetailsBase}/') ||
          location.startsWith('${AppRoutes.ownerTeamMemberDetailsBase}/') ||
          location.startsWith('${AppRoutes.ownerEmployeePayrollSetupBase}/') ||
          location.startsWith('${AppRoutes.payrollPayslipBase}/')
      ? null
      : AppRoutes.ownerOverview;
}

/// Staff may use the shared Add Sale screen from the employee app via
/// [`AppRoutes.ownerSalesAdd`] + `?source=employee` (same [GoRoute] as owner).
bool staffEmployeeAddSalePath(Uri uri) {
  return uri.path == AppRoutes.ownerSalesAdd &&
      uri.queryParameters['source'] == 'employee';
}

bool _staffMayAccessLocation(String location, bool notificationPath) {
  if (location == AppRoutes.staffHome ||
      location == AppRoutes.legacyBarberDashboard ||
      location == AppRoutes.employeeDashboard ||
      location == AppRoutes.employeeSales ||
      AppRoutes.isEmployeeAttendancePath(location) ||
      AppRoutes.isEmployeePayrollPath(location) ||
      location == AppRoutes.employeeAttendanceRequest ||
      location == AppRoutes.employeeToday ||
      location == AppRoutes.employeeAttendanceCorrection ||
      location == AppRoutes.employeeAttendancePolicy ||
      location == AppRoutes.debugMaps) {
    return true;
  }
  if (location == AppRoutes.adminDashboard) {
    return true;
  }
  if (notificationPath) {
    return true;
  }
  if (location == AppRoutes.settings ||
      location == AppRoutes.ownerHrSettings ||
      location == AppRoutes.ownerSettingsHrViolations ||
      location == AppRoutes.ownerAttendanceSettings) {
    return true;
  }
  if (isAccountBootstrapPath(location)) {
    return true;
  }
  return false;
}

bool _customerMayAccessLocation(String location, bool notificationPath) {
  if (AppRoutes.isUnderCustomerHome(location)) {
    return true;
  }
  if (notificationPath) {
    return true;
  }
  if (location == AppRoutes.settings ||
      location == AppRoutes.ownerHrSettings ||
      location == AppRoutes.ownerSettingsHrViolations ||
      location == AppRoutes.ownerAttendanceSettings) {
    return true;
  }
  if (isAccountBootstrapPath(location)) {
    return true;
  }
  return false;
}

/// Authenticated routing from Firestore [AppUser.role] only (no pre-login prefs).
String? redirectAuthenticatedUser(
  AppUser session,
  String location,
  bool notificationPath, {
  Uri? fullUri,
}) {
  final uri = fullUri ?? Uri(path: location);
  if (UserRoles.needsRoleSelection(session.role)) {
    return location == AppRoutes.firstTimeRoleSelection
        ? null
        : AppRoutes.firstTimeRoleSelection;
  }

  if (location == AppRoutes.debugMaps) {
    return null;
  }

  if (AppRoutes.isPublicCustomerExperiencePath(location)) {
    return null;
  }

  if (notificationPath) {
    return null;
  }

  if (location == AppRoutes.settings ||
      location == AppRoutes.ownerHrSettings ||
      location == AppRoutes.ownerSettingsHrViolations ||
      location == AppRoutes.ownerAttendanceSettings) {
    return null;
  }

  if (location == AppRoutes.salonAttendanceZoneSettings) {
    final r = session.role.trim();
    if (r == UserRoles.owner || r == UserRoles.admin) {
      return null;
    }
    return UserRoles.isStaffRole(r)
        ? AppRoutes.employeeToday
        : AppRoutes.customerHome;
  }

  final role = session.role.trim();

  if (role == UserRoles.customer) {
    if (AppRoutes.isOwnerWorkspacePath(location) ||
        location == AppRoutes.staffHome ||
        location == AppRoutes.legacyBarberDashboard ||
        location == AppRoutes.employeeDashboard ||
        location == AppRoutes.employeeSales ||
        AppRoutes.isEmployeeAttendancePath(location) ||
        AppRoutes.isEmployeePayrollPath(location) ||
        location == AppRoutes.employeeAttendanceRequest ||
        location == AppRoutes.employeeToday ||
        location == AppRoutes.employeeAttendanceCorrection ||
        location == AppRoutes.employeeAttendancePolicy) {
      return AppRoutes.customerHome;
    }
    return _customerMayAccessLocation(location, false)
        ? null
        : AppRoutes.customerHome;
  }

  if (role == UserRoles.employee ||
      role == UserRoles.barber ||
      role == UserRoles.admin ||
      role == UserRoles.readonly) {
    if (AppRoutes.isUnderCustomerHome(location)) {
      return AppRoutes.employeeToday;
    }
    if (AppRoutes.isOwnerWorkspacePath(location)) {
      if (staffEmployeeAddSalePath(uri)) {
        return null;
      }
      return AppRoutes.employeeToday;
    }
    return _staffMayAccessLocation(location, false)
        ? null
        : AppRoutes.employeeToday;
  }

  if (role == UserRoles.owner) {
    if (AppRoutes.isUnderCustomerHome(location) ||
        location == AppRoutes.staffHome ||
        location == AppRoutes.legacyBarberDashboard ||
        location == AppRoutes.employeeDashboard ||
        location == AppRoutes.employeeSales ||
        AppRoutes.isEmployeeAttendancePath(location) ||
        AppRoutes.isEmployeePayrollPath(location) ||
        location == AppRoutes.employeeAttendanceRequest ||
        location == AppRoutes.employeeToday ||
        location == AppRoutes.employeeAttendanceCorrection ||
        location == AppRoutes.employeeAttendancePolicy) {
      return AppRoutes.ownerOverview;
    }
    return redirectAuthenticatedOwner(session, location, notificationPath);
  }

  return location == AppRoutes.firstTimeRoleSelection
      ? null
      : AppRoutes.firstTimeRoleSelection;
}

bool isAccountBootstrapPath(String location) =>
    location == AppRoutes.accountProfileBootstrap ||
    location == AppRoutes.firstTimeRoleSelection;

bool isNotificationPath(String location) =>
    location == AppRoutes.notifications ||
    location == AppRoutes.notificationPreferences ||
    location.startsWith('${AppRoutes.customerNotificationsBase}/') ||
    location.startsWith('${AppRoutes.employeeNotificationsBase}/') ||
    location.startsWith('${AppRoutes.ownerNotificationsBase}/') ||
    location.startsWith('${AppRoutes.notificationsSettingsBase}/');

/// Routes where we **wait** for Firestore session while Firebase Auth may
/// already be signed in (avoids splash ↔ login redirect fights).
bool isAuthSessionStagingPath(String location) {
  if (location == AppRoutes.splash ||
      location == AppRoutes.legacyRoot ||
      location == AppRoutes.roleSelection ||
      location == AppRoutes.legacyRoleSelection ||
      location == AppRoutes.userSelection ||
      location == AppRoutes.onboardingLanguage ||
      location == AppRoutes.onboardingCountry ||
      location == AppRoutes.onboarding ||
      location == AppRoutes.preAuthCustomerOnboarding ||
      location == AppRoutes.customerOnboarding ||
      location == AppRoutes.customerProfileSetup ||
      location == AppRoutes.customerAuth ||
      location == AppRoutes.legacyCustomerHome ||
      location.startsWith('${AppRoutes.legacyCustomerHome}/') ||
      location == AppRoutes.legacyUserLogin ||
      location == AppRoutes.legacyBarberDashboard ||
      location == AppRoutes.login ||
      location == AppRoutes.ownerLogin ||
      location == AppRoutes.legacyOwnerLogin ||
      location == AppRoutes.customerLogin ||
      location == AppRoutes.staffLogin ||
      location == AppRoutes.ownerSignup ||
      location == AppRoutes.signup ||
      location == AppRoutes.forgotPassword ||
      location == AppRoutes.customerSignup ||
      location == AppRoutes.salonOwnerSignup ||
      location == AppRoutes.accountProfileBootstrap ||
      location == AppRoutes.firstTimeRoleSelection ||
      location == AppRoutes.createSalon ||
      location == AppRoutes.settings ||
      location == AppRoutes.ownerHrSettings ||
      location == AppRoutes.ownerSettingsHrViolations ||
      location == AppRoutes.ownerAttendanceSettings ||
      location == AppRoutes.changeTemporaryPassword ||
      location == AppRoutes.debugMaps) {
    return true;
  }
  if (AppRoutes.isPublicCustomerExperiencePath(location)) {
    return true;
  }
  if (location == AppRoutes.register ||
      location.startsWith('${AppRoutes.register}?')) {
    return true;
  }
  return false;
}

bool allowedPathsWhileProfileMissing(String location, bool notificationPath) {
  if (isAccountBootstrapPath(location)) {
    return true;
  }
  if (AppRoutes.isPublicCustomerExperiencePath(location)) {
    return true;
  }
  if (location == AppRoutes.settings) {
    return true;
  }
  if (notificationPath) {
    return true;
  }
  return false;
}

bool allowedPathsWhileStaffIncomplete(String location, bool notificationPath) {
  if (isAccountBootstrapPath(location)) {
    return true;
  }
  if (AppRoutes.isPublicCustomerExperiencePath(location)) {
    return true;
  }
  if (location == AppRoutes.settings) {
    return true;
  }
  if (notificationPath) {
    return true;
  }
  return false;
}

String homeForReadyUser(AppUser user) {
  if (UserRoles.needsRoleSelection(user.role)) {
    return AppRoutes.firstTimeRoleSelection;
  }
  if (user.role == UserRoles.employee ||
      user.role == UserRoles.barber ||
      user.role == UserRoles.admin ||
      user.role == UserRoles.readonly) {
    return AppRoutes.employeeToday;
  }
  if (user.role == UserRoles.owner) {
    final noSalon = user.salonId == null || user.salonId!.trim().isEmpty;
    return noSalon ? AppRoutes.createSalon : AppRoutes.ownerOverview;
  }
  if (user.role == UserRoles.customer) {
    return AppRoutes.customerHome;
  }
  return AppRoutes.firstTimeRoleSelection;
}

String? guardWrongRoleOnCreateSalon(AppUser user, String location) {
  if (location != AppRoutes.createSalon) {
    return null;
  }
  if (user.role == UserRoles.owner) {
    return null;
  }
  return homeForReadyUser(user);
}

String? resolveLoggedOutFlow({
  required String location,
  required OnboardingPrefsState onboarding,
}) {
  // #region agent log
  const logPaths = <String>{
    AppRoutes.splash,
    AppRoutes.roleSelection,
    AppRoutes.userSelection,
    AppRoutes.onboardingLanguage,
    AppRoutes.onboardingCountry,
    AppRoutes.login,
    AppRoutes.ownerLogin,
    AppRoutes.customerAuth,
    AppRoutes.customerLogin,
    AppRoutes.legacyUserLogin,
    AppRoutes.staffLogin,
    AppRoutes.signup,
  };
  if (logPaths.contains(location)) {
    agentSessionLog(
      hypothesisId: 'H1',
      location: 'router_guards.dart:resolveLoggedOutFlow',
      message: 'logged_out_snapshot',
      data: <String, Object?>{
        'path': location,
        'hasAuthIntent': onboarding.hasAuthIntent,
        'languageCompleted': onboarding.languageCompleted,
        'countryCompleted': onboarding.countryCompleted,
      },
    );
  }
  // #endregion

  if (location == AppRoutes.splash) {
    return bootstrapLoggedOut(onboarding);
  }

  if (AppRoutes.isPublicCustomerExperiencePath(location)) {
    return null;
  }

  if (location == AppRoutes.settings) {
    if (!onboarding.languageCompleted) {
      return AppRoutes.onboardingLanguage;
    }
    if (!onboarding.countryCompleted) {
      return AppRoutes.onboardingCountry;
    }
    if (!onboarding.hasAuthIntent) {
      return AppRoutes.roleSelection;
    }
    return null;
  }

  if (!onboarding.languageCompleted) {
    return location == AppRoutes.onboardingLanguage
        ? null
        : AppRoutes.onboardingLanguage;
  }
  if (!onboarding.countryCompleted) {
    // Allow language screen too so users can go back from country to change locale.
    final allowedPreCountry = {
      AppRoutes.onboardingLanguage,
      AppRoutes.onboardingCountry,
    };
    return allowedPreCountry.contains(location)
        ? null
        : AppRoutes.onboardingCountry;
  }

  if (!onboarding.hasAuthIntent) {
    final allowedNoIntent = {AppRoutes.roleSelection, AppRoutes.userSelection};
    return allowedNoIntent.contains(location) ? null : AppRoutes.roleSelection;
  }

  if (location == AppRoutes.login ||
      location == AppRoutes.ownerLogin ||
      location == AppRoutes.legacyOwnerLogin ||
      location == AppRoutes.customerAuth ||
      location == AppRoutes.customerLogin ||
      location == AppRoutes.legacyUserLogin ||
      location == AppRoutes.staffLogin ||
      location == AppRoutes.signup ||
      location == AppRoutes.register ||
      location == AppRoutes.customerSignup ||
      location == AppRoutes.salonOwnerSignup ||
      location == AppRoutes.ownerSignup) {
    return null;
  }

  if (onboarding.isCustomerFlow) {
    if (location == AppRoutes.customerOnboarding ||
        location == AppRoutes.customerAuth) {
      return null;
    }
  }

  if (onboarding.isStaffLoginFlow) {
    if (location == AppRoutes.customerOnboarding ||
        location == AppRoutes.customerAuth) {
      return AppRoutes.staffLogin;
    }
  }

  if (onboarding.selectedAuthRole?.trim() == UserRoles.owner) {
    if (location == AppRoutes.customerOnboarding ||
        location == AppRoutes.customerAuth ||
        location == AppRoutes.userSelection) {
      return AppRoutes.ownerLogin;
    }
  }

  if (location == AppRoutes.onboarding) {
    return AppRoutes.onboardingLanguage;
  }

  if (location == AppRoutes.userSelection ||
      location == AppRoutes.roleSelection ||
      location == AppRoutes.legacyRoleSelection ||
      location == AppRoutes.onboardingLanguage ||
      location == AppRoutes.onboardingCountry ||
      location == AppRoutes.preAuthCustomerOnboarding) {
    return AppRoutes.loginRouteForIntent(onboarding.selectedAuthRole);
  }

  return AppRoutes.loginRouteForIntent(onboarding.selectedAuthRole);
}

String? resolveRedirect({
  required String location,
  Uri? fullUri,
  required AppSessionState sessionState,
  required OnboardingPrefsState onboarding,
}) {
  if (sessionState.status == AppSessionStatus.initializing) {
    if (isAuthSessionStagingPath(location)) {
      return null;
    }
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  if (sessionState.status == AppSessionStatus.error) {
    AppBootLog.router('entry_async_error', {
      'path': location,
      'resolved': AppRoutes.splash,
      'error': sessionState.error.toString(),
    });
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  final notificationPath = isNotificationPath(location);
  switch (sessionState.status) {
    case AppSessionStatus.unauthenticated:
      return resolveLoggedOutFlow(location: location, onboarding: onboarding);

    case AppSessionStatus.profileIncomplete:
      final user = sessionState.user;
      if (user != null && UserRoles.needsRoleSelection(user.role)) {
        return location == AppRoutes.firstTimeRoleSelection
            ? null
            : AppRoutes.firstTimeRoleSelection;
      }
      if (allowedPathsWhileProfileMissing(location, notificationPath)) {
        return null;
      }
      return AppRoutes.accountProfileBootstrap;

    case AppSessionStatus.ownerNeedsSalon:
      if (location == AppRoutes.createSalon) {
        return null;
      }
      if (AppRoutes.isPublicCustomerExperiencePath(location)) {
        return null;
      }
      return AppRoutes.createSalon;

    case AppSessionStatus.ready:
      final user = sessionState.user;
      if (user == null) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }
      if (user.isActive != true) {
        AppBootLog.router('inactive_profile', {
          'path': location,
          'authUid': user.uid,
          'resolved': AppRoutes.login,
        });
        return location == AppRoutes.login ||
                location == AppRoutes.customerAuth ||
                location == AppRoutes.customerLogin ||
                location == AppRoutes.legacyUserLogin ||
                location == AppRoutes.staffLogin ||
                location == AppRoutes.ownerLogin ||
                location == AppRoutes.legacyOwnerLogin
            ? null
            : AppRoutes.roleSelection;
      }

      if (user.role.trim() == UserRoles.owner) {
        final sid = user.salonId?.trim();
        if (sid != null &&
            sid.isNotEmpty &&
            location == AppRoutes.createSalon) {
          return AppRoutes.ownerDashboard;
        }
      }

      if (requiresMandatoryTemporaryPasswordChange(user)) {
        // Only the password screen is allowed while authenticated; sign-out is
        // handled on that screen (then unauthenticated routes apply).
        if (location == AppRoutes.changeTemporaryPassword) {
          return null;
        }
        return AppRoutes.changeTemporaryPassword;
      }

      if (location == AppRoutes.changeTemporaryPassword) {
        return homeForReadyUser(user);
      }

      if (isAccountBootstrapPath(location)) {
        final target = homeForReadyUser(user);
        AppBootLog.router('leave_bootstrap', {
          'path': location,
          'resolved': target,
        });
        return target;
      }

      final salonGuard = guardWrongRoleOnCreateSalon(user, location);
      if (salonGuard != null) {
        AppBootLog.router('create_salon_guard', {
          'path': location,
          'role': user.role,
          'resolved': salonGuard,
        });
        return salonGuard;
      }

      final sessionRedirect = redirectAuthenticatedUser(
        user,
        location,
        notificationPath,
        fullUri: fullUri ?? Uri(path: location),
      );
      if (sessionRedirect != null) {
        AppBootLog.router('role_redirect', {
          'path': location,
          'role': user.role,
          'resolved': sessionRedirect,
        });
      } else if (location == AppRoutes.ownerDashboard) {
        return AppRoutes.ownerOverview;
      }
      return sessionRedirect;
    case AppSessionStatus.error:
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    case AppSessionStatus.initializing:
      return location == AppRoutes.splash ? null : AppRoutes.splash;
  }
}
