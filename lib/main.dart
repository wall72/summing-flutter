import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/infrastructure/app_overrides.dart';
import 'package:summing_flutter/presentation/common/game_lifecycle_listener.dart';
import 'package:summing_flutter/presentation/menu/menu_page.dart';

/// Composition root: infrastructure를 아는 유일한 진입점.
/// 포트 provider는 `appOverrides`로 실제 구현에 연결된다.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: appOverrides,
      child: const GameLifecycleListener(
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
    ref.watch(gameAudioProvider);

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
                    .read(gameAudioProvider)
                    .valueOrNull
                    ?.notifyUserGesture(),
                child: child ?? const SizedBox.shrink(),
              )
          : null,
      home: const MenuPage(),
    );
  }
}
