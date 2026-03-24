import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:summing_flutter/domain/cell_index.dart';
import 'package:summing_flutter/domain/game_phase.dart';
import 'package:summing_flutter/domain/game_state.dart';
import 'package:summing_flutter/domain/summing_rules.dart';

class BoardGrid extends StatelessWidget {
  const BoardGrid({
    super.key,
    required this.game,
    required this.onCellTap,
  });

  final GameState game;
  final void Function(int linear) onCellTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final cellSize = side / CellIndex.size;

        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: CellIndex.size,
              ),
              itemCount: CellIndex.cellCount,
              itemBuilder: (context, linear) {
                final cell = game.board.cellAt(linear);
                final canTap = SummingRules.canPlace(game, linear);
                // Empty cells: dark gray. Any cell with a digit (including outer ring
                // after place-without-clear): light gray.
                final bg = cell.isAssigned
                    ? _filledCellBackground(context)
                    : _emptyCellBackground(context);

                return Material(
                  color: bg,
                  child: InkWell(
                    onTap: game.phase == GamePhase.playing && canTap
                        ? () => onCellTap(linear)
                        : null,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 120),
                          style: TextStyle(
                            fontSize: cellSize * 0.42,
                            fontWeight: FontWeight.w600,
                            color: cell.isAssigned
                                ? scheme.onSurface
                                : Colors.transparent,
                          ),
                          child: Text(
                            cell.isAssigned ? '${cell.value}' : '',
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

Color _emptyCellBackground(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? const Color(0xFF5A5A5A)
      : const Color(0xFF2A2A2A);
}

Color _filledCellBackground(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? const Color(0xFFE8E8E8)
      : const Color(0xFF6E6E6E);
}
