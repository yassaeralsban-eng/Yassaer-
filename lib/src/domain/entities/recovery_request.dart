/// Status of a recovery request.
enum RecoveryRequestStatus {
  pending,
  verifying,
  approved,
  rejected,
  review,
  handoverPending,
  recovered,
  closed;

  String get label => switch (this) {
    RecoveryRequestStatus.pending => 'قيد الانتظار',
    RecoveryRequestStatus.verifying => 'قيد التحقق',
    RecoveryRequestStatus.approved => 'تمت الموافقة',
    RecoveryRequestStatus.rejected => 'مرفوض',
    RecoveryRequestStatus.review => 'قيد المراجعة',
    RecoveryRequestStatus.handoverPending => 'بانتظار التسليم',
    RecoveryRequestStatus.recovered => 'تم الاستلام',
    RecoveryRequestStatus.closed => 'مغلق',
  };

  static RecoveryRequestStatus fromName(String? name) {
    for (final status in RecoveryRequestStatus.values) {
      if (status.name == name) return status;
    }
    return RecoveryRequestStatus.pending;
  }
}

/// Result of verification for a recovery request (SAD section 14).
enum VerificationResult {
  verified,
  uncertain,
  unverified;

  String get label => switch (this) {
    VerificationResult.verified => 'تحقق ناجح',
    VerificationResult.uncertain => 'غير حاسم',
    VerificationResult.unverified => 'لم يتحقق',
  };

  static VerificationResult fromName(String? name) {
    for (final result in VerificationResult.values) {
      if (result.name == name) return result;
    }
    return VerificationResult.unverified;
  }
}

/// Represents a recovery request for a matched item.
class RecoveryRequest {
  const RecoveryRequest({
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

  factory RecoveryRequest.fromMap(Map<String, dynamic> map) => RecoveryRequest(
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

  RecoveryRequest copyWith({
    RecoveryRequestStatus? status,
    VerificationResult? verificationResult,
    String? reviewedBy,
    DateTime? updatedAt,
  }) => RecoveryRequest(
    id: id,
    matchId: matchId,
    requesterId: requesterId,
    status: status ?? this.status,
    verificationResult: verificationResult ?? this.verificationResult,
    reviewedBy: reviewedBy ?? this.reviewedBy,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
