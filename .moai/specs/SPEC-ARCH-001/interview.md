# SPEC-ARCH-001 인터뷰 기록

`/moai plan "모던한 스타일의 크로스플랫폼 퍼즐 게임으로 리팩토링"` 진행 중 오케스트레이터가 받은 사용자 답변입니다. Epic 전체(SPEC-ARCH-001, SPEC-UI-001)에 공통으로 적용됩니다.

## 인터뷰 (4문항)

| # | 질문 주제 | 사용자 답변 | 이 SPEC에 미치는 영향 |
|---|---|---|---|
| 1 | 스타일 방향 | 파스텔 / 소프트 캐주얼 (둥근 모서리, 부드러운 색, 친근한 느낌). 숫자 대비는 WCAG AA 유지, 라이트·다크 모두 지원 | 없음 (SPEC-UI-001 범위) |
| 2 | 리팩토링 범위 | UI 전면 개편 + 구조 정리. domain 계층(규칙)은 그대로. application(`game_session_notifier.dart`)과 presentation(`menu_page.dart`)이 infrastructure 구체 타입을 직접 가져오는 문제를 추상화/포트로 해결 | **이 SPEC의 핵심 범위** |
| 3 | 크로스플랫폼 수준 | 휴대폰·태블릿·데스크톱 폭에 반응하는 웹 (웹이 주 플랫폼). android/ios는 같은 코드로 계속 빌드, 새 플랫폼 러너 없음 | 없음 (SPEC-UI-001 범위) |
| 4 | 경험 범위 | 화면 연출만 (배치·매치 애니메이션, 화면 전환, 진행 중일 때 재시작 확인). 새 게임 모드·규칙 변경·온라인 기능 없음. 저장 `schemaVersion`(=1)과 shared_preferences 키 호환 유지 | 저장 호환 불변식(REQ-ARCH-014) |

## 확인 질문 (Decision Point 1 이후, 3문항)

| # | 주제 | 결정 | 이 SPEC에 미치는 영향 |
|---|---|---|---|
| 1 | UI 문구 언어 | 영어 유지, l10n 프레임워크 도입 없음 | 없음 |
| 2 | 폰트 | Nunito Regular + ExtraBold(OFL)를 asset으로 번들, 새 패키지 의존성 없음 | 없음 (SPEC-UI-001 범위) |
| 3 | 테마 전환 | 시스템 밝기만 따름(`ThemeMode.system`), 앱 내 토글 없음, `AppSettings` JSON 변경 없음 | `AppSettings` JSON 형태 불변(REQ-ARCH-004) 확정 |

## 추가 확정 사항

- 재시작 확인은 `phase == playing`이면 턴 수와 관계없이 표시하고, Quit는 확인하지 않습니다 (SPEC-UI-001에 적용).
- SPEC은 2개로 나누고 SPEC-ARCH-001을 먼저 진행합니다. Tier는 ARCH-001 = M, UI-001 = L.
- 브랜치 작업과 GitHub 이슈 생성은 하지 않습니다.
