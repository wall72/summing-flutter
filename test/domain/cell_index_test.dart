import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/domain/cell_index.dart';

void main() {
  group('CellIndex', () {
    test('from1Based / to1Based round-trip', () {
      expect(CellIndex.from1Based(1).linear, 0);
      expect(CellIndex.from1Based(81).linear, 80);
      expect(CellIndex.fromLinear(0).to1Based(), 1);
    });

    test('isBorder matches PRD outer ring', () {
      expect(CellIndex.from1Based(1).isBorder, true); // top-left
      expect(CellIndex.from1Based(5).isBorder, true);
      expect(CellIndex.from1Based(41).isBorder, false); // inner
    });

    test('neighbors do not wrap rows (left edge)', () {
      // Linear 9 = row 1, col 0 — no wrap to previous row’s last column
      final n = CellIndex.neighborLinears(9).toList()..sort();
      expect(n, [0, 1, 10, 18, 19]);
    });

    test('neighbors do not wrap rows (right edge)', () {
      // Linear 17 = row 1, col 8
      final n = CellIndex.neighborLinears(17).toList()..sort();
      expect(n, [7, 8, 16, 25, 26]);
    });

    test('center has eight neighbors', () {
      expect(CellIndex.neighborLinears(40).length, 8);
    });
  });
}
