import 'dart:math';

import 'package:meta/meta.dart';

import 'board.dart';
import 'game_phase.dart';
import 'next_queue.dart';

/// Full immutable game snapshot (domain).
@immutable
class GameState {
  const GameState({
    required this.board,
    required this.queue,
    required this.turnCount,
  }) : assert(turnCount >= 0);

  factory GameState.initial(Random random) {
    return GameState(
      board: Board.initial(random),
      queue: NextQueue.random(random),
      turnCount: 0,
    );
  }

  final Board board;
  final NextQueue queue;
  final int turnCount;

  GamePhase get phase => GamePhase.fromBoard(board);

  GameState copyWith({
    Board? board,
    NextQueue? queue,
    int? turnCount,
  }) {
    return GameState(
      board: board ?? this.board,
      queue: queue ?? this.queue,
      turnCount: turnCount ?? this.turnCount,
    );
  }
}
