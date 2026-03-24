import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'persistence_keys.dart';

/// Top turn counts (lower is better), ascending, max 5 (PRD §6.1).
class HighScoresStore {
  HighScoresStore(this._prefs);

  final SharedPreferences _prefs;
  static const int maxEntries = 5;

  /// Sorted ascending (best first).
  List<int> load() {
    final raw = _prefs.getString(PersistenceKeys.highScores);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final list = <int>[];
      for (final e in decoded) {
        if (e is int && e >= 0) list.add(e);
      }
      list.sort();
      if (list.length > maxEntries) {
        return list.sublist(0, maxEntries);
      }
      return list;
    } on Object {
      return [];
    }
  }

  Future<void> save(List<int> scores) async {
    final sorted = List<int>.from(scores)..sort();
    final trimmed = sorted.length <= maxEntries
        ? sorted
        : sorted.sublist(0, maxEntries);
    await _prefs.setString(
      PersistenceKeys.highScores,
      jsonEncode(trimmed),
    );
  }

  /// Inserts [turnCount], keeps lowest [maxEntries] scores, ascending.
  Future<List<int>> recordCompletedGame(int turnCount) async {
    if (turnCount < 0) return load();
    final next = [...load(), turnCount]..sort();
    final trimmed = next.length <= maxEntries
        ? next
        : next.sublist(0, maxEntries);
    await save(trimmed);
    return trimmed;
  }
}
