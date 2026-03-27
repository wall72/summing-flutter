# Summing (Flutter)

9×9 보드에 숫자를 배치해 이웃 합의 일의 자리와 맞추며 칸을 비우는 퍼즐 게임입니다. iOS 원작을 Flutter로 옮긴 멀티플랫폼 버전입니다.

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

## 시작하기

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) 설치
2. 플랫폼 폴더가 없다면 프로젝트 루트에서:
   ```bash
   flutter create . --project-name summing_flutter
   ```
3. 의존성 및 테스트:
   ```bash
   flutter pub get
   flutter test
   flutter run
   ```

### 웹(Chrome)에서 저장 데이터가 재실행 시 초기화되는 경우

`shared_preferences`의 웹 구현은 브라우저 `localStorage`(Origin 단위)에 저장됩니다.
개발 중 `flutter run -d chrome`를 그대로 쓰면 **실행마다 포트가 바뀌거나 임시 프로필이 바뀌어**(Origin/Profile 변경) 저장 데이터(진행상태·설정·하이스코어)가 새로 보일 수 있습니다.

아래처럼 **고정 포트 + 고정 Chrome user-data-dir**로 실행하면 재실행 후에도 동일 저장소를 사용합니다.

```bash
flutter run -d chrome \
  --web-hostname localhost \
  --web-port 7357 \
  --web-browser-flag="--user-data-dir=$HOME/.config/summing-flutter-chrome"
```

> 참고: 실제 배포(고정 도메인)에서는 동일 Origin을 사용하므로 이 현상이 재현되지 않습니다.

## 프로젝트 구조

```
lib/
  domain/          # 규칙 엔진·모델
  application/     # 게임 세션(배치·저장·클리어 처리)
  infrastructure/  # 저장소, 오디오, 코덱
  presentation/    # menu / game / scores, lifecycle 저장 리스너
assets/audio/      # bg_music.mp3, tap_sound.wav, clap_sound.wav
tools/             # AIFF → WAV 변환 스크립트(엔디안)
test/              # domain·infrastructure·widget 스모크
```

## 오디오 에셋

- `pubspec.yaml`에 등록된 파일만 번들에 포함됩니다.
- 원본 AIFF를 WAV로 쓸 때는 **PCM 엔디안**이 다릅니다. 그대로 복사하면 잡음이 날 수 있어 `tools/convert_ios_aiff_to_wav.py`로 변환하는 것을 권장합니다.

## 라이선스

원본·에셋 라이선스는 각 출처에 따릅니다. 이 저장소의 코드는 프로젝트 정책에 맞게 사용하세요.
