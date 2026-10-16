# 의존 관계

## 외부 패키지
| 패키지 | 사용 위치 |
|--------|-----------|
| `flutter_riverpod` | `main.dart`, application, `*_providers.dart`, `app_overrides.dart`, presentation |
| `shared_preferences` | `infrastructure/persistence/*_store.dart`, `local_persistence.dart` |
| `audioplayers` | `infrastructure/audio/` |
| `meta` | `domain/`(`board`, `game_state`, `next_queue`, `summing_cell`), `app_settings.dart` |

## 내부 import (부분 목록, 확인된 것)
```mermaid
flowchart LR
  GSN[game_session_notifier] --> Rules[summing_rules]
  GSN --> PP[port_providers]
  PP --> Ports[ports]
  AQ[app_queries] --> PP
  Menu[menu_page] --> GSN
  Menu --> AQ
  Game[game_page] --> GSN
  Scores[scores_page] --> AQ
  Life[game_lifecycle_listener] --> GSN
  Life --> PP
  Game --> Domain[domain/*]
  Menu --> Domain
  Board[board_grid] --> Domain
  NQ[next_queue_row] --> Domain
  Codec[save_game_codec] --> Domain
  GSS[game_save_store] --> Codec
  GSS -.implements.-> Ports
  GAS[game_audio_service] -.implements.-> Ports
  Over[app_overrides] --> PP
  Over --> GSS
  Over --> GAS
  Main[main.dart] --> Over
  Main --> Life
  Main --> Menu
```

`application`→`infrastructure`, `presentation`→`infrastructure` 직접 참조는 없습니다. `infrastructure`가 `application`의 포트를 구현하는 방향이며, 연결은 `app_overrides.dart`가 맡습니다(경계 검사: `test/architecture/layer_boundary_test.dart`).
