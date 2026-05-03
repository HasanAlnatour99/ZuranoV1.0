import '../enums/notification_role_scope.dart';
import '../enums/notification_type.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.salonId,
    required this.title,
    required this.body,
    required this.type,
    required this.targetRole,
    required this.isRead,
    required this.readBy,
    required this.createdAt,
    required this.priority,
    required this.status,
    this.targetUserId,
    this.targetEmployeeId,
    this.targetCustomerId,
    this.customerPhoneNormalized,
    this.actionRoute,
    this.actionParams,
    this.createdBy,
    /// Production inbox: single recipient auth uid (salon notifications).
    this.recipientUserId,
    this.recipientRole,
    /// Same as Firestore `routeName` when using server-written payloads.
    this.routeName,
    this.entityId,
    this.entityType,
    this.readAt,
    this.dedupeKey,
    /// Mirrors Firestore field `data`.
    this.payloadData,
    this.imageUrl,
    /// Canonical event id string from backend (e.g. attendance_check_in).
    this.eventTypeKey,
  });

  final String id;
  final String salonId;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationTargetRole targetRole;
  final String? targetUserId;
  final String? targetEmployeeId;
  final String? targetCustomerId;
  final String? customerPhoneNormalized;
  final bool isRead;
  final Map<String, bool> readBy;
  final String? actionRoute;
  final Map<String, dynamic>? actionParams;
  final DateTime? createdAt;
  final String? createdBy;
  final String priority;
  final String status;

  final String? recipientUserId;
  final String? recipientRole;
  final String? routeName;
  final String? entityId;
  final String? entityType;
  final DateTime? readAt;
  final String? dedupeKey;
  final Map<String, dynamic>? payloadData;
  final String? imageUrl;
  final String? eventTypeKey;

  /// Prefer legacy [actionRoute], then production [routeName].
  String? get effectiveActionRoute {
    final a = actionRoute?.trim();
    if (a != null && a.isNotEmpty) return a;
    final r = routeName?.trim();
    if (r != null && r.isNotEmpty) return r;
    return null;
  }

  bool isUnreadFor(String readerId) {
    final ru = recipientUserId?.trim();
    if (ru != null && ru.isNotEmpty) {
      if (readerId.trim() != ru) return false;
      if (readAt != null) return false;
      return !isRead;
    }
    if (readerId.isEmpty) {
      return !isRead;
    }
    return !(readBy[readerId] ?? false) && !isRead;
  }

  AppNotification copyWith({bool? isRead, Map<String, bool>? readBy, DateTime? readAt}) {
    return AppNotification(
      id: id,
      salonId: salonId,
      title: title,
      body: body,
      type: type,
      targetRole: targetRole,
      targetUserId: targetUserId,
      targetEmployeeId: targetEmployeeId,
      targetCustomerId: targetCustomerId,
      customerPhoneNormalized: customerPhoneNormalized,
      isRead: isRead ?? this.isRead,
      readBy: readBy ?? this.readBy,
      actionRoute: actionRoute,
      actionParams: actionParams,
      createdAt: createdAt,
      createdBy: createdBy,
      priority: priority,
      status: status,
      recipientUserId: recipientUserId,
      recipientRole: recipientRole,
      routeName: routeName,
      entityId: entityId,
      entityType: entityType,
      readAt: readAt ?? this.readAt,
      dedupeKey: dedupeKey,
      payloadData: payloadData,
      imageUrl: imageUrl,
      eventTypeKey: eventTypeKey,
    );
  }
}
