import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('saved game can be resumed after creating a new provider container', () async {
    final firstContainer = ProviderContainer();
    addTearDown(firstContainer.dispose);

    final firstNotifier = firstContainer.read(gameSessionProvider.notifier);
    await firstNotifier.startNewGame();
    await firstNotifier.placeAt(0);

    final savedTurnCount = firstContainer.read(gameSessionProvider)?.turnCount;
    expect(savedTurnCount, isNotNull);
    expect(savedTurnCount, greaterThan(0));

    final secondContainer = ProviderContainer();
    addTearDown(secondContainer.dispose);

    final secondNotifier = secondContainer.read(gameSessionProvider.notifier);
    await secondNotifier.resumeGame();

    final resumed = secondContainer.read(gameSessionProvider);
    expect(resumed, isNotNull);
    expect(resumed!.turnCount, savedTurnCount);
  });
}
