import 'package:flutter_test/flutter_test.dart';

import 'package:found/src/domain/entities/report.dart';
import 'package:found/src/domain/services/matching_service.dart';

Report report({
  required String id,
  required ReportType type,
  required String category,
  required String location,
  required String description,
  required DateTime date,
  String? color,
}) => Report(
  id: id,
  ownerId: 'owner-$id',
  reportType: type,
  categoryId: category,
  title: 'test',
  description: description,
  color: color,
  approximateLocation: location,
  eventDate: date,
  status: ReportStatus.open,
  createdAt: DateTime(2026, 1),
  updatedAt: DateTime(2026, 1),
);

void main() {
  const service = MatchingService();

  group('MatchingService (SAD section 12)', () {
    test('identical reports score 1.0 with full factors', () {
      final date = DateTime(2026, 8, 20);
      final lost = report(
        id: 'L1',
        type: ReportType.lost,
        category: 'electronics',
        location: 'السوق القديم، عتق',
        description: 'هاتف أسود من سامسونج بحالة جيدة',
        date: date,
        color: 'أسود',
      );
      final found = report(
        id: 'F1',
        type: ReportType.found,
        category: 'electronics',
        location: 'السوق القديم، عتق',
        description: 'هاتف أسود من سامسونج بحالة جيدة',
        date: date,
        color: 'أسود',
      );

      final factors = service.factorsBetween(lost, found);
      final score = service.scoreBetween(lost, found);

      expect(score, closeTo(1.0, 0.001));
      expect(factors.length, 5);
      for (final f in factors) {
        expect(f.value, closeTo(1.0, 0.001), reason: f.name);
      }
    });

    test('only matching category contributes 0.20', () {
      final lost = report(
        id: 'L2',
        type: ReportType.lost,
        category: 'electronics',
        location: 'حي الخزان، عتق',
        description: 'هاتف',
        date: DateTime(2026, 1, 1),
      );
      final found = report(
        id: 'F2',
        type: ReportType.found,
        category: 'electronics',
        location: 'شارع الجامعة، عتق',
        description: 'مفاتيح سيارة',
        date: DateTime(2026, 8, 20),
      );

      expect(service.scoreBetween(lost, found), closeTo(0.20, 0.001));
    });

    test('matching category + location contributes 0.40', () {
      final lost = report(
        id: 'L3',
        type: ReportType.lost,
        category: 'keys',
        location: 'السوق القديم، عتق',
        description: 'مفاتيح',
        date: DateTime(2026, 1, 1),
      );
      final found = report(
        id: 'F3',
        type: ReportType.found,
        category: 'keys',
        location: 'السوق القديم، عتق',
        description: 'محفظة جلدية',
        date: DateTime(2026, 8, 20),
      );

      expect(service.scoreBetween(lost, found), closeTo(0.40, 0.001));
    });

    test('crossing the operational threshold marks a candidate', () {
      final date = DateTime(2026, 8, 20);
      final lost = report(
        id: 'L4',
        type: ReportType.lost,
        category: 'documents',
        location: 'السوق القديم، عتق',
        description: 'محفظة جلدية بنية تحتوي أوراقاً شخصية',
        date: date,
        color: 'بني',
      );
      final found = report(
        id: 'F4',
        type: ReportType.found,
        category: 'documents',
        location: 'السوق القديم، عتق',
        description: 'محفظة جلدية بنية',
        date: date,
        color: 'بني',
      );

      final score = service.scoreBetween(lost, found);
      expect(score, greaterThanOrEqualTo(matchThreshold));
      expect(service.isCandidate(lost, found), isTrue);
    });

    test('completely different reports do not match', () {
      final lost = report(
        id: 'L5',
        type: ReportType.lost,
        category: 'electronics',
        location: 'حي الخزان، عتق',
        description: 'هاتف ذكي',
        date: DateTime(2026, 1, 1),
        color: 'أسود',
      );
      final found = report(
        id: 'F5',
        type: ReportType.found,
        category: 'bags',
        location: 'شارع الجامعة، عتق',
        description: 'حقيبة سفر زرقاء',
        date: DateTime(2026, 8, 20),
        color: 'أزرق',
      );

      expect(service.scoreBetween(lost, found), closeTo(0.0, 0.001));
      expect(service.isCandidate(lost, found), isFalse);
    });

    test('factor weights sum to 1.0 (SAD formula)', () {
      var sum = 0.0;
      for (final w in matchWeights.values) {
        sum += w;
      }
      expect(sum, closeTo(1.0, 0.001));
      expect(matchWeights['category'], 0.20);
      expect(matchWeights['location'], 0.20);
      expect(matchWeights['date'], 0.15);
      expect(matchWeights['color'], 0.10);
      expect(matchWeights['description'], 0.35);
    });
  });
}