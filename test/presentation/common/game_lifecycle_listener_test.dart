import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/presentation/common/game_lifecycle_listener.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('persists current game when app is detached', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GameLifecycleListener(
          child: MaterialApp(home: SizedBox.shrink()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(SizedBox));
    final container = ProviderScope.containerOf(context, listen: false);

    final notifier = container.read(gameSessionProvider.notifier);
    await notifier.startNewGame();
    await notifier.placeAt(0);
    final persistedTurnCount = container.read(gameSessionProvider)!.turnCount;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    final resumedContainer = ProviderContainer();
    addTearDown(resumedContainer.dispose);
    final resumedNotifier = resumedContainer.read(gameSessionProvider.notifier);
    await resumedNotifier.resumeGame();

    final resumedState = resumedContainer.read(gameSessionProvider);
    expect(resumedState, isNotNull);
    expect(resumedState!.turnCount, persistedTurnCount);
  });
}
