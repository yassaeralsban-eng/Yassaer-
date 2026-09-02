import '../entities/report.dart';
import '../entities/private_verification.dart';
import '../repositories/report_repository.dart';

/// Use case: Create a lost or found report (SRS FR-004, FR-005).
class CreateReport {
  const CreateReport(this._repository);

  final ReportRepository _repository;

  Future<Report> call({
    required Report report,
    required PrivateVerification privateVerification,
  }) async {
    // Validate required fields per SRS.
    if (report.title.trim().isEmpty) {
      throw ArgumentError('عنوان البلاغ مطلوب');
    }
    if (report.description.trim().length < 10) {
      throw ArgumentError('الوصف يجب ألا يقل عن 10 أحرف');
    }
    if (report.approximateLocation.trim().isEmpty) {
      throw ArgumentError('الموقع التقريبي مطلوب');
    }
    if (report.eventDate.isAfter(DateTime.now())) {
      throw ArgumentError('التاريخ غير صالح');
    }

    return _repository.createReport(
      report: report,
      privateVerification: privateVerification,
    );
  }
}
