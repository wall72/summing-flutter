import 'package:flutter/material.dart';
import 'package:summing_flutter/domain/next_queue.dart';

class NextQueueRow extends StatelessWidget {
  const NextQueueRow({super.key, required this.queue});

  final NextQueue queue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Next:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(width: 12),
        ...List.generate(NextQueue.length, (i) {
          final d = queue.slots[i];
          final isFirst = i == 0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isFirst
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFirst ? scheme.primary : scheme.outlineVariant,
                  width: isFirst ? 2 : 1,
                ),
              ),
              child: Text(
                '$d',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isFirst
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
