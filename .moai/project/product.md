# Summing — 제품 개요

## 한 줄 소개

Summing은 9×9 보드에 숫자를 놓아 이웃 칸 합의 일의 자리와 맞추며 보드를 비워 나가는 퍼즐 게임입니다. iOS 원작을 Flutter로 옮긴 버전이며, 웹을 주 플랫폼으로 삼습니다.

## 목표

- 웹을 주 플랫폼으로 두고 게임의 기능 완성도와 품질을 높입니다.
- `android/`, `ios/` 폴더는 유지하지만 우선순위는 낮습니다.
- 검증 기준: `flutter analyze && flutter test`

## 게임 규칙 (코드 기준: `lib/domain/summing_rules.dart`)

- 보드는 9×9이며, 바깥 한 줄은 비어 있고 안쪽 7×7은 0–9 무작위 숫자로 시작합니다.
- 다음에 놓을 숫자는 4칸 큐의 맨 앞 값입니다. 빈 칸에만 놓을 수 있습니다.
- 놓은 숫자가 숫자가 있는 8방향 이웃 칸 합의 일의 자리(`sum % 10`)와 같으면 이웃 칸이 모두 비워지고, 놓은 숫자는 기록되지 않습니다.
- 일치하지 않으면 그 칸에 숫자가 기록됩니다.
- 어느 경우든 턴 수가 1 증가하고 큐가 한 칸 당겨집니다.
- 모든 칸이 비면 클리어(`complete`), 모든 칸이 차면 게임 오버(`gameOver`)입니다.

## 기능 범위

| 영역 | 현재 동작 |
|------|-----------|
| 메뉴 | 새 게임, 이어하기, 점수판, 설정(메뉴 안의 Music·Sound effects 토글), How to Play |
| 게임 | 9×9 보드, 다음 숫자 큐, 재시작(진행 중이면 확인 대화상자), 종료(Quit), 클리어/게임 오버 오버레이(Play again / Back to menu) |
| 화면·연출 | 파스텔 라이트·다크 테마(시스템 밝기), 화면 크기별 반응형 배치(compact / medium / expanded / 저높이 가로), 셀·큐·화면 전환·오버레이 연출, 감속 모드 대응 (SPEC-UI-001) |
| 점수판 | 클리어한 판만 기록, 턴 수가 적은 순으로 상위 5개 |
| 저장 | 진행 중인 판을 매 수마다 저장, 앱 백그라운드 전환 시 저장, 끝난 판은 저장 삭제 |
| 오디오 | 배경음악, 탭·매치 효과음, 설정 반영, 웹 자동재생 제한 대응 |

## 범위

- 포함: 현재 구현된 메뉴·게임·점수판·저장·오디오, 테스트 보강, 아키텍처 개선
- 제외: 신규 게임 모드, 온라인 기능, 릴리스·배포 자동화
- 외부 시스템: 없음 (로컬 `shared_preferences`만 사용)
- 개발 형태: 1인 개발

## 알려진 개선 지점 (확인됨)

- (해결됨, SPEC-ARCH-001) application·presentation의 infrastructure 직접 의존은 포트 도입으로 제거되었고 `test/architecture/layer_boundary_test.dart`가 경계를 검사합니다.
- (해결됨, SPEC-UI-001) 진행 중인 판의 재시작은 확인 대화상자를 거칩니다.
- `web/index.html`의 `theme-color` 메타 태그가 이전 색(`#009688`)으로 남아 있습니다(`web/manifest.json`은 새 색으로 바뀜).
- 화면 전환(`AppPageRoute`)은 iOS 스와이프 뒤로 가기 제스처를 지원하지 않습니다.
- Android `applicationId = "com.example.summing_flutter"`, iOS `PRODUCT_BUNDLE_IDENTIFIER = com.example.summingFlutter`는 임시값입니다.
- `web/manifest.json`은 `portrait-primary`인데 iOS `Info.plist`는 가로 방향도 허용합니다.
- README가 L3에서는 "Web 플랫폼 중심"이라고 하면서 L104-112에서는 Android/iOS 릴리스 절차까지 안내합니다. 또 L115의 앱 ID `com.example.summing_flutter`는 Android 값이며 iOS bundle id(`com.example.summingFlutter`)와 다릅니다.
- `tools/convert_ios_aiff_to_wav.py`는 Python 3.13에서 제거된 `aifc`, `audioop` 모듈에 의존합니다.
- Dart용 CI 워크플로가 없습니다(`.github/workflows/`에는 `label-sync.yml`만 존재).

## Roadmap candidates (후보일 뿐, SPEC 미작성)

1. ~~재시작 전 확인 대화상자 추가 (진행 중인 판이 있을 때만)~~ (SPEC-UI-001로 완료)
2. ~~application 계층의 infrastructure 의존을 추상 인터페이스로 분리~~ (SPEC-ARCH-001로 완료)
3. ~~위젯 테스트 보강: `GamePage`, `BoardGrid`~~ (SPEC-UI-001로 보강), `ScoresPage`, `MenuPage`는 화면 대비·반응형 테스트만 추가됨
4. `GameAudioService` 테스트 및 `placeAt` 점수 기록, `restartGame`/`clearSession` 테스트 추가
5. `flutter analyze && flutter test`를 돌리는 GitHub Actions 워크플로
6. 웹 방향 정책과 iOS 방향 설정 정렬
7. 앱 식별자(applicationId / bundle id) 확정
8. 오디오 변환 스크립트를 Python 3.13 이후에서도 동작하도록 교체
