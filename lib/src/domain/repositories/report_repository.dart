import '../entities/report.dart';
import '../entities/private_verification.dart';

/// Contract for report operations (SAD section 8 - Data layer).
abstract interface class ReportRepository {
  /// Creates a new report with its private verification data.
  /// The private verification is stored separately (SAD section 10).
  Future<Report> createReport({
    required Report report,
    required PrivateVerification privateVerification,
  });

  /// Updates an existing report.
  Future<Report> updateReport(Report report);

  /// Fetches a report by id.
  Future<Report?> getReport(String id);

  /// Streams reports owned by a user.
  Stream<List<Report>> watchMyReports(String ownerId);

  /// Searches reports with filters (SRS FR-007, FR-008).
  Future<List<Report>> searchReports({
    String? query,
    String? categoryId,
    String? location,
    DateTime? fromDate,
    DateTime? toDate,
    ReportType? type,
  });

  /// Streams all public reports.
  Stream<List<Report>> watchPublicReports();

  /// Fetches private verification data for a report.
  /// Only accessible via server-side verification (SAD section 14).
  Future<PrivateVerification?> getPrivateVerification(String reportId);
}
