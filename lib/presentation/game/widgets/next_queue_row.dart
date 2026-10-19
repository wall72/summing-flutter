import 'package:flutter/material.dart';
import 'package:summing_flutter/domain/next_queue.dart';
import 'package:summing_flutter/presentation/layout/breakpoints.dart';
import 'package:summing_flutter/presentation/theme/app_motion.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

/// 다음 숫자 네 칸 (`design.md` §5 큐 행).
///
/// 큐가 한 칸 당겨지면 칸들이 오른쪽 한 칸 간격(칸 폭 + 8)에서 제자리로 미끄러진다
/// (base 200ms, easeOutCubic). 칸 키는 `queue.slot.<i>`.
class NextQueueRow extends StatefulWidget {
  const NextQueueRow({
    super.key,
    required this.queue,
    this.labelAbove = false,
    this.slotSize = GameLayout.queueSlotSize,
  });

  final NextQueue queue;

  /// true면 `Next:` 라벨을 네 칸 위 별도 줄에 둔다 (저높이 가로 사이드 패널, `design.md` §5).
  /// 이 배치에서는 큐 숫자도 [AppTypeScale.queueDigitCompact]로 줄인다.
  final bool labelAbove;

  /// 큐 칸 한 변. 칸 사이 간격은 [GameLayout.queueSlotGap].
  final double slotSize;

  @override
  State<NextQueueRow> createState() => _NextQueueRowState();
}

class _NextQueueRowState extends State<NextQueueRow> {
  /// 큐가 당겨진 횟수. 값이 바뀌면 이동 연출을 처음부터 다시 재생한다 (연속 탭).
  int _shiftGeneration = 0;

  /// 마지막 큐 변화가 한 칸 당김이었는지. 재시작처럼 통째로 바뀐 큐는 미끄러지지 않는다.
  bool _shifted = false;

  /// [after]가 [before]를 한 칸 당긴 큐인지 (2→1, 3→2, 4→3).
  static bool _isShift(NextQueue before, NextQueue after) {
    for (var i = 0; i < NextQueue.length - 1; i++) {
      if (after.slots[i] != before.slots[i + 1]) return false;
    }
    return true;
  }

  @override
  void didUpdateWidget(NextQueueRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.queue, widget.queue)) {
      _shifted = _isShift(oldWidget.queue, widget.queue);
      if (_shifted) _shiftGeneration++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final digitSize = widget.labelAbove
        ? AppTypeScale.queueDigitCompact
        : AppTypeScale.queueDigit;

    final label = Text(
      'Next:',
      style: Theme.of(context).textTheme.titleSmall,
    );

    Widget slots = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < NextQueue.length; i++) ...[
          if (i > 0) const SizedBox(width: GameLayout.queueSlotGap),
          _QueueSlot(
            key: ValueKey('queue.slot.$i'),
            digit: widget.queue.slots[i],
            isHead: i == 0,
            size: widget.slotSize,
            digitSize: digitSize,
            palette: palette,
          ),
        ],
      ],
    );

    if (_shifted) {
      final pitch = widget.slotSize + GameLayout.queueSlotGap;
      // 미끄러지는 동안 마지막 칸이 행 밖(패널 가장자리)에 그려지지 않게 잘라낸다.
      slots = ClipRect(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(_shiftGeneration),
          tween: Tween(begin: 1, end: 0),
          duration: AppMotion.of(context, AppMotion.base),
          curve: AppMotion.queueShiftCurve,
          child: slots,
          builder: (context, t, child) => Transform.translate(
            offset: Offset(pitch * t, 0),
            child: child,
          ),
        ),
      );
    }

    if (widget.labelAbove) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          const SizedBox(height: GameLayout.queueLabelGapAbove),
          slots,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        label,
        const SizedBox(width: GameLayout.queueLabelGap),
        slots,
      ],
    );
  }
}

class _QueueSlot extends StatelessWidget {
  const _QueueSlot({
    super.key,
    required this.digit,
    required this.isHead,
    required this.size,
    required this.digitSize,
    required this.palette,
  });

  final int digit;
  final bool isHead;
  final double size;
  final double digitSize;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isHead ? palette.queueHeadContainer : palette.surfaceContainer,
        borderRadius: AppRadius.queueSlot,
        border: Border.all(
          color: isHead ? palette.queueHeadOutline : palette.cellOutline,
          width: isHead ? AppStroke.emphasis : AppStroke.outline,
        ),
      ),
      child: Text(
        '$digit',
        style: TextStyle(
          fontSize: digitSize,
          fontWeight: FontWeight.w800,
          color: isHead ? palette.onQueueHead : palette.onSurface,
        ),
      ),
    );
  }
}
