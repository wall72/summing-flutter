# 기술 스택

## 런타임

| 항목 | 값 (`pubspec.yaml`) |
|------|------|
| Dart SDK | `>=3.5.0 <4.0.0` |
| 프레임워크 | Flutter (Material) |
| 상태 관리 | `flutter_riverpod ^2.6.1` |
| 저장소 | `shared_preferences ^2.3.2` |
| 오디오 | `audioplayers ^6.1.0` |
| 기타 | `meta ^1.12.0` |
| 개발용 | `flutter_test`, `flutter_lints ^5.0.0` |

앱 버전: `1.0.0+1`, `publish_to: "none"`.

## 정적 분석 (`analysis_options.yaml`)

- `package:flutter_lints/flutter.yaml` 포함
- 추가 규칙: `prefer_const_constructors`, `prefer_final_fields`, `avoid_print`
- 분석 제외: `build/`, `android/`, `ios/`, `windows/`, `macos/`, `web/`

## 저장 형식

- `shared_preferences` 키: `summing_settings`, `summing_savegame`, `summing_highscores`
- 저장 게임은 `SaveGameCodec`이 JSON으로 직렬화하며, JSON 키 `schemaVersion`에 `SaveGameCodec.currentSchemaVersion`(=1)을 기록합니다.
- 점수는 오름차순 정렬 후 상위 5개(`maxEntries = 5`)만 보관합니다.

## 개발 도구

- 검증: `flutter analyze && flutter test`
- 웹 실행: `run_chrome.sh`(Linux/WSL, 포트 7357, 고정 Chrome 프로필, `/mnt/<드라이브>/` 경로의 Windows Flutter SDK는 거부), `run_chrome.ps1`(Windows)
- 줄바꿈: `.gitattributes`에서 `* text=auto eol=lf`, 오디오·이미지는 binary
- 오디오 변환: `tools/convert_ios_aiff_to_wav.py` (`aifc`, `audioop` 필요 — Python 3.13에서 제거됨)
- CI: Dart 빌드·테스트 워크플로 없음. `.github/`, `.claude/`, `.moai/` 등 MoAI 구성은 아직 git에 추가되지 않았습니다.

## 플랫폼

- 웹: 주 대상. `web/manifest.json` 방향 `portrait-primary`
- Android: `applicationId = "com.example.summing_flutter"` (임시값)
- iOS: `com.example.summingFlutter` (임시값), 세로·가로 방향 모두 허용
