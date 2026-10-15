import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summing_flutter/infrastructure/persistence/app_settings.dart';
import 'package:summing_flutter/infrastructure/persistence/settings_store.dart';

/// AppSettings JSON 형식 고정 (AC-ARCH-13, REQ-ARCH-004).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fromJson then toJson keeps exactly musicOn and soundOn', () {
    final decoded = jsonDecode('{"musicOn":false,"soundOn":true}')
        as Map<String, dynamic>;

    final json = AppSettings.fromJson(decoded).toJson();

    expect(json.keys.toSet(), {'musicOn', 'soundOn'});
    expect(json, {'musicOn': false, 'soundOn': true});
  });

  test('missing keys default to true', () {
    final settings =
        AppSettings.fromJson(jsonDecode('{}') as Map<String, dynamic>);

    expect(settings.musicOn, isTrue);
    expect(settings.soundOn, isTrue);
  });

  test('settings store loads the summing_settings key', () async {
    SharedPreferences.setMockInitialValues({
      'summing_settings': '{"musicOn":false,"soundOn":true}',
    });
    final prefs = await SharedPreferences.getInstance();
    final store = SettingsStore(prefs);

    expect(store.load(), const AppSettings(musicOn: false, soundOn: true));
  });

  test('copyWith, equality and hashCode follow both fields', () {
    const base = AppSettings();

    expect(base.copyWith(musicOn: false),
        const AppSettings(musicOn: false, soundOn: true));
    expect(base.copyWith(), base);
    expect(base.hashCode, const AppSettings().hashCode);
    expect(base == const AppSettings(soundOn: false), isFalse);
  });
}
