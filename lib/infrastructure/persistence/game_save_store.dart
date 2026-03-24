import 'package:shared_preferences/shared_preferences.dart';

import 'package:summing_flutter/domain/game_state.dart';

import 'persistence_keys.dart';
import 'save_game_codec.dart';

/// Persists in-progress game for Resume (PRD §5.6).
class GameSaveStore {
  GameSaveStore(this._prefs);

  final SharedPreferences _prefs;

  bool get hasSaveGame {
    final s = _prefs.getString(PersistenceKeys.saveGame);
    return s != null && s.isNotEmpty && SaveGameCodec.decode(s) != null;
  }

  GameState? load() {
    return SaveGameCodec.decode(_prefs.getString(PersistenceKeys.saveGame));
  }

  Future<void> save(GameState state) async {
    await _prefs.setString(
      PersistenceKeys.saveGame,
      SaveGameCodec.encode(state),
    );
  }

  Future<void> clear() async {
    await _prefs.remove(PersistenceKeys.saveGame);
  }
}
