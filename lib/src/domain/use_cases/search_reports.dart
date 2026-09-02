import '../entities/report.dart';
import '../repositories/report_repository.dart';

/// Use case: Search and filter reports (SRS FR-007, FR-008).
class SearchReports {
  const SearchReports(this._repository);

  final ReportRepository _repository;

  Future<List<Report>> call({
    String? query,
    String? categoryId,
    String? location,
    DateTime? fromDate,
    DateTime? toDate,
    ReportType? type,
  }) => _repository.searchReports(
    query: query,
    categoryId: categoryId,
    location: location,
    fromDate: fromDate,
    toDate: toDate,
    type: type,
  );
}
