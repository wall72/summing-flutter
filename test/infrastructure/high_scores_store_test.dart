import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summing_flutter/infrastructure/persistence/high_scores_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('record keeps five lowest turns ascending', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = HighScoresStore(prefs);
    await store.recordCompletedGame(20);
    await store.recordCompletedGame(5);
    await store.recordCompletedGame(15);
    await store.recordCompletedGame(8);
    await store.recordCompletedGame(12);
    await store.recordCompletedGame(3);
    expect(store.load(), [3, 5, 8, 12, 15]);
  });

  test('load returns empty when missing', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = HighScoresStore(prefs);
    expect(store.load(), isEmpty);
  });
}
