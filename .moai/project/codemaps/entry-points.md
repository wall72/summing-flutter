# 진입점

| 진입점 | 설명 |
|--------|------|
| `lib/main.dart` | `runApp(ProviderScope(...))`, `gameAudioServiceProvider`를 watch해 오디오 초기화, `kIsWeb` 분기 포함. 위젯 구성: `ProviderScope` → `GameLifecycleListener` → `SummingApp`(MaterialApp, `home: MenuPage`) |
| `MenuPage` | 새 게임 / 이어하기 / 점수판 / 설정 / How to Play |
| `GamePage` | 보드 탭 → `placeAt`, 재시작 → `restartGame` |
| `GameLifecycleListener` | inactive·paused·hidden·detached에서 `persistIfNeeded`, paused·hidden·detached에서 BGM `suspend`, resumed에서 `resume`(저장 없음) |
| `run_chrome.sh` / `run_chrome.ps1` | 개발용 웹 실행 (포트 7357) |
| `flutter test` | `test/` 아래 11개 테스트 파일 |
