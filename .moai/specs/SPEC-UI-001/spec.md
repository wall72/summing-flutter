---
id: SPEC-UI-001
title: "파스텔 디자인 시스템·반응형 레이아웃·연출 효과 UI 개편"
version: "0.3.2"
status: draft
created: 2026-10-15
updated: 2026-10-15
author: Cliff W. Lee
priority: P1
phase: "v1.1.0 target"
module: "lib/presentation, lib/main.dart"
lifecycle: spec-anchored
tags: "ui, theme, responsive, animation, accessibility, pastel"
tier: L
depends_on: [SPEC-ARCH-001]
---

# SPEC-UI-001: 파스텔 디자인 시스템·반응형 레이아웃·연출 효과 UI 개편

## HISTORY

| 버전 | 날짜 | 작성자 | 변경 내용 |
|------|------|--------|-----------|
| 0.1.0 | 2026-10-15 | Cliff W. Lee | 최초 작성 (plan-phase, 사용자 인터뷰 4문항 + 확인 3문항 반영) |
| 0.2.0 | 2026-10-15 | Cliff W. Lee | plan-audit 1차 FAIL(0.70) 반영: 텍스트 버튼 전경색·셀 외곽선 토큰 추가, 셀 크기 계산에 간격 포함(compact 여백 12→8), 매치 분류를 0개 이상 소거로 수정(REQ-UI-014), REQ-UI-001/003/009/020 문구 구체화, REQ-UI-023을 맨 끝으로 이동. AC 19개 → 24개, 모든 셸 명령을 표 밖 코드 블록으로 이동 |
| 0.3.0 | 2026-10-15 | Cliff W. Lee | plan-audit 2차 FAIL(0.84) 반영: 사용자 결정에 따라 가로 저높이 화면 규칙 추가(REQ-UI-024, AC-UI-25), Material 기본 색 역할 전체를 토큰에 매핑(tonal 버튼, CircleAvatar, Switch, SnackBar, 시트, 진행 표시기), 디자인 토큰 소스 정의(§D), 보드 프레임 안쪽 여백 2·반경 8로 정리(compact 여백 8→6), AC-UI-14/15/20 판정 강화, AC-UI-03/04 높이 명시. REQ 23개 → 24개, AC 24개 → 25개 |
| 0.3.1 | 2026-10-15 | Cliff W. Lee | plan-audit 3차 FAIL(0.88, D23 차단) 반영, 사용자 승인으로 4차 감사(D23/D24 범위): 저높이 가로 패널에서 큐 `Next:` 라벨을 칸 위 별도 줄로 옮기고 폭·높이 양축 검산(480·531·568×320, 740×360), AC-UI-06에 480×320 추가, 큐 이동 커브 easeOutCubic 명시. 선택 결함: 큐 첫 칸 외곽선 토큰(queueHeadOutline), 상태 레이어 대비 쌍, AC-UI-25 제목 검사를 기존 AC 문구에 추가. REQ·AC 개수 변경 없음(24 / 25) |
| 0.3.2 | 2026-10-15 | Cliff W. Lee | plan-audit 4차 FAIL(0.90, D28 차단) 반영, 사용자 결정에 따라 마지막 수정(오케스트레이터가 diff와 lint로 확인, 5차 감사 없음): 시간을 지정한 `pump` 앞에 시작 프레임 `pump()`를 넣음(AC-UI-15, 20), 같은 프레임 규칙을 AC-UI-08~14, 21, 24에 반영. 칸 옆 라벨의 넘침 범위를 480~561(여백 6 포함 시 480~573)로 바로잡음(0.3.1 행의 480·531은 검산 뷰포트 목록). 저높이 사이드 패널 안쪽 여백 6(상한 8) 명시. 상호 참조에 3·4차 감사 추가. REQ·AC 개수 변경 없음(24 / 25) |

## §A 개요

### 배경

현재 화면은 teal 시드 기본 Material 3 테마(`lib/main.dart:22-28`), 하드코딩 회색 보드(`lib/presentation/game/widgets/board_grid.dart:25-27`), 애니메이션 없는 셀, 확인 없이 진행 중인 판을 덮어쓰는 Restart(`lib/presentation/game/game_page.dart:35-38`)로 이루어져 있습니다. 화면 폭에 따른 배치 변화도 없습니다(`game_page.dart:54`의 `maxWidth 520` 고정).

### 목표

- 파스텔·소프트 캐주얼 스타일의 디자인 시스템을 라이트·다크 테마로 적용하고, 숫자와 문구의 대비는 WCAG AA를 지킵니다.
- 휴대폰(세로·가로)·태블릿·데스크톱 폭에 맞춰 배치가 바뀌는 반응형 웹을 만듭니다. android/ios는 같은 코드로 계속 빌드합니다.
- 배치·매치 애니메이션, 화면 전환, 진행 중 재시작 확인 같은 화면 연출만 추가합니다. 규칙과 저장 형식은 바꾸지 않습니다.

### 확정된 결정 (interview.md)

- UI 문구는 영어를 유지하고 l10n 프레임워크는 도입하지 않습니다.
- Nunito Regular, ExtraBold(OFL)를 asset으로 번들하고 새 패키지 의존성은 추가하지 않습니다.
- 테마는 시스템 밝기만 따르며(`ThemeMode.system`) 앱 내 토글은 두지 않습니다. `AppSettings` JSON은 바뀌지 않습니다.
- 재시작 확인은 `phase == playing`이면 턴 수와 관계없이 표시하고, Quit는 확인하지 않습니다.
- 가로로 눕힌 휴대폰(높이 < 480)에서도 보드가 플레이 가능한 크기가 되도록 전용 배치 규칙을 둡니다 (2차 감사 후 사용자 결정).

### 도메인 규칙 확인 (연출 판정의 근거)

매치가 일어나면 도메인은 놓은 숫자를 기록하지 않고 8방향 이웃 칸을 모두 비웁니다(`lib/domain/summing_rules.dart:37-42`, `lib/domain/board.dart:59-66`). 따라서 한 번의 매치로 지워지는 숫자 칸은 0개부터 8개까지입니다. 이웃에 숫자가 하나도 없는 칸에 0을 놓으면 합의 일의 자리가 0이라 매치가 되지만 보드는 바뀌지 않고 턴 수와 큐만 바뀝니다.

## §B 선행 조건

- SPEC-ARCH-001이 `status: completed`일 것 (depends_on 판정 기준. `implemented`는 충족으로 보지 않음).
- SPEC-ARCH-001이 만든 `test/presentation/game/game_page_characterization_test.dart`의 "Restart 즉시 재시작" 단언(AC-ARCH-16)은 이 SPEC M1에서 의도적으로 바뀝니다.

## §C 요구사항 (GEARS)

### [DELTA] Module 1 — 디자인 시스템과 테마

- **REQ-UI-001** [NEW] The app shall take its colors, corner radii, spacing, font sizes, and motion durations from the design-token source defined in §D, and presentation code outside that source shall not hard-code those values.
- **REQ-UI-002** [MODIFY] The app shall follow the platform brightness (`ThemeMode.system`) to choose between the light and dark pastel themes, and the app shall not provide an in-app theme toggle.
- **REQ-UI-003** [NEW] The board, the queue, the end overlay, the dialogs, the menu, the scores list, the bottom sheet, the snack bar, and every button shall render digits and text at a contrast ratio of at least 4.5:1 against their background in every enabled visual state in both themes, and every color role a Material widget in scope reads from the theme shall be mapped to a design token.
- **REQ-UI-004** [MODIFY] Presentation code outside the design-token source defined in §D shall not contain color literals (`Color(0x…)` or `Colors.*` other than `Colors.transparent`).

### [DELTA] Module 2 — 반응형 레이아웃

- **REQ-UI-005** [MODIFY] While the window width is below 600 logical px and the low-height rule of REQ-UI-024 does not apply (compact), the game page shall use a single column of header (turn count), queue row, and board, with Restart and Quit in the top bar.
- **REQ-UI-006** [NEW] While the window width is at least 600 and below 840 logical px and the window height is at least 480 logical px (medium), the game page shall use a single column with the board side capped at 560 logical px.
- **REQ-UI-007** [NEW] While the window width is at least 840 logical px and the window height is at least 480 logical px (expanded), the game page shall show a two-pane layout: the board, plus a side panel holding the turn count, the queue, Restart, and Quit.
- **REQ-UI-008** [MODIFY] The board shall stay square and fully visible at min(available width, available height), with no layout overflow on the game, menu, and scores pages, at every viewport from 320×568 to 1920×1080 logical px, including landscape phone sizes.
- **REQ-UI-009** [NEW] While the viewport width is between 360 and 599 logical px and the viewport height is at least 640 logical px, each rendered board cell, excluding the inter-cell gap, shall be at least 36 logical px on each side.

### [DELTA] Module 3 — 재시작 확인 흐름

- **REQ-UI-010** [NEW] While the run is in `playing`, when the user activates Restart, the game page shall show a confirmation dialog before any change to the game state or the saved game.
- **REQ-UI-011** [NEW] When the user confirms the dialog, the game page shall start a new run; when the user cancels or dismisses the dialog (Cancel, barrier tap, Escape, or system back), the game page shall leave the game state and the saved game unchanged.
- **REQ-UI-012** [EXISTING] While the run is in `complete` or `gameOver`, Restart and "Play again" shall start a new run without a dialog.

### [DELTA] Module 4 — 연출 효과

- **REQ-UI-013** [NEW] When a placement records a digit, the board shall animate the placed cell (scale and fade in) over the base motion duration.
- **REQ-UI-014** [NEW] When a placement matches and clears one or more filled neighbor cells, the board shall animate exactly those cleared cells (accent flash, then fade out), and when a match clears no cell, the board shall run no per-cell animation; the cleared set is derived by comparing the previous board with the new board.
- **REQ-UI-015** [NEW] When the queue advances, the queue row shall animate the shift toward the head slot.
- **REQ-UI-016** [NEW] When the board changes in a way that is not exactly one placement (new run, restart, resume), the board shall not run per-cell placement or match animations.
- **REQ-UI-017** [MODIFY] When the user navigates between the menu, game, and scores pages, or when the end overlay appears, the app shall use the token-defined transition (fade with scale, the page or emphasized duration, and the easeOutCubic curve).
- **REQ-UI-018** [NEW] Where the platform requests reduced motion (`MediaQuery.disableAnimations`), every presentation animation shall run with zero duration.
- **REQ-UI-019** [NEW] Animations shall not delay or block game-state updates, persistence, or further cell taps, and no animation shall repeat indefinitely.

### [DELTA] Module 5 — 접근성·호환성·문구와 글꼴

- **REQ-UI-020** [EXISTING] Board cells shall keep their current semantics (the digit or "Empty cell" label, and a button role only while tappable), and the board shall show a keyboard focus indicator with at least 3:1 contrast against both the focused cell's fill and the board frame.
- **REQ-UI-021** [EXISTING] Where the app runs on web, the first-gesture audio-unlock listener shall stay active.
- **REQ-UI-022** [EXISTING] The UI overhaul shall not change domain files, the shared_preferences keys, the saved-game format, or `SaveGameCodec.currentSchemaVersion` (= 1).
- **REQ-UI-023** [NEW] The app shall render UI text with the bundled Nunito family (Regular 400 and ExtraBold 800) and shall keep all UI strings in English.
- **REQ-UI-024** [NEW] While the window height is below 480 logical px and the window width is at least 480 logical px (low-height landscape), the game page shall show a two-pane layout without a top bar (board on the left, a side panel on the right holding the title, turn count, queue, Restart, and Quit), and the board side shall be at least 304 logical px at 568×320 and at least 344 logical px at 740×360.

## §D 제약

- **디자인 토큰 소스(design-token source)**: `lib/presentation/theme/`와 `lib/presentation/layout/` 두 폴더 아래의 파일을 뜻합니다. REQ-UI-001, REQ-UI-004와 AC-UI-16, AC-UI-23은 모두 이 정의를 씁니다.
- 새 패키지 의존성 없음. `pubspec.yaml`은 `flutter:` 아래 `fonts:` 섹션 추가만 허용합니다.
- 폭 브레이크포인트는 Material 3 window size class(600 / 840), 높이 기준은 Material 3 height class의 compact 경계(480)를 씁니다.
- 비활성(disabled) 컨트롤은 WCAG 대비 기준의 예외로 보고 Material 기본 비활성 색을 씁니다 (`design.md` §1.2).
- 검증 명령: `flutter analyze && flutter test`.
- 코드 주석은 한국어(`code_comments: ko`)로 작성합니다.
- 디자인 수치(색상, 반경, 간격, 모션)는 `design.md`, 근거와 측정값은 `research.md`에 있습니다.

## §E 변경 대상 파일

- [NEW] 디자인 토큰, 테마(Material ColorScheme 역할 매핑과 컴포넌트 테마 포함), 모션 정의, 브레이크포인트, 페이지 전환, 재시작 확인 대화상자, 종료 오버레이(기존 `_EndOverlay` 분리), 게임 사이드 패널(expanded·저높이 가로 공용), 보드 셀 위젯, 웹 첫 제스처 오디오 해제 위젯(현재 `lib/main.dart:40-50`의 Listener 분리)
- [NEW] `assets/fonts/` 아래 Nunito 2개 굵기와 OFL 라이선스 파일
- [MODIFY] `lib/main.dart`, `lib/presentation/menu/menu_page.dart`, `lib/presentation/game/game_page.dart`, `lib/presentation/game/widgets/board_grid.dart`, `lib/presentation/game/widgets/next_queue_row.dart`, `lib/presentation/scores/scores_page.dart`, `lib/presentation/common/how_to_play_sheet.dart`, `pubspec.yaml`(fonts만), `web/manifest.json`(색상만)
- [MODIFY] SPEC-ARCH-001의 `test/presentation/game/game_page_characterization_test.dart` (Restart 흐름 단언을 의도적으로 변경)
- [EXISTING] `lib/domain/**`, `lib/application/**`의 동작, `persistence_keys.dart`, `save_game_codec.dart`

구체 파일명은 `plan.md` §F를 따릅니다.

## §F 인수 기준

`acceptance.md`의 AC-UI-01 ~ AC-UI-25와 엣지 케이스를 따릅니다.

## §G Exclusions (What NOT to Build)

이 SPEC의 범위(out of scope)에서 제외하는 항목입니다.

### Out of Scope — 게임 규칙과 모드

- 새 게임 모드, 규칙 변경, 난이도, `lib/domain/**` 수정
- 힌트, 되돌리기(undo), 통계 화면

### Out of Scope — 데이터와 설정

- 저장 키, 저장 형식, `schemaVersion`, 점수 보관 정책(상위 5개) 변경
- 앱 내 테마 토글, `AppSettings` 필드 추가
- 점수판에 날짜·통계 추가

### Out of Scope — 플랫폼과 인프라

- 온라인 기능, 새 플랫폼 러너, 웹/iOS 방향 정책 정렬(manifest의 `portrait-primary` 변경 포함), 앱 식별자 확정
- CI 워크플로, 오디오 변환 스크립트, 오디오 에셋 교체, 햅틱
- 폭과 높이가 모두 480 미만인 창의 플레이 가능 크기 보장 (넘침 없음만 요구)

### Out of Scope — 의존성과 테스트

- go_router, animations, google_fonts, intl 등 새 패키지와 l10n
- 골든 테스트 (플랫폼마다 폰트 렌더링이 달라 결과가 흔들림)

## §H Cross-References

- `.moai/specs/SPEC-ARCH-001/` — 선행 SPEC
- `design.md` — 토큰, ColorScheme 매핑, 레이아웃, 모션, 컴포넌트 사양
- `research.md` — 코드 근거, 대비 측정, 보드 크기 계산, API 확인, 대안 검토
- `interview.md` — 사용자 결정
- `.moai/reports/plan-audit/SPEC-UI-001-review-1.md`, `SPEC-UI-001-review-2.md`, `SPEC-UI-001-review-3.md`, `SPEC-UI-001-review-4.md` — 1~4차 감사 결과
