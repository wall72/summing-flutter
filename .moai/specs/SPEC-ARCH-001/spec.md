---
id: SPEC-ARCH-001
title: "application/presentation 계층의 infrastructure 의존 역전 (포트 도입)"
version: "0.2.0"
status: completed
created: 2026-10-15
updated: 2026-10-16
author: Cliff W. Lee
priority: P1
phase: "v1.1.0 target"
module: "lib/application, lib/presentation, lib/infrastructure"
lifecycle: spec-anchored
tags: "architecture, dependency-inversion, riverpod, refactor, characterization"
tier: M
related_specs: [SPEC-UI-001]
---

# SPEC-ARCH-001: application/presentation 계층의 infrastructure 의존 역전

## HISTORY

| 버전 | 날짜 | 작성자 | 변경 내용 |
|------|------|--------|-----------|
| 0.1.0 | 2026-10-15 | Cliff W. Lee | 최초 작성 (plan-phase, 사용자 인터뷰 4문항 + 확인 3문항 반영) |
| 0.2.0 | 2026-10-15 | Cliff W. Lee | plan-audit 1차 FAIL(0.72) 반영: REQ-ARCH-003 범위를 `lib/`로 한정, REQ-ARCH-009 "persist" 의미 명확화, REQ-ARCH-010에 저장→resync 순서 명시, REQ-ARCH-016에 동작 고정 테스트 포함, REQ 문서 순서 정렬. AC 12개 → 16개, 모든 셸 명령을 표 밖 코드 블록으로 이동 |

## §A 개요

### 배경

Summing의 계층 규칙은 `presentation → application → domain`이지만, 현재 코드는 application과 presentation이 infrastructure의 구체 provider와 구체 타입을 직접 가져옵니다. 이 때문에 위젯·애플리케이션 테스트가 shared_preferences와 audioplayers 플러그인 동작에 묶여 있고, 후속 UI 개편(SPEC-UI-001)의 위젯 테스트를 결정적으로 작성하기 어렵습니다.

### 목표

- application과 presentation이 infrastructure 대신 application 계층이 소유한 추상 포트에만 의존하도록 바꿉니다.
- 사용자 입장에서 보이는 동작, 저장 키·저장 형식·`schemaVersion`은 그대로 유지합니다.
- 리팩토링 전에 현재 동작을 고정하는 테스트를 먼저 작성합니다.
- 이 SPEC은 SPEC-UI-001보다 먼저 완료되어야 합니다 (UI-001이 이 SPEC의 테스트 seam을 사용).

## §B 현재 상태 (근거)

| 위반 지점 | 근거 |
|---|---|
| notifier가 오디오·저장 provider를 직접 import | `lib/application/game_session_notifier.dart:8-9`, 사용처 `:22`, `:30`, `:53`, `:68-82` |
| 메뉴가 provider와 구체 타입 `AppSettings`, `LocalPersistence` 사용 | `lib/presentation/menu/menu_page.dart:5-8`, `:21`, `:40-50`, `:54-66` |
| 점수판이 저장 provider 직접 사용 | `lib/presentation/scores/scores_page.dart:3`, `:10`, `:20` |
| 생명주기 리스너가 오디오 provider 직접 사용 | `lib/presentation/common/game_lifecycle_listener.dart:7`, `:36` |
| composition root (허용 대상) | `lib/main.dart:4`, `:33`, `:44-47` |
| BGM resync가 저장된 설정을 다시 읽음 (저장 → resync 순서 계약) | `lib/infrastructure/audio/game_audio_service.dart:57-62`, 현재 호출 순서 `lib/presentation/menu/menu_page.dart:43-48` |

plan 단계 실측: `grep -rnE "import .*infrastructure/" lib/application lib/presentation`가 기준 커밋 `6a695b2`에서 8줄을 출력합니다 (acceptance.md AC-ARCH-01).

## §C 요구사항 (GEARS)

### [DELTA] Module 1 — 계층 경계와 포트

- **REQ-ARCH-001** [MODIFY] The `lib/application/` and `lib/presentation/` libraries shall not import any library under `lib/infrastructure/`, whether by package import or relative import.
- **REQ-ARCH-002** [NEW] The application layer shall define abstract port interfaces for game-save persistence, high-score persistence, settings persistence, and game audio.
- **REQ-ARCH-003** [NEW] The infrastructure layer shall implement every application port, and within `lib/` the composition root (`lib/main.dart` together with one infrastructure-owned override list) shall be the only code that binds ports to implementations; test code under `test/` may bind fakes as permitted by REQ-ARCH-013.
- **REQ-ARCH-004** [MODIFY] The `AppSettings` value type shall be owned by the application layer, and its JSON shape (exactly the keys `musicOn` and `soundOn`, each defaulting to `true` when absent) shall stay unchanged.

### [DELTA] Module 2 — 게임 세션 (GameSessionNotifier)

- **REQ-ARCH-005** [MODIFY] The `GameSessionNotifier` shall access persistence and audio only through the application port providers.
- **REQ-ARCH-006** [EXISTING] When a placement succeeds, the `GameSessionNotifier` shall request the tap sound (non-match) or the match sound (match) before awaiting any persistence operation.
- **REQ-ARCH-007** [EXISTING] When a placement leaves the run in `complete`, the `GameSessionNotifier` shall record the turn count as a high score and clear the saved game; when a placement leaves the run in `gameOver`, the `GameSessionNotifier` shall clear the saved game without recording a score.
- **REQ-ARCH-008** [EXISTING] While the run is in `playing`, the `GameSessionNotifier` shall save the new state after every successful placement.
- **REQ-ARCH-009** [EXISTING] When the audio port has not resolved or has failed, the `GameSessionNotifier` shall still apply the placement and perform the persistence step that REQ-ARCH-007 or REQ-ARCH-008 requires for the resulting phase, without propagating an audio error to the caller.

### [DELTA] Module 3 — 설정과 조회 (메뉴·점수판·생명주기)

- **REQ-ARCH-010** [MODIFY] When the user changes a setting, the application-layer settings controller shall persist the new settings, and when the music setting changes, the settings controller shall request a BGM resync through the audio port only after the new settings have been persisted.
- **REQ-ARCH-011** [MODIFY] When the menu is shown or the user returns from the game page, the menu shall read resume availability and the saved turn count through an application-layer query.
- **REQ-ARCH-012** [MODIFY] The scores page shall read high scores through an application-layer query, and the lifecycle listener shall reach audio suspend and resume through the audio port.

### [DELTA] Module 4 — 테스트 seam

- **REQ-ARCH-013** [NEW] Where a test overrides the port providers with fake implementations, the application and presentation layers shall run without the shared_preferences or audioplayers plugins.

### [DELTA] Module 5 — 호환성 불변식

- **REQ-ARCH-014** [EXISTING] The refactor shall not change the shared_preferences keys (`summing_settings`, `summing_savegame`, `summing_highscores`), the saved-game JSON format, or `SaveGameCodec.currentSchemaVersion` (= 1).
- **REQ-ARCH-015** [EXISTING] The refactor shall not modify any file under `lib/domain/` or `test/domain/`.
- **REQ-ARCH-016** [EXISTING] Every existing test's `expect` assertions shall pass unchanged (only setup code such as provider overrides and imports may change), and the user-visible behavior fixed by the milestone-1 characterization tests, including Restart starting a new run immediately, shall stay unchanged within this SPEC.

## §D 제약

- 새 패키지 의존성을 추가하지 않습니다 (`pubspec.yaml`의 `dependencies`, `dev_dependencies` 변경 없음).
- 기존 상태 관리(`flutter_riverpod ^2.6.1`)를 그대로 씁니다.
- 검증 명령: `flutter analyze && flutter test` (`analysis_options.yaml`의 `prefer_const_constructors`, `prefer_final_fields`, `avoid_print` 포함).
- 코드 주석은 한국어(`code_comments: ko`)로 작성합니다.

## §E 변경 대상 파일

- [NEW] application 계층 포트 정의, 포트 provider, `AppSettings` 소유 위치, 메뉴·점수판·설정용 조회/컨트롤러
- [NEW] infrastructure 소유 override 목록 (composition root 보조)
- [MODIFY] `lib/application/game_session_notifier.dart`, `lib/application/application.dart`
- [MODIFY] `lib/presentation/menu/menu_page.dart`, `lib/presentation/scores/scores_page.dart`, `lib/presentation/common/game_lifecycle_listener.dart`
- [MODIFY] `lib/main.dart` (composition root)
- [MODIFY] `lib/infrastructure/persistence/{game_save_store,high_scores_store,settings_store,app_settings}.dart`, `lib/infrastructure/audio/game_audio_service.dart`, `lib/infrastructure/infrastructure.dart`
- [MODIFY] 기존 테스트 3개의 셋업: `test/widget_test.dart`, `test/presentation/common/game_lifecycle_listener_test.dart`, `test/application/game_session_notifier_persistence_test.dart`
- [EXISTING] `lib/domain/**`, `lib/infrastructure/persistence/persistence_keys.dart`, `lib/infrastructure/persistence/save_game_codec.dart` (변경 금지)

구체 파일명과 구조는 `plan.md` §E, §F에 정리했습니다.

## §F 인수 기준

`acceptance.md`의 AC-ARCH-01 ~ AC-ARCH-16과 엣지 케이스를 따릅니다.

## §G Exclusions (What NOT to Build)

이 SPEC의 범위(out of scope)에서 제외하는 항목입니다.

### Out of Scope — UI·연출

- 화면 디자인, 테마, 색상, 반응형 레이아웃, 애니메이션 변경 (SPEC-UI-001 범위)
- 재시작 확인 대화상자 (SPEC-UI-001 범위. 이 SPEC은 현재의 즉시 재시작 동작을 고정만 함)

### Out of Scope — 게임 규칙과 데이터

- `lib/domain/**`의 규칙·타입 변경
- 저장 키, 저장 JSON 형식, `schemaVersion`, 점수 보관 정책(상위 5개) 변경
- `AppSettings`에 새 필드 추가

### Out of Scope — 인프라와 도구

- 새 패키지 도입 (go_router, get_it 등), 상태 관리 교체
- 난수 생성기 주입 구조 변경
- CI 워크플로, 앱 식별자, 방향 정책, 오디오 변환 스크립트

## §H Cross-References

- `.moai/project/product.md` — 알려진 개선 지점 (계층 의존)
- `.moai/project/structure.md` — 계층 의존 관계 (sync 단계에서 갱신 대상)
- `.moai/specs/SPEC-UI-001/` — 이 SPEC에 의존하는 후속 SPEC
- `.moai/specs/SPEC-ARCH-001/interview.md` — 사용자 결정 기록
- `.moai/reports/plan-audit/SPEC-ARCH-001-review-1.md` — 1차 감사 결과 (0.2.0에서 반영)
