import 'dart:math';

import 'package:meta/meta.dart';

/// Four next digits; always play [first], then shift (PRD §5.2).
@immutable
class NextQueue {
  static const int length = 4;

  final List<int> slots;

  /// Not `const`: `slots.length` is not a valid constant expression for asserts.
  NextQueue(List<int> slots)
    : slots = List<int>.unmodifiable(slots),
      assert(slots.length == length);

  int get first => slots[0];

  factory NextQueue.random(Random random) {
    return NextQueue(
      List<int>.generate(length, (_) => random.nextInt(10)),
    );
  }

  /// After a placement: `2→1, 3→2, 4→3`, new random at slot 4.
  NextQueue afterPlace(Random random) {
    return NextQueue(<int>[
      slots[1],
      slots[2],
      slots[3],
      random.nextInt(10),
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (other is! NextQueue) return false;
    for (var i = 0; i < length; i++) {
      if (other.slots[i] != slots[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(slots);
}
