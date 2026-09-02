import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/abuse_report.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/repositories/admin_repository.dart';
import '../models/user_model.dart';
import '../models/report_model.dart';
import '../models/abuse_report_model.dart';

/// Firebase implementation of [AdminRepository] (SAD section 15).
class FirebaseAdminRepository implements AdminRepository {
  FirebaseAdminRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<User>> watchUsers() => _firestore
      .collection('users')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()).toEntity())
            .toList(),
      );

  @override
  Future<void> updateUserStatus(String userId, UserStatus status) async {
    await _firestore.collection('users').doc(userId).update({
      'status': status.name,
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Stream<List<AbuseReport>> watchAbuseReports() => _firestore
      .collection('abuse_reports')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => AbuseReportModel.fromMap(doc.data()).toEntity())
            .toList(),
      );

  @override
  Future<void> reviewAbuseReport(
    String abuseReportId, {
    required bool resolved,
  }) async {
    await _firestore.collection('abuse_reports').doc(abuseReportId).update({
      'status': resolved
          ? AbuseReportStatus.resolved.name
          : AbuseReportStatus.dismissed.name,
    });
  }

  @override
  Stream<List<Report>> watchReportsForReview() => _firestore
      .collection('reports')
      .where('status', isEqualTo: ReportStatus.review.name)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromMap(doc.data()).toEntity())
            .toList(),
      );

  @override
  Stream<List<AuditLog>> watchAuditLogs() => _firestore
      .collection('audit_logs')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => AuditLog.fromMap(doc.data())).toList(),
      );

  @override
  Future<Map<String, int>> getStatistics() async {
    final reports = await _firestore.collection('reports').get();
    final lossList = reports.docs.map((doc) => doc.data()).toList();
    final lost = lossList.where((d) => d['reportType'] == 'lost').length;
    final found = lossList.length - lost;
    final recovered = lossList.where((d) => d['status'] == 'recovered').length;
    final closed = lossList.where((d) => d['status'] == 'closed').length;

    return {
      'total': lossList.length,
      'lost': lost,
      'found': found,
      'recovered': recovered,
      'closed': closed,
      'open': lossList.length - recovered - closed,
    };
  }
}
