import '../../domain/entities/app_notification.dart';

/// Data model for the notifications collection in Firestore (SAD section 10).
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.entityId,
    this.readAt,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? entityId;
  final DateTime? readAt;
  final DateTime createdAt;

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['id'] as String,
        userId: map['userId'] as String,
        type: NotificationType.fromName(map['type'] as String?),
        title: map['title'] as String,
        body: map['body'] as String,
        entityId: map['entityId'] as String?,
        readAt: map['readAt'] == null
            ? null
            : (map['readAt'] as dynamic).toDate(),
        createdAt: (map['createdAt'] as dynamic).toDate(),
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'type': type.name,
    'title': title,
    'body': body,
    'entityId': entityId,
    'readAt': readAt,
    'createdAt': createdAt,
  };

  AppNotification toEntity() => AppNotification(
    id: id,
    userId: userId,
    type: type,
    title: title,
    body: body,
    entityId: entityId,
    readAt: readAt,
    createdAt: createdAt,
  );

  factory NotificationModel.fromEntity(AppNotification entity) =>
      NotificationModel(
        id: entity.id,
        userId: entity.userId,
        type: entity.type,
        title: entity.title,
        body: entity.body,
        entityId: entity.entityId,
        readAt: entity.readAt,
        createdAt: entity.createdAt,
      );
}
