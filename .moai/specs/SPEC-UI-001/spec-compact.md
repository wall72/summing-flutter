# SPEC-UI-001 (compact)

run 단계용 요약본입니다 (spec 0.3.2 기준). 원문은 `spec.md`, `acceptance.md`, 수치는 `design.md`입니다. 선행 조건: SPEC-ARCH-001 `completed`. 디자인 토큰 소스는 `lib/presentation/theme/`와 `lib/presentation/layout/`입니다(`spec.md` §D). 아래 요구사항은 `spec.md` §C에서, AC 본문은 `acceptance.md` §D의 시작·끝 마커 주석 사이 구간에서 그대로 가져왔습니다.

## Requirements (GEARS)

- **REQ-UI-001** [NEW] The app shall take its colors, corner radii, spacing, font sizes, and motion durations from the design-token source defined in §D, and presentation code outside that source shall not hard-code those values.
- **REQ-UI-002** [MODIFY] The app shall follow the platform brightness (`ThemeMode.system`) to choose between the light and dark pastel themes, and the app shall not provide an in-app theme toggle.
- **REQ-UI-003** [NEW] The board, the queue, the end overlay, the dialogs, the menu, the scores list, the bottom sheet, the snack bar, and every button shall render digits and text at a contrast ratio of at least 4.5:1 against their background in every enabled visual state in both themes, and every color role a Material widget in scope reads from the theme shall be mapped to a design token.
- **REQ-UI-004** [MODIFY] Presentation code outside the design-token source defined in §D shall not contain color literals (`Color(0x…)` or `Colors.*` other than `Colors.transparent`).
- **REQ-UI-005** [MODIFY] While the window width is below 600 logical px and the low-height rule of REQ-UI-024 does not apply (compact), the game page shall use a single column of header (turn count), queue row, and board, with Restart and Quit in the top bar.
- **REQ-UI-006** [NEW] While the window width is at least 600 and below 840 logical px and the window height is at least 480 logical px (medium), the game page shall use a single column with the board side capped at 560 logical px.
- **REQ-UI-007** [NEW] While the window width is at least 840 logical px and the window height is at least 480 logical px (expanded), the game page shall show a two-pane layout: the board, plus a side panel holding the turn count, the queue, Restart, and Quit.
- **REQ-UI-008** [MODIFY] The board shall stay square and fully visible at min(available width, available height), with no layout overflow on the game, menu, and scores pages, at every viewport from 320×568 to 1920×1080 logical px, including landscape phone sizes.
- **REQ-UI-009** [NEW] While the viewport width is between 360 and 599 logical px and the viewport height is at least 640 logical px, each rendered board cell, excluding the inter-cell gap, shall be at least 36 logical px on each side.
- **REQ-UI-010** [NEW] While the run is in `playing`, when the user activates Restart, the game page shall show a confirmation dialog before any change to the game state or the saved game.
- **REQ-UI-011** [NEW] When the user confirms the dialog, the game page shall start a new run; when the user cancels or dismisses the dialog (Cancel, barrier tap, Escape, or system back), the game page shall leave the game state and the saved game unchanged.
- **REQ-UI-012** [EXISTING] While the run is in `complete` or `gameOver`, Restart and "Play again" shall start a new run without a dialog.
- **REQ-UI-013** [NEW] When a placement records a digit, the board shall animate the placed cell (scale and fade in) over the base motion duration.
- **REQ-UI-014** [NEW] When a placement matches and clears one or more filled neighbor cells, the board shall animate exactly those cleared cells (accent flash, then fade out), and when a match clears no cell, the board shall run no per-cell animation; the cleared set is derived by comparing the previous board with the new board.
- **REQ-UI-015** [NEW] When the queue advances, the queue row shall animate the shift toward the head slot.
- **REQ-UI-016** [NEW] When the board changes in a way that is not exactly one placement (new run, restart, resume), the board shall not run per-cell placement or match animations.
- **REQ-UI-017** [MODIFY] When the user navigates between the menu, game, and scores pages, or when the end overlay appears, the app shall use the token-defined transition (fade with scale, the page or emphasized duration, and the easeOutCubic curve).
- **REQ-UI-018** [NEW] Where the platform requests reduced motion (`MediaQuery.disableAnimations`), every presentation animation shall run with zero duration.
- **REQ-UI-019** [NEW] Animations shall not delay or block game-state updates, persistence, or further cell taps, and no animation shall repeat indefinitely.
- **REQ-UI-020** [EXISTING] Board cells shall keep their current semantics (the digit or "Empty cell" label, and a button role only while tappable), and the board shall show a keyboard focus indicator with at least 3:1 contrast against both the focused cell's fill and the board frame.
- **REQ-UI-021** [EXISTING] Where the app runs on web, the first-gesture audio-unlock listener shall stay active.
- **REQ-UI-022** [EXISTING] The UI overhaul shall not change domain files, the shared_preferences keys, the saved-game format, or `SaveGameCodec.currentSchemaVersion` (= 1).
- **REQ-UI-023** [NEW] The app shall render UI text with the bundled Nunito family (Regular 400 and ExtraBold 800) and shall keep all UI strings in English.
- **REQ-UI-024** [NEW] While the window height is below 480 logical px and the window width is at least 480 logical px (low-height landscape), the game page shall show a two-pane layout without a top bar (board on the left, a side panel on the right holding the title, turn count, queue, Restart, and Quit), and the board side shall be at least 304 logical px at 568×320 and at least 344 logical px at 740×360.

## Acceptance Criteria (Given/When/Then)

<!-- AC-BODY-START: acceptance.md와 동일하게 유지 -->

### AC-UI-01 (REQ-UI-003, REQ-UI-020)

**Given** `design.md` §1의 토큰과 §1.1의 ColorScheme 매핑, **When** `test/presentation/theme/token_contrast_test.dart`가 `Color.computeLuminance()`로 `(L1+0.05)/(L2+0.05)`를 계산하면, **Then** 아래 텍스트 쌍은 모두 4.5 이상, 비텍스트 쌍은 모두 3.0 이상이다 (라이트·다크 각각). **When** `test/presentation/theme/app_theme_test.dart`가 라이트·다크 `ThemeData.colorScheme`의 각 역할을 읽으면, **Then** `design.md` §1.1 표의 역할마다 지정된 토큰 값과 같다.

| 구분 | 전경 / 배경 |
|---|---|
| 텍스트 | digit / cellFilled, digit / placeHighlight, digit / matchFlash |
| 텍스트 | onSurface / background, onSurface / surfaceContainer |
| 텍스트 | onSurfaceVariant / background, onSurfaceVariant / surfaceContainer |
| 텍스트 | onPrimary / primary, onQueueHead / queueHeadContainer (큐 첫 칸, tonal 버튼, CircleAvatar) |
| 텍스트 | accentText / background, accentText / surfaceContainer |
| 텍스트 | onInverseSurface / inverseSurface, inversePrimary / inverseSurface (SnackBar) |
| 비텍스트 | focus / cellEmpty, focus / cellFilled, focus / surfaceContainer(보드 프레임) |
| 비텍스트 | cellOutline / surfaceContainer, cellOutline / background (칸 외곽선, OutlinedButton 테두리, Switch 꺼짐 테두리, 시트 손잡이) |
| 비텍스트 | Switch 켜짐: thumb / accentText 트랙, accentText 트랙 / background |
| 비텍스트 | Switch 꺼짐: onSurfaceVariant thumb / cellEmpty 트랙 |
| 비텍스트 | 진행 표시기 accentText / background |
| 비텍스트 | 큐 첫 칸 외곽선 queueHeadOutline / background, queueHeadOutline / surfaceContainer, queueHeadOutline / queueHeadContainer |
| 텍스트 (상태 레이어, 전경색 10%를 배경에 덧칠한 색) | accentText / (accentText 10% + background), accentText / (accentText 10% + surfaceContainer), onPrimary / (onPrimary 10% + primary), onQueueHead / (onQueueHead 10% + queueHeadContainer) |

### AC-UI-02 (REQ-UI-003)

**Given** 라이트와 다크 테마 각각에서 다음 화면을 그린 상태 — 알려진 상태의 GamePage, 재시작 확인 대화상자가 열린 GamePage, 종료 오버레이가 보이는 GamePage, 이어하기 버튼이 활성인 MenuPage(저장된 판 있음), SnackBar가 떠 있는 MenuPage, How to Play 시트가 열린 MenuPage, 점수 행이 1개 이상인 ScoresPage — **When** 각 화면에서 `expectLater(tester, meetsGuideline(textContrastGuideline))`를 실행하면, **Then** 모든 경우에 통과한다.

### AC-UI-03 (REQ-UI-005)

**Given** 뷰포트 360×780 (compact), **When** GamePage가 그려지면, **Then** 큐와 보드가 한 열이고 사이드 패널 키(`game.sidePanel`)가 없으며 `Restart`·`Quit`가 상단 바(`AppBar`)에 있다.

### AC-UI-04 (REQ-UI-006)

**Given** 뷰포트 700×1000 (medium), **When** GamePage가 그려지면, **Then** 한 열 배치이고 사이드 패널 키(`game.sidePanel`)가 없으며 보드 한 변이 560 이하이다.

### AC-UI-05 (REQ-UI-007)

**Given** 뷰포트 1280×800 (expanded), **When** GamePage가 그려지면, **Then** 사이드 패널(`game.sidePanel`)에 턴 수, 큐, `Restart`, `Quit`가 있고 보드는 사이드 패널 왼쪽에 있다.

### AC-UI-06 (REQ-UI-008)

**Given** 뷰포트 {320×568, 360×780, 480×320, 568×320, 740×360, 800×1280, 1280×800, 1920×1080} 각각, **When** GamePage, MenuPage, ScoresPage를 그리면, **Then** `tester.takeException()`이 null이고 보드 영역이 뷰포트 안에 있다.

### AC-UI-07 (REQ-UI-009)

**Given** 뷰포트 {360×640, 360×780, 599×640} 각각, **When** GamePage가 그려지면, **Then** 셀 위젯 하나(`tester.getSize(find.byKey(const ValueKey('cell.0')))`, 셀 사이 간격과 프레임 여백 제외)의 크기가 가로·세로 모두 36 이상이다. 설계상 360 폭의 값은 (360 − 2×6 − 2×2 − 8×2) / 9 = 36.44이다 (`design.md` §4).

### AC-UI-08 (REQ-UI-010)

**Given** `phase == playing`, turnCount 3, **When** `Restart`를 탭하고 `tester.pumpAndSettle()`을 실행하면, **Then** 확인 대화상자가 보이고 turnCount는 3, fake 저장소의 save 호출 수는 0이다.

### AC-UI-09 (REQ-UI-011)

**Given** turnCount 3에서 확인 대화상자가 열린 상태, **When** 다음 네 경로를 각각 따로(경로마다 새로 대화상자를 연 뒤) 실행하고 경로마다 `tester.pumpAndSettle()`을 실행하면 — (1) `Cancel` 탭, (2) 대화상자 바깥 배리어 탭, (3) `tester.sendKeyEvent(LogicalKeyboardKey.escape)`, (4) `tester.binding.handlePopRoute()` — **Then** 네 경우 모두 대화상자가 닫히고 turnCount는 3이며 save 호출 수가 늘지 않고 GamePage가 그대로 남아 있다.

### AC-UI-10 (REQ-UI-011)

**Given** 확인 대화상자가 열린 상태, **When** 확인 버튼(`Restart`)을 탭하고 `tester.pumpAndSettle()`을 실행하면, **Then** turnCount가 0이 되고 새 상태로 save가 1회 호출되며 대화상자가 닫힌다.

### AC-UI-11 (REQ-UI-012)

**Given** `phase == complete` (그리고 별도로 `gameOver`), **When** `Play again` 또는 `Restart`를 탭하고 `tester.pumpAndSettle()`을 실행하면, **Then** 대화상자 없이 바로 새 판이 시작된다.

### AC-UI-12 (REQ-UI-013, REQ-UI-014)

**Given** 직전 GameState(turnCount n)로 그려진 BoardGrid, **When** 빈 칸 하나만 채워진 turnCount n+1 상태로 다시 그리면, **Then** 그 칸의 배치 애니메이션만 동작한다. **When** 대신 숫자 칸 k개(k ≥ 1)가 빈 칸이 된 turnCount n+1 상태(매치)로 다시 그리면, **Then** 비워진 k개 칸에만 매치 애니메이션이 동작하고 배치 애니메이션은 없다. **When** 대신 보드가 직전과 같은 turnCount n+1 상태(이웃에 숫자가 없는 칸에 0을 놓은 매치)로 다시 그리면, **Then** 셀 단위 애니메이션이 하나도 동작하지 않는다. 애니메이션 동작 여부는 셀별 연출 키(`cell.<i>.place`, `cell.<i>.match`)의 존재로, `tester.pumpWidget`으로 다시 그린 직후 프레임에서 판정한다(키 존재만 보므로 연출 진행 시점에 영향받지 않음).

### AC-UI-13 (REQ-UI-016)

**Given** 직전 GameState로 그려진 BoardGrid, **When** 재시작(turnCount가 0으로 돌아감) 상태 또는 resume으로 불러온 상태로 `tester.pumpWidget`을 써서 다시 그리면, **Then** 셀 단위 애니메이션이 하나도 동작하지 않는다.

### AC-UI-14 (REQ-UI-018)

**Given** `MediaQuery(disableAnimations: true)`, **When** 다음 다섯 경우를 각각 실행하면 — 매치가 아닌 배치, 숫자 칸 1개 이상을 지우는 매치, 큐 이동, 화면 이동(MenuPage → GamePage), 종료 오버레이 등장 — **Then** 각 경우 동작(탭 또는 이동) 뒤 `tester.pump()`를 두 번(동작을 반영하는 프레임 1회, 다음 프레임 1회) 실행하면 최종 프레임이 그려지고(지워진 칸은 빈 칸으로, 오버레이는 opacity 1.0으로 보임) `tester.hasRunningAnimations`가 false다.

### AC-UI-15 (REQ-UI-015, REQ-UI-019)

**Given** `playing` 상태 GamePage(감속 모드 꺼짐)와 큐 첫 칸의 최종 위치 x₀(`find.descendant(of: find.byType(NextQueueRow), matching: find.byKey(const ValueKey('queue.slot.0')))`의 왼쪽 위 x), **When** 빈 칸을 탭하고 `tester.pump()`로 연출을 시작한 뒤 `tester.pump(const Duration(milliseconds: 100))`(시작 후 base 200ms의 절반)을 실행하면, **Then** `NextQueueRow` 안의 `queue.slot.0` 왼쪽 위 x가 x₀보다 크고 x₀ + 칸 간격(칸 폭 + 8, `design.md` §5)보다 작다. **When** 이어서 200ms 안에 다른 빈 칸을 탭하면, **Then** `placeAt`이 두 번째로 호출되어 turnCount가 총 2 늘고, 이후 `pumpAndSettle()`이 timeout 없이 끝나며 `queue.slot.0`의 x가 x₀와 같다.

### AC-UI-16 (REQ-UI-004)

**When** 아래 명령을 실행하면, **Then** 출력이 0줄이다 (제외 폴더 두 개는 `spec.md` §D의 디자인 토큰 소스).

```bash
grep -rnP "Color\(0x|Colors\.(?!transparent)" lib/presentation lib/main.dart | grep -v -e "lib/presentation/theme/" -e "lib/presentation/layout/"
```

판별력 확인: 기준 커밋 `6a695b2`에서 같은 명령은 4줄을 출력한다(plan 단계 실측: `game_page.dart:106`, `board_grid.dart:25`, `board_grid.dart:27`, `main.dart:24`).

### AC-UI-17 (REQ-UI-022)

**Given** SPEC-ARCH-001 완료 커밋 SHA(run 단계 pre-flight에서 기록, 아래 `<ARCH_SHA>`), **When** 아래 명령을 실행하면, **Then** 종료 코드가 0이고, `test/infrastructure/save_compat_fixture_test.dart`가 계속 통과한다.

```bash
git diff --exit-code <ARCH_SHA> -- lib/domain lib/infrastructure/persistence/persistence_keys.dart lib/infrastructure/persistence/save_game_codec.dart
```

### AC-UI-18 (전체)

**When** 아래 명령을 실행하면, **Then** 종료 코드가 0이고, `coverage/lcov.info`에서 이 SPEC으로 바뀌거나 새로 생긴 `lib/presentation/**` 파일 각각의 라인 커버리지(LH/LF)가 85% 이상이다.

```bash
flutter analyze && flutter test --coverage
```

### AC-UI-19 (REQ-UI-023)

**Given** 개편이 끝난 트리, **When** `pubspec.yaml`과 앱 테마를 검사하면, **Then** `fonts:`에 Nunito 400, 800 asset이 선언되어 있고, 아래 명령의 출력이 0줄이며(의존성 불변), 앱 테마의 `fontFamily`가 `Nunito`이고, MenuPage에서 `find.text('New Game')`이 위젯 하나를 찾는다.

```bash
git diff <ARCH_SHA> -- pubspec.yaml | grep -E "^[-+] " | grep -vE "^[-+] +(fonts:|- family:|family:|- asset:|asset:|weight:|fonts/)"
```

### AC-UI-20 (REQ-UI-017)

**Given** 감속 모드가 꺼진 기본 상태의 앱, **When** MenuPage에서 GamePage로 이동하면, **Then** 새 route의 `transitionDuration`이 320ms이다. **When** 이동(탭 후 `tester.pump()` 한 번으로 전환 시작) 후 `tester.pump(const Duration(milliseconds: 160))`(시작 후 320ms의 절반)을 실행하면, **Then** 새 화면의 조상 `FadeTransition`의 opacity가 0.875 ± 0.01이고 `ScaleTransition`의 scale이 0.995 ± 0.001이다 (easeOutCubic(0.5) = 0.875, scale = 0.96 + 0.04 × 0.875). 같은 검사를 MenuPage → ScoresPage 이동(탭 후 `tester.pump()` 한 번으로 시작, 이어서 `tester.pump(const Duration(milliseconds: 160))`)과 종료 오버레이 등장(마지막 수를 탭한 뒤 `tester.pump()` 한 번으로 시작, 이어서 `tester.pump(const Duration(milliseconds: 150))`, emphasized 300ms의 절반, 같은 기대값)에 대해서도 각각 수행해 통과한다. **When** 이어서 `pumpAndSettle()`을 실행하면, **Then** opacity와 scale이 모두 1.0이다.

### AC-UI-21 (REQ-UI-020)

**Given** `playing` 상태 BoardGrid의 빈 칸 e와 숫자 7이 있는 칸 f, 그리고 `gameOver` 상태 BoardGrid의 빈 칸 g, **When** 각 칸의 semantics를 `tester.getSemantics`로 읽으면, **Then** e는 `matchesSemantics(label: 'Empty cell', isButton: true, hasTapAction: true)`, f는 `matchesSemantics(label: '7', isButton: false, hasTapAction: false)`, g는 `matchesSemantics(label: 'Empty cell', isButton: false, hasTapAction: false)`와 일치한다. **Given** `playing` 상태 GamePage, **When** `tester.sendKeyEvent(LogicalKeyboardKey.tab)`과 `tester.pump()`를 반복해 빈 칸 하나에 포커스가 가면, **Then** 그 칸에만 포커스 링(`cell.<i>.focusRing`)이 있고 링의 두께는 2, 색은 현재 테마의 `focus` 토큰이다.

### AC-UI-22 (REQ-UI-021)

**Given** 앱 루트를 웹 첫 제스처 오디오 해제가 켜진 상태로 구성하고(운영 코드에서는 이 스위치 값이 `kIsWeb`, 테스트에서는 같은 스위치를 직접 켬) fake 오디오 포트로 override한 상태, **When** 화면 아무 곳에 포인터 다운을 보내면, **Then** fake 오디오 포트의 `notifyUserGesture`가 1회 이상 기록된다. **Given** 같은 구성에서 스위치를 끈 상태, **When** 포인터 다운을 보내면, **Then** `notifyUserGesture`는 기록되지 않는다. 그리고 아래 명령은 1줄 이상을 출력한다(운영 배선이 `kIsWeb`을 쓰는지 확인).

```bash
grep -rn "kIsWeb" lib/main.dart lib/presentation/common
```

### AC-UI-23 (REQ-UI-001)

**When** 아래 명령을 실행하면, **Then** 출력이 0줄이다 (모션 시간, 반경, 글자 크기, 간격 리터럴이 `spec.md` §D의 디자인 토큰 소스 밖에 없음).

```bash
grep -rnE "Duration\(|Radius\.circular\(|fontSize: *[0-9]|EdgeInsets\.[a-zA-Z]+\([^)]*[0-9]|SizedBox\((height|width): *[0-9]" lib/presentation lib/main.dart | grep -v -e "lib/presentation/theme/" -e "lib/presentation/layout/"
```

판별력 확인: 기준 커밋 `6a695b2`에서 같은 명령은 25줄을 출력한다(plan 단계 실측).

### AC-UI-24 (REQ-UI-002)

**Given** 앱 전체(`SummingApp`)를 그린 상태, **When** `tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode`를 읽으면, **Then** `ThemeMode.system`이다. **When** MenuPage를 그리면, **Then** `SwitchListTile`은 정확히 2개(`Music`, `Sound effects`)이고 `find.textContaining(RegExp('theme|dark mode', caseSensitive: false))`는 아무것도 찾지 못한다. **Given** 플랫폼 밝기를 `Brightness.dark`로 바꾼 상태(`tester.platformDispatcher.platformBrightnessTestValue`), **When** `tester.pumpAndSettle()`로 다시 그리면(테마 전환 애니메이션 완료), **Then** `Theme.of(context).brightness`가 `Brightness.dark`이다.

### AC-UI-25 (REQ-UI-024)

**Given** 뷰포트 568×320과 740×360 각각, **When** `playing` 상태 GamePage가 그려지면, **Then** `tester.takeException()`이 null이고, `find.byType(AppBar)`가 아무것도 찾지 못하며, 사이드 패널(`game.sidePanel`)이 보드 오른쪽에 있고 그 안에 제목(`find.descendant(of: find.byKey(const ValueKey('game.sidePanel')), matching: find.text('Summing'))`이 위젯 하나를 찾음), 턴 수, 큐, `Restart`, `Quit`가 있으며, 패널 안 `Next:` 라벨의 아래쪽 y가 `queue.slot.0`의 위쪽 y 이하다(라벨이 네 칸 위 별도 줄, `design.md` §5). 그리고 보드(`game.board`) 한 변과 셀 하나(`cell.0`)의 크기가 568×320에서 각각 304 이상과 31.5 이상, 740×360에서 각각 344 이상과 36 이상이다 (설계값 308 / 32.00, 348 / 36.44, `design.md` §4). **Given** 뷰포트 1280×400 (폭 ≥ 840이지만 높이 < 480), **When** GamePage가 그려지면, **Then** 같은 저높이 배치(`AppBar` 없음, `game.sidePanel` 있음)가 쓰인다.

<!-- AC-BODY-END -->

## Files to Modify

- [NEW] `lib/presentation/theme/{app_tokens,app_theme,app_motion}.dart`, `lib/presentation/layout/breakpoints.dart`, `lib/presentation/common/{app_page_route,web_audio_unlock}.dart`
- [NEW] `lib/presentation/game/widgets/{restart_confirm_dialog,end_overlay,game_side_panel,board_cell}.dart`
- [NEW] `assets/fonts/Nunito-Regular.ttf`, `assets/fonts/Nunito-ExtraBold.ttf`, `assets/fonts/OFL.txt`
- [MODIFY] `lib/main.dart`, `lib/presentation/menu/menu_page.dart`, `lib/presentation/game/game_page.dart`, `lib/presentation/game/widgets/board_grid.dart`, `lib/presentation/game/widgets/next_queue_row.dart`, `lib/presentation/scores/scores_page.dart`, `lib/presentation/common/how_to_play_sheet.dart`, `pubspec.yaml` (fonts only), `web/manifest.json` (colors only)
- [MODIFY] `test/presentation/game/game_page_characterization_test.dart` (intentional Restart-flow change)
- [NEW] tests: `test/presentation/theme/{token_contrast,app_theme}_test.dart`, `test/presentation/game/{game_page,restart_dialog,board_grid,next_queue_row}_test.dart`, `test/presentation/common/{app_page_route,web_audio_unlock}_test.dart`, `test/presentation/responsive_layout_test.dart`
- [EXISTING] do not touch: `lib/domain/**`, `persistence_keys.dart`, `save_game_codec.dart`, application behavior

## Exclusions (What NOT to Build)

### Out of Scope — 게임 규칙과 모드

- 새 게임 모드, 규칙 변경, 난이도, 힌트, 되돌리기, 통계, `lib/domain/**` 수정

### Out of Scope — 데이터와 설정

- 저장 키·형식·`schemaVersion`·점수 정책 변경, 앱 내 테마 토글, `AppSettings` 필드 추가

### Out of Scope — 플랫폼과 인프라

- 온라인 기능, 새 플랫폼 러너, 방향 정책(manifest `portrait-primary` 포함), 앱 식별자, CI, 오디오 스크립트·에셋, 햅틱
- 폭과 높이가 모두 480 미만인 창의 플레이 가능 크기 보장 (넘침 없음만 요구)

### Out of Scope — 의존성과 테스트

- 새 패키지(go_router, animations, google_fonts, intl)와 l10n, 골든 테스트
