import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:summing_flutter/application/models/app_settings.dart';
import 'package:summing_flutter/application/ports.dart';

import 'persistence_keys.dart';

class SettingsStore implements SettingsRepository {
  SettingsStore(this._prefs);

  final SharedPreferences _prefs;

  @override
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

  @override
  Future<void> save(AppSettings settings) async {
    await _prefs.setString(
      PersistenceKeys.settings,
      jsonEncode(settings.toJson()),
    );
  }
}
