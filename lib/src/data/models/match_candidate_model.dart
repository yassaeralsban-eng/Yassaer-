import '../../domain/entities/match_candidate.dart';

/// Data model for the match_candidates collection in Firestore (SAD section 10).
class MatchCandidateModel {
  const MatchCandidateModel({
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

  factory MatchCandidateModel.fromMap(Map<String, dynamic> map) =>
      MatchCandidateModel(
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

  MatchCandidate toEntity() => MatchCandidate(
    id: id,
    lostReportId: lostReportId,
    foundReportId: foundReportId,
    score: score,
    factors: factors,
    status: status,
    createdAt: createdAt,
  );

  factory MatchCandidateModel.fromEntity(MatchCandidate entity) =>
      MatchCandidateModel(
        id: entity.id,
        lostReportId: entity.lostReportId,
        foundReportId: entity.foundReportId,
        score: entity.score,
        factors: entity.factors,
        status: entity.status,
        createdAt: entity.createdAt,
      );
}
