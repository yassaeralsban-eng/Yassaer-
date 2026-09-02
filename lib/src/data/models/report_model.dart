import '../../domain/entities/report.dart';
import '../../domain/entities/private_verification.dart';

/// Data model for the reports collection in Firestore (SAD section 10).
class ReportModel {
  const ReportModel({
    required this.id,
    required this.ownerId,
    required this.reportType,
    required this.categoryId,
    required this.title,
    required this.description,
    this.color,
    required this.approximateLocation,
    required this.eventDate,
    this.images = const [],
    this.publicAttributes = const {},
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;
  final ReportType reportType;
  final String categoryId;
  final String title;
  final String description;
  final String? color;
  final String approximateLocation;
  final DateTime eventDate;
  final List<String> images;
  final Map<String, String> publicAttributes;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ReportModel.fromMap(Map<String, dynamic> map) => ReportModel(
    id: map['id'] as String,
    ownerId: map['ownerId'] as String,
    reportType: ReportType.fromName(map['reportType'] as String?),
    categoryId: map['categoryId'] as String,
    title: map['title'] as String,
    description: map['description'] as String,
    color: map['color'] as String?,
    approximateLocation: map['approximateLocation'] as String,
    eventDate: (map['eventDate'] as dynamic).toDate(),
    images: (map['images'] as List<dynamic>?)?.cast<String>() ?? const [],
    publicAttributes:
        (map['publicAttributes'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v as String),
        ) ??
        const {},
    status: ReportStatus.fromName(map['status'] as String?),
    createdAt: (map['createdAt'] as dynamic).toDate(),
    updatedAt: (map['updatedAt'] as dynamic).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'ownerId': ownerId,
    'reportType': reportType.name,
    'categoryId': categoryId,
    'title': title,
    'description': description,
    'color': color,
    'approximateLocation': approximateLocation,
    'eventDate': eventDate,
    'images': images,
    'publicAttributes': publicAttributes,
    'status': status.name,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  Report toEntity() => Report(
    id: id,
    ownerId: ownerId,
    reportType: reportType,
    categoryId: categoryId,
    title: title,
    description: description,
    color: color,
    approximateLocation: approximateLocation,
    eventDate: eventDate,
    images: images,
    publicAttributes: publicAttributes,
    status: status,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory ReportModel.fromEntity(Report entity) => ReportModel(
    id: entity.id,
    ownerId: entity.ownerId,
    reportType: entity.reportType,
    categoryId: entity.categoryId,
    title: entity.title,
    description: entity.description,
    color: entity.color,
    approximateLocation: entity.approximateLocation,
    eventDate: entity.eventDate,
    images: entity.images,
    publicAttributes: entity.publicAttributes,
    status: entity.status,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );
}

/// Data model for the private_verification collection (SAD section 10).
/// This collection is NEVER readable by regular users.
class PrivateVerificationModel {
  const PrivateVerificationModel({
    required this.reportId,
    required this.secretAttributes,
    required this.verificationQuestions,
    required this.verificationAnswers,
    required this.createdAt,
  });

  final String reportId;
  final Map<String, String> secretAttributes;
  final List<String> verificationQuestions;
  final List<String> verificationAnswers;
  final DateTime createdAt;

  factory PrivateVerificationModel.fromMap(Map<String, dynamic> map) =>
      PrivateVerificationModel(
        reportId: map['reportId'] as String,
        secretAttributes:
            (map['secretAttributes'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as String),
            ) ??
            const {},
        verificationQuestions:
            (map['verificationQuestions'] as List<dynamic>?)?.cast<String>() ??
            const [],
        verificationAnswers:
            (map['verificationAnswers'] as List<dynamic>?)?.cast<String>() ??
            const [],
        createdAt: (map['createdAt'] as dynamic).toDate(),
      );

  Map<String, dynamic> toMap() => {
    'reportId': reportId,
    'secretAttributes': secretAttributes,
    'verificationQuestions': verificationQuestions,
    'verificationAnswers': verificationAnswers,
    'createdAt': createdAt,
  };

  PrivateVerification toEntity() => PrivateVerification(
    reportId: reportId,
    secretAttributes: secretAttributes,
    verificationQuestions: verificationQuestions,
    verificationAnswers: verificationAnswers,
    createdAt: createdAt,
  );

  factory PrivateVerificationModel.fromEntity(PrivateVerification entity) =>
      PrivateVerificationModel(
        reportId: entity.reportId,
        secretAttributes: entity.secretAttributes,
        verificationQuestions: entity.verificationQuestions,
        verificationAnswers: entity.verificationAnswers,
        createdAt: entity.createdAt,
      );
}
