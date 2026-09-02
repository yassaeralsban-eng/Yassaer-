import '../../domain/entities/handover_record.dart';

/// Data model for the handover_records collection in Firestore (SAD section 10).
class HandoverRecordModel {
  const HandoverRecordModel({
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

  factory HandoverRecordModel.fromMap(Map<String, dynamic> map) =>
      HandoverRecordModel(
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

  HandoverRecord toEntity() => HandoverRecord(
    id: id,
    recoveryRequestId: recoveryRequestId,
    method: method,
    location: location,
    status: status,
    confirmedAt: confirmedAt,
    createdAt: createdAt,
  );

  factory HandoverRecordModel.fromEntity(HandoverRecord entity) =>
      HandoverRecordModel(
        id: entity.id,
        recoveryRequestId: entity.recoveryRequestId,
        method: entity.method,
        location: entity.location,
        status: entity.status,
        confirmedAt: entity.confirmedAt,
        createdAt: entity.createdAt,
      );
}
