import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/infrastructure/app_overrides.dart';
import 'package:summing_flutter/presentation/common/game_lifecycle_listener.dart';
import 'package:summing_flutter/presentation/common/web_audio_unlock.dart';
import 'package:summing_flutter/presentation/menu/menu_page.dart';
import 'package:summing_flutter/presentation/theme/app_theme.dart';

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
  const SummingApp({super.key, this.webAudioUnlockEnabled = kIsWeb});

  /// 웹 첫 제스처 오디오 해제 스위치. 운영값은 `kIsWeb` (브라우저 자동재생 차단 대응).
  final bool webAudioUnlockEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start audio (and BGM) at launch rather than on the first move.
    ref.watch(gameAudioProvider);

    return MaterialApp(
      title: 'Summing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // 앱 안 테마 전환은 두지 않고 시스템 밝기를 따른다 (REQ-UI-002).
      themeMode: ThemeMode.system,
      builder: (context, child) => WebAudioUnlock(
        enabled: webAudioUnlockEnabled,
        child: ReducedMotionTheme(child: child ?? const SizedBox.shrink()),
      ),
      home: const MenuPage(),
    );
  }
}
