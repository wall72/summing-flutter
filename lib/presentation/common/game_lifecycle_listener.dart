import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/infrastructure/audio/audio_providers.dart';

/// Saves in-progress game and pauses BGM when the app goes to background (PRD §8).
class GameLifecycleListener extends ConsumerStatefulWidget {
  const GameLifecycleListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GameLifecycleListener> createState() =>
      _GameLifecycleListenerState();
}

class _GameLifecycleListenerState extends ConsumerState<GameLifecycleListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audio = ref.read(gameAudioServiceProvider).valueOrNull;
    switch (state) {
      case AppLifecycleState.inactive:
        unawaited(ref.read(gameSessionProvider.notifier).persistIfNeeded());
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        unawaited(ref.read(gameSessionProvider.notifier).persistIfNeeded());
        if (audio != null) unawaited(audio.suspend());
      case AppLifecycleState.resumed:
        if (audio != null) unawaited(audio.resume());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
