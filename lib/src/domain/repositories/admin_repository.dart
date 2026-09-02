import '../entities/user.dart';
import '../entities/report.dart';
import '../entities/abuse_report.dart';
import '../entities/audit_log.dart';

/// Contract for admin/moderation operations (SAD section 15, SRS FR-018 to FR-022).
abstract interface class AdminRepository {
  /// Streams all users (admin only).
  Stream<List<User>> watchUsers();

  /// Updates a user's status (suspend/ban/activate).
  Future<void> updateUserStatus(String userId, UserStatus status);

  /// Streams abuse reports for moderation.
  Stream<List<AbuseReport>> watchAbuseReports();

  /// Reviews an abuse report.
  Future<void> reviewAbuseReport(
    String abuseReportId, {
    required bool resolved,
  });

  /// Streams reports needing review (REVIEW status).
  Stream<List<Report>> watchReportsForReview();

  /// Streams audit logs (admin only).
  Stream<List<AuditLog>> watchAuditLogs();

  /// Fetches platform statistics (SRS FR-022).
  Future<Map<String, int>> getStatistics();
}
