import 'package:flutter/material.dart';
import 'package:summing_flutter/domain/game_state.dart';
import 'package:summing_flutter/presentation/game/widgets/next_queue_row.dart';
import 'package:summing_flutter/presentation/layout/breakpoints.dart';

/// expanded와 저높이 가로 배치가 함께 쓰는 사이드 패널 (`design.md` §4, §5).
/// 턴 수, 큐, Restart, Quit를 세로로 쌓는다. 저높이 가로에서는 상단 바가 없으므로
/// 제목도 이 패널에 둔다.
class GameSidePanel extends StatelessWidget {
  const GameSidePanel({
    super.key = panelKey,
    required this.game,
    required this.onRestart,
    required this.onQuit,
    this.lowHeight = false,
  });

  /// 테스트와 배치 검사가 찾는 패널 키.
  static const panelKey = ValueKey('game.sidePanel');

  final GameState game;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  /// 저높이 가로 배치: 제목 표시, 안쪽 여백 6, 큐 라벨을 칸 위 별도 줄, 큐 칸 40.
  final bool lowHeight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final padding =
        lowHeight ? GameLayout.lowHeightPanelPadding : GameLayout.gapLarge;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lowHeight) ...[
            Text(
              'Summing',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: GameLayout.gapSmall),
          ],
          Text('${game.turnCount} turns', style: textTheme.titleMedium),
          const SizedBox(height: GameLayout.gapSmall),
          NextQueueRow(
            queue: game.queue,
            labelAbove: lowHeight,
            slotSize: lowHeight
                ? GameLayout.lowHeightQueueSlotSize
                : GameLayout.queueSlotSize,
          ),
          const SizedBox(height: GameLayout.gapMedium),
          TextButton(onPressed: onRestart, child: const Text('Restart')),
          const SizedBox(height: GameLayout.gapSmall),
          TextButton(onPressed: onQuit, child: const Text('Quit')),
        ],
      ),
    );
  }
}
