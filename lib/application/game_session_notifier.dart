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
  @override
  GameState? build() => null;

  Future<void> startNewGame() async {
    final persistence = await ref.read(localPersistenceProvider.future);
    final state = GameState.initial(Random());
    await persistence.gameSave.save(state);
    this.state = state;
  }

  Future<void> resumeGame() async {
    final persistence = await ref.read(localPersistenceProvider.future);
    final loaded = persistence.gameSave.load();
    if (loaded != null) {
      state = loaded;
    }
  }

  /// New random board (same as PRD restart).
  Future<void> restartGame() async {
    await startNewGame();
  }

  void clearSession() {
    state = null;
  }

  /// Writes current game to disk (PRD: background / consistency).
  /// Skips when there is no session or the run is already cleared (complete).
  Future<void> persistIfNeeded() async {
    final current = state;
    if (current == null) return;
    if (current.phase == GamePhase.complete) return;

    final persistence = await ref.read(localPersistenceProvider.future);
    await persistence.gameSave.save(current);
  }

  Future<void> placeAt(int linear) async {
    final current = state;
    if (current == null) return;

    final outcome = SummingRules.place(current, linear, Random());
    if (outcome is PlaceFailure) return;

    final success = outcome as PlaceSuccess;
    state = success.state;

    final persistence = await ref.read(localPersistenceProvider.future);

    if (success.state.phase == GamePhase.complete) {
      await persistence.highScores.recordCompletedGame(success.state.turnCount);
      await persistence.gameSave.clear();
    } else {
      await persistence.gameSave.save(success.state);
    }

    await ref.read(gameAudioServiceProvider).when(
      data: (svc) async {
        if (success.wasMatch) {
          await svc.playMatch();
        } else {
          await svc.playTap();
        }
      },
      loading: () async {},
      error: (_, __) async {},
    );
  }
}
