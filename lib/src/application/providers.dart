import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/user.dart';
import '../domain/entities/report.dart';
import '../domain/entities/match_candidate.dart';
import '../domain/entities/recovery_request.dart';
import '../domain/entities/app_notification.dart';
import '../domain/entities/abuse_report.dart';
import '../domain/entities/audit_log.dart';
import '../data/repositories/firebase_auth_repository.dart';
import '../data/repositories/firebase_report_repository.dart';
import '../data/repositories/firebase_match_repository.dart';
import '../data/repositories/firebase_recovery_repository.dart';
import '../data/repositories/firebase_notification_repository.dart';
import '../data/repositories/firebase_admin_repository.dart';
import '../data/repositories/demo_repositories.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/report_repository.dart';
import '../domain/repositories/match_repository.dart';
import '../domain/repositories/recovery_repository.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/repositories/admin_repository.dart';
import '../domain/use_cases/create_report.dart';
import '../domain/use_cases/search_reports.dart';
import '../domain/use_cases/request_recovery.dart';

/// When true, the app uses the in-memory demo repositories so it can run
/// and be tested without a configured Firebase project.
/// Flip to false once real Firebase credentials are set up.
const kDemoMode = bool.fromEnvironment('LAQIT_DEMO', defaultValue: true);

/// Repository providers (SAD section 8 - Data layer).
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => kDemoMode ? DemoAuthRepository() : FirebaseAuthRepository(),
);

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => kDemoMode ? DemoReportRepository() : FirebaseReportRepository(),
);

final matchRepositoryProvider = Provider<MatchRepository>(
  (ref) => kDemoMode ? DemoMatchRepository() : FirebaseMatchRepository(),
);

final recoveryRepositoryProvider = Provider<RecoveryRepository>(
  (ref) => kDemoMode ? DemoRecoveryRepository() : FirebaseRecoveryRepository(),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => kDemoMode
      ? DemoNotificationRepository()
      : FirebaseNotificationRepository(),
);

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => kDemoMode ? DemoAdminRepository() : FirebaseAdminRepository(),
);

/// Use case providers (SAD section 8 - Application layer).
final createReportProvider = Provider<CreateReport>(
  (ref) => CreateReport(ref.watch(reportRepositoryProvider)),
);

final searchReportsProvider = Provider<SearchReports>(
  (ref) => SearchReports(ref.watch(reportRepositoryProvider)),
);

final requestRecoveryProvider = Provider<RequestRecovery>(
  (ref) => RequestRecovery(ref.watch(recoveryRepositoryProvider)),
);

final submitVerificationProvider = Provider<SubmitVerification>(
  (ref) => SubmitVerification(ref.watch(recoveryRepositoryProvider)),
);

final createHandoverProvider = Provider<CreateHandover>(
  (ref) => CreateHandover(ref.watch(recoveryRepositoryProvider)),
);

final confirmHandoverProvider = Provider<ConfirmHandover>(
  (ref) => ConfirmHandover(ref.watch(recoveryRepositoryProvider)),
);

/// Auth state provider.
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// Current user provider.
final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authRepositoryProvider).currentUser,
);

/// My reports stream provider.
final myReportsProvider = StreamProvider<List<Report>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(reportRepositoryProvider).watchMyReports(user.id);
});

/// Public reports stream provider.
final publicReportsProvider = StreamProvider<List<Report>>(
  (ref) => ref.watch(reportRepositoryProvider).watchPublicReports(),
);

/// My matches stream provider.
final myMatchesProvider = StreamProvider<List<MatchCandidate>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(matchRepositoryProvider).watchMatchesForUser(user.id);
});

/// My recovery requests stream provider.
final myRequestsProvider = StreamProvider<List<RecoveryRequest>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(recoveryRepositoryProvider).watchMyRequests(user.id);
});

/// My notifications stream provider.
final myNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(notificationRepositoryProvider).watchNotifications(user.id);
});

/// Admin: users stream provider.
final adminUsersProvider = StreamProvider<List<User>>(
  (ref) => ref.watch(adminRepositoryProvider).watchUsers(),
);

/// Admin: abuse reports stream provider.
final adminAbuseReportsProvider = StreamProvider<List<AbuseReport>>(
  (ref) => ref.watch(adminRepositoryProvider).watchAbuseReports(),
);

/// Admin: reports for review stream provider.
final adminReportsForReviewProvider = StreamProvider<List<Report>>(
  (ref) => ref.watch(adminRepositoryProvider).watchReportsForReview(),
);

/// Admin: audit logs stream provider.
final adminAuditLogsProvider = StreamProvider<List<AuditLog>>(
  (ref) => ref.watch(adminRepositoryProvider).watchAuditLogs(),
);
