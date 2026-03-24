import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';
import 'persistence_keys.dart';

class SettingsStore {
  SettingsStore(this._prefs);

  final SharedPreferences _prefs;

  AppSettings load() {
    final raw = _prefs.getString(PersistenceKeys.settings);
    if (raw == null || raw.isEmpty) {
      return const AppSettings();
    }
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return const AppSettings();
      return AppSettings.fromJson(Map<String, dynamic>.from(map));
    } on Object {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(
      PersistenceKeys.settings,
      jsonEncode(settings.toJson()),
    );
  }
}
