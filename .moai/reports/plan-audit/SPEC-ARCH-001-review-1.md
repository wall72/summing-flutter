# SPEC Review Report: SPEC-ARCH-001
Iteration: 1/3
Verdict: FAIL
Overall Score: 0.72 (Tier M PASS 기준 0.80 미달)

Reasoning context ignored per M1 Context Isolation. 감사 입력: Tier M 3종(spec.md, plan.md, acceptance.md) + 참고용 spec-compact.md, interview.md, progress.md, 그리고 근거 검증을 위한 `lib/`, `test/` 실제 코드.

교차 모델 감사: `mcp__moai__audit_multi` 호출 — codex(바이너리 없음), glm(API 키 없음) 모두 `inconclusive`(fail-open). 판정은 Claude 단독 감사 결과입니다.

## Must-Pass Results

- [PASS] MP-1 REQ 번호 일관성: REQ-ARCH-001 ~ 016 16개가 빠짐·중복 없이 존재하고 3자리 패딩이 일관됨 (spec.md:L53-L80). 단, 문서 내 배치 순서가 013 → 016 → 014 → 015 (spec.md:L74-L80)로 순차가 아님 — 결함 D9(minor)로 기록.
- [PASS] MP-2 GEARS 형식 (판정 레이어: spec.md §C 요구사항 레이어. acceptance.md의 Given-When-Then AC는 검증 레이어라 이 항목에서 채점하지 않음): 001·014·015는 Unwanted `shall not` (L53, L79, L80), 002·003·004·005·012·016은 Ubiquitous (L54-L56, L60, L70, L75), 006·007·009·010·011은 Event-driven `When ..., the ... shall` (L61-L62, L64, L68-L69), 008은 State-driven `While` (L63), 013은 `Where` (L74). 형식 위반 없음.
- [PASS] MP-3 YAML frontmatter: 12개 필드 모두 존재하고 타입 정상 — `id: SPEC-ARCH-001`(L2), `title` 따옴표(L3), `version: "0.1.0"`(L4), `status: draft`(L5), `created/updated: 2026-10-15`(L6-L7), `author`(L8), `priority: P1`(L9), `phase: "v1.1.0 target"`(L10, 생명주기 단계명 아님), `module`(L11), `lifecycle: spec-anchored`(L12), `tags` 쉼표 문자열(L13). 거부 alias(`created_at` 등) 없음. 선택 필드 `tier: M`(L14). `related_specs`(L15)는 스키마 밖 필드지만 필수 필드 위반은 아님.
- [N/A] MP-4 언어 중립성: Flutter/Dart 단일 언어 프로젝트 SPEC (`pubspec.yaml`, spec.md:L84-L86). 자동 통과.
- [PASS] MP-5 D7 교차 SPEC: 본문 참조 SPEC은 SPEC-UI-001 하나. `.moai/specs/SPEC-UI-001/spec.md` 존재, `status: draft` (retired/superseded/archived 아님). UI-001의 `depends_on: [SPEC-ARCH-001]`, `test_overrides.dart` 사용, `game_page_characterization_test.dart` 의도적 변경(UI-001 acceptance.md:L43-L44)이 ARCH-001 acceptance.md §D.2(L30-L34)와 일치. BLOCKING 없음.
- [PASS] MP-6 D8 교차 플랫폼: 모든 산출물에서 `syscall` 0건. 자동 통과.
- [PASS] MP-7 clarification gate: `grep -rn '\[NEEDS CLARIFICATION'` 결과 0건 (exit 1). research.md는 Tier M이라 없음.

## Category Scores (0.0-1.0, rubric-anchored)

| Dimension | Score | Rubric Band | Evidence |
|-----------|-------|-------------|----------|
| Clarity | 0.75 | 0.75 | 대부분 단일 해석. 다만 REQ-ARCH-003 "the only code that binds"(L55)는 테스트 override와 충돌하는 범위 모호, REQ-ARCH-009 "persist"(L64)는 종료 상태(clear)에서 의미 모호, REQ-ARCH-010(L68)은 저장→resync 순서 미명시 |
| Completeness | 0.90 | 1.0 근접 | HISTORY(L20), 배경/목표(L26-L37), 근거(L39-L47), REQ(L49-L80), 제약(L82), 변경 파일(L89), AC 포인터(L102), `### Out of Scope — <topic>` 3개 + bullet(L110-L125) 모두 존재. 감점: Restart 동작 고정 테스트에 대응 REQ/AC 없음(acceptance.md:L32-L34) |
| Testability | 0.60 | 0.50-0.75 사이 | AC-ARCH-01 명령이 원문 그대로는 위반 트리에서도 0줄(D1), AC-ARCH-11 명령 깨짐(D2), AC-ARCH-09 "새 저장 기준으로 갱신"(L17) 기대 문구 없음, AC-ARCH-08 초기 설정값 미명시(L16) |
| Traceability | 0.65 | 0.50-0.75 사이 | AC Matrix(acceptance.md:L7-L20)에서 REQ-ARCH-002, 003을 직접 검증하는 AC 없음(AC-12 "전체"는 포괄 표기일 뿐). REQ-012 생명주기 리스너 부분, REQ-009 "failed" 분기, REQ-004 JSON 형태, REQ-016(11개 중 3개만)이 부분 검증 |

집계: 네 차원 평균 0.725 → 0.72. Tier M 기준 0.80 미달.

## Defects Found (structured defect-list)

D1. AC-01-VACUOUS — acceptance.md:L9 — AC-ARCH-01 명령이 표 셀 안에서 `\|`로 이스케이프되어 있어, 원문을 그대로 복사해 실행하면 ERE에서 `\|`가 리터럴 파이프로 해석됩니다. 현재(위반 8건이 있는) 트리에서 실측: `/usr/bin/grep -rnE "import .*(infrastructure/\|\.\./infrastructure)" lib/application lib/presentation | wc -l` → `0` (GNU grep 3.11). 같은 패턴을 일반 `|`로 쓰면 → `8`. 즉 이 SPEC의 핵심 REQ-ARCH-001을 검증하는 AC가 리팩토링 전에도 통과하는 무의미한 검사입니다. spec-compact.md:L26은 올바른 `|`를 써서 두 산출물이 서로 다른 명령을 담고 있음(SSOT 불일치). — Severity: critical — Class: blocking — Required fix: 명령을 표 밖 fenced code block으로 옮기거나, 대안 없이 `grep -rnE "import .*infrastructure/" lib/application lib/presentation`(상대 경로 `../infrastructure/`도 `infrastructure/`를 포함하므로 단일 패턴으로 충분)로 바꾸고, spec-compact.md와 같은 문자열로 맞출 것. 가능하면 "리팩토링 전 트리에서 이 명령이 8줄을 출력함을 M1에서 기록"이라는 판별력 확인 단계를 추가.

D2. AC-11-PIPE-AND-SCOPE — acceptance.md:L19 — (a) `git diff 6a695b2 -- <파일> \| grep -E "^[-+].*expect\("`의 `\|`도 원문 복사 시 셸 파이프가 아니라 `git diff`의 pathspec 인자가 되어, 출력이 0줄이 될 수 없는 깨진 명령입니다. (b) REQ-ARCH-016(spec.md:L75)은 "Every existing test's `expect` assertions shall pass unchanged"인데, AC-11은 11개 기존 테스트 파일 중 3개만 diff 검사합니다. `test/domain/` 4개는 AC-02가 덮지만 `test/infrastructure/` 4개(18개 `expect(` 줄, plan.md D-4로 대상 클래스에 `implements`가 추가되는 파일들)는 어떤 AC도 덮지 않습니다. — Severity: major — Class: blocking — Required fix: 명령을 code block으로 옮기고 범위를 `git diff 6a695b2 --diff-filter=M -- test/ | grep -E "^[-+].*expect\("`(수정된 기존 파일 전체)로 넓힐 것.

D3. REQ-004-JSON-UNVERIFIED — spec.md:L56, acceptance.md:L16 — REQ-ARCH-004는 `AppSettings` JSON 형태(`musicOn`, `soundOn`, 기본값 `true`) 불변을 요구하지만, 이를 추적한다는 AC-ARCH-08은 fake 저장소에 넘어간 `AppSettings` 객체만 비교하므로 JSON을 보지 않습니다. 기존 `test/infrastructure/settings_store_test.dart:22-23`도 save→load 왕복만 확인하므로 키 이름이 바뀌어도 통과합니다. `AppSettings`를 application 계층으로 옮기는 바로 이 SPEC에서 `toJson`/`fromJson`이 건드려질 위험이 가장 큽니다. — Severity: major — Class: blocking — Required fix: AC-ARCH-03과 같은 방식의 설정 JSON fixture AC 추가 — 예: Given 문자열 `{"musicOn":false,"soundOn":true}`, When `AppSettings.fromJson` 후 `toJson()`, Then 키 집합이 정확히 `{musicOn, soundOn}`이고 값이 같다; Given `{}`, Then 두 값 모두 `true`.

D4. REQ-010-ORDERING — spec.md:L68, acceptance.md:L16 — 현재 `GameAudioService.applySettingsAndSyncBgm()`은 인자 없이 `_settings.load().musicOn`을 읽습니다(`lib/infrastructure/audio/game_audio_service.dart:57-62`, 주석 "Call after [SettingsStore.save]"). 따라서 resync는 저장 이후에 와야 하는 숨은 순서 계약이 있고, 현재 메뉴 코드도 `await p.settings.save(next)` 후 resync합니다(`menu_page.dart:43-48`). REQ-ARCH-010과 AC-ARCH-08 어디에도 이 순서가 없어, 새 settings controller가 resync를 먼저 부르거나 save를 기다리지 않아도 fake 기반 AC-08은 통과합니다. — Severity: major — Class: blocking — Required fix: REQ-ARCH-010을 "...shall request a BGM resync through the audio port after the new settings have been persisted"로 고치고, AC-ARCH-08에 "기록 순서가 `save` → resync"를 추가.

D5. REQ-002-003-UNTRACED — acceptance.md:L7-L20 — REQ-ARCH-002(포트 4개 정의)와 REQ-ARCH-003(인프라가 모든 포트를 구현, composition root만 바인딩)을 직접 검증하는 AC가 없습니다. AC-ARCH-12의 "전체" 추적은 `flutter analyze && flutter test` 통과일 뿐이라 포트 존재·바인딩 위치를 판별하지 못합니다. — Severity: major — Class: blocking — Required fix: AC 1개 추가 — 예: Given 리팩토링 후 트리, When `layer_boundary_test.dart`(또는 grep)가 검사하면, Then (a) `lib/application/`에 4개 포트 추상 타입이 있고, (b) `lib/` 아래에서 포트 provider의 `overrideWith`/`overrideWithValue`가 `lib/infrastructure/app_overrides.dart`에만 나타나며, (c) `lib/main.dart`의 `ProviderScope`가 `appOverrides`를 사용한다. REQ-ARCH-003의 "the only code"는 "the only code under `lib/`"로 범위를 좁혀 테스트 override(REQ-ARCH-013)와의 모호함도 해소.

D6. REQ-012-LIFECYCLE-UNTRACED — spec.md:L70, acceptance.md:L18 — REQ-ARCH-012 후반부("the lifecycle listener shall reach audio suspend and resume through the audio port")를 검증하는 AC가 없습니다. AC-ARCH-10은 점수판만 다루고, 기존 `game_lifecycle_listener_test.dart`는 저장 지속만 확인합니다. — Severity: minor — Class: blocking — Required fix: AC 추가 또는 AC-10 확장 — Given fake 오디오 포트, When `AppLifecycleState.paused` 후 `resumed`, Then fake에 `suspend` 1회 → `resume` 1회가 기록된다.

D7. REQ-009-FAILED-BRANCH — spec.md:L64, acceptance.md:L15 — REQ-ARCH-009는 "has not resolved or has failed" 두 경우를 요구하지만 AC-ARCH-07은 끝나지 않는 Completer(미해결)만 다룹니다. error 경우는 엣지 케이스 목록(acceptance.md:L27)에만 있고 AC가 아닙니다. 또 "persist"는 종료 상태로 끝나는 배치에서는 save가 아니라 clear이므로 의미가 모호합니다. — Severity: minor — Class: blocking — Required fix: AC-ARCH-07에 "오디오 포트 provider가 error로 끝난 경우에도 turnCount +1, `save` 1회, 예외 전파 없음"을 추가하고, REQ-009의 "persist"를 "apply the placement and perform the persistence step required by REQ-ARCH-007/008"로 명확화.

D8. AC-09-EXPECTED-TEXT — acceptance.md:L17 — "버튼 문구가 새 저장 기준으로 갱신된다"는 기대값이 없어 판정자가 해석해야 합니다. — Severity: minor — Class: optional — Required fix: "New Game 진입 후 수를 두지 않고 돌아오면 버튼 문구가 `Resume Game (0 turns)`이고 활성 상태"처럼 정확한 문구를 명시.

D9. REQ-ORDER — spec.md:L74-L80 — REQ-ARCH-016이 Module 4(013 뒤)에 있고 014, 015가 그 뒤 Module 5에 있어 문서 순서가 비순차입니다. 번호 공백·중복은 없어 MP-1 FAIL은 아닙니다. — Severity: minor — Class: optional — Required fix: REQ-016을 015 뒤로 옮기거나(모듈 귀속을 Module 5로) 번호를 재배열하고 acceptance.md의 참조를 함께 갱신.

D10. AC-08-PRECONDITION — acceptance.md:L16 — Given에 fake 설정 저장소의 초기 값이 없어, `save(AppSettings(musicOn: false, soundOn: true))` 기대값이 초기값 `(true, true)`를 암묵 전제합니다. — Severity: minor — Class: optional — Required fix: "Given fake 설정 저장소가 `AppSettings()`(둘 다 true)를 반환"을 명시.

D11. COVERAGE-THROW-DEFAULTS — acceptance.md:L42, plan.md:L32 — 포트 provider 기본값이 `UnimplementedError`를 던지도록 설계(D-1)되어 있어, 모든 테스트가 override하면 `port_providers.dart`의 throw 줄이 실행되지 않아 "바뀌거나 새로 생긴 `lib/application/**` 파일 85%" 게이트에서 해당 파일이 기준 미달일 수 있습니다. — Severity: minor — Class: optional — Required fix: plan.md M2에 "override 없이 읽으면 `UnimplementedError`가 난다"는 테스트를 명시하거나 커버리지 게이트에서 해당 파일 취급을 명시.

D12. CHARACTERIZATION-UNTRACED — acceptance.md:L30-L34, plan.md:L52 — SPEC-UI-001이 의존하는 `game_page_characterization_test.dart`(Restart 즉시 재시작 고정)는 어떤 REQ/AC에도 연결되어 있지 않고 AC-12(`flutter test` 통과)로만 간접 보장됩니다. — Severity: minor — Class: optional — Required fix: AC-ARCH-04~07 묶음에 "Given turnCount 3인 playing 상태, When GamePage에서 Restart 탭, Then 대화상자 없이 turnCount 0"을 AC로 추가하고 REQ-ARCH-016 또는 새 [EXISTING] REQ로 추적.

## Regression Check (Iteration 2+ only)

해당 없음 (iteration 1).

## Recommendation

판정: FAIL. Must-pass 7개는 모두 통과했지만 집계 점수 0.72가 Tier M 기준 0.80에 못 미치고, blocking 결함 7건(D1-D7)이 있습니다. manager-spec이 고칠 항목은 다음과 같습니다.

1. acceptance.md:L9 (D1) — AC-ARCH-01 명령을 표 밖 code block으로 옮기고 `grep -rnE "import .*infrastructure/" lib/application lib/presentation`로 단순화. spec-compact.md:L26과 같은 문자열로 통일. 리팩토링 전 트리에서 이 명령이 0이 아닌 줄을 출력하는지 M1에서 기록하도록 plan.md M1/§C에 한 줄 추가.
2. acceptance.md:L19 (D2) — AC-ARCH-11 명령을 code block으로 옮기고 pathspec을 `--diff-filter=M -- test/`로 넓힐 것.
3. spec.md:L56 + acceptance.md (D3) — 설정 JSON fixture AC 추가 (키 집합과 기본값).
4. spec.md:L68 + acceptance.md:L16 (D4) — REQ-ARCH-010에 "after the new settings have been persisted" 추가, AC-08에 `save` → resync 순서 검증 추가.
5. acceptance.md (D5) — REQ-ARCH-002/003 전용 AC 추가. REQ-ARCH-003의 "the only code"를 "the only code under `lib/`"로 범위 지정.
6. acceptance.md:L18 (D6) — 생명주기 리스너 suspend/resume AC 추가.
7. acceptance.md:L15 + spec.md:L64 (D7) — AC-07에 오디오 error 분기 추가, REQ-009 "persist" 명확화.
8. 선택 항목 D8-D12는 오케스트레이터 판단에 맡기며, 이것만으로 FAIL 사유가 되지는 않습니다. 다만 D8(정확한 기대 문구)과 D10(초기값 명시)은 수정 비용이 거의 없습니다.

AC 추가 후에도 Tier M 상한(REQ 16, AC 16)을 넘지 않습니다. 현재 REQ 16개는 상한에 도달해 있으므로, D5/D7 수정은 새 REQ를 만들지 말고 기존 REQ 문구 수정으로 처리해야 합니다.

검증 근거 (이번 감사에서 실제 실행):
- `/usr/bin/grep -rnE "import .*(infrastructure/\|\.\./infrastructure)" lib/application lib/presentation | wc -l` → `0`
- `/usr/bin/grep -rnE "import .*(infrastructure/|\.\./infrastructure)" lib/application lib/presentation | wc -l` → `8`
- `grep -rn "\[NEEDS CLARIFICATION" .moai/specs/SPEC-ARCH-001/` → 출력 없음, exit 1
- `grep -c syscall .moai/specs/SPEC-ARCH-001/*.md` → 모든 파일 0
- `grep '^status:' .moai/specs/SPEC-UI-001/spec.md` → `status: draft`
- `find test -name '*_test.dart' | wc -l` 상당 목록 → 기존 테스트 11개 확인 (AC-11의 "기존 11개 파일"과 일치)
- spec.md §B의 줄 번호 근거(`game_session_notifier.dart:8-9, :22, :30, :53, :68-82`, `menu_page.dart:5-8, :21, :40-50, :54-66`, `scores_page.dart:3, :10, :20`, `game_lifecycle_listener.dart:7, :36`, `main.dart:4, :33, :44-47`) 실제 코드와 모두 일치.
