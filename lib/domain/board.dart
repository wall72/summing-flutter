import 'dart:math';

import 'package:meta/meta.dart';

import 'cell_index.dart';
import 'summing_cell.dart';

/// 9×9 Summing board (PRD §5.1).
@immutable
class Board {
  const Board._(this._cells)
    : assert(_cells.length == CellIndex.cellCount);

  final List<SummingCell> _cells;

  /// Border cells empty; inner 7×7 random `0…9`.
  factory Board.initial(Random random) {
    final cells = List<SummingCell>.generate(CellIndex.cellCount, (linear) {
      final idx = CellIndex.fromLinear(linear);
      if (idx.isBorder) return SummingCell.empty;
      return SummingCell.filled(random.nextInt(10));
    });
    return Board._(List.unmodifiable(cells));
  }

  /// Test / deserialization helper.
  factory Board.fromCells(List<SummingCell> cells) {
    if (cells.length != CellIndex.cellCount) {
      throw ArgumentError.value(
        cells.length,
        'cells',
        'expected ${CellIndex.cellCount} cells',
      );
    }
    return Board._(List.unmodifiable(List<SummingCell>.from(cells)));
  }

  SummingCell cellAt(int linear) {
    assert(linear >= 0 && linear < CellIndex.cellCount);
    return _cells[linear];
  }

  List<SummingCell> get cells => _cells;

  bool get isComplete => _cells.every((c) => !c.isAssigned);

  bool get isGameOver => _cells.every((c) => c.isAssigned);

  Board _copyWithCell(int linear, SummingCell cell) {
    final next = List<SummingCell>.from(_cells);
    next[linear] = cell;
    return Board._(List.unmodifiable(next));
  }

  /// Place digit [value] on empty [linear] when there is no match (PRD §5.3).
  Board withPlacedDigit(int linear, int value) {
    assert(value >= 0 && value <= 9);
    final current = cellAt(linear);
    if (current.isAssigned) {
      throw StateError('Cannot place on assigned cell at $linear');
    }
    return _copyWithCell(linear, SummingCell.filled(value));
  }

  /// Clear placement cell (already empty after logic) and assigned neighbors.
  Board afterMatchClear({
    required int placedLinear,
    required Iterable<int> neighborLinears,
  }) {
    var board = this;
    for (final n in neighborLinears) {
      if (board.cellAt(n).isAssigned) {
        board = board._copyWithCell(n, SummingCell.empty);
      }
    }
    return board;
  }
}
