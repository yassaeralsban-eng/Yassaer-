/// Status of an abuse report.
enum AbuseReportStatus {
  pending,
  reviewed,
  resolved,
  dismissed;

  String get label => switch (this) {
    AbuseReportStatus.pending => 'قيد المراجعة',
    AbuseReportStatus.reviewed => 'تمت المراجعة',
    AbuseReportStatus.resolved => 'تمت المعالجة',
    AbuseReportStatus.dismissed => 'مرفوض',
  };

  static AbuseReportStatus fromName(String? name) {
    for (final status in AbuseReportStatus.values) {
      if (status.name == name) return status;
    }
    return AbuseReportStatus.pending;
  }
}

/// Reasons for reporting a report.
enum AbuseReason {
  misleading,
  suspiciousClaim,
  inappropriateContent;

  String get label => switch (this) {
    AbuseReason.misleading => 'معلومات مضللة',
    AbuseReason.suspiciousClaim => 'ادعاء ملكية مشبوه',
    AbuseReason.inappropriateContent => 'محتوى غير مناسب',
  };

  static AbuseReason fromName(String? name) {
    for (final reason in AbuseReason.values) {
      if (reason.name == name) return reason;
    }
    return AbuseReason.misleading;
  }
}

/// Represents a report of abusive/malicious content.
class AbuseReport {
  const AbuseReport({
    required this.id,
    required this.targetReportId,
    required this.reporterId,
    required this.reason,
    this.description,
    required this.status,
    this.reviewedBy,
    required this.createdAt,
  });

  final String id;
  final String targetReportId;
  final String reporterId;
  final AbuseReason reason;
  final String? description;
  final AbuseReportStatus status;
  final String? reviewedBy;
  final DateTime createdAt;

  factory AbuseReport.fromMap(Map<String, dynamic> map) => AbuseReport(
    id: map['id'] as String,
    targetReportId: map['targetReportId'] as String,
    reporterId: map['reporterId'] as String,
    reason: AbuseReason.fromName(map['reason'] as String?),
    description: map['description'] as String?,
    status: AbuseReportStatus.fromName(map['status'] as String?),
    reviewedBy: map['reviewedBy'] as String?,
    createdAt: (map['createdAt'] as dynamic).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'targetReportId': targetReportId,
    'reporterId': reporterId,
    'reason': reason.name,
    'description': description,
    'status': status.name,
    'reviewedBy': reviewedBy,
    'createdAt': createdAt,
  };

  AbuseReport copyWith({AbuseReportStatus? status, String? reviewedBy}) =>
      AbuseReport(
        id: id,
        targetReportId: targetReportId,
        reporterId: reporterId,
        reason: reason,
        description: description,
        status: status ?? this.status,
        reviewedBy: reviewedBy ?? this.reviewedBy,
        createdAt: createdAt,
      );
}
