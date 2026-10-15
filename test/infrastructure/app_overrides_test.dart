import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summing_flutter/application/models/app_settings.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/infrastructure/app_overrides.dart';
import 'package:summing_flutter/infrastructure/audio/audio_providers.dart';
import 'package:summing_flutter/infrastructure/audio/game_audio_service.dart';
import 'package:summing_flutter/infrastructure/persistence/game_save_store.dart';
import 'package:summing_flutter/infrastructure/persistence/high_scores_store.dart';
import 'package:summing_flutter/infrastructure/persistence/settings_store.dart';

/// composition root(`appOverrides`)가 포트를 실제 구현에 연결하는지 확인한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('appOverrides binds every port to its infrastructure implementation',
      () async {
    SharedPreferences.setMockInitialValues({
      'summing_settings': '{"musicOn":false,"soundOn":true}',
      'summing_highscores': '[15,12]',
    });
    final prefs = await SharedPreferences.getInstance();
    // 오디오 플러그인은 띄우지 않고 구현 객체만 넘긴다 (init 미호출).
    final audio = GameAudioService(settingsStore: SettingsStore(prefs));
    final container = ProviderContainer(
      overrides: [
        ...appOverrides,
        gameAudioServiceProvider.overrideWith((ref) async => audio),
      ],
    );
    addTearDown(container.dispose);

    final gameSave = await container.read(gameSaveRepositoryProvider.future);
    final highScores =
        await container.read(highScoreRepositoryProvider.future);
    final settings = await container.read(settingsRepositoryProvider.future);
    final gameAudio = await container.read(gameAudioProvider.future);

    expect(gameSave, isA<GameSaveStore>());
    expect(highScores, isA<HighScoresStore>());
    expect(highScores.load(), [12, 15]);
    expect(settings, isA<SettingsStore>());
    expect(settings.load(), const AppSettings(musicOn: false, soundOn: true));
    expect(gameAudio, same(audio));
  });
}
