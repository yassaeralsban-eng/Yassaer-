/// Demo repositories for the Laqit platform (MVP demo mode).
///
/// These in-memory implementations let the app run and be widget-tested
/// without a configured Firebase project, while preserving the exact
/// repository contracts (Repository Pattern - SAD section 8).
library;

import 'dart:async';

import '../../domain/entities/user.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/private_verification.dart';
import '../../domain/entities/match_candidate.dart';
import '../../domain/entities/recovery_request.dart';
import '../../domain/entities/handover_record.dart';
import '../../domain/entities/abuse_report.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/repositories/match_repository.dart';
import '../../domain/repositories/recovery_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/services/matching_service.dart';

/// Shared in-memory demo store (singleton) so all demo repositories
/// operate on the same data.
class DemoStore {
  DemoStore._();
  static final DemoStore instance = DemoStore._();

  final reports = <Report>[];
  final private = <String, PrivateVerification>{};
  final matches = <MatchCandidate>[];
  final requests = <RecoveryRequest>[];
  final handovers = <HandoverRecord>[];
  final notifications = <AppNotification>[];
  final users = <User>[];
  final abuseReports = <AbuseReport>[];
  final logs = <AuditLog>[];
}

/// Demo auth: provides a signed-in demo user out of the box.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository();

  final _controller = StreamController<User?>.broadcast();

  User? _user = User(
    id: 'demo-user',
    displayName: 'أحمد العولقي',
    phone: '+967700000000',
    role: UserRole.user,
    trustScore: 85,
    status: UserStatus.active,
    createdAt: _seedTime(),
    updatedAt: _seedTime(),
  );

  static DateTime _seedTime() => DateTime(2026, 1);

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> authStateChanges() => _controller.stream;

  @override
  Future<User> signInWithPhone(String phone) async {
    _user = User(
      id: 'demo-user',
      displayName: 'أحمد العولقي',
      phone: phone,
      role: UserRole.user,
      trustScore: 85,
      status: UserStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _controller.add(_user);
    return _user!;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  @override
  Future<User> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final current = _user!;
    _user = current.copyWith(
      displayName: displayName,
      photoUrl: photoUrl,
    );
    _controller.add(_user);
    return _user!;
  }
}

/// In-memory report repository backed by the shared [DemoStore].
class DemoReportRepository implements ReportRepository {
  DemoReportRepository();

  /// Broadcasts the full reports list after every mutation,
  /// simulating Firestore snapshots so live UIs update.
  final _reportsController = StreamController<List<Report>>.broadcast(
    sync: true,
  );

  void _notify() {
    _reportsController.add(List.of(DemoStore.instance.reports));
  }

  @override
  Future<Report> createReport({
    required Report report,
    required PrivateVerification privateVerification,
  }) async {
    final store = DemoStore.instance;
    store.reports.insert(0, report);
    store.private[report.id] = privateVerification;

    // Simulate the onReportCreated Cloud Function (SAD section 18):
    // scan opposite-type open reports and rank explainable candidates.
    const service = MatchingService();
    final oppositeType =
        report.reportType == ReportType.lost
            ? ReportType.found
            : ReportType.lost;
    final candidates = store.reports
        .where(
          (r) =>
              r.reportType == oppositeType &&
              r.ownerId != report.ownerId &&
              r.status == ReportStatus.open,
        )
        .toList();

    final scored = <(Report, double)>[];
    for (final other in candidates) {
      final lost = report.reportType == ReportType.lost ? report : other;
      final found = report.reportType == ReportType.found ? report : other;
      scored.add((other, service.scoreBetween(lost, found)));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));

    for (final (other, score) in scored.take(3)) {
      if (score < matchThreshold) continue;
      final lostId =
          report.reportType == ReportType.lost ? report.id : other.id;
      final foundId =
          report.reportType == ReportType.found ? report.id : other.id;
      store.matches.insert(
        0,
        MatchCandidate(
          id: '${lostId}_$foundId',
          lostReportId: lostId,
          foundReportId: foundId,
          score: score,
          factors: service.factorsBetween(
            report.reportType == ReportType.lost ? report : other,
            report.reportType == ReportType.found ? report : other,
          ),
          status: MatchCandidateStatus.pending,
          createdAt: DateTime.now(),
        ),
      );
    }

    _notify();
    return report;
  }

  @override
  Future<Report> updateReport(Report report) async {
    final store = DemoStore.instance;
    final index = store.reports.indexWhere((r) => r.id == report.id);
    if (index >= 0) store.reports[index] = report;
    _notify();
    return report;
  }

  @override
  Future<Report?> getReport(String id) async =>
      DemoStore.instance.reports.where((r) => r.id == id).firstOrNull;

  @override
  Stream<List<Report>> watchMyReports(String ownerId) async* {
    yield* _reportsController.stream.map(
      (reports) => reports.where((r) => r.ownerId == ownerId).toList(),
    );
  }

  @override
  Future<List<Report>> searchReports({
    String? query,
    String? categoryId,
    String? location,
    DateTime? fromDate,
    DateTime? toDate,
    ReportType? type,
  }) async {
    var results = List.of(DemoStore.instance.reports);
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim();
      results = results
          .where(
            (r) =>
                r.title.contains(q) ||
                r.description.contains(q) ||
                r.categoryId.contains(q) ||
                r.approximateLocation.contains(q),
          )
          .toList();
    }
    if (categoryId != null) {
      results = results.where((r) => r.categoryId == categoryId).toList();
    }
    if (location != null) {
      results = results
          .where((r) => r.approximateLocation == location)
          .toList();
    }
    if (fromDate != null) {
      results = results.where((r) => !r.eventDate.isBefore(fromDate)).toList();
    }
    if (toDate != null) {
      results = results.where((r) => !r.eventDate.isAfter(toDate)).toList();
    }
    if (type != null) {
      results = results.where((r) => r.reportType == type).toList();
    }
    return results;
  }

  @override
  Stream<List<Report>> watchPublicReports() async* {
    yield List.of(DemoStore.instance.reports);
    yield* _reportsController.stream;
  }

  @override
  Future<PrivateVerification?> getPrivateVerification(String reportId) async =>
      DemoStore.instance.private[reportId];
}
/// In-memory match candidate repository.
class DemoMatchRepository implements MatchRepository {
  DemoMatchRepository();

  @override
  Stream<List<MatchCandidate>> watchMatchesForUser(String userId) async* {
    final store = DemoStore.instance;
    yield store.matches
        .where((m) => m.lostReportId == userId || m.foundReportId == userId)
        .toList();
  }

  @override
  Future<MatchCandidate?> getMatchCandidate(String id) async =>
      DemoStore.instance.matches.where((m) => m.id == id).firstOrNull;

  @override
  Future<void> acceptMatch(String matchId) async => _setStatus(
    matchId,
    MatchCandidateStatus.accepted,
  );

  @override
  Future<void> rejectMatch(String matchId) async => _setStatus(
    matchId,
    MatchCandidateStatus.rejected,
  );

  void _setStatus(String id, MatchCandidateStatus status) {
    final store = DemoStore.instance;
    final index = store.matches.indexWhere((m) => m.id == id);
    if (index >= 0) {
      final m = store.matches[index];
      store.matches[index] = MatchCandidate(
        id: m.id,
        lostReportId: m.lostReportId,
        foundReportId: m.foundReportId,
        score: m.score,
        factors: m.factors,
        status: status,
        createdAt: m.createdAt,
      );
    }
  }
}

/// In-memory recovery request and handover repository.
class DemoRecoveryRepository implements RecoveryRepository {
  DemoRecoveryRepository();

  @override
  Future<RecoveryRequest> createRecoveryRequest({
    required String matchId,
    required String requesterId,
  }) async {
    final now = DateTime.now();
    final store = DemoStore.instance;
    final request = RecoveryRequest(
      id: 'req-${store.requests.length + 1}',
      matchId: matchId,
      requesterId: requesterId,
      status: RecoveryRequestStatus.pending,
      createdAt: now,
      updatedAt: now,
    );
    store.requests.insert(0, request);
    return request;
  }

  @override
  Stream<List<RecoveryRequest>> watchMyRequests(String userId) async* {
    yield DemoStore.instance.requests
        .where((r) => r.requesterId == userId)
        .toList();
  }

  @override
  Future<VerificationResult> submitVerificationAnswers({
    required String recoveryRequestId,
    required List<String> answers,
  }) async {
    final result = answers.isEmpty
        ? VerificationResult.unverified
        : VerificationResult.verified;
    final store = DemoStore.instance;
    final index = store.requests.indexWhere((r) => r.id == recoveryRequestId);
    if (index >= 0) {
      final r = store.requests[index];
      store.requests[index] = r.copyWith(
        status: result == VerificationResult.verified
            ? RecoveryRequestStatus.approved
            : RecoveryRequestStatus.review,
        verificationResult: result,
        updatedAt: DateTime.now(),
      );
    }
    return result;
  }
@override
  Future<HandoverRecord> createHandover({
    required String recoveryRequestId,
    required String method,
    required String location,
  }) async {
    final store = DemoStore.instance;
    final record = HandoverRecord(
      id: 'hand-${store.handovers.length + 1}',
      recoveryRequestId: recoveryRequestId,
      method: method,
      location: location,
      status: HandoverStatus.pending,
      createdAt: DateTime.now(),
    );
    store.handovers.insert(0, record);
    final index = store.requests.indexWhere(
      (r) => r.id == recoveryRequestId,
    );
    if (index >= 0) {
      final r = store.requests[index];
      store.requests[index] = r.copyWith(
        status: RecoveryRequestStatus.handoverPending,
        updatedAt: DateTime.now(),
      );
    }
    return record;
  }

  @override
  Future<void> confirmHandover(String handoverId) async {
    final store = DemoStore.instance;
    final index = store.handovers.indexWhere((h) => h.id == handoverId);
    if (index >= 0) {
      store.handovers[index] = store.handovers[index].copyWith(
        status: HandoverStatus.completed,
        confirmedAt: DateTime.now(),
      );
    }
  }
}

/// In-memory notification repository.
class DemoNotificationRepository implements NotificationRepository {
  DemoNotificationRepository();

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) async* {
    yield DemoStore.instance.notifications
        .where((n) => n.userId == userId)
        .toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final store = DemoStore.instance;
    final index = store.notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      store.notifications[index] = store.notifications[index].markRead();
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final store = DemoStore.instance;
    for (var i = 0; i < store.notifications.length; i++) {
      if (store.notifications[i].userId == userId) {
        store.notifications[i] = store.notifications[i].markRead();
      }
    }
  }
}
/// In-memory admin repository.
class DemoAdminRepository implements AdminRepository {
  DemoAdminRepository();

  @override
  Stream<List<User>> watchUsers() async* {
    yield List.of(DemoStore.instance.users);
  }

  @override
  Future<void> updateUserStatus(String userId, UserStatus status) async {
    final store = DemoStore.instance;
    final index = store.users.indexWhere((u) => u.id == userId);
    if (index >= 0) {
      final u = store.users[index];
      store.users[index] = u.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Stream<List<AbuseReport>> watchAbuseReports() async* {
    yield List.of(DemoStore.instance.abuseReports);
  }

  @override
  Future<void> reviewAbuseReport(
    String abuseReportId, {
    required bool resolved,
  }) async {
    final store = DemoStore.instance;
    final index = store.abuseReports.indexWhere((a) => a.id == abuseReportId);
    if (index >= 0) {
      final a = store.abuseReports[index];
      store.abuseReports[index] = a.copyWith(
        status: resolved
            ? AbuseReportStatus.resolved
            : AbuseReportStatus.dismissed,
      );
    }
  }

  @override
  Stream<List<Report>> watchReportsForReview() async* {
    yield DemoStore.instance.reports
        .where((r) => r.status == ReportStatus.review)
        .toList();
  }

  @override
  Stream<List<AuditLog>> watchAuditLogs() async* {
    yield List.of(DemoStore.instance.logs);
  }

  @override
  Future<Map<String, int>> getStatistics() async {
    final reports = DemoStore.instance.reports;
    final lost =
        reports.where((r) => r.reportType == ReportType.lost).length;
    final recovered =
        reports.where((r) => r.status == ReportStatus.recovered).length;
    final closed =
        reports.where((r) => r.status == ReportStatus.closed).length;
    return {
      'total': reports.length,
      'lost': lost,
      'found': reports.length - lost,
      'recovered': recovered,
      'closed': closed,
      'open': reports.length - recovered - closed,
    };
  }
}