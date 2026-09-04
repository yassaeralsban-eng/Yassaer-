/// Matching Service (SAD section 12).
///
/// Weighted, explainable matching between a lost report and a found report:
///
///   MatchScore = 0.20×CatMatch + 0.20×LocMatch + 0.15×DateMatch
///              + 0.10×ColorMatch + 0.35×DescSimilarity
///
/// The score is ONLY used to rank potential candidates and decide which
/// cases deserve a verification flow. It is NOT proof of ownership
/// (SAD section 13), and it never reads private_verification data.
library;

import '../entities/match_candidate.dart';
import '../entities/report.dart';

/// Weights defined in the SAD architecture document.
const matchWeights = <String, double>{
  'category': 0.20,
  'location': 0.20,
  'date': 0.15,
  'color': 0.10,
  'description': 0.35,
};

/// Operational threshold (SAD section 13): a calibratable parameter used to
/// decide which candidates trigger a notification. It is not a claim of
/// statistical accuracy.
const matchThreshold = 0.6;

/// Explainable matching service. Pure function - fully unit-testable.
class MatchingService {
  const MatchingService();

  /// Computes the weighted match score and its contributing factors
  /// between two public reports.
  List<MatchFactor> factorsBetween(Report lost, Report found) {
    final cat = lost.categoryId == found.categoryId ? 1.0 : 0.0;
    final loc = lost.approximateLocation == found.approximateLocation
        ? 1.0
        : 0.0;
    final date = _dateMatch(lost.eventDate, found.eventDate);
    final color = lost.color != null &&
            found.color != null &&
            lost.color == found.color
        ? 1.0
        : 0.0;
    final desc = _similarity(lost.description, found.description);

    return [
      MatchFactor(name: 'category', weight: matchWeights['category']!, value: cat),
      MatchFactor(name: 'location', weight: matchWeights['location']!, value: loc),
      MatchFactor(name: 'date', weight: matchWeights['date']!, value: date),
      MatchFactor(name: 'color', weight: matchWeights['color']!, value: color),
      MatchFactor(name: 'description', weight: matchWeights['description']!, value: desc),
    ];
  }

  /// Weighted score in the 0..1 range.
  double scoreBetween(Report lost, Report found) => factorsBetween(lost, found)
      .fold(0.0, (sum, f) => sum + f.weight * f.value);

  /// Whether the pair crosses the operational notification threshold.
  bool isCandidate(Report lost, Report found) =>
      scoreBetween(lost, found) >= matchThreshold;
}

/// Normalized 0..1 similarity between two Arabic free-text strings,
/// based on token overlap (keyword matching, explainable).
double _similarity(String a, String b) {
  final tokensA = _tokens(a);
  final tokensB = _tokens(b);
  if (tokensA.isEmpty || tokensB.isEmpty) return 0;
  if (tokensA.length == tokensB.length && tokensA.toSet().length == tokensB.toSet().length) {
    var same = 0;
    for (final t in tokensA) {
      if (tokensB.contains(t)) same++;
    }
    return same / tokensA.length;
  }
  var common = 0;
  final setB = tokensB.toSet();
  for (final t in tokensA.toSet()) {
    if (setB.contains(t)) common++;
  }
  return common / (tokensA.toSet().length > tokensB.toSet().length
      ? tokensA.toSet().length
      : tokensB.toSet().length);
}

/// Proximity between two event dates normalized to 0..1.
double _dateMatch(DateTime a, DateTime b, {int windowDays = 7}) {
  final diffDays = (a.difference(b).inHours / 24).abs();
  if (diffDays <= windowDays) return 1;
  if (diffDays >= windowDays * 4) return 0;
  return 1 - (diffDays - windowDays) / (windowDays * 3);
}

/// Splits Arabic text into normalized tokens.
List<String> _tokens(String text) => text
    .trim()
    .toLowerCase()
    .split(RegExp(r'[\s،,؛;.!؟?]+'))
    .where((t) => t.isNotEmpty)
    .toList();
