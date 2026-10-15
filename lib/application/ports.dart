import 'package:summing_flutter/application/models/app_settings.dart';
import 'package:summing_flutter/domain/game_state.dart';

// application 계층이 소유하는 추상 포트. infrastructure가 구현하고
// composition root(`lib/main.dart` + `appOverrides`)만 구현을 연결한다.

// @MX:ANCHOR: [AUTO] 진행 중인 판 저장 포트 — 계층 공개 경계
// @MX:REASON: GameSessionNotifier·조회 provider가 소비하고 GameSaveStore와 테스트 fake가 구현한다. 시그니처 변경은 모든 구현체에 전파된다
abstract interface class GameSaveRepository {
  /// 저장된 판. 없거나 읽을 수 없으면 null.
  GameState? load();

  Future<void> save(GameState state);

  Future<void> clear();
}

// @MX:ANCHOR: [AUTO] 최고 기록 포트 — 계층 공개 경계
// @MX:REASON: 완료 판 기록(notifier)과 점수판 조회가 소비하고 HighScoresStore와 테스트 fake가 구현한다
abstract interface class HighScoreRepository {
  /// 오름차순(낮을수록 좋음) 상위 기록.
  List<int> load();

  /// [turnCount]를 기록하고 갱신된 목록을 돌려준다.
  Future<List<int>> recordCompletedGame(int turnCount);
}

// @MX:ANCHOR: [AUTO] 설정 저장 포트 — 계층 공개 경계
// @MX:REASON: 설정 컨트롤러가 소비하고 SettingsStore와 테스트 fake가 구현한다. 저장 키·JSON 형식 불변식(REQ-ARCH-004/014)이 구현 쪽에 걸려 있다
abstract interface class SettingsRepository {
  AppSettings load();

  Future<void> save(AppSettings settings);
}

/// 게임 오디오 포트 (BGM + 효과음). 구현은 오디오 실패를 호출자에게 전파하지 않는다.
// @MX:ANCHOR: [AUTO] 게임 오디오 포트 — 계층 공개 경계
// @MX:REASON: notifier·설정 컨트롤러·생명주기 리스너·웹 제스처 해제가 소비하고 GameAudioService와 테스트 fake가 구현한다
abstract interface class GameAudio {
  Future<void> playTap();

  Future<void> playMatch();

  /// 저장된 설정을 다시 읽어 BGM 재생 여부를 맞춘다. 설정 저장이 끝난 뒤 호출해야 한다.
  Future<void> applySettingsAndSyncBgm();

  Future<void> suspend();

  Future<void> resume();

  Future<void> notifyUserGesture();
}
