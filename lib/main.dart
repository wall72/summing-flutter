import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/infrastructure/audio/audio_providers.dart';
import 'package:summing_flutter/presentation/common/game_lifecycle_listener.dart';
import 'package:summing_flutter/presentation/menu/menu_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: GameLifecycleListener(
        child: SummingApp(),
      ),
    ),
  );
}

class SummingApp extends ConsumerWidget {
  const SummingApp({super.key});

  static ThemeData _theme(Brightness brightness) => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: brightness,
        ),
        useMaterial3: true,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start audio (and BGM) at launch rather than on the first move.
    ref.watch(gameAudioServiceProvider);

    return MaterialApp(
      title: 'Summing',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      builder: kIsWeb
          ? (context, child) => Listener(
                behavior: HitTestBehavior.translucent,
                // Browsers block autoplay until the first user gesture.
                onPointerDown: (_) => ref
                    .read(gameAudioServiceProvider)
                    .valueOrNull
                    ?.notifyUserGesture(),
                child: child ?? const SizedBox.shrink(),
              )
          : null,
      home: const MenuPage(),
    );
  }
}
