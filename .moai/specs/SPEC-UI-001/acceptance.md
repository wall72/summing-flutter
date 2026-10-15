# SPEC-UI-001 인수 기준

검증 레이어 문서입니다 (spec 0.3.2 기준). 시간을 지정한 `tester.pump(<시간>)`은 항상 동작(탭·이동) 뒤 `tester.pump()` 한 번으로 연출을 시작한 다음에 실행합니다(연출이 시작되는 프레임에서는 시작 값이 그려지기 때문). 각 항목은 Given-When-Then 형식이며 통과/실패가 명확히 갈립니다. 요구사항 원문은 `spec.md` §C를 따릅니다.

뷰포트 테스트는 `tester.view.physicalSize`와 `tester.view.devicePixelRatio = 1`로 폭과 높이를 모두 정하고 `addTearDown(tester.view.reset)`로 되돌립니다. 상태 주입은 SPEC-ARCH-001의 fake 포트 override를 씁니다. 모든 셸 명령은 표 밖 코드 블록에 원문 그대로 적었고, `spec-compact.md`의 AC 본문은 이 문서 §D의 시작·끝 마커 주석 사이 구간과 글자 단위로 같습니다.

## §D AC 목록

<!-- AC-BODY-START: spec-compact.md와 동일하게 유지 -->

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

## §D.0 추적 표

| AC | 추적 REQ |
|---|---|
| AC-UI-23 | REQ-UI-001 |
| AC-UI-24 | REQ-UI-002 |
| AC-UI-01, 02 | REQ-UI-003 |
| AC-UI-16 | REQ-UI-004 |
| AC-UI-03 | REQ-UI-005 |
| AC-UI-04 | REQ-UI-006 |
| AC-UI-05 | REQ-UI-007 |
| AC-UI-06 | REQ-UI-008 |
| AC-UI-07 | REQ-UI-009 |
| AC-UI-08 | REQ-UI-010 |
| AC-UI-09, 10 | REQ-UI-011 |
| AC-UI-11 | REQ-UI-012 |
| AC-UI-12 | REQ-UI-013, 014 |
| AC-UI-15 | REQ-UI-015, 019 |
| AC-UI-13 | REQ-UI-016 |
| AC-UI-20 | REQ-UI-017 |
| AC-UI-14 | REQ-UI-018 |
| AC-UI-01, 21 | REQ-UI-020 |
| AC-UI-22 | REQ-UI-021 |
| AC-UI-17 | REQ-UI-022 |
| AC-UI-19 | REQ-UI-023 |
| AC-UI-25 | REQ-UI-024 |
| AC-UI-18 | 전체 |

REQ 24개 모두 하나 이상의 AC가 직접 검증합니다. AC는 25개로 Tier L 상한(25)에 닿았습니다. 이후 AC를 더 추가해야 하면 AC-UI-03·04·05(배치 클래스별 검사)를 하나로 합쳐 자리를 만드는 것을 우선 검토합니다.

## §D.1 엣지 케이스

- Restart를 빠르게 두 번 탭해도 대화상자는 하나만 열린다.
- 대화상자가 열린 채로 앱이 백그라운드로 가면 생명주기 저장(`persistIfNeeded`)은 그대로 실행되고, 돌아왔을 때 대화상자가 남아 있다.
- 게임 중에 창 폭이 839 ↔ 840을 오가거나 높이가 479 ↔ 480을 오가면 배치만 바뀌고 턴 수, 보드, 큐는 유지된다.
- 저높이 가로 화면에서 MenuPage와 ScoresPage는 세로 스크롤로 넘침 없이 보인다 (AC-UI-06의 480×320, 568×320, 740×360).
- 폭 480~532 × 높이 320에서는 사이드 패널 폭이 최소값 200이 된다. 큐 `Next:` 라벨을 칸 위 별도 줄에 두므로 필요 폭은 184다. 라벨을 칸 옆에 두면 약 230이 필요해 높이 320에서 폭 480~561(패널 안쪽 여백 6 포함 시 480~573)에서 넘친다 (AC-UI-06의 480×320이 이를 잡음). 패널 안쪽 여백은 좌우 6(상한 8)이라 안쪽 폭은 최소 188이다.
- 폭과 높이가 모두 480 미만인 창(예: 400×400)은 compact 한 열 배치를 쓰고 넘침 없음만 요구한다 (`spec.md` §G).
- 매치로 보드가 완전히 비어 `complete`가 되는 수: 매치 애니메이션과 종료 오버레이 진입이 겹쳐도 예외가 없고 오버레이 버튼을 바로 누를 수 있다.
- 이웃에 숫자가 없는 칸에 0을 놓는 매치(보드 변화 없음): 셀 연출은 없고 큐 이동과 턴 수 변경만 보인다 (AC-UI-12 세 번째 경우).
- 다크 테마 새 게임(81칸 모두 빈 칸): 셀 외곽선이 보드 프레임 대비 5.35:1로 칸 경계가 보인다 (`research.md` §3).
- 비활성 이어하기 버튼(저장 없음)은 Material 기본 비활성 색을 쓰며 대비 기준 예외다 (`design.md` §1.2). AC-UI-02의 MenuPage는 이 때문에 이어하기 버튼이 활성인 상태로 검사한다.

## §D.2 의도된 동작 변경

- SPEC-ARCH-001 M1의 `test/presentation/game/game_page_characterization_test.dart`(AC-ARCH-16)는 "Restart를 누르면 확인 없이 즉시 재시작"을 단언합니다.
- 이 SPEC M1에서 이 단언을 AC-UI-08 ~ 11 흐름(playing 중 확인 대화상자, 종료 상태에서는 즉시 재시작)으로 **의도적으로 바꿉니다.** 회귀가 아니라 계획된 변경이며, 변경 커밋 메시지에 이 사실을 적습니다.

## §D.3 품질 게이트

| 항목 | 기준 |
|---|---|
| 정적 분석 | `flutter analyze` issue 0건 |
| 테스트 | `flutter test` 전체 통과 |
| 커버리지 | AC-UI-18 (파일별 85%) |
| 접근성 | AC-UI-01, 02, 21 (텍스트 4.5:1, 비텍스트 3:1, ColorScheme 매핑, semantics 유지, 포커스 링) |
| 하드코딩 값 | AC-UI-16, 23 출력 0줄 |
| 불변 파일 | AC-UI-17 종료 코드 0 |
| 의존성 | AC-UI-19 |

`androidTapTargetGuideline`(48dp)은 9×9 보드 특성상 적용하지 않고 AC-UI-07(셀 36px 이상)과 AC-UI-25(저높이 가로 셀 하한)로 대신합니다. 골든 테스트는 범위 밖입니다.

## §D.4 Definition of Done

- [ ] run 단계 첫 단계로 기준선 `flutter analyze && flutter test`를 실행하고 결과를 `progress.md` §E.2에 기록
- [ ] SPEC-ARCH-001이 `completed`임을 확인하고 완료 커밋 SHA 기록
- [ ] 변경 전에 AC-UI-16(4줄), AC-UI-23(25줄) 명령을 실행하고, AC-UI-20 테스트가 현재 `MaterialPageRoute`에서 실패함을 확인해 판별력 기록
- [ ] AC-UI-01 ~ 25 전부 통과, 각 명령과 출력을 `progress.md` §E.2에 기록
- [ ] Restart 동작 고정 테스트의 의도된 변경을 커밋 메시지에 명시
- [ ] Nunito 폰트 출처와 라이선스(OFL 1.1) 확인, 웹 빌드 용량 변화 실측값 기록
- [ ] mx_plan의 High 우선순위 태그 반영
