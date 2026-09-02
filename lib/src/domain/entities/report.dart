/// Type of report.
enum ReportType {
  lost,
  found;

  String get label => switch (this) {
    ReportType.lost => 'مفقود',
    ReportType.found => 'معثور عليه',
  };

  static ReportType fromName(String? name) {
    for (final type in ReportType.values) {
      if (type.name == name) return type;
    }
    return ReportType.lost;
  }
}

/// Lifecycle status of a report per SAD section 11.
enum ReportStatus {
  open,
  matched,
  claimed,
  verifying,
  approved,
  rejected,
  review,
  handoverPending,
  recovered,
  closed;

  String get label => switch (this) {
    ReportStatus.open => 'مفتوح',
    ReportStatus.matched => 'تطابق محتمل',
    ReportStatus.claimed => 'تم المطالبة',
    ReportStatus.verifying => 'قيد التحقق',
    ReportStatus.approved => 'تمت الموافقة',
    ReportStatus.rejected => 'مرفوض',
    ReportStatus.review => 'قيد المراجعة',
    ReportStatus.handoverPending => 'بانتظار التسليم',
    ReportStatus.recovered => 'تم الاستلام',
    ReportStatus.closed => 'مغلق',
  };

  static ReportStatus fromName(String? name) {
    for (final status in ReportStatus.values) {
      if (status.name == name) return status;
    }
    return ReportStatus.open;
  }

  /// Allowed transitions per SAD section 11.
  bool canTransitionTo(ReportStatus next) => switch (this) {
    ReportStatus.open =>
      next == ReportStatus.matched || next == ReportStatus.closed,
    ReportStatus.matched =>
      next == ReportStatus.claimed || next == ReportStatus.open,
    ReportStatus.claimed => next == ReportStatus.verifying,
    ReportStatus.verifying =>
      next == ReportStatus.approved ||
          next == ReportStatus.rejected ||
          next == ReportStatus.review,
    ReportStatus.approved => next == ReportStatus.handoverPending,
    ReportStatus.review =>
      next == ReportStatus.approved || next == ReportStatus.rejected,
    ReportStatus.handoverPending => next == ReportStatus.recovered,
    ReportStatus.recovered => next == ReportStatus.closed,
    ReportStatus.rejected => false,
    ReportStatus.closed => false,
  };
}

/// Represents a lost or found item report.
class Report {
  const Report({
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

  factory Report.fromMap(Map<String, dynamic> map) => Report(
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

  Report copyWith({
    String? title,
    String? description,
    String? color,
    String? approximateLocation,
    DateTime? eventDate,
    List<String>? images,
    Map<String, String>? publicAttributes,
    ReportStatus? status,
    DateTime? updatedAt,
  }) => Report(
    id: id,
    ownerId: ownerId,
    reportType: reportType,
    categoryId: categoryId,
    title: title ?? this.title,
    description: description ?? this.description,
    color: color ?? this.color,
    approximateLocation: approximateLocation ?? this.approximateLocation,
    eventDate: eventDate ?? this.eventDate,
    images: images ?? this.images,
    publicAttributes: publicAttributes ?? this.publicAttributes,
    status: status ?? this.status,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
