import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:summing_flutter/domain/cell_index.dart';
import 'package:summing_flutter/domain/game_phase.dart';
import 'package:summing_flutter/domain/game_state.dart';
import 'package:summing_flutter/presentation/game/widgets/board_cell.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

// @MX:NOTE: [AUTO] 판정 표(design.md §7): turnCount가 정확히 1 늘었을 때만 판정한다. 빈 칸 정확히 하나가 채워짐 = 배치, 숫자 칸 1개 이상이 비워짐 = 매치(지워지기 전 숫자 보관), 변화 없음 = 0개 소거 매치(셀 연출 없음). 재시작·resume·+2 이상·규칙에 없는 변화는 셀 연출이 없다
/// 직전 상태 [previous]와 새 상태 [next]를 비교해 칸별 연출을 정한다.
Map<int, CellEffect> cellEffectsBetween(GameState previous, GameState next) {
  if (next.turnCount != previous.turnCount + 1) return const {};

  final filled = <int>[];
  final cleared = <int, int>{};
  for (var i = 0; i < CellIndex.cellCount; i++) {
    final before = previous.board.cellAt(i);
    final after = next.board.cellAt(i);
    if (before == after) continue;
    if (!before.isAssigned) {
      filled.add(i);
    } else if (!after.isAssigned) {
      cleared[i] = before.value;
    } else {
      // 숫자가 다른 숫자로 바뀌는 수는 규칙에 없다.
      return const {};
    }
  }

  if (filled.length == 1 && cleared.isEmpty) {
    return {filled.single: const CellEffect.place()};
  }
  if (filled.isEmpty && cleared.isNotEmpty) {
    return {
      for (final entry in cleared.entries)
        entry.key: CellEffect.match(entry.value),
    };
  }
  return const {};
}

/// 9×9 보드 (`design.md` §2, §5).
///
/// 프레임(surfaceContainer)은 안쪽 여백 2, 반경 8로 잘라내고 셀 간격은 2다.
/// 셀 한 변 = (보드 한 변 − 2 × 2 − 8 × 2) / 9.
class BoardGrid extends StatefulWidget {
  const BoardGrid({
    super.key,
    required this.game,
    required this.onCellTap,
  });

  final GameState game;
  final void Function(int linear) onCellTap;

  @override
  State<BoardGrid> createState() => _BoardGridState();
}

class _BoardGridState extends State<BoardGrid> {
  /// 마지막 수가 만든 칸별 연출. 다음 상태가 들어올 때까지 유지한다.
  Map<int, CellEffect> _effects = const {};

  // @MX:WARN: [AUTO] 직전 GameState와 새 GameState를 비교해 셀 연출을 정한다. 같은 상태로 다시 그려질 때(identical)는 연출을 유지하고, 상태가 바뀌면 바로 앞 상태하고만 비교한다
  // @MX:REASON: 연출 상태 수명주기가 위젯 재사용에 묶여 있다. 빠른 연속 탭에서 두 수가 한 프레임에 반영되면 turnCount가 +2가 되어 연출이 없어야 하고(REQ-UI-016), 0개 소거 매치를 배치로 오판하면 안 된다(AC-UI-12). 비교 기준을 바꾸면 연출이 섞이거나 재시작·resume에서 셀 연출이 생긴다(AC-UI-13)
  @override
  void didUpdateWidget(BoardGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.game, widget.game)) {
      _effects = cellEffectsBetween(oldWidget.game, widget.game);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final game = widget.game;
    final playing = game.phase == GamePhase.playing;
    const n = CellIndex.size;
    const gap = AppSpacing.hairline;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final cellSide = math.max(0.0, (side - 2 * gap - (n - 1) * gap) / n);
        final digitSize = cellSide * AppTypeScale.cellDigitRatio;

        Widget cellAt(int linear) {
          final cell = game.board.cellAt(linear);
          return BoardCell(
            key: ValueKey('cell.$linear'),
            index: linear,
            cell: cell,
            digitSize: digitSize,
            effect: _effects[linear],
            onTap: playing && !cell.isAssigned
                ? () => widget.onCellTap(linear)
                : null,
          );
        }

        return Center(
          child: SizedBox.square(
            dimension: side,
            child: ClipRRect(
              borderRadius: AppRadius.boardFrame,
              child: DecoratedBox(
                decoration: BoxDecoration(color: palette.surfaceContainer),
                child: Padding(
                  padding: const EdgeInsets.all(gap),
                  child: Column(
                    children: [
                      for (var row = 0; row < n; row++) ...[
                        if (row > 0) const SizedBox(height: gap),
                        Expanded(
                          child: Row(
                            children: [
                              for (var col = 0; col < n; col++) ...[
                                if (col > 0) const SizedBox(width: gap),
                                Expanded(child: cellAt(row * n + col)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
