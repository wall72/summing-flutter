import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/domain/game_phase.dart';
import 'package:summing_flutter/domain/game_state.dart';
import 'package:summing_flutter/domain/place_outcome.dart';
import 'package:summing_flutter/domain/summing_rules.dart';
import 'package:summing_flutter/infrastructure/audio/audio_providers.dart';
import 'package:summing_flutter/infrastructure/persistence/persistence_providers.dart';

/// In-memory session + persistence hooks (PRD application layer).
final gameSessionProvider =
    NotifierProvider<GameSessionNotifier, GameState?>(GameSessionNotifier.new);

class GameSessionNotifier extends Notifier<GameState?> {
  final _random = Random();

  @override
  GameState? build() => null;

  Future<void> startNewGame() async {
    final persistence = await ref.read(localPersistenceProvider.future);
    final fresh = GameState.initial(_random);
    state = fresh;
    await persistence.gameSave.save(fresh);
  }

  /// Loads the saved run. Finished runs are never resumable.
  Future<void> resumeGame() async {
    final persistence = await ref.read(localPersistenceProvider.future);
    final loaded = persistence.gameSave.load();
    if (loaded == null) return;
    if (loaded.phase != GamePhase.playing) {
      await persistence.gameSave.clear();
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

    final persistence = await ref.read(localPersistenceProvider.future);
    await persistence.gameSave.save(current);
  }

  Future<void> placeAt(int linear) async {
    final current = state;
    if (current == null) return;

    final outcome = SummingRules.place(current, linear, _random);
    if (outcome is! PlaceSuccess) return;

    final next = outcome.state;
    state = next;

    // Feedback first: don't make sound wait on disk I/O.
    final audio = ref.read(gameAudioServiceProvider).valueOrNull;
    if (audio != null) {
      outcome.wasMatch ? audio.playMatch() : audio.playTap();
    }

    final persistence = await ref.read(localPersistenceProvider.future);
    if (next.phase == GamePhase.complete) {
      await persistence.highScores.recordCompletedGame(next.turnCount);
    }
    if (next.phase == GamePhase.playing) {
      await persistence.gameSave.save(next);
    } else {
      // Complete or game over: nothing to resume.
      await persistence.gameSave.clear();
    }
  }
}
