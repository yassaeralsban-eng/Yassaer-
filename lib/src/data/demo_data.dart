/// Demo seed data for the Laqit MVP (نموذج تجريبي).
///
/// Populates the in-memory [DemoStore] so the app is usable immediately
/// and widget tests have deterministic data, matching the UX/UI mockups
/// (phone near the old souq, brown wallet, silver keys).
library;

import '../domain/entities/report.dart';
import '../domain/entities/user.dart';
import '../domain/entities/app_notification.dart';
import '../domain/entities/match_candidate.dart';
import 'repositories/demo_repositories.dart';

DateTime _ago(DateTime from, int days) => from.subtract(Duration(days: days));

/// Seeds the demo store with sample data.
void seedDemoData() {
  final store = DemoStore.instance;
  if (store.reports.isNotEmpty) return; // Only seed once.

  final now = DateTime(2026, 8, 22, 18, 20);

  store.users.add(
    User(
      id: 'demo-user',
      displayName: 'أحمد العولقي',
      phone: '+967700000000',
      role: UserRole.user,
      trustScore: 85,
      status: UserStatus.active,
      createdAt: _ago(now, 90),
      updatedAt: now,
    ),
  );

  store.reports.addAll([
    Report(
      id: 'F-2208',
      ownerId: 'demo-user',
      reportType: ReportType.found,
      categoryId: 'electronics',
      title: 'هاتف ذكي أسود',
      description: 'هاتف بحالة جيدة عُثر عليه بالقرب من السوق القديم.',
      approximateLocation: 'السوق القديم، عتق',
      eventDate: _ago(now, 1),
      status: ReportStatus.matched,
      createdAt: _ago(now, 1),
      updatedAt: _ago(now, 1),
    ),
    Report(
      id: 'L-1482',
      ownerId: 'demo-user',
      reportType: ReportType.lost,
      categoryId: 'documents',
      title: 'محفظة بنية',
      description:
          'محفظة جلدية تحتوي على أوراق شخصية. لا تظهر التفاصيل الخاصة للعامة.',
      approximateLocation: 'حي الخزان، عتق',
      eventDate: _ago(now, 4),
      status: ReportStatus.open,
      createdAt: _ago(now, 4),
      updatedAt: _ago(now, 4),
    ),
    Report(
      id: 'F-2201',
      ownerId: 'demo-user',
      reportType: ReportType.found,
      categoryId: 'keys',
      title: 'مجموعة مفاتيح فضية',
      description: 'مفاتيح سيارة ومفتاحان صغيران، عُثر عليها في مكان عام.',
      approximateLocation: 'شارع الجامعة، عتق',
      eventDate: _ago(now, 5),
      status: ReportStatus.open,
      createdAt: _ago(now, 5),
      updatedAt: _ago(now, 5),
    ),
  ]);

  store.matches.add(
    MatchCandidate(
      id: 'match-1',
      lostReportId: 'demo-user',
      foundReportId: 'F-2208',
      score: 0.87,
      factors: const [
        // Weights per SAD section 12.
        MatchFactor(name: 'category', weight: 0.20, value: 1.0),
        MatchFactor(name: 'location', weight: 0.20, value: 1.0),
        MatchFactor(name: 'date', weight: 0.15, value: 0.9),
        MatchFactor(name: 'color', weight: 0.10, value: 0.8),
        MatchFactor(name: 'description', weight: 0.35, value: 0.78),
      ],
      status: MatchCandidateStatus.pending,
      createdAt: _ago(now, 1),
    ),
  );

  store.notifications.addAll([
    AppNotification(
      id: 'n1',
      userId: 'demo-user',
      type: NotificationType.matchFound,
      title: 'تطابق محتمل جديد',
      body: 'وجدنا بلاغًا قد يتشابه مع هاتفك المفقود.',
      entityId: 'match-1',
      createdAt: _ago(now, 1),
    ),
    AppNotification(
      id: 'n2',
      userId: 'demo-user',
      type: NotificationType.recoveryCompleted,
      title: 'تم نشر بلاغك',
      body: 'بلاغ المحفظة البنية الآن مفتوح للبحث والمطابقة.',
      entityId: 'L-1482',
      readAt: _ago(now, 4),
      createdAt: _ago(now, 4),
    ),
  ]);
}
