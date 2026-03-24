import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/domain/cell_index.dart';
import 'package:summing_flutter/domain/game_phase.dart';
import 'package:summing_flutter/domain/game_state.dart';
import 'package:summing_flutter/domain/next_queue.dart';
import 'package:summing_flutter/domain/place_outcome.dart';
import 'package:summing_flutter/domain/board.dart';
import 'package:summing_flutter/domain/summing_cell.dart';
import 'package:summing_flutter/domain/summing_rules.dart';

void main() {
  group('SummingRules.place', () {
    test('match clears assigned neighbors only; placement stays empty', () {
      final cells = List<SummingCell>.filled(
        CellIndex.cellCount,
        SummingCell.empty,
      );
      const center = 40;
      const east = 41;
      cells[east] = const SummingCell.filled(3);

      final state = GameState(
        board: Board.fromCells(cells),
        queue: NextQueue([3, 0, 0, 0]),
        turnCount: 0,
      );

      final r = Random(1);
      final outcome = SummingRules.place(state, center, r);

      expect(outcome, isA<PlaceSuccess>());
      final success = outcome as PlaceSuccess;
      expect(success.wasMatch, true);
      final next = success.state;
      expect(next.board.cellAt(center).isAssigned, false);
      expect(next.board.cellAt(east).isAssigned, false);
      expect(next.turnCount, 1);
      expect(next.queue.slots[0], 0);
    });

    test('no match keeps digit on cell', () {
      final cells = List<SummingCell>.filled(
        CellIndex.cellCount,
        SummingCell.empty,
      );
      const center = 40;
      cells[31] = const SummingCell.filled(1); // neighbor contributes 1

      final state = GameState(
        board: Board.fromCells(cells),
        queue: NextQueue([5, 0, 0, 0]), // 5 != 1 % 10
        turnCount: 0,
      );

      final outcome = SummingRules.place(state, center, Random(2));
      expect(outcome, isA<PlaceSuccess>());
      final success = outcome as PlaceSuccess;
      expect(success.wasMatch, false);
      final next = success.state;
      expect(next.board.cellAt(center), const SummingCell.filled(5));
    });

    test('fails when cell is not empty', () {
      final cells = List<SummingCell>.filled(
        CellIndex.cellCount,
        SummingCell.empty,
      );
      cells[40] = const SummingCell.filled(1);
      final state = GameState(
        board: Board.fromCells(cells),
        queue: NextQueue([9, 0, 0, 0]),
        turnCount: 0,
      );
      final outcome = SummingRules.place(state, 40, Random(3));
      expect(outcome, isA<PlaceFailure>());
    });

    test('complete when board becomes all empty', () {
      final cells = List<SummingCell>.filled(
        CellIndex.cellCount,
        SummingCell.empty,
      );
      // Empty 40; neighbor 41 = 7 → placing 7 matches and clears 41; board all empty.
      cells[41] = const SummingCell.filled(7);
      final state = GameState(
        board: Board.fromCells(cells),
        queue: NextQueue([7, 0, 0, 0]),
        turnCount: 0,
      );
      final outcome = SummingRules.place(state, 40, Random(4));
      expect(outcome, isA<PlaceSuccess>());
      final next = (outcome as PlaceSuccess).state;
      expect(next.phase, GamePhase.complete);
    });

    test('fails after game already complete', () {
      final cells = List<SummingCell>.generate(
        CellIndex.cellCount,
        (_) => SummingCell.empty,
      );
      final state = GameState(
        board: Board.fromCells(cells),
        queue: NextQueue([1, 0, 0, 0]),
        turnCount: 0,
      );
      expect(state.phase, GamePhase.complete);
      final outcome = SummingRules.place(state, 40, Random(5));
      expect(outcome, isA<PlaceFailure>());
    });

    test('fails when board is full (game over)', () {
      final cells = List<SummingCell>.generate(
        CellIndex.cellCount,
        (_) => const SummingCell.filled(0),
      );
      final state = GameState(
        board: Board.fromCells(cells),
        queue: NextQueue([1, 2, 3, 4]),
        turnCount: 99,
      );
      expect(state.phase, GamePhase.gameOver);
      final outcome = SummingRules.place(state, 0, Random(6));
      expect(outcome, isA<PlaceFailure>());
    });
  });
}
