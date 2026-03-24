import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/domain/game_phase.dart';
import 'package:summing_flutter/presentation/game/widgets/board_grid.dart';
import 'package:summing_flutter/presentation/game/widgets/next_queue_row.dart';

class GamePage extends ConsumerWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameSessionProvider);

    if (game == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).maybePop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final playing = game.phase == GamePhase.playing;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(gameSessionProvider.notifier).clearSession();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Summing'),
          actions: [
            TextButton(
              onPressed: () async {
                await ref.read(gameSessionProvider.notifier).restartGame();
              },
              child: const Text('Restart'),
            ),
            TextButton(
              onPressed: () {
                ref.read(gameSessionProvider.notifier).clearSession();
                Navigator.of(context).pop();
              },
              child: const Text('Quit'),
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          '${game.turnCount} turns',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        NextQueueRow(queue: game.queue),
                        const SizedBox(height: 16),
                        Expanded(
                          child: BoardGrid(
                            game: game,
                            onCellTap: (linear) {
                              ref
                                  .read(gameSessionProvider.notifier)
                                  .placeAt(linear);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              if (!playing)
                _EndOverlay(phase: game.phase, turnCount: game.turnCount),
            ],
          ),
        ),
      ),
    );
  }
}

class _EndOverlay extends ConsumerWidget {
  const _EndOverlay({required this.phase, required this.turnCount});

  final GamePhase phase;
  final int turnCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = phase == GamePhase.complete ? 'Complete!' : 'Game Over';
    final subtitle = phase == GamePhase.complete
        ? 'Finished in $turnCount turns.'
        : 'The board is full.';

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      ref.read(gameSessionProvider.notifier).clearSession();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Back to menu'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
