# 의존 관계

## 외부 패키지
| 패키지 | 사용 위치 |
|--------|-----------|
| `flutter_riverpod` | `main.dart`, application, `*_providers.dart`, presentation |
| `shared_preferences` | `infrastructure/persistence/*_store.dart`, `local_persistence.dart` |
| `audioplayers` | `infrastructure/audio/` |
| `meta` | `domain/`(`board`, `game_state`, `next_queue`, `summing_cell`), `app_settings.dart` |

## 내부 import (부분 목록, 확인된 것)
```mermaid
flowchart LR
  GSN[game_session_notifier] --> Rules[summing_rules]
  GSN --> AP[audio_providers]
  GSN --> PP[persistence_providers]
  Menu[menu_page] --> GSN
  Menu --> AP
  Menu --> PP
  Menu --> LP[local_persistence]
  Game[game_page] --> GSN
  Scores[scores_page] --> PP
  Life[game_lifecycle_listener] --> GSN
  Life --> AP
  Codec[save_game_codec] --> Domain[domain/*]
  Game --> Domain
  Menu --> Domain
  Board[board_grid] --> Domain
  NQ[next_queue_row] --> Domain
  AP --> PP
  GAS[game_audio_service] --> SS[settings_store]
  AP --> GAS
  GSS[game_save_store] --> Codec
  Main[main.dart] --> AP
  Main --> Life
  Main --> Menu
```

`application`→`infrastructure`, `presentation`→`infrastructure` 직접 참조는 개선 후보입니다.
