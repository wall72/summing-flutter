import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/domain/game_phase.dart';
import 'package:summing_flutter/domain/game_state.dart';
import 'package:summing_flutter/domain/place_outcome.dart';
import 'package:summing_flutter/domain/summing_rules.dart';

/// In-memory session + persistence hooks (PRD application layer).
final gameSessionProvider =
    NotifierProvider<GameSessionNotifier, GameState?>(GameSessionNotifier.new);

class GameSessionNotifier extends Notifier<GameState?> {
  final _random = Random();

  @override
  GameState? build() => null;

  Future<void> startNewGame() async {
    final saves = await ref.read(gameSaveRepositoryProvider.future);
    final fresh = GameState.initial(_random);
    state = fresh;
    await saves.save(fresh);
  }

  /// Loads the saved run. Finished runs are never resumable.
  Future<void> resumeGame() async {
    final saves = await ref.read(gameSaveRepositoryProvider.future);
    final loaded = saves.load();
    if (loaded == null) return;
    if (loaded.phase != GamePhase.playing) {
      await saves.clear();
      return;
    }
    state = loaded;
  }

  /// New random board (same as PRD restart).
  Future<void> restartGame() => startNewGame();

  void clearSession() {
    state = null;
  }

  /// Writes current game to disk (PRD: background / consistency).
  /// Skips when there is no session or the run is already finished.
  Future<void> persistIfNeeded() async {
    final current = state;
    if (current == null || current.phase != GamePhase.playing) return;

    final saves = await ref.read(gameSaveRepositoryProvider.future);
    await saves.save(current);
  }

  // @MX:ANCHOR: [AUTO] 착수 후 효과음→저장 순서와 저장/삭제/점수 기록 정책의 불변식
  // @MX:REASON: 게임 화면·생명주기·테스트가 호출한다. 효과음은 저장 I/O를 기다리지 않고(REQ-ARCH-006), complete는 점수 기록+저장 삭제, gameOver는 저장 삭제만, playing은 저장(REQ-ARCH-007/008). 오디오 포트가 준비 전·실패여도 진행한다(REQ-ARCH-009)
  Future<void> placeAt(int linear) async {
    final current = state;
    if (current == null) return;

    final outcome = SummingRules.place(current, linear, _random);
    if (outcome is! PlaceSuccess) return;

    final next = outcome.state;
    state = next;

    // Feedback first: don't make sound wait on disk I/O.
    final audio = ref.read(gameAudioProvider).valueOrNull;
    if (audio != null) {
      outcome.wasMatch ? audio.playMatch() : audio.playTap();
    }

    if (next.phase == GamePhase.complete) {
      final highScores = await ref.read(highScoreRepositoryProvider.future);
      await highScores.recordCompletedGame(next.turnCount);
    }
    final saves = await ref.read(gameSaveRepositoryProvider.future);
    if (next.phase == GamePhase.playing) {
      await saves.save(next);
    } else {
      // Complete or game over: nothing to resume.
      await saves.clear();
    }
  }
}
