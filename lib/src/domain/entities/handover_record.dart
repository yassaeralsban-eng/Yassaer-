/// Status of a handover record.
enum HandoverStatus {
  pending,
  completed,
  cancelled;

  String get label => switch (this) {
    HandoverStatus.pending => 'قيد الانتظار',
    HandoverStatus.completed => 'مكتمل',
    HandoverStatus.cancelled => 'ملغي',
  };

  static HandoverStatus fromName(String? name) {
    for (final status in HandoverStatus.values) {
      if (status.name == name) return status;
    }
    return HandoverStatus.pending;
  }
}

/// Represents a handover/delivery record for a recovery request.
class HandoverRecord {
  const HandoverRecord({
    required this.id,
    required this.recoveryRequestId,
    required this.method,
    required this.location,
    required this.status,
    this.confirmedAt,
    required this.createdAt,
  });

  final String id;
  final String recoveryRequestId;
  final String method;
  final String location;
  final HandoverStatus status;
  final DateTime? confirmedAt;
  final DateTime createdAt;

  factory HandoverRecord.fromMap(Map<String, dynamic> map) => HandoverRecord(
    id: map['id'] as String,
    recoveryRequestId: map['recoveryRequestId'] as String,
    method: map['method'] as String,
    location: map['location'] as String,
    status: HandoverStatus.fromName(map['status'] as String?),
    confirmedAt: map['confirmedAt'] == null
        ? null
        : (map['confirmedAt'] as dynamic).toDate(),
    createdAt: (map['createdAt'] as dynamic).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'recoveryRequestId': recoveryRequestId,
    'method': method,
    'location': location,
    'status': status.name,
    'confirmedAt': confirmedAt,
    'createdAt': createdAt,
  };

  HandoverRecord copyWith({HandoverStatus? status, DateTime? confirmedAt}) =>
      HandoverRecord(
        id: id,
        recoveryRequestId: recoveryRequestId,
        method: method,
        location: location,
        status: status ?? this.status,
        confirmedAt: confirmedAt ?? this.confirmedAt,
        createdAt: createdAt,
      );
}
