# SPEC-UI-001 디자인 사양

디자인 결정을 표로 정리한 문서입니다. 코드는 담지 않습니다. 대비 수치는 모두 WCAG 공식으로 다시 계산한 값이며 측정 근거는 `research.md` §3에 있습니다 (spec 0.3.2 기준). 이 문서의 토큰은 `lib/presentation/theme/`와 `lib/presentation/layout/`(디자인 토큰 소스, `spec.md` §D)에 구현됩니다.

## §1 색상 토큰

| 토큰 | Light | Dark | 쓰임 | 대비 (측정값, Light / Dark) |
|---|---|---|---|---|
| background | `#FFF8F1` 크림 | `#1C1924` 짙은 자두빛 회색 | 화면 배경, 상단 바 | — |
| surfaceContainer | `#FFFFFF` | `#262230` | 카드, 대화상자, 시트, 보드 프레임 | — |
| onSurface | `#2E2A3A` | `#F4EFFF` | 본문, 셀 숫자(digit), 목록 제목 | background 13.22 / 15.35, surfaceContainer 13.92 / 13.77 |
| onSurfaceVariant | `#5E5670` | `#CFC6E0` | 보조 문구, 목록 부제, Switch 꺼짐 thumb | background 6.56 / 10.55, surfaceContainer 6.91 / 9.46 |
| accentText | `#9C3358` | `#F4B6C2` | TextButton·OutlinedButton 전경, Switch 켜짐 트랙, 진행 표시기 | background 6.59 / 10.15, surfaceContainer 6.94 / 9.10 |
| focus | `#9C3358` | `#F4B6C2` | 키보드 포커스 링 (accentText와 같은 값) | cellEmpty 4.17 / 9.81, cellFilled 6.94 / 5.44, 보드 프레임 6.94 / 9.10 |
| onAccent | `#FFFFFF` | `#3B1F2B` | Switch 켜짐 thumb | accentText 6.94 / 8.69 |
| cellEmpty | `#CEC3EB` 라벤더 | `#1F1C28` | 빈 칸 채움, Switch 꺼짐 트랙 | Switch 꺼짐 thumb(onSurfaceVariant) 4.15 / 10.20 |
| cellFilled | `#FFFFFF` | `#4A4266` | 숫자가 있는 칸 채움 | digit 13.92 / 8.24 |
| cellOutline | `#8E80B8` | `#9C90C8` | 모든 칸의 1px 외곽선, OutlinedButton 테두리, Switch 꺼짐 테두리, 시트 손잡이 | surfaceContainer 3.54 / 5.35, background 3.36 / 5.96 |
| placeHighlight | `#FFE1C7` 피치 | `#6B4A33` | 배치 직후 강조 | digit 11.17 / 7.03 |
| matchFlash | `#C9EEDC` 민트 | `#2E5A4B` | 매치로 지워지는 칸 | digit 11.10 / 6.95 |
| primary | `#F6B7C4` 핑크 | `#F4B6C2` | FilledButton 채움 (텍스트 전경으로는 쓰지 않음) | — |
| onPrimary | `#3B1F2B` | `#3B1F2B` | FilledButton 문구 | primary 8.81 / 8.69 |
| queueHeadContainer | `#FCD9E0` | `#6A3A4C` | 큐 첫 칸, tonal 버튼 채움, CircleAvatar 배경 | — |
| onQueueHead | `#3B1F2B` | `#FFE3EA` | 큐 첫 칸 숫자, tonal 버튼 문구, CircleAvatar 순위 숫자 | queueHeadContainer 11.39 / 7.50 |
| queueHeadOutline | `#9C3358` | `#F4B6C2` | 큐 첫 칸 2px 외곽선 (accentText와 같은 값) | background 6.59 / 10.15, surfaceContainer 6.94 / 9.10, queueHeadContainer 5.33 / 5.30 |
| inverseSurface | `#2E2A3A` | `#F4EFFF` | SnackBar 배경 | — |
| onInverseSurface | `#F4EFFF` | `#2E2A3A` | SnackBar 문구 | inverseSurface 12.36 / 12.36 |
| inversePrimary | `#F4B6C2` | `#9C3358` | SnackBar 액션 | inverseSurface 8.17 / 6.15 |
| scrim | onSurface 40% | background 70% | 종료 오버레이 배경 | `Colors.black54` 대체 |

### §1.1 Material ColorScheme 역할 매핑

테마는 Material이 위젯 기본값으로 읽는 역할을 모두 아래 토큰으로 채웁니다. 시드 색에서 자동으로 만들어지는 역할에 기대지 않습니다. AC-UI-01이 이 표와 실제 `ThemeData.colorScheme`이 같은지 검사합니다.

| ColorScheme 역할 | 토큰 | 이 역할을 읽는 범위 내 위젯 |
|---|---|---|
| primary / onPrimary | primary / onPrimary | FilledButton (New Game, Play again, 대화상자 Restart) |
| primaryContainer / onPrimaryContainer | queueHeadContainer / onQueueHead | CircleAvatar (점수판 순위) |
| secondaryContainer / onSecondaryContainer | queueHeadContainer / onQueueHead | FilledButton.tonal (Resume Game) |
| surface / onSurface | background / onSurface | Scaffold, AppBar, ListTile 제목, SwitchListTile 제목 |
| onSurfaceVariant | onSurfaceVariant | ListTile 부제, 보조 문구 |
| surfaceContainerLowest / Low / (기본) / High | surfaceContainer | Card, AlertDialog, 바텀 시트 |
| surfaceContainerHighest | cellEmpty | Switch 꺼짐 트랙 |
| outline | cellOutline | OutlinedButton 테두리, Switch 꺼짐 테두리 |
| outlineVariant | cellEmpty | Divider (장식, 대비 기준 예외) |
| inverseSurface / onInverseSurface / inversePrimary | inverseSurface / onInverseSurface / inversePrimary | SnackBar |
| surfaceTint | 투명 | 높이(elevation)에 따른 색 덧칠과 스크롤 시 AppBar 색 변화를 끔 |
| error / onError, tertiary 계열 | Material 기본값 유지 | 범위 내 위젯이 쓰지 않음 |

### §1.2 컴포넌트 테마 지정

| 위젯 | 지정 |
|---|---|
| TextButton, OutlinedButton | 전경 accentText (Material 기본값 primary는 대비 1.68이라 금지) |
| Switch (SwitchListTile) | 켜짐: 트랙 accentText, thumb onAccent. 꺼짐: 트랙 cellEmpty, 테두리 cellOutline, thumb onSurfaceVariant |
| CircularProgressIndicator | 색 accentText |
| 바텀 시트 손잡이 | cellOutline |
| SnackBar | §1.1의 inverse 역할 사용 (기본 동작) |
| 비활성 컨트롤 | Material 기본 비활성 색(onSurface 38% / 12%). WCAG 1.4.3·1.4.11의 비활성 컴포넌트 예외로 대비 검사에서 제외 |
| hover·포커스·눌림 상태 레이어 | Material 기본(전경색 8% / 10% / 10%를 배경에 덧칠). 덧칠 비율이 클수록 대비가 낮아지므로 10% 경우를 최악값으로 측정 (`research.md` §3, AC-UI-01) |

### 판정 기준

- 텍스트(숫자, 문구, 버튼 라벨): WCAG 1.4.3 기준 4.5:1 이상.
- 칸 경계, 포커스 링, 컨트롤 경계와 상태 표시: WCAG 1.4.11(비텍스트) 기준 3:1 이상. 칸 경계는 외곽선 색과 보드 프레임 색의 대비로 판정합니다. 채움색끼리의 차이(빈 칸 대 채운 칸 1.66 / 1.80, 다크 빈 칸 대 프레임 1.08)는 기준에 넣지 않고 보조 신호로만 봅니다.
- 채워진 칸에는 항상 숫자가 있으므로 빈 칸과 채운 칸의 구분은 숫자(4.5:1 이상)로 보장됩니다.

### 이전 버전에서 바꾼 값

| 항목 | 이전 | 현재 | 이유 |
|---|---|---|---|
| 텍스트 버튼 전경 (0.2.0) | Material 기본값 primary `#F6B7C4` | accentText | 기본값은 흰 배경 대비 1.68, 크림 배경 대비 1.60 |
| Light focus (0.2.0) | `#B4476A` | `#9C3358` | 빈 칸 대비 3.12 → 4.17 |
| 칸 외곽선 (0.2.0) | 채운 칸만 | 모든 칸 | 다크 빈 칸이 프레임 대비 1.08, 배경 대비 1.03 |
| tonal 버튼·CircleAvatar (0.3.0) | 시드 색 자동 파생 | queueHeadContainer / onQueueHead | 토큰 밖 색이었고 대비 미측정 |
| Switch, SnackBar, 진행 표시기, 시트 손잡이 (0.3.0) | 시드 색 자동 파생 | §1.1, §1.2 지정 | 같은 이유. Switch 켜짐 트랙을 primary로 두면 배경 대비 1.60 |
| 큐 첫 칸 외곽선 (0.3.1) | `scheme.primary` `#F6B7C4` (현재 코드 `next_queue_row.dart:36`) | queueHeadOutline | primary는 배경 대비 1.60 |
| 저높이 패널의 `Next:` 라벨 (0.3.1) | 칸 옆 같은 줄(약 230) | 칸 위 별도 줄(184) | 높이 320에서 폭 480~561의 패널 폭(200~229)을 넘침 (패널 안쪽 여백 6을 빼면 480~573) |

## §2 형태와 간격

| 범주 | 값 |
|---|---|
| Radius | xs 6 (셀), sm 10 (큐 칸), frame 8 (보드 프레임 = 셀 반경 6 + 프레임 안쪽 여백 2, 모서리 동심원), md 16 (카드), lg 24 (대화상자, 시트), 버튼은 stadium |
| Spacing | 4pt 스케일: 2(셀 간격·프레임 여백 전용), 4, 6(compact 보드 여백 전용), 8, 12, 16, 24, 32, 48 |
| 보드 바깥 여백 | compact 좌우 6, medium 좌우 16, expanded 좌우 24, 저높이 가로 상하·좌우 6 |
| 저높이 가로 사이드 패널 안쪽 여백 | 상하좌우 6 (상한 8, 안쪽 폭 최소 188 ≥ 큐 184) |
| 보드 프레임 안쪽 여백 | 2 (프레임 색이 셀 사이 간격과 같은 두께로 보드 테두리에도 보임) |
| 보드 프레임 잘라내기 | 반경 8로 잘라냄(anti-alias). 안쪽 여백 2 덕분에 모서리 셀(반경 6)은 잘리지 않음 |
| 셀 간격 | 2 (9칸 사이 8곳) |
| 셀 외곽선 | 1 (셀 크기 안쪽에 그림, 셀 크기에 영향 없음) |
| Elevation | 셀에는 그림자 없음. 카드·대화상자만 부드러운 그림자 (blur 12, y 4, primary 12%) |

## §3 타이포그래피

| 용도 | 크기 / 굵기 |
|---|---|
| 앱 제목 "Summing" | 40 / 800 (저높이 가로 사이드 패널에서는 20 / 800) |
| headline (오버레이 제목) | 28 / 800 |
| title (상단 바, 섹션) | 20 / 700 |
| body | 16 / 400 |
| label (버튼) | 14 / 700 |
| 셀 숫자 | 셀 한 변 × 0.5 / 800 |
| 큐 숫자 | 24 / 800 (저높이 가로에서는 20 / 800) |

- 글꼴: Nunito (Regular 400, ExtraBold 800). 700은 800으로 대체 렌더링됩니다.
- 숫자 tabular figures는 폰트가 지원할 때만 적용합니다 (턴 카운터 폭 흔들림 방지).
- 모든 문구는 영어입니다.

## §4 반응형 배치

배치 클래스는 위에서부터 먼저 맞는 규칙을 씁니다.

| 순서 | 클래스 | 조건 | 게임 화면 | 메뉴 | 점수판 |
|---|---|---|---|---|---|
| 1 | 저높이 가로 | 높이 < 480 이고 폭 ≥ 480 | 상단 바 없음. 두 칸: 보드(왼쪽) + 사이드 패널(오른쪽, 폭 200 이상: 제목, 턴 수, 큐, Restart, Quit) | 카드 두 개 나란히, 각 카드 세로 스크롤 | 목록 최대 폭 560, 세로 스크롤 |
| 2 | expanded | 폭 ≥ 840 (높이 ≥ 480) | 두 칸: 보드(높이에 맞춤, 최대 640) + 상단 바 + 오른쪽 사이드 패널(폭 280–320: 턴 수, 큐, Restart, Quit) | 카드 두 개 나란히: 시작 버튼 카드 + 설정·How to Play 카드 | 목록 최대 폭 560, 가운데 정렬 |
| 3 | medium | 600 ≤ 폭 < 840 (높이 ≥ 480) | 한 열, 보드 한 변 최대 560, 큐 칸 크게 | compact와 같고 여백만 넓힘 | 목록 최대 폭 560 |
| 4 | compact | 그 밖 (폭 < 600) | 한 열: 상단 바(제목, Restart, Quit) → 턴 수 → 큐 → 보드 | 가운데 카드 하나(최대 폭 440), 버튼 세로 배치, 높이가 모자라면 세로 스크롤 | 목록 한 열 |

### 보드와 셀 크기 계산

- 셀 한 변 = (보드 한 변 − 2 × 프레임 여백 2 − 8 × 셀 간격 2) / 9 = (보드 한 변 − 20) / 9.
- compact·medium 보드 한 변 = min(폭 − 좌우 여백 합, 높이 − 세로 고정 영역). compact 세로 고정 영역(상단 바, 턴 수, 큐, 위아래 간격)은 260 이하로 잡습니다.
- 저높이 가로 보드 한 변 = min(높이 − 12, 폭 − 6 − 12 − 6 − 200). 12는 위아래 여백 6씩, 두 번째 항은 왼쪽 여백 6 + 보드·패널 사이 12 + 오른쪽 여백 6 + 사이드 패널 최소 폭 200입니다. 사이드 패널 폭 = 폭 − 24 − 보드 한 변이며, 폭 480~532에서는 정확히 200입니다.
- 저높이 가로 사이드 패널은 내용을 세로로 쌓고, **큐의 `Next:` 라벨은 네 칸 위 별도 줄에 둡니다** (§5). - **저높이 가로 사이드 패널 안쪽 여백은 상하좌우 6(spacing 6 토큰, 상한 8)입니다.** 패널 안쪽 폭 = 패널 폭 − 12이며 최소 188입니다. 가로 필요 폭 = 큐 네 칸 4 × 40 + 3 × 8 = 184 ≤ 188 (여유 4). 여백을 8로 늘리면 여유가 0, 8을 넘기면 넘칩니다. 라벨을 칸 옆에 두면 약 230이 필요해 높이 320에서 폭 480~561(여백 6 포함 시 480~573)에서 넘칩니다. 세로 필요 높이 = 위아래 여백 6 × 2 + 제목 줄 28 + 8 + 턴 수 줄 24 + 8 + `Next:` 라벨 줄 20 + 4 + 큐 칸 40 + 12 + `Restart` 40 + 8 + `Quit` 40 = 244 ≤ 패널 높이(높이 − 12).

| 뷰포트 | 보드 | 패널 폭 → 안쪽 폭 / 필요 184 | 패널 높이 / 필요 244 |
|---|---|---|---|
| 480 × 320 | 256 | 200 → 188 충족 | 308 충족 |
| 531 × 320 | 307 | 200 → 188 충족 | 308 충족 |
| 561 × 320 | 308 | 229 → 217 충족 | 308 충족 |
| 568 × 320 | 308 | 236 → 224 충족 | 308 충족 |
| 740 × 360 | 348 | 368 → 356 충족 | 348 충족 |

| 뷰포트 | 클래스 | 보드 한 변 | 셀 한 변 | 기준 |
|---|---|---|---|---|
| 360 × 640 | compact | min(348, 380) = 348 | 36.44 | REQ-UI-009 ≥ 36 충족 |
| 360 × 780 | compact | 348 | 36.44 | 충족 |
| 599 × 640 | compact | min(587, 380) = 380 | 40.00 | 충족 |
| 320 × 568 | compact | min(308, 308) = 308 | 32.00 | 하한 대상 아님 (넘침 없음만) |
| 700 × 1000 | medium | min(668, 560, 740) = 560 | 60.00 | 최대 560 |
| 568 × 320 | 저높이 가로 | min(308, 344) = 308 | 32.00 | REQ-UI-024 보장: 보드 ≥ 304, 셀 ≥ 31.5 |
| 740 × 360 | 저높이 가로 | min(348, 516) = 348 | 36.44 | REQ-UI-024 보장: 보드 ≥ 344, 셀 ≥ 36 |
| 812 × 375 | 저높이 가로 | 363 | 38.11 | 참고 |
| 480 × 320 | 저높이 가로 | min(308, 256) = 256 | 26.22 | 셀 크기 보장 대상 아님. 넘침 없음은 요구 (REQ-UI-008, AC-UI-06). 패널 폭 200, 높이 308 |

보장값은 설계값에서 4px(셀 0.5px) 여유를 둔 값입니다. 0.2.0의 단일 열 배치였다면 568 × 320에서 보드 60, 셀 4.44로 플레이할 수 없었습니다. 프레임 안쪽 여백 2를 넣으면서 compact 여백을 8에서 6으로 줄였습니다 (여백 8이면 360 폭 셀이 정확히 36.00으로 여유가 없음).

## §5 컴포넌트

| 컴포넌트 | 사양 |
|---|---|
| 재시작 확인 대화상자 | 배경 surfaceContainer, radius lg. 제목 "Restart game?", 본문 "Your current progress will be lost."(onSurfaceVariant). 버튼 "Cancel"(TextButton, accentText) / "Restart"(FilledButton, primary + onPrimary). 배리어 탭·Esc·시스템 뒤로 가기로 닫힘 |
| 종료 오버레이 | scrim 위 surfaceContainer 카드. complete: "Complete!" + "Finished in N turns.", gameOver: "Game Over" + "The board is full.". 버튼 "Play again"(FilledButton), "Back to menu"(TextButton, accentText). 기존 문구 유지 |
| 상단 바 | 배경 background. `Restart`, `Quit`는 TextButton, 전경 accentText. 저높이 가로에서는 없음 |
| 사이드 패널 | expanded와 저높이 가로 공용. 키 `game.sidePanel`. 저높이 가로에서는 안쪽 여백 상하좌우 6(상한 8), 내용을 세로로 쌓음 (§4) |
| 큐 행 | 4칸, 칸 폭 44(저높이 가로 40), 칸 사이 8 (칸 간격 = 칸 폭 + 8). 첫 칸은 queueHeadContainer + onQueueHead + 2px 외곽선 queueHeadOutline, 나머지는 surfaceContainer + onSurface. "Next:" 라벨 유지: compact·medium·expanded에서는 칸 왼쪽 같은 줄, **저높이 가로 패널에서는 네 칸 위 별도 줄**(필요 폭 184, §4). 큐가 당겨질 때 새 첫 칸이 오른쪽 한 칸 간격에서 제자리로 미끄러짐(커브 easeOutCubic, §6) |
| 보드 셀 | 모든 칸에 cellOutline 1px. 빈 칸: cellEmpty, 탭 가능하면 hover/press 시 살짝 밝아짐. 채운 칸: cellFilled + 숫자(onSurface). 포커스 시 focus 색 2px 링 |
| 버튼 | stadium 모양. FilledButton(primary + onPrimary), FilledButton.tonal(queueHeadContainer + onQueueHead), OutlinedButton·TextButton(전경 accentText, 테두리 cellOutline) |
| 메뉴 설정 | SwitchListTile 2개(Music, Sound effects). Switch 색은 §1.2 |
| 점수판 | ListTile + CircleAvatar(queueHeadContainer + onQueueHead), Divider(outlineVariant, 장식) |
| SnackBar | inverseSurface + onInverseSurface, 액션 inversePrimary |
| How to Play 시트 | 배경 surfaceContainer, 손잡이 cellOutline, 문구 onSurface / onSurfaceVariant |

## §6 모션

| 토큰 | 시간 | 커브 | 쓰임 |
|---|---|---|---|
| fast | 120ms | easeOutCubic | 탭 반응, hover |
| base | 200ms | 배치 팝: easeOutBack, 큐 이동: easeOutCubic | 배치 팝(scale 0.85→1.0 + fade), 큐 이동(새 첫 칸이 한 칸 간격만큼 미끄러짐). 큐 이동에 easeOutBack을 쓰면 절반 시점 값이 1.0676으로 제자리를 지나쳐 AC-UI-15의 x > x₀ 검사를 통과할 수 없음 |
| emphasized | 300ms | easeOutCubic | 매치 소거(민트 flash → fade out), 종료 오버레이 진입(fade + scale 0.96→1.0) |
| page | 320ms | easeOutCubic | 화면 전환(fade + scale 0.96→1.0) |

- 절반 시점 기대값: easeOutCubic(0.5) = 0.875 → opacity 0.875, scale 0.96 + 0.04 × 0.875 = 0.995 (AC-UI-20).
- 감속 모드(`MediaQuery.disableAnimations`)에서는 모든 시간이 0입니다.
- 무한 반복 애니메이션은 쓰지 않습니다.
- 애니메이션은 상태 변화를 따라가는 표현일 뿐이며 입력을 막지 않습니다.

## §7 보드 변화 판정 (개념)

도메인 규칙: 매치가 되면 놓은 숫자는 기록되지 않고 8방향 이웃이 모두 비워집니다(`lib/domain/summing_rules.dart:37-42`, `lib/domain/board.dart:59-66`). 그래서 매치 한 번에 지워지는 숫자 칸은 0~8개입니다.

| 직전 → 새 상태 | 판정 | 연출 |
|---|---|---|
| turnCount +1, 빈 칸 정확히 하나가 채워지고 나머지는 그대로 | 배치 (매치 아님) | 그 칸에 배치 팝 + placeHighlight |
| turnCount +1, 숫자 칸 하나 이상(1~8개)이 비워지고 새로 채워진 칸은 없음 | 매치 (k ≥ 1 소거) | 비워진 칸에만 matchFlash 후 fade out |
| turnCount +1, 보드 변화 없음 | 매치 (0개 소거: 이웃에 숫자가 없는 칸에 0을 놓은 경우) | 셀 연출 없음. 큐 이동과 턴 수 변경만 |
| turnCount가 0으로 돌아감, 또는 +1이 아닌 변화 (새 판, 재시작, resume) | 재시작·resume | 셀 단위 연출 없음 (보드 전체 fade만 허용) |
