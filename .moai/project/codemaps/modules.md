# 모듈

## domain
- `cell_index.dart` — 9×9 선형 인덱스, `cellCount`, 8방향 `neighborLinears`
- `summing_cell.dart` — 칸 값과 `isAssigned`
- `board.dart` — `withPlacedDigit`, `afterMatchClear`, `isComplete`, `isGameOver`
- `next_queue.dart` — 4칸 큐, `afterPlace(random)`
- `game_phase.dart` — `playing` / `complete` / `gameOver` 판정
- `game_state.dart` — 보드 + 큐 + `turnCount`, `GameState.initial`
- `place_outcome.dart` — `PlaceSuccess(state, wasMatch)` / `PlaceFailure`
- `summing_rules.dart` — `canPlace`, `place`

## application
- `game_session_notifier.dart` — `gameSessionProvider` (`NotifierProvider<GameSessionNotifier, GameState?>`); `startNewGame`, `resumeGame`, `restartGame`, `clearSession`, `persistIfNeeded`, `placeAt`

## infrastructure/persistence
- `persistence_keys.dart`, `app_settings.dart`, `settings_store.dart`, `game_save_store.dart`, `high_scores_store.dart`, `save_game_codec.dart`, `local_persistence.dart`(세 저장소 묶음), `persistence_providers.dart`(`localPersistenceProvider`)

## infrastructure/audio
- `game_audio_assets.dart`, `game_audio_service.dart`(`playTap`, `playMatch`, BGM), `audio_providers.dart`(`gameAudioServiceProvider`)

## presentation
- `menu/menu_page.dart`, `game/game_page.dart`, `game/widgets/board_grid.dart`, `game/widgets/next_queue_row.dart`, `scores/scores_page.dart`, `common/how_to_play_sheet.dart`, `common/game_lifecycle_listener.dart`
