# 코드맵 개요

Flutter 앱 하나로 구성되며, `lib/` 아래 Dart 파일 47개(약 3,350줄)가 4개 계층으로 나뉩니다.

| 계층 | 역할 |
|------|------|
| `domain` | 보드·큐·규칙·국면 판정. 순수 Dart, 불변 값 객체 |
| `application` | 추상 포트(`ports.dart`), 포트 provider, 조회 provider(`app_queries.dart`), `GameSessionNotifier` — 세션 상태·저장·오디오 조율 |
| `infrastructure` | 포트 구현: `shared_preferences` 저장소, `audioplayers` 오디오. `appOverrides`로 포트에 연결(composition root) |
| `presentation` | 메뉴·게임·점수판 화면, 생명주기 리스너, 디자인 토큰·테마·연출 시간(`theme/`), 반응형 배치(`layout/`), 화면 전환(`common/app_page_route.dart`) |

관련 문서: [modules.md](modules.md), [dependencies.md](dependencies.md), [entry-points.md](entry-points.md), [data-flow.md](data-flow.md)
