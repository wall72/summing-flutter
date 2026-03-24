import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/infrastructure/audio/audio_providers.dart';
import 'package:summing_flutter/presentation/common/game_lifecycle_listener.dart';
import 'package:summing_flutter/presentation/menu/menu_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: GameLifecycleListener(
        child: SummingApp(),
      ),
    ),
  );
}

class SummingApp extends ConsumerStatefulWidget {
  const SummingApp({super.key});

  @override
  ConsumerState<SummingApp> createState() => _SummingAppState();
}

class _SummingAppState extends ConsumerState<SummingApp> {
  void _onPointerDown() {
    if (!kIsWeb) return;
    ref.read(gameAudioServiceProvider.future).then((audio) => audio.notifyUserGesture());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Summing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      builder: (context, child) {
        var content = child ?? const SizedBox.shrink();
        if (kIsWeb) {
          content = Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => _onPointerDown(),
            child: content,
          );
        }
        return content;
      },
      home: const MenuPage(),
    );
  }
}
