import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:summing_flutter/domain/cell_index.dart';
import 'package:summing_flutter/domain/game_phase.dart';
import 'package:summing_flutter/domain/game_state.dart';
import 'package:summing_flutter/domain/summing_cell.dart';

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
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    // Empty cells: dark gray. Any cell with a digit (including the outer ring
    // after place-without-clear): light gray.
    final emptyBg = isLight ? const Color(0xFF5A5A5A) : const Color(0xFF2A2A2A);
    final filledBg =
        isLight ? const Color(0xFFE8E8E8) : const Color(0xFF6E6E6E);
    final borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.5);
    final textColor = theme.colorScheme.onSurface;
    final playing = game.phase == GamePhase.playing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final fontSize = side / CellIndex.size * 0.42;

        return Center(
          child: SizedBox.square(
            dimension: side,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: CellIndex.size,
              ),
              itemCount: CellIndex.cellCount,
              itemBuilder: (context, linear) {
                final cell = game.board.cellAt(linear);
                return _BoardCell(
                  cell: cell,
                  background: cell.isAssigned ? filledBg : emptyBg,
                  borderColor: borderColor,
                  textColor: textColor,
                  fontSize: fontSize,
                  onTap: playing && !cell.isAssigned
                      ? () => onCellTap(linear)
                      : null,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    required this.cell,
    required this.background,
    required this.borderColor,
    required this.textColor,
    required this.fontSize,
    required this.onTap,
  });

  final SummingCell cell;
  final Color background;
  final Color borderColor;
  final Color textColor;
  final double fontSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: cell.isAssigned ? '${cell.value}' : 'Empty cell',
      button: onTap != null,
      child: Material(
        color: background,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Center(
              child: cell.isAssigned
                  ? Text(
                      '${cell.value}',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
