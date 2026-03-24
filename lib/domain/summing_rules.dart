import 'dart:math';

import 'board.dart';
import 'cell_index.dart';
import 'game_phase.dart';
import 'game_state.dart';
import 'place_outcome.dart';

/// Pure game rules — no Flutter `BuildContext`, no I/O (PRD §7.1).
abstract final class SummingRules {
  /// Whether [linear] is a legal target for the next digit.
  static bool canPlace(GameState state, int linear) {
    if (state.phase != GamePhase.playing) return false;
    if (linear < 0 || linear >= CellIndex.cellCount) return false;
    return !state.board.cellAt(linear).isAssigned;
  }

  /// Places [state.queue.first] on [linear]. Consumes one turn and shifts queue.
  static PlaceOutcome place(GameState state, int linear, Random random) {
    if (!canPlace(state, linear)) {
      if (state.phase != GamePhase.playing) {
        return const PlaceFailure('Game is not in progress');
      }
      return const PlaceFailure('Cell is not empty');
    }

    final digit = state.queue.first;
    final neighbors = CellIndex.neighborLinears(linear).toList();

    var sum = 0;
    for (final n in neighbors) {
      final cell = state.board.cellAt(n);
      if (cell.isAssigned) sum += cell.value;
    }

    final matched = digit == sum % 10;
    final Board nextBoard;
    if (matched) {
      nextBoard = state.board.afterMatchClear(
        placedLinear: linear,
        neighborLinears: neighbors,
      );
    } else {
      nextBoard = state.board.withPlacedDigit(linear, digit);
    }

    final nextState = GameState(
      board: nextBoard,
      queue: state.queue.afterPlace(random),
      turnCount: state.turnCount + 1,
    );

    return PlaceSuccess(nextState, wasMatch: matched);
  }
}
