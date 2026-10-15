# SPEC Review Report: SPEC-ARCH-001
Iteration: 2/3
Verdict: PASS
Overall Score: 0.91 (Tier M PASS 기준 0.80 이상, 1차 0.72 대비 상승 — STOP 신호 없음)

Reasoning context ignored per M1 Context Isolation. 감사 입력: Tier M 3종(spec.md 0.2.0, plan.md, acceptance.md) + 참고용 spec-compact.md, progress.md, 그리고 AC 명령·동작 주장 검증을 위한 `lib/`, `test/` 실제 코드와 git 기준 커밋 `6a695b2`.

범위: Retry Loop Contract에 따라 1차 결함 D1-D12의 해결 여부(회귀 검사)를 중심으로 감사하고, 수정으로 새로 생긴 표면(AC-13~16, 수정된 REQ-003/009/010/016, AC 명령 4종)을 추가로 확인했습니다. 교차 모델 감사: 1차에서 codex(바이너리 없음)·glm(API 키 없음) 모두 `inconclusive`로 확인되어 이번 판정도 Claude 단독 감사입니다.

## Must-Pass Results

- [PASS] MP-1 REQ 번호 일관성: REQ-ARCH-001 ~ 016 16개가 문서 순서대로 연속 배치됨 (spec.md:L57, L58, L59, L60, L64-L68, L72-L74, L78, L82-L84). 빠짐·중복 없음, 3자리 패딩 일관. 1차 D9(배치 순서) 해소.
- [PASS] MP-2 GEARS 형식 (판정 레이어: spec.md §C 요구사항 레이어만. acceptance.md의 Given-When-Then AC는 검증 레이어라 채점 대상 아님): 001·014·015 Unwanted `shall not` (L57, L82, L83), 002·003·004·005·012·016 Ubiquitous `shall` (L58-L60, L64, L74, L84), 006·007·009·010·011 Event-driven `When ..., the ... shall` (L65, L66, L68, L72, L73), 008 State-driven `While` (L67), 013 Where (L78). 수정된 REQ-010은 "only after the new settings have been persisted"(L72)를 포함한 복합 Event-driven 절로 형식 적합.
- [PASS] MP-3 YAML frontmatter: 12개 필드 모두 존재·타입 정상 — `id`(L2), `title` 따옴표(L3), `version: "0.2.0"`(L4), `status: draft`(L5), `created`/`updated: 2026-10-15`(L6-L7), `author`(L8), `priority: P1`(L9), `phase: "v1.1.0 target"`(L10, 금지된 단계명 아님), `module`(L11), `lifecycle: spec-anchored`(L12), `tags` 쉼표 문자열(L13). 거부 alias 없음. 선택 필드 `tier: M`(L14).
- [N/A] MP-4 언어 중립성: Flutter/Dart 단일 언어 프로젝트 SPEC. 자동 통과.
- [PASS] MP-5 D7 교차 SPEC: 참조 SPEC은 SPEC-UI-001 하나, `status: draft`(retired/superseded/archived 아님). UI-001 쪽 참조(`AC-ARCH-16`, `test/support/test_overrides.dart`, `game_page_characterization_test.dart`의 의도적 변경, `AC-UI-08 ~ 11`)가 이번 재번호 후의 ARCH-001 acceptance.md §D.2(L133-L137), plan.md D-7(L47)과 일치 (UI-001 spec.md:L53, plan.md:L9, L15, acceptance.md:L188-L189). BLOCKING 없음.
- [PASS] MP-6 D8 교차 플랫폼: 모든 산출물에서 `syscall` 0건. 자동 통과.
- [PASS] MP-7 clarification gate: `grep -rn '\[NEEDS CLARIFICATION' .moai/specs/SPEC-ARCH-001/` → 출력 없음, exit 1. research.md는 Tier M이라 없음.

## Category Scores (0.0-1.0, rubric-anchored)

| Dimension | Score | Rubric Band | Evidence |
|-----------|-------|-------------|----------|
| Clarity | 0.90 | 0.75-1.0 | REQ-003 범위가 `within lib/`로 한정(spec.md:L59), REQ-009 "persist"가 "persistence step that REQ-ARCH-007 or REQ-ARCH-008 requires"로 명확화(L68), REQ-010 순서 명시(L72). 남은 경미한 모호: AC-08의 "save 완료" 기록 시점(N2), AC-13의 "JSON 문자열을 fromJson으로 읽기"(N3) |
| Completeness | 0.95 | 1.0 근접 | HISTORY(L20-L25, 0.2.0 행 포함), 개요(L27), 근거(L40-L51), REQ(L53-L84), 제약(L86), 변경 파일(L93), AC 포인터(L106), `### Out of Scope — <topic>` 3개 + bullet(L114-L129). 기준선 미실행은 plan.md §B/§C-1(L14, L21)에 HARD 선행 단계로 처리됨 |
| Testability | 0.88 | 0.75-1.0 | 모든 셸 명령이 코드 블록으로 이동했고 실측과 일치: AC-01 → 현재 트리 `8`(acceptance.md:L15-L19), AC-11 → `11`과 `0`/exit 1(L66-L69). AC-09 기대 문구 정확(L56). 감점: AC-11이 삭제·이름 변경된 기존 테스트를 잡지 못함(N1), AC-08 fake 기록 시점 미명시(N2) |
| Traceability | 0.90 | 0.75-1.0 | 추적 표(acceptance.md:L104-L123)상 REQ 16개 모두 직접 AC 보유. REQ-002/003 → AC-14, REQ-004 → AC-13, REQ-012 → AC-10·15, REQ-016 → AC-11·16. REQ-013만 AC-11로 간접 추적(N4) |

집계: (0.90 + 0.95 + 0.88 + 0.90) / 4 = 0.9075 → 0.91. Tier M 기준 0.80 이상.

## Defects Found (structured defect-list)

1차 blocking 결함 D1-D7은 모두 해결되었습니다. 이번 회차에 새로 찾은 항목은 전부 minor / optional이며 판정에 영향을 주지 않습니다 (M6).

N1. AC-11-DELETE-RENAME-GAP — acceptance.md:L64-L69 — 두 번째 명령의 `--diff-filter=M`은 수정(M)된 파일만 보므로, 기존 테스트 파일이 삭제(D)되거나 이름이 바뀐(R, git 2.43은 `diff.renames` 기본 활성) 경우 그 파일의 `expect(` 변경은 검사에서 빠집니다. 첫 명령 `git ls-tree -r --name-only 6a695b2 -- test | wc -l`은 기준 커밋 트리를 세므로 리팩토링 결과와 무관하게 항상 `11`입니다(판별력 없음). "11개 파일의 테스트가 모두 통과"라는 Then 문구가 존재를 전제하긴 하지만 기계적으로 확인하는 명령은 없습니다. — Severity: minor — Class: optional — Required fix: 명령 하나 추가 — `git diff 6a695b2 --diff-filter=DR --name-only -- test/` 출력 0줄. (선택) 첫 명령은 기준선 확인용임을 문구에 명시.

N2. AC-08-RECORD-TIMING — acceptance.md:L52 — "기록이 정확히 `save(...)` 완료 → `applySettingsAndSyncBgm` 1회 순서"의 "완료"를 검증하려면 fake 설정 저장소가 `save` 호출 시점이 아니라 비동기 완료 시점(예: `await Future<void>.delayed(Duration.zero)` 이후)에 기록해야 합니다. 호출 즉시 기록하는 fake면 `save`를 기다리지 않는 컨트롤러도 이 AC를 통과합니다. — Severity: minor — Class: optional — Required fix: Given에 "fake 설정 저장소는 비동기 간격 뒤에 `save` 완료를 기록한다"를 추가하거나, plan.md D-7(L47)에 같은 fake 구현 규칙을 적을 것.

N3. AC-13-FROMJSON-INPUT — acceptance.md:L81 — "JSON 문자열 `{...}`, When `AppSettings.fromJson`으로 읽은 뒤"라고 되어 있지만 실제 시그니처는 `factory AppSettings.fromJson(Map<String, dynamic> json)`입니다(`lib/infrastructure/persistence/app_settings.dart:29`). `jsonDecode` 단계가 암묵적입니다. — Severity: minor — Class: optional — Required fix: "`jsonDecode`한 맵을 `AppSettings.fromJson`으로 읽은 뒤"로 문구 수정.

N4. REQ-013-INDIRECT — acceptance.md:L62-L69, L117 — REQ-ARCH-013(fake override 시 shared_preferences·audioplayers 플러그인 없이 동작)은 AC-11에만 추적되는데, AC-11은 파일 수와 `expect` diff만 검사하므로 "플러그인 없이"를 판별하지 못합니다. AC-04~10, 15, 16의 Given이 fake 포트를 쓰므로 간접 증거는 있습니다. 현재 `test/`에는 `setMockInitialValues` 사용이 6건 있습니다. — Severity: minor — Class: optional — Required fix: AC-11에 판별 명령 추가 — 예: M3 이후 `grep -rln "setMockInitialValues" test/application test/presentation test/widget_test.dart` 출력 0줄 (infrastructure 테스트는 플러그인 mock이 정당하므로 제외).

N5. REQ-003-MAY — spec.md:L59 — 규범 문장 안에 "test code under `test/` may bind fakes"라는 허용 절이 있습니다. 주 절은 `shall`이라 GEARS 형식 위반은 아니고, 허용 범위를 명확히 하는 역할입니다. — Severity: minor — Class: optional — Required fix: 필요하면 허용 절을 REQ 밖 설명 문장으로 옮길 것. 그대로 두어도 무방.

## Regression Check (Iteration 2+ only)

Defects from previous iteration:
- D1 (AC-01 명령 무의미): RESOLVED — 명령이 표 밖 코드 블록으로 이동하고 단일 패턴 `grep -rnE "import .*infrastructure/" lib/application lib/presentation`로 단순화(acceptance.md:L15-L17). 이번 감사에서 현재 트리 실측 `8`줄(위반 검출 확인). 판별력 확인 단계 추가(L19, plan.md §C-2 L22-L26, progress.md `ac01_discrimination_baseline`). spec-compact.md의 AC 본문은 acceptance.md와 diff 결과 마커 주석 외 동일.
- D2 (AC-11 파이프 깨짐 + 범위 부족): RESOLVED — 코드 블록 이동, 범위를 `git diff 6a695b2 --diff-filter=M -- test/`로 확대(L66-L69). 실측: 첫 명령 `11`, 두 번째 `0`(exit 1). 삭제·이름 변경 경로는 N1(optional)로 남음.
- D3 (REQ-004 JSON 미검증): RESOLVED — AC-ARCH-13 추가(L79-L81): 키 집합 `{musicOn, soundOn}`, 빈 객체 기본값 `true`, `summing_settings` 키 로딩. REQ-004에 키와 기본값 명시(spec.md:L60). 현재 `toJson`/`fromJson`(app_settings.dart:24-34), `PersistenceKeys.settings = 'summing_settings'`와 일치.
- D4 (REQ-010 순서): RESOLVED — REQ-010 "only after the new settings have been persisted"(spec.md:L72), AC-08 공유 호출 기록으로 `save` 완료 → resync 순서 검증(acceptance.md:L52), plan.md D-6(L46)·§B(L17)·§G(L99)·mx_plan(L114). fake 기록 시점 세부는 N2(optional).
- D5 (REQ-002/003 미추적): RESOLVED — AC-ARCH-14 추가(L83-L92): 포트 4개, `lib/` 안 override 위치가 `app_overrides.dart` 하나, `main.dart`의 `appOverrides` 사용, 구현체 4개. REQ-003 범위를 `within lib/`로 한정(spec.md:L59). 명령 4개 모두 plan.md D-1~D-4(L41-L44)의 이름·경로와 일치.
- D6 (생명주기 suspend/resume 미추적): RESOLVED — AC-ARCH-15 추가(L94-L96). 현재 `game_lifecycle_listener.dart:37-47`(inactive는 저장만, paused는 suspend, resumed는 resume)과 일치.
- D7 (REQ-009 실패 분기): RESOLVED — AC-07이 (a) 미해결 Completer와 (b) error 두 경우를 모두 다룸(L46-L48), REQ-009 "persist" 명확화(spec.md:L68). 현재 `game_session_notifier.dart:68`의 `valueOrNull`이 두 경우 모두 null을 반환해 동작 주장과 일치.
- D8 (AC-09 기대 문구): RESOLVED — `Resume Game (3 turns)` / `Resume Game` / `Resume Game (0 turns)` 정확한 문구(L56). `startNewGame`이 turnCount 0 상태를 저장하고(notifier:21-26) Quit 후 메뉴가 다시 읽으므로(menu_page.dart:36-37, 66-68) 세 번째 시나리오가 현재 동작과 일치.
- D9 (REQ 문서 순서): RESOLVED — spec.md:L57-L84 연속 배치.
- D10 (AC-08 초기값): RESOLVED — "처음에 `AppSettings()`(`musicOn: true`, `soundOn: true`)를 반환"(L52).
- D11 (커버리지 throw 줄): RESOLVED — `port_providers_test.dart` 추가(plan.md M2 L70), 품질 게이트에 처리 명시(acceptance.md:L145), 엣지 케이스(L131).
- D12 (동작 고정 테스트 미추적): RESOLVED — AC-ARCH-16 추가(L98-L100), REQ-016에 "including Restart starting a new run immediately" 포함(spec.md:L84). 현재 `game_page.dart`의 AppBar `Restart` → `restartGame()` → `startNewGame()`(저장 1회), 대화상자 없음과 일치.

미해결 결함 없음. 3회 연속 정체 결함 없음.

## Recommendation

판정: PASS (0.91, Tier M 기준 0.80 이상). 근거:

- MP-1: REQ-ARCH-001~016 연속·무중복 (spec.md:L57-L84).
- MP-2: 요구사항 레이어 16개 모두 GEARS 패턴 (위 Must-Pass 항목의 줄 인용).
- MP-3: 12개 필수 필드 존재, 타입 정상 (spec.md:L2-L13).
- MP-4: N/A (Dart 단일 언어). MP-5: SPEC-UI-001 `draft`, 참조 정합. MP-6: `syscall` 0건. MP-7: 마커 0건.
- 1차 blocking 결함 D1-D7과 optional D8-D12 모두 해결, 근거 위 회귀 검사 참조. AC 16개, REQ 16개로 Tier M 상한 이내.

선택 항목 N1-N5는 오케스트레이터 판단에 맡깁니다. 수정 비용이 가장 낮고 효과가 큰 것은 N1(명령 한 줄 추가)과 N2(fake 기록 시점 한 문장)이며, run 단계 위임 프롬프트의 Section B/D에 메모로 넣는 것만으로도 충분합니다.

검증 근거 (이번 감사에서 실제 실행, 트리 = `6a695b2` + 추적되지 않는 `.moai/` 등):
- `grep -rnE "import .*infrastructure/" lib/application lib/presentation | wc -l` → `8`
- `grep -rnE "export .*infrastructure" lib/application lib/presentation` → 출력 없음 (barrel 경유 의존 없음)
- `git ls-tree -r --name-only 6a695b2 -- test | wc -l` → `11` (파일 목록이 AC-11 Given의 분류와 일치)
- `git diff 6a695b2 --diff-filter=M -- test/ | grep -cE "^[-+].*expect\("` → `0`, exit 1
- `grep -rn '\[NEEDS CLARIFICATION' .moai/specs/SPEC-ARCH-001/` → 출력 없음, exit 1
- `grep -c syscall .moai/specs/SPEC-ARCH-001/*.md` → 모든 파일 0
- `grep '^status:' .moai/specs/SPEC-UI-001/spec.md` → `status: draft`
- acceptance.md와 spec-compact.md의 `AC-BODY-START` ~ `AC-BODY-END` 구간 diff → 마커 주석 문구 외 차이 없음
- `grep -nE "^### AC-" acceptance.md | wc -l` → `16`
- spec.md §B 줄 번호 근거와 AC 동작 주장(notifier:21-26, 41, 57-83 / menu_page:36-50, 66-68, 117-121 / scores_page:20-26, 40 / game_lifecycle_listener:36-47 / game_page AppBar Restart·Quit / main:4, 33, 40-50 / game_audio_service:57-62 / persistence_keys / `currentSchemaVersion = 1`) 실제 코드와 일치
