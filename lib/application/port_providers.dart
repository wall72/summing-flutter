import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/ports.dart';

// @MX:NOTE: [AUTO] 포트 provider 기본값은 UnimplementedError를 던진다. 앱은 `appOverrides`, 테스트는 fake override로 반드시 연결해야 한다
Never _unbound(String provider) => throw UnimplementedError(
      '$provider is not bound. Override it in ProviderScope '
      '(lib/main.dart uses appOverrides; tests use fake overrides).',
    );

/// 진행 중인 판 저장 포트.
final gameSaveRepositoryProvider = FutureProvider<GameSaveRepository>(
  (ref) => _unbound('gameSaveRepositoryProvider'),
);

/// 최고 기록 포트.
final highScoreRepositoryProvider = FutureProvider<HighScoreRepository>(
  (ref) => _unbound('highScoreRepositoryProvider'),
);

/// 설정 저장 포트.
final settingsRepositoryProvider = FutureProvider<SettingsRepository>(
  (ref) => _unbound('settingsRepositoryProvider'),
);

/// 게임 오디오 포트. 준비 전이거나 실패하면 소비자는 소리 없이 진행한다.
final gameAudioProvider = FutureProvider<GameAudio>(
  (ref) => _unbound('gameAudioProvider'),
);
