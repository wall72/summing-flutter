import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summing_flutter/infrastructure/persistence/app_settings.dart';
import 'package:summing_flutter/infrastructure/persistence/settings_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults when missing', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = SettingsStore(prefs);
    expect(store.load(), const AppSettings());
  });

  test('save and load', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = SettingsStore(prefs);
    await store.save(const AppSettings(musicOn: false, soundOn: true));
    expect(store.load(), const AppSettings(musicOn: false, soundOn: true));
  });
}
