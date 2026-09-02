import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/match_candidate.dart';
import '../../domain/repositories/match_repository.dart';
import '../models/match_candidate_model.dart';

/// Firebase implementation of [MatchRepository] (SAD section 12).
class FirebaseMatchRepository implements MatchRepository {
  FirebaseMatchRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<MatchCandidate>> watchMatchesForUser(String userId) => _firestore
      .collection('match_candidates')
      .where('lostReportId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => MatchCandidateModel.fromMap(doc.data()).toEntity())
            .toList(),
      );

  @override
  Future<MatchCandidate?> getMatchCandidate(String id) async {
    final snapshot = await _firestore
        .collection('match_candidates')
        .doc(id)
        .get();
    if (!snapshot.exists) return null;
    return MatchCandidateModel.fromMap(snapshot.data()!).toEntity();
  }

  @override
  Future<void> acceptMatch(String matchId) async {
    await _firestore.collection('match_candidates').doc(matchId).update({
      'status': MatchCandidateStatus.accepted.name,
    });
  }

  @override
  Future<void> rejectMatch(String matchId) async {
    await _firestore.collection('match_candidates').doc(matchId).update({
      'status': MatchCandidateStatus.rejected.name,
    });
  }
}
