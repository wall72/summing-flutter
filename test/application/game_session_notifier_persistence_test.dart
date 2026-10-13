import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/infrastructure/audio/audio_providers.dart';
import 'package:summing_flutter/infrastructure/audio/game_audio_service.dart';
import 'package:summing_flutter/infrastructure/persistence/local_persistence.dart';

/// Audio needs native plugins; keep it pending so tests stay silent.
ProviderContainer _container() => ProviderContainer(
      overrides: [
        gameAudioServiceProvider.overrideWith(
          (ref) => Completer<GameAudioService>().future,
        ),
      ],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('saved game can be resumed after creating a new provider container',
      () async {
    final firstContainer = _container();
    addTearDown(firstContainer.dispose);

    final firstNotifier = firstContainer.read(gameSessionProvider.notifier);
    await firstNotifier.startNewGame();
    await firstNotifier.placeAt(0);

    final savedTurnCount = firstContainer.read(gameSessionProvider)?.turnCount;
    expect(savedTurnCount, isNotNull);
    expect(savedTurnCount, greaterThan(0));

    final secondContainer = _container();
    addTearDown(secondContainer.dispose);

    final secondNotifier = secondContainer.read(gameSessionProvider.notifier);
    await secondNotifier.resumeGame();

    final resumed = secondContainer.read(gameSessionProvider);
    expect(resumed, isNotNull);
    expect(resumed!.turnCount, savedTurnCount);
  });

  test('finished (board full) saves are not resumable and get cleared',
      () async {
    final persistence = await LocalPersistence.open();
    final fullBoard = Board.fromCells(
      List.filled(CellIndex.cellCount, const SummingCell.filled(1)),
    );
    await persistence.gameSave.save(
      GameState(
          board: fullBoard, queue: NextQueue(const [1, 2, 3, 4]), turnCount: 7),
    );

    final container = _container();
    addTearDown(container.dispose);
    await container.read(gameSessionProvider.notifier).resumeGame();

    expect(container.read(gameSessionProvider), isNull);
    expect(persistence.gameSave.hasSaveGame, isFalse);
  });
}
