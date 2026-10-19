import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/domain/game_phase.dart';
import 'package:summing_flutter/presentation/theme/app_motion.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

/// 판이 끝났을 때(complete / gameOver) 보드 위에 덮는 종료 오버레이.
/// 종료 상태에서는 확인 없이 바로 새 판을 시작한다 (REQ-UI-012).
///
/// 나타날 때 한 번 fade + scale(0.96 → 1.0)로 들어온다 (emphasized 300ms, `design.md` §6).
/// 연출 중에도 버튼은 바로 누를 수 있다.
class EndOverlay extends ConsumerStatefulWidget {
  const EndOverlay({super.key, required this.phase, required this.turnCount});

  final GamePhase phase;
  final int turnCount;

  @override
  ConsumerState<EndOverlay> createState() => _EndOverlayState();
}

class _EndOverlayState extends ConsumerState<EndOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(vsync: this);
  late final Animation<double> _opacity =
      _entrance.drive(CurveTween(curve: AppMotion.emphasizedCurve));
  late final Animation<double> _scale = _entrance.drive(
    Tween<double>(begin: AppMotion.enterStartScale, end: 1.0)
        .chain(CurveTween(curve: AppMotion.emphasizedCurve)),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 감속 모드면 시간이 0이라 첫 프레임에 최종 모습으로 그려진다 (AC-UI-14).
    _entrance.duration = AppMotion.of(context, AppMotion.emphasized);
    if (_entrance.isDismissed) _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complete = widget.phase == GamePhase.complete;
    final title = complete ? 'Complete!' : 'Game Over';
    final subtitle = complete
        ? 'Finished in ${widget.turnCount} turns.'
        : 'The board is full.';

    return Positioned.fill(
      child: FadeTransition(
        opacity: _opacity,
        child: ColoredBox(
          color: AppPalette.of(context).scrim,
          child: Center(
            child: ScaleTransition(
              scale: _scale,
              child: Card(
                margin: const EdgeInsets.all(AppSpacing.xxl),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                        onPressed: () => ref
                            .read(gameSessionProvider.notifier)
                            .restartGame(),
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
        ),
      ),
    );
  }
}
