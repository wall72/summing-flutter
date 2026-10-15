# SPEC-ARCH-001 (compact)

run 단계용 요약본입니다 (spec 0.2.0 기준). 원문은 `spec.md`, `acceptance.md`입니다. 아래 AC 본문은 `acceptance.md` §D의 `AC-BODY-START` ~ `AC-BODY-END` 구간과 글자 단위로 같습니다.

## Requirements (GEARS)

- **REQ-ARCH-001** [MODIFY] The `lib/application/` and `lib/presentation/` libraries shall not import any library under `lib/infrastructure/`, whether by package import or relative import.
- **REQ-ARCH-002** [NEW] The application layer shall define abstract port interfaces for game-save persistence, high-score persistence, settings persistence, and game audio.
- **REQ-ARCH-003** [NEW] The infrastructure layer shall implement every application port, and within `lib/` the composition root (`lib/main.dart` together with one infrastructure-owned override list) shall be the only code that binds ports to implementations; test code under `test/` may bind fakes as permitted by REQ-ARCH-013.
- **REQ-ARCH-004** [MODIFY] The `AppSettings` value type shall be owned by the application layer, and its JSON shape (exactly the keys `musicOn` and `soundOn`, each defaulting to `true` when absent) shall stay unchanged.
- **REQ-ARCH-005** [MODIFY] The `GameSessionNotifier` shall access persistence and audio only through the application port providers.
- **REQ-ARCH-006** [EXISTING] When a placement succeeds, the `GameSessionNotifier` shall request the tap sound (non-match) or the match sound (match) before awaiting any persistence operation.
- **REQ-ARCH-007** [EXISTING] When a placement leaves the run in `complete`, the `GameSessionNotifier` shall record the turn count as a high score and clear the saved game; when a placement leaves the run in `gameOver`, the `GameSessionNotifier` shall clear the saved game without recording a score.
- **REQ-ARCH-008** [EXISTING] While the run is in `playing`, the `GameSessionNotifier` shall save the new state after every successful placement.
- **REQ-ARCH-009** [EXISTING] When the audio port has not resolved or has failed, the `GameSessionNotifier` shall still apply the placement and perform the persistence step that REQ-ARCH-007 or REQ-ARCH-008 requires for the resulting phase, without propagating an audio error to the caller.
- **REQ-ARCH-010** [MODIFY] When the user changes a setting, the application-layer settings controller shall persist the new settings, and when the music setting changes, the settings controller shall request a BGM resync through the audio port only after the new settings have been persisted.
- **REQ-ARCH-011** [MODIFY] When the menu is shown or the user returns from the game page, the menu shall read resume availability and the saved turn count through an application-layer query.
- **REQ-ARCH-012** [MODIFY] The scores page shall read high scores through an application-layer query, and the lifecycle listener shall reach audio suspend and resume through the audio port.
- **REQ-ARCH-013** [NEW] Where a test overrides the port providers with fake implementations, the application and presentation layers shall run without the shared_preferences or audioplayers plugins.
- **REQ-ARCH-014** [EXISTING] The refactor shall not change the shared_preferences keys (`summing_settings`, `summing_savegame`, `summing_highscores`), the saved-game JSON format, or `SaveGameCodec.currentSchemaVersion` (= 1).
- **REQ-ARCH-015** [EXISTING] The refactor shall not modify any file under `lib/domain/` or `test/domain/`.
- **REQ-ARCH-016** [EXISTING] Every existing test's `expect` assertions shall pass unchanged (only setup code such as provider overrides and imports may change), and the user-visible behavior fixed by the milestone-1 characterization tests, including Restart starting a new run immediately, shall stay unchanged within this SPEC.

## Acceptance Criteria (Given/When/Then)

<!-- AC-BODY-START: acceptance.md와 동일하게 유지 -->

### AC-ARCH-01 (REQ-ARCH-001)

**Given** 리팩토링이 끝난 트리, **When** 아래 명령을 실행하면, **Then** 출력이 0줄이고 같은 검사를 하는 `test/architecture/layer_boundary_test.dart`가 통과한다.

```bash
grep -rnE "import .*infrastructure/" lib/application lib/presentation
```

판별력 확인: 기준 커밋 `6a695b2`에서 같은 명령은 8줄을 출력한다(plan 단계 실측). M1에서 리팩토링 전에 다시 실행해 8줄임을 `progress.md` §E.2에 기록한다. 상대 경로 import(`'../infrastructure/…'`)도 `infrastructure/`를 포함하므로 같은 패턴에 걸린다.

### AC-ARCH-02 (REQ-ARCH-014, REQ-ARCH-015)

**Given** 기준 커밋 `6a695b2`, **When** 아래 두 명령을 실행하면, **Then** 첫 명령의 종료 코드가 0이고 두 번째 명령의 출력이 0줄이다.

```bash
git diff --exit-code 6a695b2 -- lib/domain test/domain lib/infrastructure/persistence/persistence_keys.dart lib/infrastructure/persistence/save_game_codec.dart
git status --porcelain -- lib/domain test/domain
```

### AC-ARCH-03 (REQ-ARCH-014)

**Given** 리팩토링 전 코덱이 만든 저장 JSON 문자열 fixture(M1에서 캡처해 `test/infrastructure/save_compat_fixture_test.dart`에 고정), **When** 리팩토링 후 게임 저장 포트로 그 문자열을 불러오면, **Then** turnCount, 보드 81칸, 큐 4칸이 fixture를 만들 때의 값과 모두 같다.

### AC-ARCH-04 (REQ-ARCH-005, REQ-ARCH-006)

**Given** 호출 순서를 기록하는 fake 오디오 포트와 fake 게임 저장소, **When** 매치가 아닌 `placeAt`이 성공하면, **Then** 기록 순서가 `playTap` → `save`이다. **When** 매치인 `placeAt`이 성공하면, **Then** 기록 순서가 `playMatch` → `save`이다.

### AC-ARCH-05 (REQ-ARCH-007)

**Given** 한 수만 두면 `complete`가 되는 상태, **When** `placeAt`을 실행하면, **Then** `recordCompletedGame(turnCount)`가 1회, `clear`가 1회 호출되고 `save`는 호출되지 않는다.

### AC-ARCH-06 (REQ-ARCH-007)

**Given** 한 수만 두면 `gameOver`가 되는 상태, **When** `placeAt`을 실행하면, **Then** `clear`가 1회 호출되고 `recordCompletedGame`과 `save`는 호출되지 않는다.

### AC-ARCH-07 (REQ-ARCH-008, REQ-ARCH-009)

**Given** `playing` 상태와 fake 게임 저장소, 그리고 오디오 포트 provider가 (a) 끝나지 않는 Completer로 override된 경우와 (b) error로 끝나도록 override된 경우 각각, **When** 매치가 아닌 `placeAt`을 실행하면, **Then** 두 경우 모두 `placeAt`이 예외 없이 완료되고(`expectLater(..., completes)`), turnCount가 1 늘며, `save`가 1회 호출된다.

### AC-ARCH-08 (REQ-ARCH-010)

**Given** fake 설정 저장소가 처음에 `AppSettings()`(`musicOn: true`, `soundOn: true`)를 반환하고, fake 설정 저장소와 fake 오디오 포트가 하나의 호출 기록을 공유하는 상태, **When** MenuPage에서 Music 스위치를 끄면, **Then** 기록이 정확히 `save(AppSettings(musicOn: false, soundOn: true))` 완료 → `applySettingsAndSyncBgm` 1회 순서다. **When** 대신 Sound effects 스위치만 끄면, **Then** `save(AppSettings(musicOn: true, soundOn: false))`가 1회 기록되고 `applySettingsAndSyncBgm`은 기록되지 않는다.

### AC-ARCH-09 (REQ-ARCH-011)

**Given** turnCount 3인 `playing` 저장, **When** MenuPage가 그려지면, **Then** 문구 `Resume Game (3 turns)`인 버튼이 활성 상태다. **Given** 저장 없음, **When** MenuPage가 그려지면, **Then** 문구 `Resume Game`인 버튼이 비활성 상태다. **Given** 저장 없음, **When** New Game으로 게임 화면에 들어갔다가 수를 두지 않고 Quit로 돌아오면, **Then** 버튼 문구가 `Resume Game (0 turns)`이고 활성 상태다.

### AC-ARCH-10 (REQ-ARCH-012)

**Given** fake 점수 저장소가 `[12, 15]`를 반환, **When** ScoresPage가 그려지면, **Then** `12 turns`가 `15 turns`보다 위에 있다. **Given** fake 점수 저장소가 빈 목록을 반환, **When** ScoresPage가 그려지면, **Then** `No completed games yet.`으로 시작하는 안내가 보인다.

### AC-ARCH-11 (REQ-ARCH-013, REQ-ARCH-016)

**Given** 기준 커밋 `6a695b2`에 있던 테스트 파일 11개(`test/domain/` 4개, `test/application/` 1개, `test/infrastructure/` 4개, `test/presentation/common/` 1개, `test/widget_test.dart`), **When** 아래 명령과 `flutter test`를 실행하면, **Then** 첫 명령은 `11`을 출력하고, 두 번째 명령은 `0`을 출력하며(grep은 일치 0건일 때 종료 코드 1), 11개 파일의 테스트가 모두 통과한다.

```bash
git ls-tree -r --name-only 6a695b2 -- test | wc -l
git diff 6a695b2 --diff-filter=M -- test/ | grep -cE "^[-+].*expect\("
```

### AC-ARCH-12 (전체)

**When** 아래 명령을 실행하면, **Then** 종료 코드 0, analyzer issue 0건이다.

```bash
flutter analyze && flutter test
```

### AC-ARCH-13 (REQ-ARCH-004)

**Given** JSON 문자열 `{"musicOn":false,"soundOn":true}`, **When** `AppSettings.fromJson`으로 읽은 뒤 `toJson()`으로 다시 쓰면, **Then** 결과 맵의 키 집합이 정확히 `{musicOn, soundOn}`이고 값이 `{musicOn: false, soundOn: true}`이다. **Given** JSON 문자열 `{}`, **When** `AppSettings.fromJson`으로 읽으면, **Then** `musicOn`과 `soundOn`이 모두 `true`이다. **Given** shared_preferences 키 `summing_settings`에 문자열 `{"musicOn":false,"soundOn":true}`가 저장된 상태, **When** 설정 포트의 `load()`를 호출하면, **Then** `AppSettings(musicOn: false, soundOn: true)`와 같다.

### AC-ARCH-14 (REQ-ARCH-002, REQ-ARCH-003)

**Given** 리팩토링이 끝난 트리, **When** 아래 명령을 실행하면, **Then** (1) 첫 명령은 `4`를 출력하고, (2) 두 번째 명령은 정확히 `lib/infrastructure/app_overrides.dart` 한 줄을 출력하며, (3) 세 번째 명령은 1줄 이상을 출력하고, (4) 네 번째 명령은 `game_save_store.dart`, `high_scores_store.dart`, `settings_store.dart`, `game_audio_service.dart` 4개 파일을 출력한다. `test/` 아래의 override는 REQ-ARCH-013에 따라 허용되므로 검사 범위에서 제외한다.

```bash
grep -cE "^abstract interface class (GameSaveRepository|HighScoreRepository|SettingsRepository|GameAudio) " lib/application/ports.dart
grep -rlE "(gameSaveRepositoryProvider|highScoreRepositoryProvider|settingsRepositoryProvider|gameAudioProvider)\.override" lib
grep -nE "overrides: *appOverrides" lib/main.dart
grep -rlE "implements .*(GameSaveRepository|HighScoreRepository|SettingsRepository|GameAudio)\b" lib/infrastructure
```

### AC-ARCH-15 (REQ-ARCH-012)

**Given** `GameLifecycleListener`가 호출 순서를 기록하는 fake 오디오 포트로 override된 `ProviderScope` 안에 있는 상태, **When** `AppLifecycleState.inactive`를 보내면, **Then** `suspend`는 기록되지 않는다. **When** 이어서 `AppLifecycleState.paused`를 보낸 뒤 `AppLifecycleState.resumed`를 보내면, **Then** 기록이 `suspend` 1회 → `resume` 1회 순서다.

### AC-ARCH-16 (REQ-ARCH-016)

**Given** turnCount 3인 `playing` 저장을 resume해서 연 GamePage, **When** 상단 바의 `Restart`를 탭하면, **Then** 대화상자가 나타나지 않고(`find.byType(AlertDialog)` 0개), turnCount가 0이 되며, 새 상태로 `save`가 1회 호출된다. 이 단언은 `test/presentation/game/game_page_characterization_test.dart`에 둔다.

<!-- AC-BODY-END -->

## Files to Modify

- [NEW] `lib/application/ports.dart`, `lib/application/port_providers.dart`, `lib/application/models/app_settings.dart`, `lib/application/app_queries.dart`, `lib/infrastructure/app_overrides.dart`
- [MODIFY] `lib/application/game_session_notifier.dart`, `lib/application/application.dart`, `lib/presentation/menu/menu_page.dart`, `lib/presentation/scores/scores_page.dart`, `lib/presentation/common/game_lifecycle_listener.dart`, `lib/main.dart`
- [MODIFY] `lib/infrastructure/persistence/{game_save_store,high_scores_store,settings_store,app_settings}.dart`, `lib/infrastructure/audio/game_audio_service.dart`, `lib/infrastructure/infrastructure.dart`
- [NEW] tests: `test/support/test_overrides.dart`, `test/application/game_session_notifier_test.dart`, `test/application/app_queries_test.dart`, `test/application/port_providers_test.dart`, `test/application/app_settings_json_test.dart`, `test/infrastructure/save_compat_fixture_test.dart`, `test/presentation/menu/menu_page_test.dart`, `test/presentation/scores/scores_page_test.dart`, `test/presentation/common/lifecycle_audio_test.dart`, `test/presentation/game/game_page_characterization_test.dart`, `test/architecture/layer_boundary_test.dart`
- [MODIFY] tests (setup only): `test/widget_test.dart`, `test/presentation/common/game_lifecycle_listener_test.dart`, `test/application/game_session_notifier_persistence_test.dart`
- [EXISTING] do not touch: `lib/domain/**`, `persistence_keys.dart`, `save_game_codec.dart`

## Exclusions (What NOT to Build)

### Out of Scope — UI·연출

- 디자인·테마·반응형·애니메이션·재시작 확인 대화상자 (SPEC-UI-001)

### Out of Scope — 게임 규칙과 데이터

- `lib/domain/**` 변경, 저장 키·형식·`schemaVersion`·점수 정책 변경, `AppSettings` 필드 추가

### Out of Scope — 인프라와 도구

- 새 패키지, 상태 관리 교체, 난수 주입 구조 변경, CI·앱 식별자·방향 정책·오디오 스크립트
