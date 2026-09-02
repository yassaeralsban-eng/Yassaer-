/// Type of in-app notification (SAD section 19).
enum NotificationType {
  matchFound,
  recoveryRequestCreated,
  verificationResult,
  handoverPending,
  recoveryCompleted;

  String get label => switch (this) {
    NotificationType.matchFound => 'تطابق محتمل',
    NotificationType.recoveryRequestCreated => 'طلب استعادة',
    NotificationType.verificationResult => 'نتيجة التحقق',
    NotificationType.handoverPending => 'بانتظار التسليم',
    NotificationType.recoveryCompleted => 'اكتملت الاستعادة',
  };

  static NotificationType fromName(String? name) {
    for (final type in NotificationType.values) {
      if (type.name == name) return type;
    }
    return NotificationType.matchFound;
  }
}

/// Represents an in-app notification for a user.
class AppNotification {
  const AppNotification({
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

  bool get isRead => readAt != null;

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
    id: map['id'] as String,
    userId: map['userId'] as String,
    type: NotificationType.fromName(map['type'] as String?),
    title: map['title'] as String,
    body: map['body'] as String,
    entityId: map['entityId'] as String?,
    readAt: map['readAt'] == null ? null : (map['readAt'] as dynamic).toDate(),
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

  AppNotification markRead() => AppNotification(
    id: id,
    userId: userId,
    type: type,
    title: title,
    body: body,
    entityId: entityId,
    readAt: DateTime.now(),
    createdAt: createdAt,
  );
}
