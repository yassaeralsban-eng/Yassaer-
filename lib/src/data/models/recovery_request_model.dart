import '../../domain/entities/recovery_request.dart';

/// Data model for the recovery_requests collection in Firestore (SAD section 10).
class RecoveryRequestModel {
  const RecoveryRequestModel({
    required this.id,
    required this.matchId,
    required this.requesterId,
    required this.status,
    this.verificationResult,
    this.reviewedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String matchId;
  final String requesterId;
  final RecoveryRequestStatus status;
  final VerificationResult? verificationResult;
  final String? reviewedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory RecoveryRequestModel.fromMap(Map<String, dynamic> map) =>
      RecoveryRequestModel(
        id: map['id'] as String,
        matchId: map['matchId'] as String,
        requesterId: map['requesterId'] as String,
        status: RecoveryRequestStatus.fromName(map['status'] as String?),
        verificationResult: map['verificationResult'] == null
            ? null
            : VerificationResult.fromName(map['verificationResult'] as String?),
        reviewedBy: map['reviewedBy'] as String?,
        createdAt: (map['createdAt'] as dynamic).toDate(),
        updatedAt: (map['updatedAt'] as dynamic).toDate(),
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'matchId': matchId,
    'requesterId': requesterId,
    'status': status.name,
    'verificationResult': verificationResult?.name,
    'reviewedBy': reviewedBy,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  RecoveryRequest toEntity() => RecoveryRequest(
    id: id,
    matchId: matchId,
    requesterId: requesterId,
    status: status,
    verificationResult: verificationResult,
    reviewedBy: reviewedBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory RecoveryRequestModel.fromEntity(RecoveryRequest entity) =>
      RecoveryRequestModel(
        id: entity.id,
        matchId: entity.matchId,
        requesterId: entity.requesterId,
        status: entity.status,
        verificationResult: entity.verificationResult,
        reviewedBy: entity.reviewedBy,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}
