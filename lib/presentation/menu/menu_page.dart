import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/app_queries.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/presentation/common/how_to_play_sheet.dart';
import 'package:summing_flutter/presentation/game/game_page.dart';
import 'package:summing_flutter/presentation/scores/scores_page.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  Future<void> _openGame(Future<void> Function() prepare) async {
    await prepare();
    if (!mounted) return;
    final game = ref.read(gameSessionProvider);
    if (game == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start or load the game.')),
      );
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const GamePage()),
    );
    // Refresh Resume visibility / savegame state after returning from game.
    if (mounted) ref.invalidate(resumableGameProvider);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final resumableAsync = ref.watch(resumableGameProvider);

    final error = settingsAsync.error ?? resumableAsync.error;
    if (error != null) {
      return Scaffold(
        body: Center(child: Text('Load error: $error')),
      );
    }
    if (!settingsAsync.hasValue || !resumableAsync.hasValue) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final s = settingsAsync.requireValue;
    final savedGame = resumableAsync.requireValue;
    final canResume = savedGame != null;
    final settings = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Summing',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clear the board in as few turns as possible.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => _openGame(
                      () => ref.read(gameSessionProvider.notifier).startNewGame(),
                    ),
                    child: const Text('New Game'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: canResume
                        ? () => _openGame(
                              () => ref
                                  .read(gameSessionProvider.notifier)
                                  .resumeGame(),
                            )
                        : null,
                    child: Text(
                      canResume
                          ? 'Resume Game (${savedGame.turnCount} turns)'
                          : 'Resume Game',
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const ScoresPage(),
                        ),
                      );
                    },
                    child: const Text('Scores'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => showHowToPlaySheet(context),
                    child: const Text('How to Play'),
                  ),
                  const SizedBox(height: 32),
                  SwitchListTile(
                    title: const Text('Music'),
                    value: s.musicOn,
                    onChanged: settings.setMusicOn,
                  ),
                  SwitchListTile(
                    title: const Text('Sound effects'),
                    value: s.soundOn,
                    onChanged: settings.setSoundOn,
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
