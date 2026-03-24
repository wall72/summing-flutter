import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/domain/next_queue.dart';

void main() {
  group('NextQueue', () {
    test('afterPlace shifts 2→1,3→2,4→3 and fills slot 4', () {
      final r = Random(999);
      final q = NextQueue([5, 6, 7, 8]);
      final next = q.afterPlace(r);
      expect(next.slots[0], 6);
      expect(next.slots[1], 7);
      expect(next.slots[2], 8);
      expect(next.slots[3], inInclusiveRange(0, 9));
    });

    test('afterPlace uses new random for fourth slot (seeded)', () {
      final r = Random(0);
      final q = NextQueue([1, 2, 3, 4]);
      final fourth = r.nextInt(10);
      final r2 = Random(0);
      final next = q.afterPlace(r2);
      expect(next.slots.sublist(0, 3), [2, 3, 4]);
      expect(next.slots[3], fourth);
    });
  });
}
