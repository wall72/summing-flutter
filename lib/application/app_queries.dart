import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/models/app_settings.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/domain/game_phase.dart';
import 'package:summing_flutter/domain/game_state.dart';

/// 메뉴의 Resume 버튼용 조회: 진행 중(playing)인 저장만 돌려준다.
/// 게임 화면에서 돌아올 때 메뉴가 invalidate 해서 다시 읽는다.
final resumableGameProvider = FutureProvider<GameState?>((ref) async {
  final saves = await ref.watch(gameSaveRepositoryProvider.future);
  final saved = saves.load();
  return saved?.phase == GamePhase.playing ? saved : null;
});

/// 점수판 조회 (오름차순, 낮을수록 좋음). 화면을 열 때마다 새로 읽도록 autoDispose.
final highScoresProvider = FutureProvider.autoDispose<List<int>>((ref) async {
  final highScores = await ref.watch(highScoreRepositoryProvider.future);
  return highScores.load();
});

/// 메뉴의 Music / Sound effects 설정 상태와 변경.
final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final settings = await ref.watch(settingsRepositoryProvider.future);
    return settings.load();
  }

  Future<void> setMusicOn(bool value) => _update(
        (s) => s.copyWith(musicOn: value),
      );

  Future<void> setSoundOn(bool value) => _update(
        (s) => s.copyWith(soundOn: value),
      );

  Future<void> _update(AppSettings Function(AppSettings) change) async {
    final prev = state.valueOrNull;
    if (prev == null) return;
    final next = change(prev);
    // 화면은 즉시 새 값을 보여 준다.
    state = AsyncData(next);

    final settings = await ref.read(settingsRepositoryProvider.future);
    // @MX:NOTE: [AUTO] 저장 완료 후에만 BGM resync. GameAudio.applySettingsAndSyncBgm()은 인자 없이 저장된 설정을 다시 읽으므로 순서가 바뀌면 이전 음악 설정이 적용된다 (REQ-ARCH-010, AC-ARCH-08)
    await settings.save(next);
    if (prev.musicOn != next.musicOn) {
      await ref.read(gameAudioProvider).valueOrNull?.applySettingsAndSyncBgm();
    }
  }
}
