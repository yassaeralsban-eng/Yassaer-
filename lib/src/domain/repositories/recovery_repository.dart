import '../entities/recovery_request.dart';
import '../entities/handover_record.dart';

/// Contract for recovery operations (SAD section 9 - Recovery flow).
abstract interface class RecoveryRepository {
  /// Creates a recovery request for a match.
  Future<RecoveryRequest> createRecoveryRequest({
    required String matchId,
    required String requesterId,
  });

  /// Streams recovery requests for a user.
  Stream<List<RecoveryRequest>> watchMyRequests(String userId);

  /// Submits verification answers for a recovery request.
  /// This is a server-side operation (SAD section 14).
  Future<VerificationResult> submitVerificationAnswers({
    required String recoveryRequestId,
    required List<String> answers,
  });

  /// Creates a handover record for an approved recovery.
  Future<HandoverRecord> createHandover({
    required String recoveryRequestId,
    required String method,
    required String location,
  });

  /// Confirms receipt of the item (SRS FR-017).
  Future<void> confirmHandover(String handoverId);
}
