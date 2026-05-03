import 'package:flutter/foundation.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/enums/notification_role_scope.dart';
import '../../domain/repositories/notification_repository_contract.dart';

enum NotificationFilter { all, unread }

class NotificationControllerState {
  const NotificationControllerState({
    this.selectedFilter = NotificationFilter.all,
    this.notifications = const <AppNotification>[],
    this.isRefreshing = false,
    this.provisionalEmptyDueToIndexBuilding = false,
  });

  final NotificationFilter selectedFilter;
  final List<AppNotification> notifications;
  final bool isRefreshing;

  /// True when Firestore returned no rows because the inbox index was still building.
  final bool provisionalEmptyDueToIndexBuilding;

  NotificationControllerState copyWith({
    NotificationFilter? selectedFilter,
    List<AppNotification>? notifications,
    bool? isRefreshing,
    bool? provisionalEmptyDueToIndexBuilding,
  }) {
    return NotificationControllerState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      notifications: notifications ?? this.notifications,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      provisionalEmptyDueToIndexBuilding:
          provisionalEmptyDueToIndexBuilding ??
          this.provisionalEmptyDueToIndexBuilding,
    );
  }
}

@immutable
class NotificationControllerArgs {
  const NotificationControllerArgs({
    required this.salonId,
    required this.scope,
    required this.readerId,
    this.userId,
    this.employeeId,
    this.customerId,
    this.customerPhoneNormalized,
  });

  final String salonId;
  final NotificationRoleScope scope;
  final String readerId;
  final String? userId;
  final String? employeeId;
  final String? customerId;
  final String? customerPhoneNormalized;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NotificationControllerArgs &&
            salonId == other.salonId &&
            scope == other.scope &&
            readerId == other.readerId &&
            userId == other.userId &&
            employeeId == other.employeeId &&
            customerId == other.customerId &&
            customerPhoneNormalized == other.customerPhoneNormalized;
  }

  @override
  int get hashCode => Object.hash(
        salonId,
        scope,
        readerId,
        userId,
        employeeId,
        customerId,
        customerPhoneNormalized,
      );
}

@immutable
class NotificationViewRequest {
  const NotificationViewRequest({required this.args, required this.filter});

  final NotificationControllerArgs args;
  final NotificationFilter filter;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NotificationViewRequest &&
            filter == other.filter &&
            args == other.args;
  }

  @override
  int get hashCode => Object.hash(args, filter);
}

class NotificationController {
  NotificationController({
    required NotificationRepositoryContract repository,
    required NotificationControllerArgs args,
  }) : _repository = repository,
       _args = args;

  final NotificationRepositoryContract _repository;
  final NotificationControllerArgs _args;

  Future<void> markAsRead(AppNotification notification) async {
    await _repository.markAsRead(
      salonId: _args.salonId,
      notificationId: notification.id,
      readerId: _args.readerId,
    );
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead(
      salonId: _args.salonId,
      scope: _args.scope,
      readerId: _args.readerId,
      userId: _args.userId,
      employeeId: _args.employeeId,
      customerId: _args.customerId,
      customerPhoneNormalized: _args.customerPhoneNormalized,
    );
  }
}
