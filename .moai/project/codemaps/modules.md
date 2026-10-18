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
- `ports.dart` — 추상 포트 `GameSaveRepository`, `HighScoreRepository`, `SettingsRepository`, `GameAudio`
- `port_providers.dart` — `gameSaveRepositoryProvider`, `highScoreRepositoryProvider`, `settingsRepositoryProvider`, `gameAudioProvider` (미바인딩 시 `UnimplementedError`)
- `app_queries.dart` — `resumableGameProvider`, `highScoresProvider`, `settingsControllerProvider`(`SettingsController`)
- `models/app_settings.dart` — 설정 값 객체
- `game_session_notifier.dart` — `gameSessionProvider` (`NotifierProvider<GameSessionNotifier, GameState?>`); `startNewGame`, `resumeGame`, `restartGame`, `clearSession`, `persistIfNeeded`, `placeAt`

## infrastructure
- `app_overrides.dart` — `appOverrides`: 포트 provider를 구현에 연결하는 목록 (composition root, `main.dart`가 사용)

## infrastructure/persistence
- `persistence_keys.dart`, `app_settings.dart`, `settings_store.dart`, `game_save_store.dart`, `high_scores_store.dart`, `save_game_codec.dart`, `local_persistence.dart`(세 저장소 묶음, 각 저장소가 application 포트를 `implements`), `persistence_providers.dart`(`localPersistenceProvider`)

## infrastructure/audio
- `game_audio_assets.dart`, `game_audio_service.dart`(`GameAudio` 구현: `playTap`, `playMatch`, BGM), `audio_providers.dart`(`gameAudioServiceProvider`)

## presentation
- `menu/menu_page.dart`(application 조회 provider만 사용), `scores/scores_page.dart`, `common/how_to_play_sheet.dart`, `common/game_lifecycle_listener.dart`
- `game/game_page.dart` — `LayoutClass`에 따라 세로 배치 또는 보드+사이드 패널 배치, 재시작 guard(진행 중이면 확인)
- `game/widgets/board_grid.dart` — 직전·새 `GameState` 비교로 배치/매치 셀 효과(`CellEffect`) 판정; `board_cell.dart` — 칸 하나(`BoardCell`, `CellEffectKind.place/match`)
- `game/widgets/next_queue_row.dart` — 큐 슬롯과 이동 연출; `game_side_panel.dart` — 넓은·저높이 배치의 사이드 패널; `end_overlay.dart` — 클리어/게임 오버 오버레이(등장 연출); `restart_confirm_dialog.dart` — 재시작 확인(true/false 반환)

## presentation/theme
- `app_tokens.dart` — `AppPalette`(`ThemeExtension`, 라이트·다크, `AppPalette.of`), 반경·선·상태 레이어 등 토큰
- `app_theme.dart` — `AppTheme.light/dark`(ColorScheme 역할 전부를 토큰으로 채움, Nunito), `ReducedMotionTheme`(감속 모드에서 splash 제거)
- `app_motion.dart` — 연출 시간 상수와 `AppMotion.of`(감속 모드면 `Duration.zero`)

## presentation/layout
- `breakpoints.dart` — `LayoutClass { lowHeightLandscape, expanded, medium, compact }` 판정(폭 600/840, 높이 480), `GameLayout`·`ScreenLayout` 배치 값

## presentation/common (추가분)
- `app_page_route.dart` — `AppPageRoute`(페이드+스케일 화면 전환, 감속 모드면 0); `web_audio_unlock.dart` — `WebAudioUnlock`(웹 첫 제스처에서 `notifyUserGesture`)
