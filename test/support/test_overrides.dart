import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/models/app_settings.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/application/ports.dart';
import 'package:summing_flutter/domain/game_state.dart';

/// 테스트용 fake 포트. 모두 하나의 호출 기록([log])을 공유해 호출 순서를 검증할 수 있다.
/// shared_preferences / audioplayers 플러그인 없이 동작한다 (REQ-ARCH-013).
class FakeGameSaveRepository implements GameSaveRepository {
  FakeGameSaveRepository(this.log);

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

class FakeHighScoreRepository implements HighScoreRepository {
  FakeHighScoreRepository(this.log);

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

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository(this.log);

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

class FakeGameAudio implements GameAudio {
  FakeGameAudio(this.log);

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

/// fake 포트 묶음과 포트 provider override 목록.
class FakePorts {
  FakePorts() : log = <String>[] {
    gameSave = FakeGameSaveRepository(log);
    highScores = FakeHighScoreRepository(log);
    settings = FakeSettingsRepository(log);
    audio = FakeGameAudio(log);
  }

  final List<String> log;
  late final FakeGameSaveRepository gameSave;
  late final FakeHighScoreRepository highScores;
  late final FakeSettingsRepository settings;
  late final FakeGameAudio audio;

  /// [audioFuture]를 주면 오디오 포트 provider를 그 Future로 대체한다
  /// (끝나지 않는 Completer, 실패하는 Future 등).
  List<Override> overrides({Future<GameAudio> Function()? audioFuture}) => [
        gameSaveRepositoryProvider.overrideWith((ref) async => gameSave),
        highScoreRepositoryProvider.overrideWith((ref) async => highScores),
        settingsRepositoryProvider.overrideWith((ref) async => settings),
        gameAudioProvider.overrideWith(
          (ref) => audioFuture != null ? audioFuture() : Future.value(audio),
        ),
      ];
}
