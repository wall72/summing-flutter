import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/domain/game_phase.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

/// 판이 끝났을 때(complete / gameOver) 보드 위에 덮는 종료 오버레이.
/// 종료 상태에서는 확인 없이 바로 새 판을 시작한다 (REQ-UI-012).
class EndOverlay extends ConsumerWidget {
  const EndOverlay({super.key, required this.phase, required this.turnCount});

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
        color: AppPalette.of(context).scrim,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(AppSpacing.xxl),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: () =>
                        ref.read(gameSessionProvider.notifier).restartGame(),
                    child: const Text('Play again'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
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
