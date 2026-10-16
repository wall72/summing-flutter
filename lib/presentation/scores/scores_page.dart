import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/app_queries.dart';
import 'package:summing_flutter/presentation/layout/breakpoints.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

/// 점수판 (`design.md` §4, §5). 목록은 최대 폭 560으로 가운데에 두고 세로 스크롤한다.
class ScoresPage extends ConsumerWidget {
  const ScoresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(highScoresProvider);
    final palette = AppPalette.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top scores'),
      ),
      body: scoresAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (scores) {
          if (scores.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'No completed games yet.\nLower turn counts rank higher.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: ScreenLayout.listMaxWidth),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: scores.length,
                // 구분선은 테마의 outlineVariant(장식, 대비 기준 예외)를 쓴다.
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final turns = scores[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: palette.queueHeadContainer,
                      foregroundColor: palette.onQueueHead,
                      child: Text('${i + 1}'),
                    ),
                    title: Text('$turns turns'),
                    subtitle: const Text('Lower is better'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
