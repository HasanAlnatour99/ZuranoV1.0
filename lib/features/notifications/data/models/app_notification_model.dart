import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/firestore/firestore_serializers.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/enums/notification_role_scope.dart';
import '../../domain/notification_type_mapper.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.salonId,
    required super.title,
    required super.body,
    required super.type,
    required super.targetRole,
    required super.isRead,
    required super.readBy,
    required super.createdAt,
    required super.priority,
    required super.status,
    super.targetUserId,
    super.targetEmployeeId,
    super.targetCustomerId,
    super.customerPhoneNormalized,
    super.actionRoute,
    super.actionParams,
    super.createdBy,
    super.recipientUserId,
    super.recipientRole,
    super.routeName,
    super.entityId,
    super.entityType,
    super.readAt,
    super.dedupeKey,
    super.payloadData,
    super.imageUrl,
    super.eventTypeKey,
  });

  factory AppNotificationModel.fromEntity(AppNotification entity) {
    return AppNotificationModel(
      id: entity.id,
      salonId: entity.salonId,
      title: entity.title,
      body: entity.body,
      type: entity.type,
      targetRole: entity.targetRole,
      targetUserId: entity.targetUserId,
      targetEmployeeId: entity.targetEmployeeId,
      targetCustomerId: entity.targetCustomerId,
      customerPhoneNormalized: entity.customerPhoneNormalized,
      isRead: entity.isRead,
      readBy: entity.readBy,
      actionRoute: entity.actionRoute,
      actionParams: entity.actionParams,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
      priority: entity.priority,
      status: entity.status,
      recipientUserId: entity.recipientUserId,
      recipientRole: entity.recipientRole,
      routeName: entity.routeName,
      entityId: entity.entityId,
      entityType: entity.entityType,
      readAt: entity.readAt,
      dedupeKey: entity.dedupeKey,
      payloadData: entity.payloadData,
      imageUrl: entity.imageUrl,
      eventTypeKey: entity.eventTypeKey,
    );
  }

  factory AppNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final json = (doc.data() as Map<String, dynamic>? ?? <String, dynamic>{});
    final readByRaw = json['readBy'];
    final typeRaw = FirestoreSerializers.string(json['type']);
    final category = notificationCategoryForStoredType(typeRaw);

    return AppNotificationModel(
      id: doc.id,
      salonId: FirestoreSerializers.string(json['salonId']) ?? '',
      title: FirestoreSerializers.string(json['title']) ?? '',
      body: FirestoreSerializers.string(json['body']) ?? '',
      type: category,
      targetRole: NotificationTargetRole.fromValue(
        FirestoreSerializers.string(json['targetRole']),
      ),
      targetUserId: FirestoreSerializers.string(json['targetUserId']),
      targetEmployeeId: FirestoreSerializers.string(json['targetEmployeeId']),
      targetCustomerId: FirestoreSerializers.string(json['targetCustomerId']),
      customerPhoneNormalized: FirestoreSerializers.string(
        json['customerPhoneNormalized'],
      ),
      isRead: json['isRead'] == true,
      readBy: readByRaw is Map
          ? readByRaw.map<String, bool>(
              (key, value) => MapEntry(key.toString(), value == true),
            )
          : <String, bool>{},
      actionRoute: FirestoreSerializers.string(json['actionRoute']),
      actionParams: json['actionParams'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(
              json['actionParams'] as Map<String, dynamic>,
            )
          : null,
      createdAt: FirestoreSerializers.dateTime(json['createdAt']),
      createdBy: FirestoreSerializers.string(json['createdBy']),
      priority: FirestoreSerializers.string(json['priority']) ?? 'normal',
      status: FirestoreSerializers.string(json['status']) ?? 'active',
      recipientUserId: FirestoreSerializers.string(json['recipientUserId']),
      recipientRole: FirestoreSerializers.string(json['recipientRole']),
      routeName: FirestoreSerializers.string(json['routeName']),
      entityId: FirestoreSerializers.string(json['entityId']),
      entityType: FirestoreSerializers.string(json['entityType']),
      readAt: FirestoreSerializers.dateTime(json['readAt']),
      dedupeKey: FirestoreSerializers.string(json['dedupeKey']),
      payloadData: json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'] as Map<String, dynamic>)
          : null,
      imageUrl: FirestoreSerializers.string(json['imageUrl']),
      eventTypeKey: typeRaw,
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'id': id,
      'salonId': salonId,
      'title': title,
      'body': body,
      'type': eventTypeKey ?? type.value,
      'targetRole': targetRole.value,
      'targetUserId': targetUserId,
      'targetEmployeeId': targetEmployeeId,
      'targetCustomerId': targetCustomerId,
      'customerPhoneNormalized': customerPhoneNormalized,
      'isRead': isRead,
      'readBy': readBy,
      'actionRoute': actionRoute,
      'actionParams': actionParams,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'createdBy': createdBy,
      'priority': priority,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
      if (recipientUserId != null) 'recipientUserId': recipientUserId,
      if (recipientRole != null) 'recipientRole': recipientRole,
      if (routeName != null) 'routeName': routeName,
      if (entityId != null) 'entityId': entityId,
      if (entityType != null) 'entityType': entityType,
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      if (dedupeKey != null) 'dedupeKey': dedupeKey,
      if (payloadData != null) 'data': payloadData,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
