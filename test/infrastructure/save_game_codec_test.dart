import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/domain/game_state.dart';
import 'package:summing_flutter/infrastructure/persistence/save_game_codec.dart';

void main() {
  test('encode/decode round-trip', () {
    final state = GameState.initial(Random(42));
    final json = SaveGameCodec.encode(state);
    final restored = SaveGameCodec.decode(json);
    expect(restored, isNotNull);
    expect(restored!.turnCount, state.turnCount);
    expect(restored.queue.slots, state.queue.slots);
    for (var i = 0; i < 81; i++) {
      expect(
        restored.board.cellAt(i),
        state.board.cellAt(i),
        reason: 'cell $i',
      );
    }
  });

  test('decode returns null for garbage', () {
    expect(SaveGameCodec.decode(null), isNull);
    expect(SaveGameCodec.decode(''), isNull);
    expect(SaveGameCodec.decode('not json'), isNull);
    expect(SaveGameCodec.decode('[]'), isNull);
  });
}
