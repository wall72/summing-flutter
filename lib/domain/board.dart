import 'dart:math';

import 'package:meta/meta.dart';

import 'cell_index.dart';
import 'summing_cell.dart';

/// 9×9 Summing board (PRD §5.1).
@immutable
class Board {
  const Board._(this._cells) : assert(_cells.length == CellIndex.cellCount);

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

  /// Place digit [value] on empty [linear] when there is no match (PRD §5.3).
  Board withPlacedDigit(int linear, int value) {
    assert(value >= 0 && value <= 9);
    if (cellAt(linear).isAssigned) {
      throw StateError('Cannot place on assigned cell at $linear');
    }
    final next = List<SummingCell>.of(_cells);
    next[linear] = SummingCell.filled(value);
    return Board._(List.unmodifiable(next));
  }

  /// Clears every assigned cell in [neighborLinears] (single list copy).
  Board afterMatchClear({required Iterable<int> neighborLinears}) {
    final next = List<SummingCell>.of(_cells);
    for (final n in neighborLinears) {
      next[n] = SummingCell.empty;
    }
    return Board._(List.unmodifiable(next));
  }
}
