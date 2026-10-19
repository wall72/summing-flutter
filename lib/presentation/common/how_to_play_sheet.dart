import 'package:flutter/material.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

/// How to Play 바텀 시트 (`design.md` §5). 배경 surfaceContainer와 손잡이 cellOutline은
/// 테마의 `bottomSheetTheme`이 정하고, 제목은 onSurface, 본문은 onSurfaceVariant로 그린다.
Future<void> showHowToPlaySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final palette = AppPalette.of(context);
      return Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.sm,
          bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.xl,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to Play',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: palette.onSurface,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _RuleParagraph(
                title: 'Board',
                body:
                    'The board is 9×9. At the start, the outer ring is empty and the inner 7×7 is filled with random digits 0–9.',
              ),
              const _RuleParagraph(
                title: 'Queue',
                body:
                    'You always place the digit shown in the first slot of the four-slot queue. After each placement the queue shifts and a new random digit appears in slot 4.',
              ),
              const _RuleParagraph(
                title: 'Match',
                body:
                    'When the digit you place equals the sum of your eight neighbors’ digits, modulo 10, that placement and all neighboring cells with digits are cleared.',
              ),
              const _RuleParagraph(
                title: 'Goal',
                body:
                    'Clear every cell to win. If the entire board becomes filled, you lose.',
              ),
              const _RuleParagraph(
                title: 'Score',
                body:
                    'Your score is the number of turns taken — lower is better.',
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _RuleParagraph extends StatelessWidget {
  const _RuleParagraph({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: palette.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            body,
            style: textTheme.bodyMedium?.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
