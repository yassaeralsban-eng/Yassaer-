import '../entities/match_candidate.dart';

/// Contract for matching operations (SAD section 12).
abstract interface class MatchRepository {
  /// Streams match candidates for a user's reports.
  Stream<List<MatchCandidate>> watchMatchesForUser(String userId);

  /// Fetches a match candidate by id.
  Future<MatchCandidate?> getMatchCandidate(String id);

  /// Accepts a match candidate (starts recovery flow).
  Future<void> acceptMatch(String matchId);

  /// Rejects a match candidate.
  Future<void> rejectMatch(String matchId);
}
