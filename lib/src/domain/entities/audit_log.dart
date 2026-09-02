/// Represents an audit log entry for sensitive operations (SAD section 10).
class AuditLog {
  const AuditLog({
    required this.id,
    required this.actorId,
    required this.action,
    required this.entityType,
    required this.entityId,
    this.metadata = const {},
    required this.createdAt,
  });

  final String id;
  final String actorId;
  final String action;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  factory AuditLog.fromMap(Map<String, dynamic> map) => AuditLog(
    id: map['id'] as String,
    actorId: map['actorId'] as String,
    action: map['action'] as String,
    entityType: map['entityType'] as String,
    entityId: map['entityId'] as String,
    metadata: (map['metadata'] as Map<String, dynamic>?) ?? const {},
    createdAt: (map['createdAt'] as dynamic).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'actorId': actorId,
    'action': action,
    'entityType': entityType,
    'entityId': entityId,
    'metadata': metadata,
    'createdAt': createdAt,
  };
}
