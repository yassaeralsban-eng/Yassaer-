/// Private verification data for a report.
/// This is critical for the Security by Design principle (SAD section 5).
/// It is NEVER exposed publicly or used in the matching query.
class PrivateVerification {
  const PrivateVerification({
    required this.reportId,
    required this.secretAttributes,
    required this.verificationQuestions,
    required this.verificationAnswers,
    required this.createdAt,
  });

  final String reportId;

  /// Secret attributes entered by the report creator - never published.
  final Map<String, String> secretAttributes;

  /// Questions asked when someone requests recovery.
  final List<String> verificationQuestions;

  /// The expected answers (hashed server-side in production).
  final List<String> verificationAnswers;
  final DateTime createdAt;

  factory PrivateVerification.fromMap(Map<String, dynamic> map) =>
      PrivateVerification(
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
}
