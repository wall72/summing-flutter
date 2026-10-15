import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/presentation/scores/scores_page.dart';

import '../../support/test_overrides.dart';

Future<void> _pumpScores(WidgetTester tester, List<int> scores) async {
  final fakes = FakePorts();
  fakes.highScores.scores = scores;
  final container = ProviderContainer(overrides: fakes.overrides());
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ScoresPage()),
    ),
  );
  await tester.pumpAndSettle();
}

/// 점수판 조회 고정 (AC-ARCH-10).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scores are listed best first', (tester) async {
    await _pumpScores(tester, [12, 15]);

    final best = tester.getTopLeft(find.text('12 turns'));
    final next = tester.getTopLeft(find.text('15 turns'));
    expect(best.dy, lessThan(next.dy));
  });

  testWidgets('empty scores show the no-games hint', (tester) async {
    await _pumpScores(tester, []);

    expect(
      find.textContaining(RegExp(r'^No completed games yet\.')),
      findsOneWidget,
    );
  });
}
