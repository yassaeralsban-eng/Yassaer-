import '../../domain/entities/abuse_report.dart';

/// Data model for the abuse_reports collection in Firestore (SAD section 10).
class AbuseReportModel {
  const AbuseReportModel({
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

  factory AbuseReportModel.fromMap(Map<String, dynamic> map) =>
      AbuseReportModel(
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

  AbuseReport toEntity() => AbuseReport(
    id: id,
    targetReportId: targetReportId,
    reporterId: reporterId,
    reason: reason,
    description: description,
    status: status,
    reviewedBy: reviewedBy,
    createdAt: createdAt,
  );

  factory AbuseReportModel.fromEntity(AbuseReport entity) => AbuseReportModel(
    id: entity.id,
    targetReportId: entity.targetReportId,
    reporterId: entity.reporterId,
    reason: entity.reason,
    description: entity.description,
    status: entity.status,
    reviewedBy: entity.reviewedBy,
    createdAt: entity.createdAt,
  );
}
