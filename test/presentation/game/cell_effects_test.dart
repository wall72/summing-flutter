import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/presentation/game/widgets/board_cell.dart';
import 'package:summing_flutter/presentation/game/widgets/board_grid.dart';

/// 직전 보드와 새 보드 비교 판정 (`design.md` §7, REQ-UI-013, 014, 016).
void main() {
  GameState stateWith(Map<int, int> filled, {required int turnCount}) {
    final cells =
        List<SummingCell>.filled(CellIndex.cellCount, SummingCell.empty);
    filled.forEach((i, v) => cells[i] = SummingCell.filled(v));
    return GameState(
      board: Board.fromCells(cells),
      queue: NextQueue(const [1, 2, 3, 4]),
      turnCount: turnCount,
    );
  }

  test('turn +1, exactly one empty cell filled → place on that cell', () {
    final effects = cellEffectsBetween(
      stateWith({40: 7}, turnCount: 3),
      stateWith({40: 7, 80: 1}, turnCount: 4),
    );
    expect(effects.keys, [80]);
    expect(effects[80]!.kind, CellEffectKind.place);
  });

  test('turn +1, digit cells emptied → match on each, keeping the old digit',
      () {
    final effects = cellEffectsBetween(
      stateWith({0: 5, 40: 3, 41: 4}, turnCount: 3),
      stateWith({0: 5}, turnCount: 4),
    );
    expect(effects.keys.toSet(), {40, 41});
    expect(effects.values.map((e) => e.kind).toSet(), {CellEffectKind.match});
    expect(effects[40]!.digit, 3);
    expect(effects[41]!.digit, 4);
  });

  test('turn +1, all 8 neighbours emptied → 8 match effects', () {
    final neighbours = CellIndex.neighborLinears(40).toList();
    final effects = cellEffectsBetween(
      stateWith({for (final n in neighbours) n: 1, 0: 2}, turnCount: 3),
      stateWith({0: 2}, turnCount: 4),
    );
    expect(effects.keys.toSet(), neighbours.toSet());
  });

  test('turn +1, board unchanged (zero-clear match) → no effect', () {
    expect(
      cellEffectsBetween(
        stateWith({40: 7}, turnCount: 3),
        stateWith({40: 7}, turnCount: 4),
      ),
      isEmpty,
    );
  });

  test('turnCount back to 0 (restart) → no effect', () {
    expect(
      cellEffectsBetween(
        stateWith({40: 7}, turnCount: 5),
        stateWith({40: 7, 80: 1}, turnCount: 0),
      ),
      isEmpty,
    );
  });

  test('turnCount +2 (two moves between frames, resume) → no effect', () {
    expect(
      cellEffectsBetween(
        stateWith({40: 7}, turnCount: 3),
        stateWith({40: 7, 80: 1}, turnCount: 5),
      ),
      isEmpty,
    );
  });

  test('same turnCount → no effect', () {
    expect(
      cellEffectsBetween(
        stateWith({40: 7}, turnCount: 3),
        stateWith({40: 7, 80: 1}, turnCount: 3),
      ),
      isEmpty,
    );
  });

  test('two cells filled in one turn (not a legal move) → no effect', () {
    expect(
      cellEffectsBetween(
        stateWith({40: 7}, turnCount: 3),
        stateWith({40: 7, 80: 1, 72: 2}, turnCount: 4),
      ),
      isEmpty,
    );
  });

  test('a cell filled and another emptied in one turn → no effect', () {
    expect(
      cellEffectsBetween(
        stateWith({40: 7}, turnCount: 3),
        stateWith({80: 1}, turnCount: 4),
      ),
      isEmpty,
    );
  });

  test('a digit changed in place → no effect', () {
    expect(
      cellEffectsBetween(
        stateWith({40: 7}, turnCount: 3),
        stateWith({40: 8}, turnCount: 4),
      ),
      isEmpty,
    );
  });
}
