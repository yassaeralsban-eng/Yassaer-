import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/report.dart';
import '../../domain/entities/private_verification.dart';
import '../../domain/repositories/report_repository.dart';
import '../models/report_model.dart';

/// Firebase implementation of [ReportRepository] (SAD section 8).
class FirebaseReportRepository implements ReportRepository {
  FirebaseReportRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<Report> createReport({
    required Report report,
    required PrivateVerification privateVerification,
  }) async {
    final batch = _firestore.batch();

    // Public report document.
    final reportRef = _firestore.collection('reports').doc(report.id);
    batch.set(reportRef, ReportModel.fromEntity(report).toMap());

    // Private verification document - separate collection (SAD section 10).
    final privateRef = _firestore
        .collection('private_verification')
        .doc(report.id);
    batch.set(
      privateRef,
      PrivateVerificationModel.fromEntity(privateVerification).toMap(),
    );

    await batch.commit();
    return report;
  }

  @override
  Future<Report> updateReport(Report report) async {
    await _firestore
        .collection('reports')
        .doc(report.id)
        .update(ReportModel.fromEntity(report).toMap());
    return report;
  }

  @override
  Future<Report?> getReport(String id) async {
    final snapshot = await _firestore.collection('reports').doc(id).get();
    if (!snapshot.exists) return null;

    return ReportModel.fromMap(snapshot.data()!).toEntity();
  }

  @override
  Stream<List<Report>> watchMyReports(String ownerId) => _firestore
      .collection('reports')
      .where('ownerId', isEqualTo: ownerId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromMap(doc.data()).toEntity())
            .toList(),
      );

  @override
  Future<List<Report>> searchReports({
    String? query,
    String? categoryId,
    String? location,
    DateTime? fromDate,
    DateTime? toDate,
    ReportType? type,
  }) async {
    Query<Map<String, dynamic>> ref = _firestore.collection('reports');

    if (categoryId != null) {
      ref = ref.where('categoryId', isEqualTo: categoryId);
    }
    if (type != null) {
      ref = ref.where('reportType', isEqualTo: type.name);
    }
    if (location != null) {
      ref = ref.where('approximateLocation', isEqualTo: location);
    }
    if (fromDate != null) {
      ref = ref.where('eventDate', isGreaterThanOrEqualTo: fromDate);
    }
    if (toDate != null) {
      ref = ref.where('eventDate', isLessThanOrEqualTo: toDate);
    }

    final snapshot = await ref.orderBy('createdAt', descending: true).get();
    var reports = snapshot.docs
        .map((doc) => ReportModel.fromMap(doc.data()).toEntity())
        .toList();

    // Client-side keyword filtering (Firestore doesn't support full-text search).
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      reports = reports
          .where(
            (r) =>
                r.title.toLowerCase().contains(q) ||
                r.description.toLowerCase().contains(q),
          )
          .toList();
    }

    return reports;
  }

  @override
  Stream<List<Report>> watchPublicReports() => _firestore
      .collection('reports')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromMap(doc.data()).toEntity())
            .toList(),
      );

  @override
  Future<PrivateVerification?> getPrivateVerification(String reportId) async {
    final snapshot = await _firestore
        .collection('private_verification')
        .doc(reportId)
        .get();
    if (!snapshot.exists) return null;

    return PrivateVerificationModel.fromMap(snapshot.data()!).toEntity();
  }
}
