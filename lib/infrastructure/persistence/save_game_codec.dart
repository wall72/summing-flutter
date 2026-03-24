import 'dart:convert';

import 'package:summing_flutter/domain/board.dart';
import 'package:summing_flutter/domain/cell_index.dart';
import 'package:summing_flutter/domain/game_state.dart';
import 'package:summing_flutter/domain/next_queue.dart';
import 'package:summing_flutter/domain/summing_cell.dart';

/// JSON encode/decode for resume data (PRD §5.6 / §7.3).
abstract final class SaveGameCodec {
  static const int currentSchemaVersion = 1;

  /// Encodes [state] as a JSON string suitable for [SharedPreferences].
  static String encode(GameState state) {
    final assigned = List<bool>.generate(
      CellIndex.cellCount,
      (i) => state.board.cellAt(i).isAssigned,
    );
    final values = List<int>.generate(CellIndex.cellCount, (i) {
      final c = state.board.cellAt(i);
      return c.isAssigned ? c.value : 0;
    });
    final map = <String, dynamic>{
      'schemaVersion': currentSchemaVersion,
      'turnCount': state.turnCount,
      'assigned': assigned,
      'values': values,
      'nextQueue': state.queue.slots,
    };
    return jsonEncode(map);
  }

  /// Returns `null` if [jsonString] is missing/invalid or schema unsupported.
  static GameState? decode(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final version = map['schemaVersion'];
      if (version is! int || version < 1 || version > currentSchemaVersion) {
        return null;
      }

      final turnCount = map['turnCount'];
      if (turnCount is! int || turnCount < 0) return null;

      final assignedRaw = map['assigned'];
      final valuesRaw = map['values'];
      if (assignedRaw is! List || valuesRaw is! List) return null;
      if (assignedRaw.length != CellIndex.cellCount ||
          valuesRaw.length != CellIndex.cellCount) {
        return null;
      }

      final cells = List<SummingCell>.generate(CellIndex.cellCount, (i) {
        final a = assignedRaw[i];
        final v = valuesRaw[i];
        if (a is! bool) throw FormatException('assigned[$i]');
        if (a) {
          if (v is! int || v < 0 || v > 9) {
            throw FormatException('values[$i]');
          }
          return SummingCell.filled(v);
        }
        return SummingCell.empty;
      });

      final queueRaw = map['nextQueue'];
      if (queueRaw is! List || queueRaw.length != NextQueue.length) {
        return null;
      }
      final slots = <int>[];
      for (var i = 0; i < NextQueue.length; i++) {
        final d = queueRaw[i];
        if (d is! int || d < 0 || d > 9) return null;
        slots.add(d);
      }

      return GameState(
        board: Board.fromCells(cells),
        queue: NextQueue(slots),
        turnCount: turnCount,
      );
    } on Object {
      return null;
    }
  }
}
