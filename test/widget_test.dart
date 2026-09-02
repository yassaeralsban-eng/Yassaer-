import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:found/main.dart';
import 'package:found/src/data/demo_data.dart';

void main() {
  setUp(() {
    // Provide deterministic demo data for the in-memory repositories.
    seedDemoData();
  });

  Widget wrap(Widget child) => ProviderScope(child: child);

  testWidgets('Laqit starts with its Arabic home screen', (tester) async {
    await tester.pumpWidget(wrap(const LaqitApp()));
    await tester.pumpAndSettle();

    expect(find.text('لَقِيَت'), findsOneWidget);
    expect(find.text('أبلغ عن مفقود'), findsOneWidget);
    expect(find.text('البحث'), findsOneWidget);
    expect(find.text('هاتف ذكي أسود'), findsOneWidget);
  });

  testWidgets('a user can create a lost-item report', (tester) async {
    await tester.pumpWidget(wrap(const LaqitApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('أبلغ عن مفقود'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'هاتف أسود');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'هاتف أسود فُقد بالقرب من السوق القديم.',
    );
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('نشر البلاغ'));
    await tester.pumpAndSettle();

    expect(find.text('هاتف أسود'), findsOneWidget);
    expect(find.text('بلاغاتي'), findsWidgets);
  });
}
