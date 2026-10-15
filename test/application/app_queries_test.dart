import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/app_queries.dart';
import 'package:summing_flutter/application/models/app_settings.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/application/ports.dart';
import 'package:summing_flutter/domain/summing_domain.dart';

import '../support/test_overrides.dart';

GameState _save({required bool finished, int turnCount = 4}) {
  final cells = List<SummingCell>.filled(
    CellIndex.cellCount,
    finished ? const SummingCell.filled(1) : SummingCell.empty,
  );
  if (!finished) cells[40] = const SummingCell.filled(7);
  return GameState(
    board: Board.fromCells(cells),
    queue: NextQueue(const [1, 2, 3, 4]),
    turnCount: turnCount,
  );
}

ProviderContainer _container(
  FakePorts ports, {
  Future<GameAudio> Function()? audioFuture,
}) {
  final container =
      ProviderContainer(overrides: ports.overrides(audioFuture: audioFuture));
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('resumableGameProvider', () {
    test('returns a playing save', () async {
      final ports = FakePorts()..gameSave.stored = _save(finished: false);
      final container = _container(ports);

      final game = await container.read(resumableGameProvider.future);

      expect(game?.turnCount, 4);
    });

    test('hides a finished save', () async {
      final ports = FakePorts()..gameSave.stored = _save(finished: true);
      final container = _container(ports);

      expect(await container.read(resumableGameProvider.future), isNull);
    });

    test('returns null without a save', () async {
      final container = _container(FakePorts());

      expect(await container.read(resumableGameProvider.future), isNull);
    });

    test('re-reads the port after invalidate', () async {
      final ports = FakePorts();
      final container = _container(ports);
      expect(await container.read(resumableGameProvider.future), isNull);

      ports.gameSave.stored = _save(finished: false, turnCount: 0);
      container.invalidate(resumableGameProvider);

      final game = await container.read(resumableGameProvider.future);
      expect(game?.turnCount, 0);
    });
  });

  test('highScoresProvider reads the high score port', () async {
    final ports = FakePorts()..highScores.scores = [12, 15];
    final container = _container(ports);

    expect(await container.read(highScoresProvider.future), [12, 15]);
  });

  group('SettingsController (REQ-ARCH-010)', () {
    test('loads stored settings', () async {
      final ports = FakePorts()
        ..settings.current = const AppSettings(musicOn: false);
      final container = _container(ports);

      expect(
        await container.read(settingsControllerProvider.future),
        const AppSettings(musicOn: false, soundOn: true),
      );
    });

    test('music change saves, then resyncs BGM', () async {
      final ports = FakePorts();
      final container = _container(ports);
      await container.read(gameAudioProvider.future);
      await container.read(settingsControllerProvider.future);

      await container
          .read(settingsControllerProvider.notifier)
          .setMusicOn(false);

      expect(ports.log, [
        'save(AppSettings(musicOn: false, soundOn: true))',
        'applySettingsAndSyncBgm',
      ]);
      expect(
        container.read(settingsControllerProvider).requireValue,
        const AppSettings(musicOn: false, soundOn: true),
      );
    });

    test('sound change saves without BGM resync', () async {
      final ports = FakePorts();
      final container = _container(ports);
      await container.read(gameAudioProvider.future);
      await container.read(settingsControllerProvider.future);

      await container
          .read(settingsControllerProvider.notifier)
          .setSoundOn(false);

      expect(ports.log, ['save(AppSettings(musicOn: true, soundOn: false))']);
    });

    test('music change still saves when audio is not ready', () async {
      final ports = FakePorts();
      final container = _container(
        ports,
        audioFuture: () => Completer<GameAudio>().future,
      );
      await container.read(settingsControllerProvider.future);

      await container
          .read(settingsControllerProvider.notifier)
          .setMusicOn(false);

      expect(ports.log, ['save(AppSettings(musicOn: false, soundOn: true))']);
    });

    test('rapid toggles persist the last value', () async {
      final ports = FakePorts();
      final container = _container(ports);
      await container.read(settingsControllerProvider.future);
      final controller = container.read(settingsControllerProvider.notifier);

      await Future.wait([
        controller.setSoundOn(false),
        controller.setSoundOn(true),
      ]);

      expect(ports.settings.current, const AppSettings());
      expect(container.read(settingsControllerProvider).requireValue,
          ports.settings.current);
    });

    test('changes before settings load are ignored', () async {
      final ports = FakePorts();
      final container = _container(ports);
      final controller = container.read(settingsControllerProvider.notifier);

      await controller.setMusicOn(false);

      expect(ports.log, isEmpty);
    });
  });
}
