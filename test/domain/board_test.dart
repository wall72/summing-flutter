import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/domain/board.dart';
import 'package:summing_flutter/domain/cell_index.dart';
import 'package:summing_flutter/domain/summing_cell.dart';

void main() {
  group('Board.initial', () {
    test('outer ring empty, inner 7×7 assigned', () {
      final board = Board.initial(Random(42));
      var borderEmpty = 0;
      var innerAssigned = 0;
      for (var i = 0; i < CellIndex.cellCount; i++) {
        final border = CellIndex.fromLinear(i).isBorder;
        final cell = board.cellAt(i);
        if (border) {
          borderEmpty += cell.isAssigned ? 0 : 1;
        } else {
          innerAssigned += cell.isAssigned ? 1 : 0;
        }
      }
      expect(borderEmpty, 32); // 81 - 49
      expect(innerAssigned, 49);
      for (var i = 0; i < CellIndex.cellCount; i++) {
        final c = board.cellAt(i);
        if (c.isAssigned) {
          expect(c.value, inInclusiveRange(0, 9));
        }
      }
    });
  });

  group('Board phase helpers', () {
    test('isComplete when all empty', () {
      final cells = List<SummingCell>.filled(
        CellIndex.cellCount,
        SummingCell.empty,
      );
      expect(Board.fromCells(cells).isComplete, true);
      expect(Board.fromCells(cells).isGameOver, false);
    });

    test('isGameOver when all assigned', () {
      final cells = List<SummingCell>.generate(
        CellIndex.cellCount,
        (_) => const SummingCell.filled(0),
      );
      expect(Board.fromCells(cells).isGameOver, true);
      expect(Board.fromCells(cells).isComplete, false);
    });
  });
}
