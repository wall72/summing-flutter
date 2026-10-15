# SPEC-UI-001 구현 계획

spec 0.3.2 기준. 4차 plan-audit(`.moai/reports/plan-audit/SPEC-UI-001-review-4.md`) 결함 D28-D31도 반영했습니다. 1차 plan-audit 결함 D1-D14, 2차 plan-audit(`.moai/reports/plan-audit/SPEC-UI-001-review-2.md`) 결함 D15-D22와 저높이 가로 배치 사용자 결정, 3차 plan-audit(`.moai/reports/plan-audit/SPEC-UI-001-review-3.md`) 결함 D23-D27을 반영했습니다.

## §A Context

- Epic: Summing 모던 크로스플랫폼 리팩토링
- Epic 구성: SPEC-ARCH-001 (Tier M, plan-audit 2차 PASS 0.91) → SPEC-UI-001 (이 문서, Tier L, `depends_on: [SPEC-ARCH-001]`)
- 이 SPEC은 ARCH-001이 만든 application 포트와 fake override(`test/support/test_overrides.dart`)를 사용해 위젯 테스트를 결정적으로 작성합니다.
- 개발 방식: `development_mode: tdd`. 재시작 흐름, 반응형 배치, 애니메이션 대상 선택은 테스트를 먼저 쓰기 좋은 구조입니다.

## §B Known Issues

- **기준선 미실행**: plan 단계 셸에서 `flutter`가 PATH에 없어(`command not found: flutter`) `flutter analyze && flutter test` 기준선을 실행하지 못했습니다. Flutter SDK 버전도 확인하지 못했습니다(3.27 이상으로 추정, `research.md` §2 참고).
- ARCH-001의 `game_page_characterization_test.dart`(AC-ARCH-16)는 "Restart 즉시 재시작"을 단언합니다. 이 SPEC M1에서 의도적으로 바꿉니다.
- Nunito 폰트 파일은 저장소에 없으므로 run 단계에서 공식 배포본(OFL 1.1)을 받아 와야 합니다. 출처 URL은 run 단계에서 확인 후 `research.md`에 기록합니다.
- Material 위젯은 테마의 ColorScheme 역할을 기본값으로 읽습니다. 시드 색 파생값을 남겨 두면 토큰 밖 색이 생기고 대비가 떨어집니다(TextButton·Switch 켜짐 트랙 1.60~1.68). 범위 내 위젯이 읽는 역할은 모두 `design.md` §1.1·§1.2대로 지정합니다.
- `kIsWeb`는 `flutter test`에서 false이므로 웹 첫 제스처 해제는 스위치 주입형 위젯으로 분리해야 테스트할 수 있습니다 (AC-UI-22).
- 현재 `web/manifest.json`은 `portrait-primary`이지만 브라우저 창과 데스크톱은 가로 저높이가 될 수 있어 저높이 가로 배치가 필요합니다. manifest 방향 정책 변경은 범위 밖입니다.

## §C Pre-flight (run 단계 첫 단계)

1. **[HARD] 기준선 실행**: `flutter --version` 기록 후 `flutter analyze && flutter test`를 실행하고, 종료 코드와 출력 끝부분을 `progress.md` §E.2에 남깁니다. 실패하면 구현에 들어가지 않고 blocker로 보고합니다.
2. **[HARD] 의존 SPEC 확인**: SPEC-ARCH-001의 frontmatter가 `status: completed`인지 확인합니다. `implemented`를 포함한 다른 값은 미충족이며, 이 경우 run에 들어가지 않습니다(depends_on Pre-flight 규칙). 완료 커밋 SHA를 `<ARCH_SHA>`로 기록합니다 (AC-UI-17, 19의 기준).
3. **AC 판별력 확인**: 변경 전 트리에서 아래 두 명령을 실행해 각각 4줄, 25줄 출력(plan 단계 실측값)을 확인하고 기록합니다. AC-UI-20 테스트는 M5에서 먼저 작성해 현재 `MaterialPageRoute` 상태에서 실패(RED)함을 기록합니다.

   ```bash
   grep -rnP "Color\(0x|Colors\.(?!transparent)" lib/presentation lib/main.dart | grep -v -e "lib/presentation/theme/" -e "lib/presentation/layout/"
   grep -rnE "Duration\(|Radius\.circular\(|fontSize: *[0-9]|EdgeInsets\.[a-zA-Z]+\([^)]*[0-9]|SizedBox\((height|width): *[0-9]" lib/presentation lib/main.dart | grep -v -e "lib/presentation/theme/" -e "lib/presentation/layout/"
   ```

4. 파일 단위 변경 목록(§F)을 TodoList로 분해합니다.

## §D Constraints

- 새 패키지 의존성 없음. `pubspec.yaml`은 `fonts:` 섹션만 추가합니다.
- `lib/domain/**`, `persistence_keys.dart`, `save_game_codec.dart`는 바꾸지 않습니다.
- application 계층의 동작을 바꾸지 않습니다. 재시작 확인은 presentation에서만 처리합니다.
- 무한 반복 애니메이션을 쓰지 않습니다 (`pumpAndSettle` timeout 방지).
- 디자인 토큰 소스는 `lib/presentation/theme/`와 `lib/presentation/layout/`입니다(`spec.md` §D). 색, 모션 시간, 반경, 글자 크기, 간격 리터럴은 이 두 폴더에만 둡니다 (AC-UI-16, 23).

## §E 설계 결정 (바뀔 가능성이 큰 순서)

| 순서 | 결정 | 채택안 |
|---|---|---|
| D-1 | 재시작 확인 흐름 | playing일 때만 대화상자. 확인 → `restartGame()`, Cancel·배리어·Esc·시스템 뒤로 → 변화 없음. 종료 상태에서는 바로 재시작. Quit는 확인 없음. 문구는 `design.md` §5 |
| D-2 | 반응형 배치 | 먼저 맞는 규칙 순서: 저높이 가로(높이 < 480, 폭 ≥ 480: 상단 바 없는 두 칸) → expanded(폭 ≥ 840) → medium(600–839) → compact. compact 보드 좌우 여백 6, 셀 간격 2, 프레임 안쪽 여백 2·반경 8 (`design.md` §4) |
| D-3 | 저높이 가로 크기 보장 | 보드 = min(높이 − 12, 폭 − 224). 568×320에서 보드 ≥ 304·셀 ≥ 31.5, 740×360에서 보드 ≥ 344·셀 ≥ 36 (설계값 308 / 32.00, 348 / 36.44) |
| D-4 | 색상 팔레트와 ColorScheme | 크림 배경, 라벤더 빈 칸, 흰 채운 칸, 핑크 primary(채움 전용), 진한 로즈 accentText·focus, 모든 칸 외곽선, 피치 배치 강조, 민트 매치 강조. 범위 내 Material 위젯이 읽는 ColorScheme 역할과 컴포넌트 테마를 모두 토큰으로 지정 (`design.md` §1.1, §1.2) |
| D-5 | 매치 애니메이션 대상 | 보드 위젯이 직전 보드와 새 보드를 비교. turnCount가 정확히 1 늘었을 때만 판정하고, 빈 칸 1개 채움 = 배치, 숫자 칸 1개 이상 비움 = 매치, 변화 없음 = 0개 소거 매치(셀 연출 없음) (`design.md` §7) |
| D-6 | 애니메이션 구현 방식 | 셀과 큐마다 implicit 애니메이션. 셀별 AnimationController와 셀 그림자는 쓰지 않음 (웹 성능). 연출 키(`cell.<i>.place`, `cell.<i>.match`, `cell.<i>.focusRing`, `queue.slot.<i>`)로 테스트 판정 |
| D-7 | 폰트 | Nunito 400, 800 번들. 숫자의 tabular figures는 폰트가 지원할 때만 적용 (`research.md` §5) |
| D-8 | 화면 전환 | 패키지 없이 fade + scale 전환 route(page 320ms, easeOutCubic). 종료 오버레이는 emphasized 300ms. 감속 모드에서는 0ms |
| D-9 | 웹 첫 제스처 해제 | `lib/main.dart`의 Listener를 스위치(운영값 `kIsWeb`)를 받는 위젯으로 분리. 동작은 그대로 |

## §F 마일스톤 (우선순위 순, 시간 추정 없음)

### M1 — UX 흐름과 레이아웃 골격 (Priority High, 3개 이상 파일)

- [NEW] `lib/presentation/game/widgets/restart_confirm_dialog.dart`, `lib/presentation/game/widgets/end_overlay.dart` (기존 `_EndOverlay` 분리), `lib/presentation/game/widgets/game_side_panel.dart` (expanded·저높이 가로 공용), `lib/presentation/layout/breakpoints.dart` (폭 600·840, 높이 480, 배치 판정 순서)
- [MODIFY] `lib/presentation/game/game_page.dart` (재시작 guard, 4가지 배치 클래스, 저높이 가로에서 상단 바 제거)
- [MODIFY] `test/presentation/game/game_page_characterization_test.dart` → 확인 대화상자 흐름으로 **의도적으로 변경**
- [NEW] `test/presentation/game/restart_dialog_test.dart`, `test/presentation/game/game_page_test.dart`
- 대상 AC: AC-UI-03, 04, 05, 08, 09, 10, 11, 25

### M2 — 디자인 토큰과 테마 (Priority High, 3개 이상 파일)

- [NEW] `lib/presentation/theme/app_tokens.dart`, `lib/presentation/theme/app_theme.dart` (ColorScheme 역할 전체 매핑, TextButton·OutlinedButton·Switch·ProgressIndicator·BottomSheet 컴포넌트 테마, surfaceTint 투명)
- [NEW] `lib/presentation/common/web_audio_unlock.dart` (D-9)
- [NEW] `assets/fonts/Nunito-Regular.ttf`, `assets/fonts/Nunito-ExtraBold.ttf`, `assets/fonts/OFL.txt`
- [MODIFY] `pubspec.yaml` (fonts), `lib/main.dart` (테마 연결, `ThemeMode.system`, 웹 해제 위젯 사용)
- [NEW] `test/presentation/theme/token_contrast_test.dart`, `test/presentation/theme/app_theme_test.dart`, `test/presentation/common/web_audio_unlock_test.dart`
- 대상 AC: AC-UI-01, 02, 19, 22, 24

### M3 — 화면별 반응형 스타일 (Priority High, 3개 이상 파일)

- [MODIFY] `lib/presentation/menu/menu_page.dart` (tonal 버튼·Switch 토큰, 저높이 가로 두 카드 + 스크롤), `lib/presentation/scores/scores_page.dart` (CircleAvatar 토큰, 스크롤), `lib/presentation/common/how_to_play_sheet.dart`, `lib/presentation/game/game_page.dart`
- [NEW] `test/presentation/responsive_layout_test.dart`
- 대상 AC: AC-UI-02(메뉴·점수판·시트 화면), 06, 07, 25

### M4 — 보드·큐 재스타일과 애니메이션 (Priority Medium, 3개 이상 파일)

- [NEW] `lib/presentation/game/widgets/board_cell.dart`, `lib/presentation/theme/app_motion.dart`
- [MODIFY] `lib/presentation/game/widgets/board_grid.dart` (직전 보드 비교, 프레임 여백 2·반경 8 잘라내기, 외곽선, 포커스 링, semantics 유지), `lib/presentation/game/widgets/next_queue_row.dart` (큐 이동 슬라이드 easeOutCubic, `queue.slot.<i>` 키, 첫 칸 외곽선 queueHeadOutline, 저높이 가로 패널에서 `Next:` 라벨을 칸 위 별도 줄로 배치)
- [NEW] `test/presentation/game/board_grid_test.dart`, `test/presentation/game/next_queue_row_test.dart`
- 대상 AC: AC-UI-12, 13, 14, 15, 21

### M5 — 화면 전환과 오버레이 진입 (Priority Medium, 3개 이상 파일)

- [NEW] `test/presentation/common/app_page_route_test.dart`를 먼저 작성해 현재 `MaterialPageRoute`에서 실패함을 기록 (§C-3)
- [NEW] `lib/presentation/common/app_page_route.dart`
- [MODIFY] `lib/presentation/game/widgets/end_overlay.dart`, 메뉴의 화면 이동 호출부
- 대상 AC: AC-UI-14 (감속 모드), 20

### M6 — 정리 (Priority Low, 3개 이상 파일)

- 하드코딩 값 제거 확인 (AC-UI-16, 23), `web/manifest.json`의 `theme_color`, `background_color`를 토큰과 맞춤
- 전체 `flutter analyze && flutter test --coverage`, 커버리지 측정 (AC-UI-17, 18)

## §G 리스크와 대응

| 리스크 | 대응 |
|---|---|
| 웹(CanvasKit)에서 셀 81개 애니메이션 성능 | implicit 애니메이션, 셀 그림자 없음, 애니메이션은 바뀐 셀에만 |
| 폰트 번들로 웹 첫 로드 용량 증가, 첫 화면에서 폰트가 바뀌어 보임(FOUT) | 2개 굵기만 번들. 용량은 run 단계에서 실측해 `progress.md`에 기록 |
| Material 위젯이 토큰에 없는 역할을 읽어 대비가 떨어짐 | ColorScheme 역할 전체 매핑 + AC-UI-01 동일성 검사 + AC-UI-02 화면 7종 검사 |
| 빠른 연속 탭에서 보드 비교 결과가 섞임 | 직전 GameState와 비교하고 turnCount +1일 때만 판정 (REQ-UI-016) |
| 0개 소거 매치를 배치로 오판 | 판정 표에 "변화 없음 = 매치, 셀 연출 없음"을 명시하고 AC-UI-12 세 번째 경우로 검증 |
| 반복 애니메이션으로 `pumpAndSettle` timeout | REQ-UI-019로 금지 |
| 839↔840, 479↔480 경계에서 창 크기 변경 시 상태 유실 | 배치만 바뀌고 상태는 provider에 있으므로 유지됨을 엣지 케이스로 검증 |
| compact 세로 고정 영역이 260을 넘어 셀이 36 미만이 됨 | AC-UI-07이 360×640에서 실측. 넘으면 세로 간격 토큰을 줄임 |
| 저높이 가로 사이드 패널 내용이 패널 폭(최소 200)이나 높이(308)를 넘음 | `Next:` 라벨을 큐 칸 위 별도 줄로 두고 패널 안쪽 여백을 6(상한 8)으로 고정해 안쪽 폭 최소 188 ≥ 필요 184, 필요 높이 244 ≤ 308 (`research.md` §4 양축 검산). AC-UI-06(480×320 포함)과 AC-UI-25가 넘침 없음을 실측 |
| 프레임 반경이 모서리 셀을 자름 | 프레임 여백 2와 반경 8(셀 반경 + 2)로 동심원 처리 |
| Nunito의 tabular figures 지원 여부 미확인 | 셀마다 숫자 하나를 가운데 정렬하므로 영향은 턴 카운터에 한정. 미지원이면 적용하지 않음 |

## mx_plan

`code_comments: ko`이므로 태그 설명은 한국어로 작성하고, 에이전트가 추가하는 태그에는 `[AUTO]` 접두어를 붙입니다.

| 대상 | 태그 | 우선순위 | 이유 |
|---|---|---|---|
| `BoardGrid`의 직전 보드 비교 로직 | `@MX:WARN` + `@MX:REASON` | High | 애니메이션 상태 수명주기, 연속 탭 경합, 0개 소거 매치 판정 |
| GamePage 재시작 guard | `@MX:NOTE` | High | playing일 때만 확인하는 정책 |
| `app_tokens.dart`의 색상 쌍 | `@MX:NOTE` | High | 대비 검증값. 바꾸면 `token_contrast_test` 재실행 필요 |
| `app_theme.dart`의 ColorScheme 매핑과 컴포넌트 테마 | `@MX:NOTE` | High | 역할을 빼면 Material 시드 파생값으로 돌아가 대비가 떨어짐(TextButton 1.68, Switch 1.60) |
| `breakpoints.dart`의 배치 판정 순서와 600 / 840 / 480, compact 여백 6 | `@MX:NOTE` | Medium | 매직 상수와 판정 순서. 여백을 늘리면 셀이 36 미만이 됨 (`design.md` §4) |
| `app_motion.dart`의 감속 모드 처리 | `@MX:NOTE` | Medium | 모든 애니메이션이 이 경로를 거쳐야 함 |
| `web_audio_unlock.dart` | `@MX:NOTE` | Medium | 브라우저 자동재생 해제. 운영 스위치는 `kIsWeb` |
| 재시작 확인 대화상자 진입 함수 | `@MX:ANCHOR` + `@MX:REASON` | Low | AppBar와 사이드 패널(expanded·저높이 가로)에서 호출. 호출처가 3곳 이상이면 ANCHOR, 아니면 NOTE로 낮춤 |

## §H Cross-References

- `spec.md` §C (REQ-UI-001 ~ 024), `acceptance.md` (AC-UI-01 ~ 25)
- `design.md`, `research.md`, `interview.md`
- `.moai/specs/SPEC-ARCH-001/acceptance.md` §D.2 — Restart 동작 고정 테스트의 의도된 변경
- `.moai/reports/plan-audit/SPEC-UI-001-review-1.md`, `SPEC-UI-001-review-2.md`, `SPEC-UI-001-review-3.md`, `SPEC-UI-001-review-4.md` — 1~4차 감사
