import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summing_flutter/domain/game_state.dart';
import 'package:summing_flutter/infrastructure/app_overrides.dart';
import 'package:summing_flutter/infrastructure/audio/audio_providers.dart';
import 'package:summing_flutter/infrastructure/audio/game_audio_service.dart';
import 'package:summing_flutter/infrastructure/persistence/app_settings.dart';
import 'package:summing_flutter/infrastructure/persistence/game_save_store.dart';
import 'package:summing_flutter/infrastructure/persistence/high_scores_store.dart';
import 'package:summing_flutter/infrastructure/persistence/local_persistence.dart';
import 'package:summing_flutter/infrastructure/persistence/persistence_providers.dart';
import 'package:summing_flutter/infrastructure/persistence/settings_store.dart';

/// M1 동작 고정 테스트용 fake. 포트 도입 전 구체 타입을 상속해 호출 순서를 기록한다.
class RecordingGameSaveStore extends GameSaveStore {
  RecordingGameSaveStore(super.prefs, this.log);

  final List<String> log;
  GameState? stored;
  final saved = <GameState>[];

  @override
  GameState? load() => stored;

  @override
  Future<void> save(GameState state) async {
    log.add('save');
    saved.add(state);
    stored = state;
  }

  @override
  Future<void> clear() async {
    log.add('clear');
    stored = null;
  }
}

class RecordingHighScoresStore extends HighScoresStore {
  RecordingHighScoresStore(super.prefs, this.log);

  final List<String> log;
  List<int> scores = [];

  @override
  List<int> load() => scores;

  @override
  Future<List<int>> recordCompletedGame(int turnCount) async {
    log.add('recordCompletedGame($turnCount)');
    scores = [...scores, turnCount]..sort();
    return scores;
  }
}

class RecordingSettingsStore extends SettingsStore {
  RecordingSettingsStore(super.prefs, this.log);

  final List<String> log;
  AppSettings current = const AppSettings();

  @override
  AppSettings load() => current;

  @override
  Future<void> save(AppSettings settings) async {
    // 저장 "완료" 시점에 기록한다. 호출자가 await 하지 않으면 resync가 먼저 기록된다.
    await Future<void>.microtask(() {});
    current = settings;
    log.add(
      'save(AppSettings(musicOn: ${settings.musicOn}, '
      'soundOn: ${settings.soundOn}))',
    );
  }
}

class RecordingGameAudioService extends GameAudioService {
  RecordingGameAudioService(this.log, {required super.settingsStore});

  final List<String> log;

  @override
  Future<void> playTap() async => log.add('playTap');

  @override
  Future<void> playMatch() async => log.add('playMatch');

  @override
  Future<void> applySettingsAndSyncBgm() async =>
      log.add('applySettingsAndSyncBgm');

  @override
  Future<void> suspend() async => log.add('suspend');

  @override
  Future<void> resume() async => log.add('resume');

  @override
  Future<void> notifyUserGesture() async => log.add('notifyUserGesture');
}

class PreRefactorFakes {
  PreRefactorFakes._(this.log, this.gameSave, this.highScores, this.settings,
      this.audio);

  final List<String> log;
  final RecordingGameSaveStore gameSave;
  final RecordingHighScoresStore highScores;
  final RecordingSettingsStore settings;
  final RecordingGameAudioService audio;

  static Future<PreRefactorFakes> create() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final log = <String>[];
    final settings = RecordingSettingsStore(prefs, log);
    return PreRefactorFakes._(
      log,
      RecordingGameSaveStore(prefs, log),
      RecordingHighScoresStore(prefs, log),
      settings,
      RecordingGameAudioService(log, settingsStore: settings),
    );
  }

  /// [audioFuture]를 주면 오디오 provider를 그 Future로 대체한다.
  List<Override> overrides({Future<GameAudioService> Function()? audioFuture}) =>
      [
        localPersistenceProvider.overrideWith(
          (ref) async => LocalPersistence(
            settings: settings,
            gameSave: gameSave,
            highScores: highScores,
          ),
        ),
        gameAudioServiceProvider.overrideWith(
          (ref) => audioFuture != null ? audioFuture() : Future.value(audio),
        ),
        // 포트로 옮겨진 소비자(notifier 등)도 같은 fake를 보도록 포트를 연결한다.
        ...appOverrides,
      ];
}
