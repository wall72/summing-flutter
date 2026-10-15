import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/infrastructure/audio/audio_providers.dart';
import 'package:summing_flutter/infrastructure/audio/game_audio_service.dart';

import '../support/pre_refactor_fakes.dart';

/// 칸 10(=3)과 칸 40(=7)만 채워진 보드. 칸 0의 이웃(1, 9, 10) 합은 3이다.
Board _playingBoard() {
  final cells = List<SummingCell>.filled(CellIndex.cellCount, SummingCell.empty);
  cells[10] = const SummingCell.filled(3);
  cells[40] = const SummingCell.filled(7);
  return Board.fromCells(cells);
}

/// 칸 10(=3)만 채워진 보드. 칸 0에 3을 두면 매치로 보드가 비어 complete.
Board _oneMoveToCompleteBoard() {
  final cells = List<SummingCell>.filled(CellIndex.cellCount, SummingCell.empty);
  cells[10] = const SummingCell.filled(3);
  return Board.fromCells(cells);
}

/// 칸 0만 비어 있고 나머지는 1. 칸 0에 4(이웃 합 3과 불일치)를 두면 gameOver.
Board _oneMoveToGameOverBoard() {
  final cells =
      List<SummingCell>.filled(CellIndex.cellCount, const SummingCell.filled(1));
  cells[0] = SummingCell.empty;
  return Board.fromCells(cells);
}

GameState _state(Board board, int firstDigit, {int turnCount = 5}) =>
    GameState(
      board: board,
      queue: NextQueue([firstDigit, 1, 2, 3]),
      turnCount: turnCount,
    );

class _Harness {
  _Harness(this.fakes, this.container);

  final PreRefactorFakes fakes;
  final ProviderContainer container;

  List<String> get log => fakes.log;

  GameSessionNotifier get notifier =>
      container.read(gameSessionProvider.notifier);

  /// fake 저장소에 [state]를 넣고 resumeGame()으로 세션에 주입한 뒤 기록을 비운다.
  Future<void> resumeWith(GameState state) async {
    fakes.gameSave.stored = state;
    await notifier.resumeGame();
    log.clear();
  }

  int count(String entry) => log.where((e) => e == entry).length;
}

Future<_Harness> _harness({
  Future<GameAudioService> Function()? audioFuture,
}) async {
  final fakes = await PreRefactorFakes.create();
  final container =
      ProviderContainer(overrides: fakes.overrides(audioFuture: audioFuture));
  addTearDown(container.dispose);
  if (audioFuture == null) {
    // 실제 앱처럼 오디오가 준비된 상태에서 시작한다.
    await container.read(gameAudioServiceProvider.future);
  }
  return _Harness(fakes, container);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('placeAt sound before persistence (AC-ARCH-04)', () {
    test('non-match placement records playTap then save', () async {
      final h = await _harness();
      await h.resumeWith(_state(_playingBoard(), 4));

      await h.notifier.placeAt(0);

      expect(h.log, ['playTap', 'save']);
    });

    test('match placement records playMatch then save', () async {
      final h = await _harness();
      await h.resumeWith(_state(_playingBoard(), 3));

      await h.notifier.placeAt(0);

      expect(h.log, ['playMatch', 'save']);
    });
  });

  test('complete records the turn count once and clears the save (AC-ARCH-05)',
      () async {
    final h = await _harness();
    await h.resumeWith(_state(_oneMoveToCompleteBoard(), 3, turnCount: 5));

    await h.notifier.placeAt(0);

    expect(h.container.read(gameSessionProvider)!.phase, GamePhase.complete);
    expect(h.count('recordCompletedGame(6)'), 1);
    expect(h.count('clear'), 1);
    expect(h.count('save'), 0);
  });

  test('gameOver clears the save without recording a score (AC-ARCH-06)',
      () async {
    final h = await _harness();
    await h.resumeWith(_state(_oneMoveToGameOverBoard(), 4));

    await h.notifier.placeAt(0);

    expect(h.container.read(gameSessionProvider)!.phase, GamePhase.gameOver);
    expect(h.count('clear'), 1);
    expect(h.log.where((e) => e.startsWith('recordCompletedGame')), isEmpty);
    expect(h.count('save'), 0);
  });

  group('audio unavailable still applies and saves (AC-ARCH-07)', () {
    test('(a) audio never resolves', () async {
      final h = await _harness(
        audioFuture: () => Completer<GameAudioService>().future,
      );
      await h.resumeWith(_state(_playingBoard(), 4, turnCount: 5));

      await expectLater(h.notifier.placeAt(0), completes);

      expect(h.container.read(gameSessionProvider)!.turnCount, 6);
      expect(h.count('save'), 1);
    });

    test('(b) audio fails', () async {
      final h = await _harness(
        audioFuture: () =>
            Future<GameAudioService>.error(StateError('audio failed')),
      );
      await expectLater(
        h.container.read(gameAudioServiceProvider.future),
        throwsA(isA<StateError>()),
      );
      await h.resumeWith(_state(_playingBoard(), 4, turnCount: 5));

      await expectLater(h.notifier.placeAt(0), completes);

      expect(h.container.read(gameSessionProvider)!.turnCount, 6);
      expect(h.count('save'), 1);
    });
  });

  group('session lifecycle', () {
    test('startNewGame saves a fresh run with zero turns', () async {
      final h = await _harness();

      await h.notifier.startNewGame();

      expect(h.container.read(gameSessionProvider)!.turnCount, 0);
      expect(h.log, ['save']);
    });

    test('restartGame replaces the run with a fresh one', () async {
      final h = await _harness();
      await h.resumeWith(_state(_playingBoard(), 4, turnCount: 9));

      await h.notifier.restartGame();

      expect(h.container.read(gameSessionProvider)!.turnCount, 0);
      expect(h.log, ['save']);
    });

    test('resumeGame with no save leaves the session empty', () async {
      final h = await _harness();

      await h.notifier.resumeGame();

      expect(h.container.read(gameSessionProvider), isNull);
      expect(h.log, isEmpty);
    });

    test('placeAt without a session does nothing', () async {
      final h = await _harness();

      await h.notifier.placeAt(0);

      expect(h.container.read(gameSessionProvider), isNull);
      expect(h.log, isEmpty);
    });

    test('placeAt on an occupied cell does nothing', () async {
      final h = await _harness();
      await h.resumeWith(_state(_playingBoard(), 4, turnCount: 5));

      await h.notifier.placeAt(10);

      expect(h.container.read(gameSessionProvider)!.turnCount, 5);
      expect(h.log, isEmpty);
    });

    test('persistIfNeeded saves only a playing run', () async {
      final h = await _harness();

      await h.notifier.persistIfNeeded();
      expect(h.log, isEmpty);

      await h.resumeWith(_state(_playingBoard(), 4));
      await h.notifier.persistIfNeeded();
      expect(h.log, ['save']);

      h.notifier.clearSession();
      expect(h.container.read(gameSessionProvider), isNull);
    });
  });
}
