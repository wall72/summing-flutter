import 'package:flutter/material.dart';
import 'package:summing_flutter/domain/next_queue.dart';
import 'package:summing_flutter/presentation/layout/breakpoints.dart';

class NextQueueRow extends StatelessWidget {
  const NextQueueRow({
    super.key,
    required this.queue,
    this.labelAbove = false,
    this.slotSize = GameLayout.queueSlotSize,
  });

  final NextQueue queue;

  /// true면 `Next:` 라벨을 네 칸 위 별도 줄에 둔다 (저높이 가로 사이드 패널, `design.md` §5).
  final bool labelAbove;

  /// 큐 칸 한 변. 칸 사이 간격은 [GameLayout.queueSlotGap].
  final double slotSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final label = Text(
      'Next:',
      style: Theme.of(context).textTheme.titleSmall,
    );

    final slots = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < NextQueue.length; i++) ...[
          if (i > 0) const SizedBox(width: GameLayout.queueSlotGap),
          _QueueSlot(
            key: ValueKey('queue.slot.$i'),
            digit: queue.slots[i],
            isFirst: i == 0,
            size: slotSize,
            scheme: scheme,
          ),
        ],
      ],
    );

    if (labelAbove) {
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
    required this.isFirst,
    required this.size,
    required this.scheme,
  });

  final int digit;
  final bool isFirst;
  final double size;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFirst ? scheme.primaryContainer : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFirst ? scheme.primary : scheme.outlineVariant,
          width: isFirst ? 2 : 1,
        ),
      ),
      child: Text(
        '$digit',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isFirst ? scheme.onPrimaryContainer : scheme.onSurface,
            ),
      ),
    );
  }
}
