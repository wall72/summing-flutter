import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:summing_flutter/application/game_session_notifier.dart';

/// Saves in-progress game when the app goes to background (PRD §8).
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
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        unawaited(ref.read(gameSessionProvider.notifier).persistIfNeeded());
        break;
      case AppLifecycleState.resumed:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
