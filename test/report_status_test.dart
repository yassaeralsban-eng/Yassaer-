import 'package:flutter_test/flutter_test.dart';

import 'package:found/src/domain/entities/report.dart';

void main() {
  group('ReportStatus lifecycle transitions (SAD section 11)', () {
    test('OPEN -> MATCHED -> CLAIMED -> VERIFYING', () {
      expect(ReportStatus.open.canTransitionTo(ReportStatus.matched), isTrue);
      expect(ReportStatus.matched.canTransitionTo(ReportStatus.claimed), isTrue);
      expect(ReportStatus.claimed.canTransitionTo(ReportStatus.verifying), isTrue);
    });

    test('VERIFYING -> APPROVED / REJECTED / REVIEW', () {
      expect(ReportStatus.verifying.canTransitionTo(ReportStatus.approved), isTrue);
      expect(ReportStatus.verifying.canTransitionTo(ReportStatus.rejected), isTrue);
      expect(ReportStatus.verifying.canTransitionTo(ReportStatus.review), isTrue);
    });

    test('REVIEW -> APPROVED / REJECTED only', () {
      expect(ReportStatus.review.canTransitionTo(ReportStatus.approved), isTrue);
      expect(ReportStatus.review.canTransitionTo(ReportStatus.rejected), isTrue);
      expect(ReportStatus.review.canTransitionTo(ReportStatus.verifying), isFalse);
    });

    test('APPROVED -> HANDOVER_PENDING -> RECOVERED -> CLOSED', () {
      expect(
        ReportStatus.approved.canTransitionTo(ReportStatus.handoverPending),
        isTrue,
      );
      expect(
        ReportStatus.handoverPending.canTransitionTo(ReportStatus.recovered),
        isTrue,
      );
      expect(ReportStatus.recovered.canTransitionTo(ReportStatus.closed), isTrue);
    });

    test('terminal states reject further transitions', () {
      expect(ReportStatus.rejected.canTransitionTo(ReportStatus.approved), isFalse);
      expect(ReportStatus.closed.canTransitionTo(ReportStatus.open), isFalse);
      expect(ReportStatus.recovered.canTransitionTo(ReportStatus.open), isFalse);
    });

    test('illegal jumps are rejected', () {
      expect(ReportStatus.open.canTransitionTo(ReportStatus.recovered), isFalse);
      expect(ReportStatus.open.canTransitionTo(ReportStatus.verifying), isFalse);
      expect(ReportStatus.matched.canTransitionTo(ReportStatus.closed), isFalse);
    });

    test('Arabic labels exist for every status', () {
      for (final status in ReportStatus.values) {
        expect(status.label, isNotEmpty);
      }
      expect(ReportStatus.open.label, 'مفتوح');
      expect(ReportStatus.recovered.label, 'تم الاستلام');
      expect(ReportStatus.closed.label, 'مغلق');
    });
  });

  group('ReportType', () {
    test('labels and fromName round-trip', () {
      expect(ReportType.lost.label, 'مفقود');
      expect(ReportType.found.label, 'معثور عليه');
      expect(ReportType.fromName('lost'), ReportType.lost);
      expect(ReportType.fromName('found'), ReportType.found);
      expect(ReportType.fromName('unknown'), ReportType.lost);
    });
  });
}