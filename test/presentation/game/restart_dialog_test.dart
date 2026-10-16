import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/presentation/game/game_page.dart';

import '../../support/test_overrides.dart';

/// 재시작 확인 흐름 (SPEC-UI-001 AC-UI-08 ~ 11, REQ-UI-010 ~ 012).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// turnCount 3, playing 상태 (가운데 칸 하나만 숫자).
  GameState playingAtTurn3() {
    final cells =
        List<SummingCell>.filled(CellIndex.cellCount, SummingCell.empty);
    cells[40] = const SummingCell.filled(7);
    return GameState(
      board: Board.fromCells(cells),
      queue: NextQueue(const [1, 2, 3, 4]),
      turnCount: 3,
    );
  }

  /// 칸 40에 7을 놓으면 이웃(41의 7)이 매치로 지워져 complete가 되는 상태.
  GameState oneMoveFromComplete() {
    final cells =
        List<SummingCell>.filled(CellIndex.cellCount, SummingCell.empty);
    cells[41] = const SummingCell.filled(7);
    return GameState(
      board: Board.fromCells(cells),
      queue: NextQueue(const [7, 1, 2, 3]),
      turnCount: 5,
    );
  }

  /// 칸 0만 비어 있고 이웃 합이 0이라 5를 놓으면 판이 가득 차 gameOver가 되는 상태.
  GameState oneMoveFromGameOver() {
    final cells =
        List<SummingCell>.filled(CellIndex.cellCount, const SummingCell.filled(0));
    cells[0] = SummingCell.empty;
    return GameState(
      board: Board.fromCells(cells),
      queue: NextQueue(const [5, 1, 2, 3]),
      turnCount: 9,
    );
  }

  Future<({FakePorts fakes, ProviderContainer container})> pumpGame(
    WidgetTester tester,
    GameState state, {
    Size? viewport,
  }) async {
    if (viewport != null) {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    final fakes = FakePorts();
    fakes.gameSave.stored = state;
    final container = ProviderContainer(overrides: fakes.overrides());
    addTearDown(container.dispose);
    await container.read(gameAudioProvider.future);
    await container.read(gameSessionProvider.notifier).resumeGame();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GamePage()),
      ),
    );
    await tester.pumpAndSettle();
    fakes.log.clear();
    return (fakes: fakes, container: container);
  }

  int saveCount(FakePorts fakes) => fakes.log.where((e) => e == 'save').length;

  Finder restartInAppBar() => find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Restart'),
      );

  Finder dialogButton(String label) => find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(label),
      );

  group('AC-UI-08 playing 중 Restart', () {
    testWidgets('opens the confirm dialog without touching state or save',
        (tester) async {
      final h = await pumpGame(tester, playingAtTurn3());

      await tester.tap(restartInAppBar());
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Restart game?'), findsOneWidget);
      expect(find.text('Your current progress will be lost.'), findsOneWidget);
      expect(dialogButton('Cancel'), findsOneWidget);
      expect(dialogButton('Restart'), findsOneWidget);
      expect(h.container.read(gameSessionProvider)!.turnCount, 3);
      expect(saveCount(h.fakes), 0);
    });

    testWidgets('a fast double tap opens only one dialog', (tester) async {
      await pumpGame(tester, playingAtTurn3());

      await tester.tap(restartInAppBar());
      await tester.tap(restartInAppBar(), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(dialogButton('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Restart in the side panel (expanded) is guarded too',
        (tester) async {
      final h = await pumpGame(
        tester,
        playingAtTurn3(),
        viewport: const Size(1280, 800),
      );

      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('game.sidePanel')),
          matching: find.text('Restart'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(h.container.read(gameSessionProvider)!.turnCount, 3);
      expect(saveCount(h.fakes), 0);
    });
  });

  group('AC-UI-09 취소·닫기 경로는 상태를 바꾸지 않음', () {
    final dismissPaths = <String, Future<void> Function(WidgetTester)>{
      'Cancel tap': (tester) => tester.tap(dialogButton('Cancel')),
      'barrier tap': (tester) => tester.tapAt(const Offset(4, 300)),
      'Escape key': (tester) async {
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      },
      'system back': (tester) async {
        await tester.binding.handlePopRoute();
      },
    };

    for (final entry in dismissPaths.entries) {
      testWidgets('${entry.key} closes the dialog and keeps turnCount 3',
          (tester) async {
        final h = await pumpGame(tester, playingAtTurn3());

        await tester.tap(restartInAppBar());
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsOneWidget);

        await entry.value(tester);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(h.container.read(gameSessionProvider)!.turnCount, 3);
        expect(find.text('3 turns'), findsOneWidget);
        expect(saveCount(h.fakes), 0);
        expect(find.byType(GamePage), findsOneWidget);
      });
    }
  });

  testWidgets('AC-UI-10 confirming starts a new run and saves it once',
      (tester) async {
    final h = await pumpGame(tester, playingAtTurn3());

    await tester.tap(restartInAppBar());
    await tester.pumpAndSettle();
    await tester.tap(dialogButton('Restart'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(h.container.read(gameSessionProvider)!.turnCount, 0);
    expect(find.text('0 turns'), findsOneWidget);
    expect(saveCount(h.fakes), 1);
    expect(h.fakes.gameSave.saved.last.turnCount, 0);
  });

  group('AC-UI-11 종료 상태에서는 확인 없이 바로 재시작', () {
    final finishedStates = <String, (GameState Function(), int, String)>{
      'complete': (oneMoveFromComplete, 40, 'Complete!'),
      'gameOver': (oneMoveFromGameOver, 0, 'Game Over'),
    };
    final triggers = <String, Finder Function()>{
      'Play again': () => find.text('Play again'),
      'Restart': restartInAppBar,
    };

    for (final state in finishedStates.entries) {
      for (final trigger in triggers.entries) {
        testWidgets('${state.key}: ${trigger.key} restarts without a dialog',
            (tester) async {
          final (build, lastMove, title) = state.value;
          final h = await pumpGame(tester, build());

          await h.container.read(gameSessionProvider.notifier).placeAt(lastMove);
          await tester.pumpAndSettle();
          expect(find.text(title), findsOneWidget);
          h.fakes.log.clear();

          await tester.tap(trigger.value());
          await tester.pump();
          expect(find.byType(AlertDialog), findsNothing);
          await tester.pumpAndSettle();

          expect(find.byType(AlertDialog), findsNothing);
          final game = h.container.read(gameSessionProvider)!;
          expect(game.turnCount, 0);
          expect(game.phase, GamePhase.playing);
          expect(find.text(title), findsNothing);
          expect(saveCount(h.fakes), 1);
        });
      }
    }
  });

  testWidgets('Quit leaves the game without a confirmation', (tester) async {
    final fakes = FakePorts();
    fakes.gameSave.stored = playingAtTurn3();
    final container = ProviderContainer(overrides: fakes.overrides());
    addTearDown(container.dispose);
    await container.read(gameAudioProvider.future);
    await container.read(gameSessionProvider.notifier).resumeGame();
    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Text('menu stub')),
        ),
      ),
    );
    navigatorKey.currentState!.push<void>(
      MaterialPageRoute<void>(builder: (_) => const GamePage()),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(of: find.byType(AppBar), matching: find.text('Quit')),
    );
    await tester.pump();
    expect(find.byType(AlertDialog), findsNothing);
    await tester.pumpAndSettle();

    expect(find.byType(GamePage), findsNothing);
    expect(find.text('menu stub'), findsOneWidget);
    expect(container.read(gameSessionProvider), isNull);
  });
}
