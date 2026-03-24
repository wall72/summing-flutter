import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summing_flutter/domain/game_state.dart';
import 'package:summing_flutter/infrastructure/persistence/game_save_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('hasSaveGame is false when empty', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = GameSaveStore(prefs);
    expect(store.hasSaveGame, false);
    expect(store.load(), isNull);
  });

  test('save, load, clear', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = GameSaveStore(prefs);
    final state = GameState.initial(Random(7));
    await store.save(state);
    expect(store.hasSaveGame, true);
    final loaded = store.load();
    expect(loaded, isNotNull);
    expect(loaded!.turnCount, state.turnCount);
    await store.clear();
    expect(store.hasSaveGame, false);
  });
}
