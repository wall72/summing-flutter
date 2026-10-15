import 'package:shared_preferences/shared_preferences.dart';

import 'package:summing_flutter/application/ports.dart';
import 'package:summing_flutter/domain/game_state.dart';

import 'persistence_keys.dart';
import 'save_game_codec.dart';

/// Persists in-progress game for Resume (PRD §5.6).
class GameSaveStore implements GameSaveRepository {
  GameSaveStore(this._prefs);

  final SharedPreferences _prefs;

  bool get hasSaveGame => load() != null;

  @override
  GameState? load() {
    return SaveGameCodec.decode(_prefs.getString(PersistenceKeys.saveGame));
  }

  @override
  Future<void> save(GameState state) async {
    await _prefs.setString(
      PersistenceKeys.saveGame,
      SaveGameCodec.encode(state),
    );
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(PersistenceKeys.saveGame);
  }
}
