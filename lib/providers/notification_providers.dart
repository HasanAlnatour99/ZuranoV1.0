import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/user_roles.dart';
import '../features/notifications/data/notification_model.dart';
import '../features/notifications/domain/enums/notification_role_scope.dart';
import '../features/notifications/logic/fcm_registration_service.dart';
import '../features/notifications/presentation/controllers/notification_providers.dart';
import '../core/session/app_session_status.dart';
import 'firebase_providers.dart';
import 'repository_providers.dart';
import 'session_provider.dart';

final fcmRegistrationServiceProvider = Provider<FcmRegistrationService>((ref) {
  return FcmRegistrationService(
    notificationRepository: ref.read(notificationRepositoryProvider),
    secureStorageService: ref.read(secureStorageServiceProvider),
    logger: ref.read(appLoggerProvider),
  );
});

/// Legacy per-user inbox (`users/{uid}/notifications`). Prefer the salon inbox
/// for new notifications (`salons/{salonId}/notifications`); retained for tooling
/// or reads that intentionally target the legacy subcollection only.
final userNotificationsStreamProvider =
    StreamProvider.autoDispose<List<AppNotificationItem>>((ref) {
      final authUid = ref.watch(firebaseAuthProvider).currentUser?.uid;
      final status = ref.watch(appSessionBootstrapProvider).status;
      if (authUid == null ||
          authUid.isEmpty ||
          status == AppSessionStatus.unauthenticated) {
        return Stream.value(const <AppNotificationItem>[]);
      }
      return ref
          .read(notificationRepositoryProvider)
          .watchNotifications(authUid);
    });

/// Unread count for the **same** salon notification center as
/// [AppRoutes.notifications] → [RoleNotificationScreen]
/// (`salons/{salonId}/notifications`). Not `users/{uid}/notifications` (FCM inbox).
final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  final session = ref.watch(sessionUserProvider).asData?.value;
  final authUid = ref.watch(firebaseAuthProvider).currentUser?.uid;
  if (session == null || authUid == null || authUid.isEmpty) {
    return 0;
  }

  final role = session.role.trim();
  if (UserRoles.needsRoleSelection(role)) {
    return 0;
  }

  final salonId = session.salonId?.trim() ?? '';
  if (salonId.isEmpty) {
    return 0;
  }

  final NotificationRoleScope scope;
  if (role == UserRoles.customer) {
    scope = NotificationRoleScope.customer;
  } else if (role == UserRoles.owner) {
    scope = NotificationRoleScope.ownerAdmin;
  } else if (UserRoles.isStaffRole(role)) {
    scope = NotificationRoleScope.employee;
  } else {
    return 0;
  }

  final args = notificationControllerArgsFromRef(
    ref,
    salonId: salonId,
    scope: scope,
  );
  return ref
      .watch(notificationUnreadCountProvider(args))
      .maybeWhen(data: (n) => n, orElse: () => 0);
});
