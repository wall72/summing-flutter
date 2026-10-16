import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/domain/game_phase.dart';
import 'package:summing_flutter/domain/game_state.dart';
import 'package:summing_flutter/presentation/game/widgets/board_grid.dart';
import 'package:summing_flutter/presentation/game/widgets/end_overlay.dart';
import 'package:summing_flutter/presentation/game/widgets/game_side_panel.dart';
import 'package:summing_flutter/presentation/game/widgets/next_queue_row.dart';
import 'package:summing_flutter/presentation/game/widgets/restart_confirm_dialog.dart';
import 'package:summing_flutter/presentation/layout/breakpoints.dart';

/// 보드 영역 키. 배치 검사가 보드 한 변을 이 키로 잰다.
const _boardKey = ValueKey('game.board');

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  /// 확인 대화상자가 열려 있는 동안 Restart를 다시 눌러도 두 번째 대화상자를 열지 않는다.
  bool _confirmingRestart = false;

  // @MX:NOTE: [AUTO] 재시작 guard: playing일 때만 확인 대화상자를 띄우고, 확인했을 때만 restartGame()을 부른다. Cancel·배리어·Esc·시스템 뒤로는 상태와 저장을 건드리지 않는다. complete·gameOver에서는 확인 없이 바로 재시작한다 (REQ-UI-010~012). 상단 바와 사이드 패널의 Restart가 모두 이 경로를 거친다
  Future<void> _onRestart() async {
    final current = ref.read(gameSessionProvider);
    if (current == null) return;

    if (current.phase != GamePhase.playing) {
      await ref.read(gameSessionProvider.notifier).restartGame();
      return;
    }

    if (_confirmingRestart) return;
    _confirmingRestart = true;
    try {
      final confirmed = await showRestartConfirmDialog(context);
      if (confirmed && mounted) {
        await ref.read(gameSessionProvider.notifier).restartGame();
      }
    } finally {
      _confirmingRestart = false;
    }
  }

  void _onQuit() {
    // 아래 PopScope가 route가 닫힐 때 세션을 비운다. Quit는 확인하지 않는다.
    Navigator.of(context).pop();
  }

  void _onCellTap(int linear) {
    ref.read(gameSessionProvider.notifier).placeAt(linear);
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameSessionProvider);

    if (game == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).maybePop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final playing = game.phase == GamePhase.playing;
    final layout = layoutClassFor(MediaQuery.sizeOf(context));
    final actionsInAppBar =
        layout == LayoutClass.compact || layout == LayoutClass.medium;

    final Widget body = switch (layout) {
      LayoutClass.compact => _SingleColumnBody(
          game: game,
          horizontalMargin: GameLayout.compactBoardMargin,
          maxBoardSide: double.infinity,
          onCellTap: _onCellTap,
        ),
      LayoutClass.medium => _SingleColumnBody(
          game: game,
          horizontalMargin: GameLayout.mediumBoardMargin,
          maxBoardSide: GameLayout.mediumBoardMaxSide,
          onCellTap: _onCellTap,
        ),
      LayoutClass.expanded => _ExpandedBody(
          game: game,
          onCellTap: _onCellTap,
          onRestart: _onRestart,
          onQuit: _onQuit,
        ),
      LayoutClass.lowHeightLandscape => _LowHeightBody(
          game: game,
          onCellTap: _onCellTap,
          onRestart: _onRestart,
          onQuit: _onQuit,
        ),
    };

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(gameSessionProvider.notifier).clearSession();
        }
      },
      child: Scaffold(
        // 저높이 가로에서는 상단 바 없이 사이드 패널이 제목과 동작을 맡는다 (REQ-UI-024).
        appBar: layout == LayoutClass.lowHeightLandscape
            ? null
            : AppBar(
                title: const Text('Summing'),
                actions: actionsInAppBar
                    ? [
                        TextButton(
                          onPressed: _onRestart,
                          child: const Text('Restart'),
                        ),
                        TextButton(
                          onPressed: _onQuit,
                          child: const Text('Quit'),
                        ),
                      ]
                    : null,
              ),
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              body,
              if (!playing)
                EndOverlay(phase: game.phase, turnCount: game.turnCount),
            ],
          ),
        ),
      ),
    );
  }
}

/// 남은 공간 안에서 가장 큰 정사각형 보드를 [maxSide] 이하로 그린다.
class _SquareBoard extends StatelessWidget {
  const _SquareBoard({
    required this.game,
    required this.onCellTap,
    this.maxSide = double.infinity,
  });

  final GameState game;
  final void Function(int linear) onCellTap;
  final double maxSide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(
          math.min(constraints.maxWidth, constraints.maxHeight),
          maxSide,
        );
        return Center(
          child: SizedBox.square(
            key: _boardKey,
            dimension: side,
            child: BoardGrid(game: game, onCellTap: onCellTap),
          ),
        );
      },
    );
  }
}

/// compact·medium: 턴 수 → 큐 → 보드 한 열 (REQ-UI-005, 006).
class _SingleColumnBody extends StatelessWidget {
  const _SingleColumnBody({
    required this.game,
    required this.horizontalMargin,
    required this.maxBoardSide,
    required this.onCellTap,
  });

  final GameState game;
  final double horizontalMargin;
  final double maxBoardSide;
  final void Function(int linear) onCellTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Column(
        children: [
          const SizedBox(height: GameLayout.gapSmall),
          Text(
            '${game.turnCount} turns',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: GameLayout.gapMedium),
          NextQueueRow(queue: game.queue),
          const SizedBox(height: GameLayout.gapLarge),
          Expanded(
            child: _SquareBoard(
              game: game,
              onCellTap: onCellTap,
              maxSide: maxBoardSide,
            ),
          ),
          const SizedBox(height: GameLayout.gapLarge),
        ],
      ),
    );
  }
}

/// expanded: 보드(최대 640) + 오른쪽 사이드 패널 (REQ-UI-007).
class _ExpandedBody extends StatelessWidget {
  const _ExpandedBody({
    required this.game,
    required this.onCellTap,
    required this.onRestart,
    required this.onQuit,
  });

  final GameState game;
  final void Function(int linear) onCellTap;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GameLayout.expandedBoardMargin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _SquareBoard(
              game: game,
              onCellTap: onCellTap,
              maxSide: GameLayout.expandedBoardMaxSide,
            ),
          ),
          const SizedBox(width: GameLayout.paneGap),
          SizedBox(
            width: GameLayout.expandedPanelWidth,
            child: GameSidePanel(
              game: game,
              onRestart: onRestart,
              onQuit: onQuit,
            ),
          ),
        ],
      ),
    );
  }
}

/// 저높이 가로: 상단 바 없이 보드(왼쪽) + 사이드 패널(오른쪽) (REQ-UI-024).
class _LowHeightBody extends StatelessWidget {
  const _LowHeightBody({
    required this.game,
    required this.onCellTap,
    required this.onRestart,
    required this.onQuit,
  });

  final GameState game;
  final void Function(int linear) onCellTap;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = lowHeightBoardSide(constraints.biggest);
        return Padding(
          padding: const EdgeInsets.all(GameLayout.lowHeightEdge),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox.square(
                key: _boardKey,
                dimension: side,
                child: BoardGrid(game: game, onCellTap: onCellTap),
              ),
              const SizedBox(width: GameLayout.paneGap),
              Expanded(
                child: GameSidePanel(
                  game: game,
                  onRestart: onRestart,
                  onQuit: onQuit,
                  lowHeight: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
