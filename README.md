# Summing (Flutter)

9×9 보드에 숫자를 배치해 이웃 합의 일의 자리와 맞추며 칸을 비우는 퍼즐 게임입니다. iOS 원작을 Flutter로 옮긴 버전이며, 현재 프로젝트 폴더는 **Web 플랫폼 중심**으로 유지합니다.

## 게임 요약

- 바깥 한 줄은 비어 있고, 안쪽 7×7에 0–9 숫자가 깔려 있음으로 시작합니다.
- 다음에 놓을 숫자는 4칸 큐의 맨 앞(1번 슬롯)입니다. 빈 칸을 탭하면 그 칸에 배치되고, 큐가 시프트됩니다.
- 배치한 값이 **이웃(8방향, 줄바꿈 없음)에 있는 숫자들의 합의 일의 자리**와 같으면, 그 이웃 칸들이 비워집니다.
- **모든 칸을 비우면** 클리어(턴 수가 적을수록 좋음). **모든 칸이 채워지면** 게임 오버입니다.

## 구현된 기능

| 영역 | 내용 |
|------|------|
| **도메인** | 보드, 이웃, 매치, 큐, 승패 판정 — UI 비의존 순수 Dart + 단위 테스트 |
| **세션** | 새 게임 / 이어하기 / 재시작, 수 저장(`savegame`), 클리어 시 Top 5 기록 |
| **연결** | 메뉴 복귀 시 이어하기 버튼 갱신, 백그라운드·일시정지 시 `persistIfNeeded`로 저장 일관성 |
| **UI** | 메뉴(설정·How to Play), 게임(9×9, 오버레이), 점수판, 보드 색: **빈 칸 어두운 회색 / 숫자 있는 칸 밝은 회색** |
| **오디오** | BGM·탭·매치 SFX, 설정 반영, 웹 등 자동재생 제한 대응(사용자 제스처 후 BGM) |

## 기술 스택

- **Flutter** (Dart ≥ 3.5)
- **flutter_riverpod** — `GameSessionNotifier` / `gameSessionProvider`
- **shared_preferences** — 설정, 세이브, 하이스코어(JSON)
- **audioplayers** — BGM / 효과음

## 플랫폼 구성

Web / Android / iOS 플랫폼 폴더를 모두 포함합니다.

```
web/  android/  ios/   # 플랫폼 설정
lib/                   # 앱 소스
assets/                # 오디오 에셋
test/                  # 테스트
```

## 시작하기

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) 설치
2. 프로젝트 루트로 이동:
   ```powershell
   cd C:\Users\user\Workspace\summing-flutter
   ```
3. 웹 플랫폼 폴더가 없다면 생성:
   ```powershell
   flutter create . --platforms web
   ```
4. 의존성 설치 및 테스트:
   ```powershell
   flutter pub get
   flutter test
   ```
5. Chrome에서 실행:
   ```powershell
   .\run_chrome.ps1
   ```

## 웹 빌드

릴리스용 웹 산출물은 아래 명령으로 생성합니다.

```powershell
flutter build web
```

빌드 결과는 `build\web`에 생성됩니다.

Chrome에서 개발 실행만 할 때는 빌드 명령이 아니라 아래 실행 명령을 사용합니다.

```powershell
flutter run -d chrome
```

### 웹(Chrome)에서 저장 데이터가 재실행 시 초기화되는 경우

`shared_preferences`의 웹 구현은 브라우저 `localStorage`(Origin 단위)에 저장됩니다.
개발 중 `flutter run -d chrome`를 그대로 쓰면 **실행마다 포트가 바뀌거나 임시 프로필이 바뀌어**(Origin/Profile 변경) 저장 데이터(진행상태·설정·하이스코어)가 새로 보일 수 있습니다.

아래처럼 **고정 포트 + 고정 Chrome user-data-dir**로 실행하면 재실행 후에도 동일 저장소를 사용합니다.

```powershell
.\run_chrome.ps1
```

`run_chrome.ps1`은 다음을 수행합니다.

- 스크립트 위치를 프로젝트 루트로 설정
- `web\index.html`이 없으면 `flutter create . --platforms web` 실행
- 전용 Chrome 프로필(`$HOME\AppData\Local\summing-flutter-chrome`) 사용
- 고정 포트 `7357`로 Chrome 실행

> 참고: 실제 배포(고정 도메인)에서는 동일 Origin을 사용하므로 이 현상이 재현되지 않습니다.

## 릴리즈 빌드

릴리즈 전 `flutter analyze && flutter test`를 통과시키세요.

| 플랫폼 | 명령 | 비고 |
|--------|------|------|
| Web | `flutter build web --release` | 결과: `build/web` |
| Android | `flutter build appbundle --release` | 아래 서명 설정 필요 |
| iOS | `flutter build ipa --release` | macOS + Xcode, Apple 서명 필요 |

### 릴리즈 전 필수 설정 (직접 해야 함)

- **앱 ID**: 현재 `com.example.summing_flutter` 입니다. 스토어 제출 전
  `android/app/build.gradle.kts`(`namespace`, `applicationId`)와
  Xcode의 Bundle Identifier(`ios/Runner.xcodeproj`)를 본인 ID로 바꾸세요.
- **Android 서명**: `android/key.properties`(git 제외)에
  `storeFile`, `storePassword`, `keyAlias`, `keyPassword`를 넣으면 release 빌드에 사용됩니다.
  없으면 debug 키로 서명되므로 스토어 업로드가 불가능합니다.
- **iOS 서명**: Xcode에서 Team / Provisioning 설정.
- **앱 아이콘**: 현재 Flutter 기본 아이콘입니다. `flutter_launcher_icons` 등으로 교체하세요.
- **버전**: `pubspec.yaml`의 `version: x.y.z+build` (빌드 번호는 제출마다 증가).

## 프로젝트 구조

```
web/ android/ ios/ # 플랫폼 설정
lib/
  domain/          # 규칙 엔진·모델
  application/     # 게임 세션(배치·저장·클리어 처리)
  infrastructure/  # 저장소, 오디오, 코덱
  presentation/    # menu / game / scores, lifecycle 저장 리스너
assets/audio/      # bg_music.mp3, tap_sound.wav, clap_sound.wav
tools/             # AIFF → WAV 변환 스크립트(엔디안)
test/              # domain·infrastructure·widget 스모크
run_chrome.ps1     # 고정 포트/프로필로 Chrome 실행
```

## 오디오 에셋

- `pubspec.yaml`에 등록된 파일만 번들에 포함됩니다.
- 원본 AIFF를 WAV로 쓸 때는 **PCM 엔디안**이 다릅니다. 그대로 복사하면 잡음이 날 수 있어 `tools/convert_ios_aiff_to_wav.py`로 변환하는 것을 권장합니다.

## 라이선스

원본·에셋 라이선스는 각 출처에 따릅니다. 이 저장소의 코드는 프로젝트 정책에 맞게 사용하세요.
