import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/recovery_request.dart';
import '../../domain/entities/handover_record.dart';
import '../../domain/repositories/recovery_repository.dart';
import '../models/recovery_request_model.dart';
import '../models/handover_record_model.dart';

/// Firebase implementation of [RecoveryRepository] (SAD section 9).
class FirebaseRecoveryRepository implements RecoveryRepository {
  FirebaseRecoveryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<RecoveryRequest> createRecoveryRequest({
    required String matchId,
    required String requesterId,
  }) async {
    final now = DateTime.now();
    final doc = _firestore.collection('recovery_requests').doc();
    final request = RecoveryRequest(
      id: doc.id,
      matchId: matchId,
      requesterId: requesterId,
      status: RecoveryRequestStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
    await doc.set(RecoveryRequestModel.fromEntity(request).toMap());
    return request;
  }

  @override
  Stream<List<RecoveryRequest>> watchMyRequests(String userId) => _firestore
      .collection('recovery_requests')
      .where('requesterId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => RecoveryRequestModel.fromMap(doc.data()).toEntity())
            .toList(),
      );

  @override
  Future<VerificationResult> submitVerificationAnswers({
    required String recoveryRequestId,
    required List<String> answers,
  }) async {
    // In production this is a Cloud Function call (SAD section 18).
    // For the MVP we simulate the verification result.
    final result = answers.isEmpty
        ? VerificationResult.unverified
        : VerificationResult.verified;

    await _firestore
        .collection('recovery_requests')
        .doc(recoveryRequestId)
        .update({
          'status': result == VerificationResult.verified
              ? RecoveryRequestStatus.approved.name
              : RecoveryRequestStatus.review.name,
          'verificationResult': result.name,
          'updatedAt': DateTime.now(),
        });

    return result;
  }

  @override
  Future<HandoverRecord> createHandover({
    required String recoveryRequestId,
    required String method,
    required String location,
  }) async {
    final doc = _firestore.collection('handover_records').doc();
    final record = HandoverRecord(
      id: doc.id,
      recoveryRequestId: recoveryRequestId,
      method: method,
      location: location,
      status: HandoverStatus.pending,
      createdAt: DateTime.now(),
    );
    await doc.set(HandoverRecordModel.fromEntity(record).toMap());

    // Update the recovery request to handover pending.
    await _firestore
        .collection('recovery_requests')
        .doc(recoveryRequestId)
        .update({
          'status': RecoveryRequestStatus.handoverPending.name,
          'updatedAt': DateTime.now(),
        });

    return record;
  }

  @override
  Future<void> confirmHandover(String handoverId) async {
    final now = DateTime.now();
    await _firestore.collection('handover_records').doc(handoverId).update({
      'status': HandoverStatus.completed.name,
      'confirmedAt': now,
    });

    // Fetch the handover to update the recovery request.
    final snapshot = await _firestore
        .collection('handover_records')
        .doc(handoverId)
        .get();
    if (snapshot.exists) {
      final data = snapshot.data()!;
      final recoveryRequestId = data['recoveryRequestId'] as String;
      await _firestore
          .collection('recovery_requests')
          .doc(recoveryRequestId)
          .update({
            'status': RecoveryRequestStatus.recovered.name,
            'updatedAt': now,
          });
    }
  }
}
