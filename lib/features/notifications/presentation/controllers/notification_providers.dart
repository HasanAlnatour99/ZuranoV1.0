import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/firebase/firestore_index_building.dart';
import '../../../../providers/session_provider.dart';
import '../../../customer/application/customer_booking_draft_provider.dart';
import '../../domain/entities/app_notification.dart';
import '../../../employee_dashboard/application/employee_workspace_scope.dart';
import '../../../employee_dashboard/application/employee_dashboard_providers.dart';
import '../../../users/data/models/app_user.dart';
import '../../domain/enums/notification_role_scope.dart';
import 'notification_controller.dart';
import 'notification_repository_provider.dart';

final notificationStateProvider =
    StreamProvider.family<NotificationControllerState, NotificationViewRequest>(
      (ref, request) {
        final raw = ref
            .read(roleNotificationRepositoryProvider)
            .watchNotifications(
              salonId: request.args.salonId,
              scope: request.args.scope,
              userId: request.args.userId,
              employeeId: request.args.employeeId,
              customerId: request.args.customerId,
              customerPhoneNormalized: request.args.customerPhoneNormalized,
              unreadOnly: request.filter == NotificationFilter.unread,
            );
        return raw
            .transform(
              StreamTransformer<List<AppNotification>,
                  (List<AppNotification>, bool)>.fromHandlers(
                handleData: (items, sink) {
                  sink.add((items, false));
                },
                handleError: (error, stackTrace, sink) {
                  if (isFirestoreIndexBuilding(error)) {
                    sink.add((const <AppNotification>[], true));
                  } else {
                    sink.addError(error, stackTrace);
                  }
                },
              ),
            )
            .map(
              (pair) => NotificationControllerState(
                selectedFilter: request.filter,
                notifications: pair.$1,
                provisionalEmptyDueToIndexBuilding: pair.$2,
              ),
            );
      },
    );

final notificationControllerProvider =
    Provider.family<NotificationController, NotificationControllerArgs>((
      ref,
      arg,
    ) {
      return NotificationController(
        repository: ref.read(roleNotificationRepositoryProvider),
        args: arg,
      );
    });

final notificationUnreadCountProvider =
    StreamProvider.family<int, NotificationControllerArgs>((ref, arg) {
      final raw = ref
          .read(roleNotificationRepositoryProvider)
          .watchUnreadCount(
            salonId: arg.salonId,
            scope: arg.scope,
            readerId: arg.readerId,
            userId: arg.userId,
            employeeId: arg.employeeId,
            customerId: arg.customerId,
            customerPhoneNormalized: arg.customerPhoneNormalized,
          );
      return recoverWhileFirestoreIndexBuilding(raw, 0);
    });

final customerNotificationLookupProvider =
    Provider<({String? customerId, String? customerPhoneNormalized})>((ref) {
      final session = ref.watch(sessionUserProvider).asData?.value;
      final draft = ref.watch(customerBookingDraftProvider);
      return (
        customerId: session?.uid,
        customerPhoneNormalized:
            draft.customerPhoneNormalized?.trim().isNotEmpty == true
            ? draft.customerPhoneNormalized?.trim()
            : null,
      );
    });

/// Pure mapping for notification query args (Firestore role center).
NotificationControllerArgs notificationControllerArgsFor({
  required String salonId,
  required NotificationRoleScope scope,
  required AppUser? sessionUser,
  required EmployeeWorkspaceScope? employeeScope,
  required ({String? customerId, String? customerPhoneNormalized})
  customerLookup,
}) {
  final authUid = sessionUser?.uid ?? '';
  if (scope == NotificationRoleScope.employee) {
    final employeeId =
        employeeScope?.employeeId ?? sessionUser?.employeeId ?? '';
    return NotificationControllerArgs(
      salonId: salonId,
      scope: scope,
      readerId: authUid.isNotEmpty
          ? authUid
          : (employeeId.isNotEmpty ? employeeId : ''),
      userId: authUid.isNotEmpty ? authUid : null,
      employeeId: employeeId.isNotEmpty ? employeeId : null,
    );
  }
  if (scope == NotificationRoleScope.customer) {
    final customerId = customerLookup.customerId;
    final phone = customerLookup.customerPhoneNormalized;
    return NotificationControllerArgs(
      salonId: salonId,
      scope: scope,
      readerId: (customerId?.isNotEmpty ?? false) ? customerId! : (phone ?? ''),
      userId: authUid.isNotEmpty ? authUid : null,
      customerId: customerId,
      customerPhoneNormalized: phone,
    );
  }
  return NotificationControllerArgs(
    salonId: salonId,
    scope: scope,
    readerId: authUid,
    userId: authUid,
  );
}

/// Prefer this from widget `Consumer` code (Riverpod 3: [WidgetRef] is not [Ref]).
NotificationControllerArgs buildNotificationControllerArgs({
  required WidgetRef ref,
  required String salonId,
  required NotificationRoleScope scope,
}) {
  final sessionUser = ref.watch(sessionUserProvider).asData?.value;
  final employeeScope = ref.watch(employeeWorkspaceScopeProvider);
  final customerLookup = ref.watch(customerNotificationLookupProvider);
  return notificationControllerArgsFor(
    salonId: salonId,
    scope: scope,
    sessionUser: sessionUser,
    employeeScope: employeeScope,
    customerLookup: customerLookup,
  );
}

/// Prefer this from `Provider`/`Ref` callbacks (e.g. app shell badge unread count).
NotificationControllerArgs notificationControllerArgsFromRef(
  Ref ref, {
  required String salonId,
  required NotificationRoleScope scope,
}) {
  final sessionUser = ref.watch(sessionUserProvider).asData?.value;
  final employeeScope = ref.watch(employeeWorkspaceScopeProvider);
  final customerLookup = ref.watch(customerNotificationLookupProvider);
  return notificationControllerArgsFor(
    salonId: salonId,
    scope: scope,
    sessionUser: sessionUser,
    employeeScope: employeeScope,
    customerLookup: customerLookup,
  );
}
