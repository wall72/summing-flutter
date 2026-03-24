import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/infrastructure/persistence/persistence_providers.dart';

class ScoresPage extends ConsumerWidget {
  const ScoresPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persistenceAsync = ref.watch(localPersistenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top scores'),
      ),
      body: persistenceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (p) {
          final scores = p.highScores.load();
          if (scores.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No completed games yet.\nLower turn counts rank higher.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: scores.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final turns = scores[i];
              return ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text('$turns turns'),
                subtitle: const Text('Lower is better'),
              );
            },
          );
        },
      ),
    );
  }
}
