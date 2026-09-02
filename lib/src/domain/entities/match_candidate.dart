/// Status of a match candidate.
enum MatchCandidateStatus {
  pending,
  accepted,
  rejected,
  expired;

  String get label => switch (this) {
    MatchCandidateStatus.pending => 'قيد الانتظار',
    MatchCandidateStatus.accepted => 'مقبول',
    MatchCandidateStatus.rejected => 'مرفوض',
    MatchCandidateStatus.expired => 'منتهي',
  };

  static MatchCandidateStatus fromName(String? name) {
    for (final status in MatchCandidateStatus.values) {
      if (status.name == name) return status;
    }
    return MatchCandidateStatus.pending;
  }
}

/// A factor that contributed to the match score.
/// Used for the Explainability principle (SAD section 12).
class MatchFactor {
  const MatchFactor({
    required this.name,
    required this.weight,
    required this.value,
  });

  final String name;
  final double weight;
  final double value;

  factory MatchFactor.fromMap(Map<String, dynamic> map) => MatchFactor(
    name: map['name'] as String,
    weight: (map['weight'] as num).toDouble(),
    value: (map['value'] as num).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'weight': weight,
    'value': value,
  };
}

/// Represents a potential match between a lost and found report.
/// Matching is NOT proof of ownership (SAD section 13).
class MatchCandidate {
  const MatchCandidate({
    required this.id,
    required this.lostReportId,
    required this.foundReportId,
    required this.score,
    required this.factors,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String lostReportId;
  final String foundReportId;
  final double score;
  final List<MatchFactor> factors;
  final MatchCandidateStatus status;
  final DateTime createdAt;

  factory MatchCandidate.fromMap(Map<String, dynamic> map) => MatchCandidate(
    id: map['id'] as String,
    lostReportId: map['lostReportId'] as String,
    foundReportId: map['foundReportId'] as String,
    score: (map['score'] as num).toDouble(),
    factors:
        (map['factors'] as List<dynamic>?)
            ?.map((e) => MatchFactor.fromMap(e as Map<String, dynamic>))
            .toList() ??
        const [],
    status: MatchCandidateStatus.fromName(map['status'] as String?),
    createdAt: (map['createdAt'] as dynamic).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'lostReportId': lostReportId,
    'foundReportId': foundReportId,
    'score': score,
    'factors': factors.map((f) => f.toMap()).toList(),
    'status': status.name,
    'createdAt': createdAt,
  };
}
