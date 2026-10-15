import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/main.dart';

import 'support/test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App builds menu with Summing title',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: FakePorts().overrides(),
        child: const SummingApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Summing'), findsOneWidget);
    expect(find.text('New Game'), findsOneWidget);
  });
}
