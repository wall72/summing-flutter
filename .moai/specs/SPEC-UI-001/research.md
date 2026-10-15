# SPEC-UI-001 조사 기록

plan 단계에서 확인한 코드 근거, 측정값, 사용 가능한 API, 검토한 대안을 정리합니다 (spec 0.3.2 기준, 1~4차 plan-audit 반영).

## §1 현재 코드 근거 (기준 커밋 6a695b2)

| 항목 | 근거 |
|---|---|
| teal 시드 테마, Material 3, 라이트·다크 | `lib/main.dart:22-28`, `:38-39` |
| 웹 첫 제스처 오디오 해제 Listener | `lib/main.dart:40-50` |
| 메뉴: FilledButton, FilledButton.tonal(Resume), OutlinedButton 2개, SwitchListTile 2개, SnackBar, 최대 폭 420, 영어 문구 | `lib/presentation/menu/menu_page.dart:28-30`, `:74`, `:100`, `:109`, `:124`, `:135`, `:140`, `:148` |
| 메뉴·점수판 로딩: CircularProgressIndicator | `lib/presentation/menu/menu_page.dart:58`, `lib/presentation/scores/scores_page.dart:17` |
| 게임: AppBar Restart/Quit TextButton, Restart는 확인 없음 | `lib/presentation/game/game_page.dart:32-46` |
| 게임: 최대 폭 520 고정 | `lib/presentation/game/game_page.dart:54` |
| 종료 오버레이: `Colors.black54` 위 Card, Play again은 FilledButton, Back to menu는 TextButton | `lib/presentation/game/game_page.dart:91-146`, `:108`, `:128`, `:134` |
| 보드: 하드코딩 회색, GridView + InkWell, 애니메이션 없음 | `lib/presentation/game/widgets/board_grid.dart:25-27`, `:40-59`, `:89-92` |
| 보드: 칸 크기 = min(폭, 높이), 글자 크기 = 칸 × 0.42 | `lib/presentation/game/widgets/board_grid.dart:34-35` |
| 셀 semantics: 숫자 또는 "Empty cell", 탭 가능할 때만 button | `lib/presentation/game/widgets/board_grid.dart:86-88` |
| 큐: 4칸 44×44, 첫 칸만 primaryContainer | `lib/presentation/game/widgets/next_queue_row.dart:21-48` |
| 점수판: ListTile + CircleAvatar 순위 + Divider | `lib/presentation/scores/scores_page.dart:32-44` |
| How to Play: showModalBottomSheet(드래그 손잡이 표시) | `lib/presentation/common/how_to_play_sheet.dart:4-7` |
| 매치 결과는 bool만 반환 (지운 칸 목록 없음) | `lib/domain/place_outcome.dart:8-12` |
| 매치 시 이웃 8칸 전부를 비우고 놓은 숫자는 기록하지 않음 | `lib/domain/summing_rules.dart:37-48`, `lib/domain/board.dart:59-66` (`afterMatchClear`가 이웃 인덱스마다 `SummingCell.empty`를 씀) |
| 매치 판정: 놓는 숫자 == 숫자가 있는 이웃 합 % 10 | `lib/domain/summing_rules.dart:30-37`. 이웃에 숫자가 없으면 합 0 → 숫자 0을 놓으면 매치, 보드 변화 없음 |
| 웹 manifest 색상 teal, 방향 portrait-primary | `web/manifest.json` (`theme_color`, `background_color` = `#009688`) |

### Material 위젯 기본 색 역할 조사 (D15)

범위 안 화면이 계속 쓰는 Material 위젯을 위 근거에서 모두 모았고, 각 위젯이 테마에서 읽는 역할을 `design.md` §1.1·§1.2에서 토큰으로 지정했습니다. 목록: Scaffold, AppBar, TextButton, FilledButton, FilledButton.tonal, OutlinedButton, SwitchListTile(ListTile + Switch), SnackBar, CircularProgressIndicator, Card, AlertDialog(신규 대화상자), ListTile, CircleAvatar, Divider, 바텀 시트. 위젯별 기본 역할(예: tonal = secondaryContainer / onSecondaryContainer, CircleAvatar = primaryContainer / onPrimaryContainer, SnackBar = inverseSurface 계열, Switch 꺼짐 트랙 = surfaceContainerHighest)은 plan 단계 Material 3 지식으로 정리한 것입니다. 실제로 맞는지는 AC-UI-01의 ColorScheme 동일성 검사와 AC-UI-02의 화면별 `textContrastGuideline` 검사가 run 단계에서 기계적으로 확인합니다. Divider는 장식이라 대비 기준에서 제외합니다.

## §2 Flutter 버전과 사용 가능한 API

- plan 단계 셸에 `flutter`가 PATH에 없어 버전을 확인하지 못했습니다. `board_grid.dart:28`의 `Color.withValues(alpha:)`는 Flutter 3.27 이상 API이므로 3.27 이상으로 추정합니다. run 단계 pre-flight에서 `flutter --version`으로 확정합니다.
- 패키지 추가 없이 쓸 수 있는 API (Flutter SDK 기본 제공):
  - `Color.computeLuminance()` — 대비 계산 단위 테스트 (AC-UI-01)
  - `flutter_test`의 `meetsGuideline(textContrastGuideline)` — 화면 대비 검사 (AC-UI-02)
  - `matchesSemantics`, `tester.getSemantics` — semantics 검사 (AC-UI-21)
  - `tester.sendKeyEvent(LogicalKeyboardKey.tab / .escape)`, `tester.binding.handlePopRoute()` — 포커스 이동, 대화상자 닫기 경로 (AC-UI-09, 21)
  - `tester.platformDispatcher.platformBrightnessTestValue` — 시스템 밝기 전환 (AC-UI-24)
  - `MediaQuery.disableAnimations` — 감속 모드 (REQ-UI-018)
  - `TweenAnimationBuilder`, `AnimatedScale`, `AnimatedOpacity`, `AnimatedContainer`, `AnimatedSlide`, `AnimatedSwitcher` — implicit 애니메이션
  - `PageRouteBuilder`(`transitionDuration`) + `FadeTransition` / `ScaleTransition` + `Curves.easeOutCubic` — 화면 전환 (REQ-UI-017, AC-UI-20)
  - `tester.view.physicalSize`, `tester.view.devicePixelRatio`, `tester.view.reset` — 뷰포트 테스트
  - `tester.hasRunningAnimations`, `tester.getTopLeft`, `find.descendant` — 애니메이션 종료와 큐 행 범위 검사 (AC-UI-14, 15)
- `kIsWeb`는 `flutter test`(VM)에서 항상 false이므로, 웹 첫 제스처 해제는 스위치를 주입받는 위젯으로 분리해 테스트에서 직접 켭니다 (AC-UI-22).
- AC-UI-20 판별력: Flutter 기본 페이지 전환은 플랫폼별 builder의 고유 시간과 커브를 써서, 토큰 route의 320ms와 easeOutCubic 절반 값(0.875 / 0.995)을 함께 만족할 가능성이 낮습니다. plan 단계에서는 실행하지 못했으므로, run 단계에서 변경 전 `MaterialPageRoute` 상태로 이 테스트가 실패하는지(RED)를 먼저 확인하고 기록합니다.
- 위 API 이름은 plan 단계 지식으로 정리한 것이며, 현재 설치된 SDK에서의 존재 여부는 run 단계에서 `flutter analyze`로 확인됩니다.

## §3 대비 측정

WCAG 2.x 상대 휘도 공식(sRGB 선형화 후 0.2126R + 0.7152G + 0.0722B, 대비 = (L1+0.05)/(L2+0.05))을 `python3 -I -c '…'`로 계산한 실행 출력입니다 (0.3.0 수정 시 새 쌍을 추가로 계산, 기존 쌍은 0.2.0에서 전 항목 재계산).

### 텍스트 쌍 (기준 4.5)

| 쌍 | Light | Dark |
|---|---|---|
| digit(onSurface) / cellFilled | `#2E2A3A`/`#FFFFFF` 13.92 | `#F4EFFF`/`#4A4266` 8.24 |
| digit / placeHighlight | `/#FFE1C7` 11.17 | `/#6B4A33` 7.03 |
| digit / matchFlash | `/#C9EEDC` 11.10 | `/#2E5A4B` 6.95 |
| onSurface / background | `/#FFF8F1` 13.22 | `/#1C1924` 15.35 |
| onSurface / surfaceContainer | `/#FFFFFF` 13.92 | `/#262230` 13.77 |
| onSurfaceVariant / background | `#5E5670`/`#FFF8F1` 6.56 | `#CFC6E0`/`#1C1924` 10.55 |
| onSurfaceVariant / surfaceContainer | `/#FFFFFF` 6.91 | `/#262230` 9.46 |
| onPrimary / primary | `#3B1F2B`/`#F6B7C4` 8.81 | `#3B1F2B`/`#F4B6C2` 8.69 |
| onQueueHead / queueHeadContainer (큐 첫 칸, tonal 버튼, CircleAvatar) | `#3B1F2B`/`#FCD9E0` 11.39 | `#FFE3EA`/`#6A3A4C` 7.50 |
| accentText / background | `#9C3358`/`#FFF8F1` 6.59 | `#F4B6C2`/`#1C1924` 10.15 |
| accentText / surfaceContainer | `#9C3358`/`#FFFFFF` 6.94 | `#F4B6C2`/`#262230` 9.10 |
| onInverseSurface / inverseSurface (SnackBar) | `#F4EFFF`/`#2E2A3A` 12.36 | `#2E2A3A`/`#F4EFFF` 12.36 |
| inversePrimary / inverseSurface (SnackBar 액션) | `#F4B6C2`/`#2E2A3A` 8.17 | `#9C3358`/`#F4EFFF` 6.15 |

### 비텍스트 쌍 (기준 3.0)

| 쌍 | Light | Dark |
|---|---|---|
| focus / cellEmpty | `#9C3358`/`#CEC3EB` 4.17 | `#F4B6C2`/`#1F1C28` 9.81 |
| focus / cellFilled | `#9C3358`/`#FFFFFF` 6.94 | `#F4B6C2`/`#4A4266` 5.44 |
| focus / 보드 프레임(surfaceContainer) | `#9C3358`/`#FFFFFF` 6.94 | `#F4B6C2`/`#262230` 9.10 |
| cellOutline / 보드 프레임·시트(surfaceContainer) | `#8E80B8`/`#FFFFFF` 3.54 | `#9C90C8`/`#262230` 5.35 |
| cellOutline / background (OutlinedButton·Switch 꺼짐 테두리) | `#8E80B8`/`#FFF8F1` 3.36 | `#9C90C8`/`#1C1924` 5.96 |
| Switch 켜짐 thumb(onAccent) / 트랙(accentText) | `#FFFFFF`/`#9C3358` 6.94 | `#3B1F2B`/`#F4B6C2` 8.69 |
| Switch 켜짐 트랙(accentText) / background | 6.59 | 10.15 |
| Switch 꺼짐 thumb(onSurfaceVariant) / 트랙(cellEmpty) | `#5E5670`/`#CEC3EB` 4.15 | `#CFC6E0`/`#1F1C28` 10.20 |
| 진행 표시기(accentText) / background | 6.59 | 10.15 |
| 큐 첫 칸 외곽선(queueHeadOutline = accentText) / background | `#9C3358`/`#FFF8F1` 6.59 | `#F4B6C2`/`#1C1924` 10.15 |
| 큐 첫 칸 외곽선 / surfaceContainer | 6.94 | 9.10 |
| 큐 첫 칸 외곽선 / queueHeadContainer | `#9C3358`/`#FCD9E0` 5.33 | `#F4B6C2`/`#6A3A4C` 5.30 |

### 상태 레이어 쌍 (기준 4.5, 0.3.1 추가)

Material 기본 hover·포커스·눌림 상태 레이어는 전경색 8% / 10% / 10%를 배경에 덧칠합니다. 덧칠 비율이 클수록 배경이 전경에 가까워져 대비가 낮아지므로 10%를 최악값으로 계산했습니다 (`python3 -I` 실행 출력, 2차 감사 D26 계산값과 같음).

| 쌍 (전경 / 전경 10% + 배경) | Light | Dark |
|---|---|---|
| TextButton accentText / background 위 | 5.64 | 8.20 |
| TextButton accentText / surfaceContainer 위 | 5.94 | 7.26 |
| FilledButton onPrimary / primary 위 | 7.44 | 7.35 |
| tonal onQueueHead / queueHeadContainer 위 | 9.48 | 5.86 |

### 참고값 (기준에 넣지 않는 보조 신호)

| 쌍 | Light | Dark |
|---|---|---|
| cellEmpty / cellFilled | 1.66 | 1.80 |
| cellOutline / cellFilled | 3.54 | 3.20 |
| cellEmpty / 보드 프레임 (외곽선 없을 때) | `#CEC3EB`/`#FFFFFF` 1.66 | `#1F1C28`/`#262230` 1.08 |
| cellEmpty / background | — | `#1F1C28`/`#1C1924` 1.03 |
| onSurface / queueHeadContainer | `#2E2A3A`/`#FCD9E0` 10.70 | — |

2차 감사가 따로 계산한 인접 쌍(focus / placeHighlight 5.56 / 4.64, focus / matchFlash 5.53 / 4.60)도 기준을 넘습니다.

### 검토 후 버린 값

| 값 | 측정 | 판단 |
|---|---|---|
| TextButton 기본 전경 = primary `#F6B7C4` | 흰 배경 1.68, 크림 배경 1.60 | 텍스트 기준 미달 → accentText 도입 |
| Switch 켜짐 트랙 = primary `#F6B7C4` (Material 기본) | 크림 배경 1.60 | 비텍스트 기준 미달 → accentText 트랙 |
| 큐 첫 칸 외곽선 = `scheme.primary` `#F6B7C4` (현재 코드 `next_queue_row.dart:36`) | 크림 배경 1.60 | queueHeadOutline(accentText)으로 교체 → 6.59 |
| Light focus `#B4476A` | 배경 4.93, 흰 칸 5.19, 빈 칸 3.12 | 빈 칸 대비 여유가 적어 `#9C3358`(4.17)로 교체 |
| 다크 빈 칸 외곽선 없음 | 프레임 1.08, 배경 1.03 | 새 게임에서 칸 경계가 보이지 않음 → 모든 칸에 외곽선 |
| Light 빈 칸 `#E4DDF4` | 채운 칸 1.32 | 1차안 이전 단계에서 `#CEC3EB`로 교체 |
| Dark 채운 칸 `#3B3550` | 빈 칸 1.34 | 1차안 이전 단계에서 `#4A4266`으로 교체 |

## §4 브레이크포인트와 보드 크기 근거

- 폭은 Material 3 window size class(compact < 600, medium 600–839, expanded ≥ 840), 높이는 Material 3 height class의 compact 경계(480)를 따릅니다.
- 저높이 가로 규칙은 2차 감사 D19에 대한 사용자 결정(가로 휴대폰에서도 플레이 가능한 보드)입니다. 높이 < 480이고 폭 ≥ 480이면 폭 브레이크포인트와 관계없이 두 칸 배치를 씁니다.
- 보드·셀 크기 계산 실행 출력 (`python3 -I`, 셀 = (보드 − 20) / 9):

| 계산 | 출력 |
|---|---|
| 프레임 여백 2, compact 여백 8, 360 폭 | 보드 344, 셀 36.00 (여유 없음 → 채택 안 함) |
| 프레임 여백 2, compact 여백 6, 360 폭 | 보드 348, 셀 36.44 |
| compact 360×640 / 360×780 | 348 / 36.44 |
| compact 599×640 | 380 / 40.00 |
| compact 320×568 | 308 / 32.00 |
| medium 700×1000 | 560 / 60.00 |
| 저높이 가로 568×320 | 308 / 32.00 |
| 저높이 가로 740×360 | 348 / 36.44 |
| 저높이 가로 480×320 | 256 / 26.22 |
| 저높이 가로 812×375 | 363 / 38.11 |
| 저높이 가로 896×414 | 402 / 42.44 |
| 0.2.0 단일 열 배치의 568×320 | 60 / 4.44 |

- 저높이 가로 사이드 패널 양축 검산 (3차 감사 D23, `python3 -I` 실행 출력). 패널 폭 = 폭 − 24 − 보드, 필요 폭 = 큐 네 칸 184(`Next:` 라벨은 칸 위 별도 줄), 라벨을 칸 옆에 둘 때 약 230. 패널 높이 = 높이 − 12, 필요 높이 = 232 (제목 28, 8, 턴 수 24, 8, 라벨 20, 4, 큐 칸 40, 12, Restart 40, 8, Quit 40).

  ```text
  queue slots width 184 | old inline label row ~ 230 | stacked panel height 232
  480x320: board 256 cell 26.22 | panel width 200 need 184 OK (inline 230 OVER) | panel height 308 need 232 OK
  531x320: board 307 cell 31.89 | panel width 200 need 184 OK (inline 230 OVER) | panel height 308 need 232 OK
  532x320: board 308 cell 32.00 | panel width 200 need 184 OK (inline 230 OVER) | panel height 308 need 232 OK
  568x320: board 308 cell 32.00 | panel width 236 need 184 OK (inline 230 OK) | panel height 308 need 232 OK
  740x360: board 348 cell 36.44 | panel width 368 need 184 OK (inline 230 OK) | panel height 348 need 232 OK
  ```

- 패널 안쪽 여백과 칸 옆 라벨의 넘침 범위 (4차 감사 D29·D30, `python3 -I` 실행 출력). 패널 안쪽 여백은 상하좌우 6으로 정했습니다. 그러면 세로 필요 높이는 232 + 2 × 6 = 244입니다.

  ```text
  inline label overflow widths at h=320, no panel padding: 480 .. 561
  inline label overflow widths at h=320, panel padding 6/side: 480 .. 573
  panel padding 6/side: min content width 188 vs need 184 -> OK (slack 4)
  panel padding 8/side: min content width 184 vs need 184 -> OK (slack 0)
  480x320: board 256 panel 200 content width 188 need 184 | panel height 308 need 244 (232 + 2x6)
  531x320: board 307 panel 200 content width 188 need 184 | panel height 308 need 244 (232 + 2x6)
  532x320: board 308 panel 200 content width 188 need 184 | panel height 308 need 244 (232 + 2x6)
  561x320: board 308 panel 229 content width 217 need 184 | panel height 308 need 244 (232 + 2x6)
  568x320: board 308 panel 236 content width 224 need 184 | panel height 308 need 244 (232 + 2x6)
  740x360: board 348 panel 368 content width 356 need 184 | panel height 348 need 244 (232 + 2x6)
  ```

- 큐 이동 커브: 2차 감사 계산으로 `Curves.easeOutBack`(0.175, 0.885, 0.32, 1.275)은 t = 0.5에서 1.0676이라 첫 칸이 제자리를 지나칩니다. 큐 이동은 easeOutCubic(0.875)을 써서 100ms 시점 x = x₀ + 0.125 × 칸 간격이 되고 AC-UI-15의 x > x₀ 검사를 통과합니다.

- 보드 프레임 반경: 반경 24에 안쪽 여백 0이면 모서리 셀이 잘리거나 반경이 보이지 않습니다(2차 감사 D20). 안쪽 여백 2와 반경 8(셀 반경 6 + 2, 동심원)로 정하고 프레임을 반경 8로 잘라냅니다.
- 이동 커브 계산 실행 출력: `easeOutCubic(0.5)=0.8750  opacity=0.8750  scale(0.96->1.0)=0.9950`.

## §5 폰트

- 결정: Nunito Regular(400), ExtraBold(800)를 `assets/fonts/`에 번들하고 `pubspec.yaml`의 `fonts:`에 선언합니다. 라이선스는 SIL Open Font License 1.1이며 `OFL.txt`를 함께 둡니다.
- 출처: Google Fonts 공식 배포본. 정확한 다운로드 URL과 파일 버전은 plan 단계에서 확인하지 않았으므로 run 단계에서 확인해 이 문서에 추가합니다.
- 웹 영향: 폰트 파일이 웹 빌드 asset에 포함되어 첫 로드 용량이 늘어납니다. 굵기당 수십~백수십 KB로 추정하지만 측정하지 않았으며, run 단계에서 `flutter build web` 결과로 실측합니다.
- 미확인: Nunito의 tabular figures(`tnum`) 지원 여부. 셀에는 숫자가 하나씩 가운데 정렬되므로 영향은 턴 카운터에 한정됩니다.
- 한글 글리프는 필요 없습니다 (UI 문구 영어 유지 결정).

## §6 검토한 대안

| 대안 | 판단 | 이유 |
|---|---|---|
| `animations` 패키지 (FadeThrough 등) | 제외 | 새 의존성. 필요한 전환은 `PageRouteBuilder`로 충분 |
| `google_fonts` 패키지 | 제외 | 새 의존성, 런타임 다운로드. asset 번들로 결정 |
| `go_router` | 제외 | 화면 3개라 이득 없음, 새 의존성 |
| 셀마다 AnimationController | 제외 | 81개 컨트롤러 수명 관리와 웹 성능 부담. implicit 애니메이션 사용 |
| domain에 지운 칸 목록 추가 | 제외 | domain 불변 결정. presentation에서 보드 비교로 해결 (0개 소거 매치 포함, `design.md` §7) |
| 셀 간격을 1로 줄이기 | 제외 | 셀 크기 하한은 맞지만 칸 경계가 흐려짐. 여백 조정으로 해결 |
| 시드 색 `ColorScheme.fromSeed`에 일부 역할만 덮어쓰기 | 제외 | 덮어쓰지 않은 역할이 토큰 밖 색으로 남음(2차 감사 D15). 범위 내 위젯이 읽는 역할을 모두 지정 |
| 저높이 가로를 "플레이 불가 허용"으로 범위 밖 처리 | 제외 | 사용자가 가로 휴대폰에서도 플레이 가능한 배치를 선택 |
| 저높이 가로에서 상단 바를 남기고 보드만 줄이기 | 제외 | 568×320에서 상단 바 56을 빼면 보드 252, 셀 25.8로 작아짐 |
| 골든 테스트 | 제외 | 플랫폼마다 폰트 렌더링 차이로 결과가 흔들림 |
| 앱 내 테마 토글 | 제외 | 사용자 결정 (`ThemeMode.system`만) |

## §7 미검증 항목

- `flutter analyze && flutter test` 기준선 (flutter가 PATH에 없음)
- Flutter SDK 정확한 버전
- 폰트 파일 출처 URL, 파일 크기, tabular figures 지원
- 웹(CanvasKit)에서 애니메이션 성능 (측정 계획 없음. 문제가 보이면 별도 SPEC)
- compact 세로 고정 영역 260 이하, 저높이 가로 사이드 패널 세로 내용 244(여백 포함)·필요 폭 184(안쪽 폭 최소 188) 가정 (run 단계 AC-UI-06, 07, 25 측정으로 확인. 줄 높이 28/24/20은 Nunito 실제 렌더링에 따라 달라질 수 있음)
- Material 위젯별 기본 색 역할 (AC-UI-01, 02로 확인)
- AC-UI-20이 기본 `MaterialPageRoute`에서 실패하는지 (run 단계 RED로 확인)
- 시간 지정 pump 앞의 시작 프레임 규칙(`tap → pump() → pump(Δ)`): 4차 감사가 `Ticker.start`의 시작 시각 처리로 근거를 제시했으며, plan 단계에서는 실행하지 못함. AC-UI-15·20의 run 단계 실행으로 확인
