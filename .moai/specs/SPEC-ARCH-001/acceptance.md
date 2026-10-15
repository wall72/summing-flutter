# SPEC-ARCH-001 인수 기준

검증 레이어 문서입니다. 각 항목은 Given-When-Then 형식이며 통과/실패가 명확히 갈립니다. 요구사항 원문은 `spec.md` §C를 따릅니다.

모든 셸 명령은 표 밖 코드 블록에 원문 그대로 적었습니다(표 셀 안 `\|` 이스케이프로 명령이 바뀌는 문제 방지). `spec-compact.md`의 AC 본문은 이 문서 §D와 글자 단위로 같습니다.

## §D AC 목록

<!-- AC-BODY-START: spec-compact.md와 동일하게 유지 -->

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

## §D.0 추적 표

| AC | 추적 REQ |
|---|---|
| AC-ARCH-01 | REQ-ARCH-001 |
| AC-ARCH-02 | REQ-ARCH-014, 015 |
| AC-ARCH-03 | REQ-ARCH-014 |
| AC-ARCH-04 | REQ-ARCH-005, 006 |
| AC-ARCH-05, 06 | REQ-ARCH-007 |
| AC-ARCH-07 | REQ-ARCH-008, 009 |
| AC-ARCH-08 | REQ-ARCH-010 |
| AC-ARCH-09 | REQ-ARCH-011 |
| AC-ARCH-10, 15 | REQ-ARCH-012 |
| AC-ARCH-11 | REQ-ARCH-013, 016 |
| AC-ARCH-12 | 전체 |
| AC-ARCH-13 | REQ-ARCH-004 |
| AC-ARCH-14 | REQ-ARCH-002, 003 |
| AC-ARCH-16 | REQ-ARCH-016 |

REQ 16개 모두 하나 이상의 AC가 직접 검증합니다. AC는 16개로 Tier M 상한(16)입니다.

## §D.1 엣지 케이스

- 설정 스위치를 빠르게 두 번 토글: 마지막 값이 저장되고 화면 값과 저장 값이 일치한다.
- 저장소 로딩 실패(포트 provider가 error): 메뉴와 점수판이 지금처럼 오류 문구를 보여 주고 앱이 멈추지 않는다.
- 끝난 판(`complete`/`gameOver`)이 저장되어 있을 때 resume: 상태는 null로 남고 저장이 삭제된다 (기존 테스트 `game_session_notifier_persistence_test.dart:52-69`와 동일).
- 웹 첫 제스처 오디오 해제(`lib/main.dart:40-50`): 오디오 포트를 거쳐서도 그대로 동작한다.
- override 없이 포트 provider를 읽으면 `UnimplementedError`가 난다 (`test/application/port_providers_test.dart`, 커버리지 처리는 §D.3).

## §D.2 동작 고정 테스트와 후속 SPEC의 관계

- M1에서 작성하는 `test/presentation/game/game_page_characterization_test.dart`(AC-ARCH-16)는 **"Restart를 누르면 확인 없이 즉시 재시작된다"**는 현재 동작을 고정합니다.
- 이 동작은 SPEC-UI-001 M1에서 **의도적으로 바뀝니다** (playing 중에는 확인 대화상자 표시). UI-001은 이 테스트를 AC-UI-08 ~ 11 흐름으로 바꿔 씁니다. 이는 회귀가 아니라 계획된 변경입니다.
- 이 SPEC 안에서는 AC-ARCH-16이 통과해야 합니다.

## §D.3 품질 게이트

| 항목 | 기준 |
|---|---|
| 정적 분석 | `flutter analyze` issue 0건 |
| 테스트 | `flutter test` 전체 통과 |
| 커버리지 | `flutter test --coverage` 결과 `coverage/lcov.info`에서 이 SPEC으로 바뀌거나 새로 생긴 `lib/application/**` 파일 각각의 라인 커버리지 85% 이상(LH/LF). `port_providers.dart`의 `UnimplementedError` 줄은 `port_providers_test.dart`가 override 없이 각 provider를 읽어 실행하므로 제외 없이 측정 |
| 계층 경계 | AC-ARCH-01 출력 0줄 |
| 불변 파일 | AC-ARCH-02 통과 |

## §D.4 Definition of Done

- [ ] run 단계 첫 단계로 기준선 `flutter analyze && flutter test`를 실행하고 결과를 `progress.md` §E.2에 기록
- [ ] M1에서 AC-ARCH-01 명령이 리팩토링 전 8줄을 출력함을 기록
- [ ] M1 동작 고정 테스트가 리팩토링 전 코드에서 통과함을 기록
- [ ] AC-ARCH-01 ~ 16 전부 통과, 각 명령과 출력을 `progress.md` §E.2에 기록
- [ ] mx_plan의 High 우선순위 태그 반영
- [ ] 새 패키지 의존성 없음 (`git diff 6a695b2 -- pubspec.yaml` 출력 없음)
