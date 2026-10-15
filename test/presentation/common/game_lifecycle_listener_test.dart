import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/presentation/common/game_lifecycle_listener.dart';

import '../../support/test_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 두 컨테이너가 같은 fake 저장소를 공유해 "앱 재시작 후 resume"을 흉내 낸다.
  late FakePorts ports;

  setUp(() async {
    ports = FakePorts();
  });

  testWidgets('persists current game when app is detached', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: ports.overrides(),
        child: const GameLifecycleListener(
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

    final resumedContainer = ProviderContainer(overrides: ports.overrides());
    addTearDown(resumedContainer.dispose);
    final resumedNotifier = resumedContainer.read(gameSessionProvider.notifier);
    await resumedNotifier.resumeGame();

    final resumedState = resumedContainer.read(gameSessionProvider);
    expect(resumedState, isNotNull);
    expect(resumedState!.turnCount, persistedTurnCount);
  });
}
