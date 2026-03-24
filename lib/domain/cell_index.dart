/// 9×9 board indexing.
///
/// PRD uses 1-based indices **1…81** (row-major). Dart code uses **0…80**
/// (`linear`) for `List` access. Use [from1Based] / [to1Based] when bridging.
class CellIndex {
  const CellIndex({required this.row, required this.col})
    : assert(row >= 0 && row < size),
      assert(col >= 0 && col < size);

  static const int size = 9;
  static const int cellCount = size * size;

  final int row;
  final int col;

  /// Row-major 0-based index in `0…80`.
  int get linear => row * size + col;

  factory CellIndex.fromLinear(int linear) {
    assert(linear >= 0 && linear < cellCount);
    return CellIndex(row: linear ~/ size, col: linear % size);
  }

  /// PRD 1-based index `1…81`.
  factory CellIndex.from1Based(int prdIndex) {
    assert(prdIndex >= 1 && prdIndex <= cellCount);
    return CellIndex.fromLinear(prdIndex - 1);
  }

  int to1Based() => linear + 1;

  /// Outer ring (PRD: rows/cols 1 and 9) — empty at game start.
  bool get isBorder =>
      row == 0 || row == size - 1 || col == 0 || col == size - 1;

  /// Eight neighbors inside the board; **no horizontal wrap** between rows.
  static Iterable<int> neighborLinears(int linear) sync* {
    assert(linear >= 0 && linear < cellCount);
    final r = linear ~/ size;
    final c = linear % size;
    for (var dr = -1; dr <= 1; dr++) {
      for (var dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = r + dr;
        final nc = c + dc;
        if (nr < 0 || nr >= size || nc < 0 || nc >= size) continue;
        yield nr * size + nc;
      }
    }
  }
}
