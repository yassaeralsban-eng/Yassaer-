import '../entities/recovery_request.dart';
import '../entities/handover_record.dart';
import '../repositories/recovery_repository.dart';

/// Use case: Request recovery of a matched item (SRS FR-012).
class RequestRecovery {
  const RequestRecovery(this._repository);

  final RecoveryRepository _repository;

  Future<RecoveryRequest> call({
    required String matchId,
    required String requesterId,
  }) => _repository.createRecoveryRequest(
    matchId: matchId,
    requesterId: requesterId,
  );
}

/// Use case: Submit verification answers (SRS FR-013, SAD section 14).
class SubmitVerification {
  const SubmitVerification(this._repository);

  final RecoveryRepository _repository;

  Future<VerificationResult> call({
    required String recoveryRequestId,
    required List<String> answers,
  }) => _repository.submitVerificationAnswers(
    recoveryRequestId: recoveryRequestId,
    answers: answers,
  );
}

/// Use case: Create a handover record (SRS FR-017).
class CreateHandover {
  const CreateHandover(this._repository);

  final RecoveryRepository _repository;

  Future<HandoverRecord> call({
    required String recoveryRequestId,
    required String method,
    required String location,
  }) => _repository.createHandover(
    recoveryRequestId: recoveryRequestId,
    method: method,
    location: location,
  );
}

/// Use case: Confirm receipt of the item (SRS FR-017).
class ConfirmHandover {
  const ConfirmHandover(this._repository);

  final RecoveryRepository _repository;

  Future<void> call(String handoverId) =>
      _repository.confirmHandover(handoverId);
}
