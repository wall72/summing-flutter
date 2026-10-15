# SPEC-ARCH-001 구현 계획

spec 0.2.0 기준. 1차 plan-audit(`.moai/reports/plan-audit/SPEC-ARCH-001-review-1.md`) 결함 D1-D12를 반영했습니다.

## §A Context

- Epic: Summing 모던 크로스플랫폼 리팩토링 (`/moai plan "모던한 스타일의 크로스플랫폼 퍼즐 게임으로 리팩토링"`)
- Epic 구성: SPEC-ARCH-001 (이 문서, Tier M) → SPEC-UI-001 (Tier L, `depends_on: [SPEC-ARCH-001]`)
- 순서 근거: UI-001이 메뉴·점수판을 다시 작성할 때 정리된 application provider를 그대로 쓰고, 이 SPEC이 만드는 fake 포트 override로 위젯 테스트를 결정적으로 돌리기 위함
- 개발 방식: `quality.yaml`의 `development_mode`는 `tdd`. 이 SPEC은 동작 보존 리팩토링이므로 run 단계에서 ddd cycle(ANALYZE-PRESERVE-IMPROVE) 적용을 권장 (최종 결정은 오케스트레이터)

## §B Known Issues

- **기준선 미실행**: plan 단계 셸에서 `flutter`가 PATH에 없어(`command not found: flutter`) `flutter analyze && flutter test` 기준선을 실행하지 못했습니다. Flutter SDK 버전도 확인하지 못했습니다(`board_grid.dart:28`의 `withValues(alpha:)` 사용으로 보아 3.27 이상으로 추정).
- 브리프에 없던 계층 위반 2건을 추가로 확인: `lib/presentation/scores/scores_page.dart:3`, `lib/presentation/common/game_lifecycle_listener.dart:7`.
- 기존 테스트 3개가 override 없는 `ProviderScope`/`ProviderContainer`를 씁니다 (`test/widget_test.dart:12`, `test/presentation/common/game_lifecycle_listener_test.dart:16-22`, `:38`). 포트 기본값을 throw로 두면 셋업 변경이 필요합니다.
- 숨은 순서 계약: `GameAudioService.applySettingsAndSyncBgm()`은 인자 없이 저장된 설정을 다시 읽습니다(`lib/infrastructure/audio/game_audio_service.dart:57-62`). 설정 컨트롤러는 저장을 기다린 뒤 resync해야 합니다 (REQ-ARCH-010, AC-ARCH-08).

## §C Pre-flight (run 단계 첫 단계)

1. **[HARD] 기준선 실행**: `flutter --version` 기록 후 `flutter analyze && flutter test`를 실행하고, 종료 코드와 출력 끝부분을 `progress.md` §E.2에 남깁니다. 기준선이 실패하면 리팩토링에 들어가지 않고 blocker로 보고합니다.
2. **AC 판별력 확인**: 리팩토링 전 트리에서 AC-ARCH-01 명령을 실행해 8줄 출력을 확인하고 기록합니다 (plan 단계 실측값 8).

   ```bash
   grep -rnE "import .*infrastructure/" lib/application lib/presentation
   ```

3. 기준 커밋 확인: `git rev-parse --short HEAD` (plan 시점 `6a695b2`).
4. 파일 단위 변경 목록(§F)을 TodoList로 분해합니다.

## §D Constraints

- 새 패키지 의존성 없음. `flutter_riverpod ^2.6.1` 유지.
- `lib/domain/**`, `persistence_keys.dart`, `save_game_codec.dart`는 diff가 비어 있어야 합니다.
- 기존 테스트의 `expect(` 줄은 바꾸지 않습니다.

## §E 설계 결정 (바뀔 가능성이 큰 순서)

| 순서 | 결정 | 채택안 | 검토한 대안 |
|---|---|---|---|
| D-1 | 포트 provider 형태 | application에 `FutureProvider<Port>` 4개(`gameSaveRepositoryProvider`, `highScoreRepositoryProvider`, `settingsRepositoryProvider`, `gameAudioProvider`)를 선언하고 기본 구현은 `UnimplementedError`를 던짐. composition root가 override. 현재의 비동기 로딩(메뉴·점수판 loading 분기)이 그대로 유지됨 | `main()`에서 SharedPreferences를 기다린 뒤 동기 `Provider`로 override. 부팅 순서와 테스트 셋업이 크게 바뀌어 제외 |
| D-2 | 포트 구성 | `lib/application/ports.dart` 한 파일에 `abstract interface class` 4개: `GameSaveRepository`(load/save/clear), `HighScoreRepository`(load/recordCompletedGame), `SettingsRepository`(load/save), `GameAudio`(playTap/playMatch/applySettingsAndSyncBgm/suspend/resume/notifyUserGesture) | 오디오를 효과음/BGM 제어로 분리. 파일과 override가 늘어 제외 |
| D-3 | composition root | `lib/infrastructure/app_overrides.dart`의 `appOverrides` 목록을 `main.dart`가 `ProviderScope(overrides: appOverrides)`로 사용. `lib/` 안에서 포트 provider를 override하는 곳은 이 파일뿐(AC-ARCH-14). infrastructure → application(포트) 의존 허용 | 별도 `lib/bootstrap/` 계층. 계층이 늘어 제외 |
| D-4 | 어댑터 방식 | 기존 `GameSaveStore`, `HighScoresStore`, `SettingsStore`, `GameAudioService`가 포트를 직접 `implements` | 별도 adapter 클래스. 현재 시그니처가 이미 포트와 일치해 이득 없음 |
| D-5 | `AppSettings` 위치 | `lib/application/models/app_settings.dart`로 옮기고 기존 경로는 re-export로 유지 (`test/infrastructure/settings_store_test.dart` import 호환). `toJson`/`fromJson`은 그대로 옮기고 AC-ARCH-13으로 고정 | domain 이동. domain 불변 결정과 충돌 |
| D-6 | 메뉴·점수판용 application 계층 | `lib/application/app_queries.dart`: `resumableGameProvider`(playing 저장만 반환, 게임 화면 복귀 시 invalidate), `highScoresProvider`, `settingsControllerProvider`(AsyncNotifier. 설정 저장을 `await`한 뒤, 음악 설정이 바뀐 경우에만 BGM resync) | 메뉴 로직 유지 + 포트만 교체. 테스트 seam이 약해 제외 |
| D-7 | 테스트 셋업 | `test/support/test_overrides.dart`에 호출 기록을 공유하는 fake 포트와 helper. 기존 3개 테스트는 셋업만 변경 | — |

변경 후 의존 그래프: `presentation → application → domain`, `infrastructure → application(ports), domain`. infrastructure를 아는 곳은 `lib/main.dart`뿐입니다.

## §F 마일스톤 (우선순위 순, 시간 추정 없음)

### M1 — 동작 고정 테스트 (Priority High, 3개 이상 파일)

리팩토링 전 코드에 대해 작성하고 통과를 확인합니다. 포트가 없으므로 `SharedPreferences.setMockInitialValues`와 `GameAudioService` fake subclass를 씁니다. 시작 전에 §C-2의 AC-ARCH-01 명령 출력(8줄)을 기록합니다.

- [NEW] `test/application/game_session_notifier_test.dart` — 효과음→저장 순서, complete 시 점수 기록+저장 삭제, gameOver 시 저장 삭제만, 오디오 미준비·실패 시에도 진행 (AC-ARCH-04 ~ 07)
- [NEW] `test/infrastructure/save_compat_fixture_test.dart` — 현재 코덱이 만든 JSON 문자열을 fixture로 고정 (AC-ARCH-03)
- [NEW] `test/application/app_settings_json_test.dart` — 설정 JSON 키 집합과 기본값 고정 (AC-ARCH-13)
- [NEW] `test/presentation/menu/menu_page_test.dart` — resume 버튼 문구·활성 상태, Music·Sound effects 토글 저장 (AC-ARCH-08, 09)
- [NEW] `test/presentation/scores/scores_page_test.dart` — 빈 상태, 정렬 (AC-ARCH-10)
- [NEW] `test/presentation/common/lifecycle_audio_test.dart` — inactive/paused/resumed 시 suspend·resume 기록 (AC-ARCH-15)
- [NEW] `test/presentation/game/game_page_characterization_test.dart` — **Restart 탭 시 확인 없이 즉시 재시작(turnCount 0)되는 현재 동작을 고정 (AC-ARCH-16, REQ-ARCH-016).** 이 테스트는 SPEC-UI-001 M1에서 확인 대화상자 흐름으로 **의도적으로 바뀝니다** (acceptance.md §D.2)

### M2 — 포트와 composition root (Priority High, 3개 이상 파일)

- [NEW] `lib/application/ports.dart`, `lib/application/port_providers.dart`, `lib/application/models/app_settings.dart`
- [NEW] `lib/infrastructure/app_overrides.dart`
- [MODIFY] `game_save_store.dart`, `high_scores_store.dart`, `settings_store.dart`, `game_audio_service.dart` (`implements` 추가), `app_settings.dart` (re-export), `infrastructure.dart` (barrel)
- [NEW] `test/application/port_providers_test.dart` — override 없이 각 포트 provider를 읽으면 `UnimplementedError`가 난다 (커버리지 게이트에서 throw 줄이 실행되도록 함)
- 대상 AC: AC-ARCH-13, 14

### M3 — 게임 세션·생명주기·진입점 재배선 (Priority High, 3개 이상 파일)

- [MODIFY] `lib/application/game_session_notifier.dart`, `lib/presentation/common/game_lifecycle_listener.dart`, `lib/main.dart`
- [NEW] `test/support/test_overrides.dart`
- [MODIFY] 기존 테스트 3개 셋업 (`expect` 줄 변경 금지)
- M1 테스트를 fake 포트 기반 셋업으로 옮기되 단언은 유지
- 대상 AC: AC-ARCH-04 ~ 07, 11, 15, 16

### M4 — 메뉴·점수판 조회 계층 (Priority Medium, 3개 이상 파일)

- [NEW] `lib/application/app_queries.dart`, `test/application/app_queries_test.dart`
- [MODIFY] `lib/presentation/menu/menu_page.dart`, `lib/presentation/scores/scores_page.dart`, `lib/application/application.dart`
- 대상 AC: AC-ARCH-08, 09, 10

### M5 — 경계 검증과 정리 (Priority Low, 3개 이상 파일)

- [NEW] `test/architecture/layer_boundary_test.dart` (VM 테스트에서 `lib/application`, `lib/presentation` 파일의 import를 검사)
- barrel 정리, 전체 `flutter analyze && flutter test`, AC-ARCH-01/02/11/14 명령 실행 결과를 `progress.md`에 기록
- `.moai/project/structure.md` 의존 다이어그램 갱신은 sync 단계(manager-docs) 담당
- 대상 AC: AC-ARCH-01, 02, 12

## §G 리스크와 대응

| 리스크 | 대응 |
|---|---|
| 포트 기본값이 throw라 override를 빠뜨린 테스트가 런타임에 실패 | `test/support/test_overrides.dart`와 `appOverrides`를 한 곳에서 관리, 실패 메시지에 원인 명시 |
| 설정 컨트롤러가 저장 전에 resync를 불러 이전 음악 설정이 적용됨 | AC-ARCH-08이 공유 호출 기록으로 `save` 완료 → resync 순서를 검증 |
| 메뉴 복귀 시 resume 정보 갱신 누락 | `resumableGameProvider` invalidate를 AC-ARCH-09(`Resume Game (0 turns)`)로 검증 |
| 결정적 상태를 만들기 어려움 (notifier 내부 `Random()`) | fake `GameSaveRepository`에 알려진 GameState를 넣고 `resumeGame()`으로 주입. complete/gameOver 직전 보드는 `Board.fromCells`로 구성 |
| `GameAudioService`가 `SettingsStore` 구체 타입에 의존 | infrastructure 내부 의존이므로 허용. 포트 경계 밖 |
| `port_providers.dart`의 throw 줄이 테스트에서 실행되지 않아 커버리지 미달 | `port_providers_test.dart`로 실행 (acceptance.md §D.3) |

## mx_plan

`code_comments: ko`이므로 태그 설명은 한국어로 작성하고, 에이전트가 추가하는 태그에는 `[AUTO]` 접두어를 붙입니다.

| 대상 | 태그 | 우선순위 | 이유 |
|---|---|---|---|
| `GameSessionNotifier.placeAt` | `@MX:ANCHOR` + `@MX:REASON` | High | 효과음→저장 순서, 저장/삭제/점수 기록 정책이라는 불변식. 게임 화면·테스트·생명주기에서 호출 |
| `lib/application/ports.dart`의 interface 4개 | `@MX:ANCHOR` + `@MX:REASON` | High | 계층 공개 경계. 구현체와 소비자가 여러 곳 |
| `lib/infrastructure/app_overrides.dart` | `@MX:ANCHOR` + `@MX:REASON` | High | 포트와 구현을 묶는 유일한 지점 |
| 설정 컨트롤러의 저장→resync 구간 | `@MX:NOTE` | High | `applySettingsAndSyncBgm()`이 저장된 설정을 다시 읽으므로 순서가 바뀌면 안 됨 |
| `port_providers.dart`의 throw 기본값 | `@MX:NOTE` | Medium | override가 반드시 필요함을 알림 |
| `save_compat_fixture_test.dart` | `@MX:NOTE` | Medium | schemaVersion 1 호환 고정. 코덱 파일은 diff를 비우기 위해 태그를 달지 않음 |
| `layer_boundary_test.dart` | `@MX:NOTE` | Low | 계층 규칙의 기계적 검사 지점 |

## §H Cross-References

- `spec.md` §C (REQ-ARCH-001 ~ 016), `acceptance.md` (AC-ARCH-01 ~ 16)
- `interview.md` — 사용자 결정
- `.moai/specs/SPEC-UI-001/plan.md` — 후속 SPEC (M1에서 Restart 동작 고정 테스트를 바꿈)
- `.moai/reports/plan-audit/SPEC-ARCH-001-review-1.md` — 1차 감사
