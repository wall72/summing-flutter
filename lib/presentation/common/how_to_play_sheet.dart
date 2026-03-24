import 'package:flutter/material.dart';

Future<void> showHowToPlaySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 8,
          bottom: MediaQuery.paddingOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to Play',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
