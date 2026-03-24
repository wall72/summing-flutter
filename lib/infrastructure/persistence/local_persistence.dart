import 'package:shared_preferences/shared_preferences.dart';

import 'game_save_store.dart';
import 'high_scores_store.dart';
import 'settings_store.dart';

/// Bundles all local stores (PRD §7.3).
class LocalPersistence {
  LocalPersistence({
    required this.settings,
    required this.gameSave,
    required this.highScores,
  });

  final SettingsStore settings;
  final GameSaveStore gameSave;
  final HighScoresStore highScores;

  static Future<LocalPersistence> open() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalPersistence(
      settings: SettingsStore(prefs),
      gameSave: GameSaveStore(prefs),
      highScores: HighScoresStore(prefs),
    );
  }
}
