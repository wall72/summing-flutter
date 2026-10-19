import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/presentation/game/game_page.dart';
import 'package:summing_flutter/presentation/game/widgets/next_queue_row.dart';

import '../../support/test_overrides.dart';

/// GamePage 반응형 배치 (SPEC-UI-001 AC-UI-03, 04, 05, 25, `design.md` §4).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sidePanel = ValueKey('game.sidePanel');
  const board = ValueKey('game.board');

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

  Future<ProviderContainer> pumpGameAt(WidgetTester tester, Size viewport) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final fakes = FakePorts();
    fakes.gameSave.stored = playingAtTurn3();
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
    return container;
  }

  Finder inPanel(Finder matching) =>
      find.descendant(of: find.byKey(sidePanel), matching: matching);

  /// 큐 행이 보드 위에 있고 같은 열(가로로 겹침)에 놓였는지 확인한다.
  void expectSingleColumn(WidgetTester tester) {
    final queue = tester.getRect(find.byType(NextQueueRow));
    final boardRect = tester.getRect(find.byKey(board));
    expect(queue.bottom, lessThanOrEqualTo(boardRect.top));
    expect(queue.left, lessThan(boardRect.right));
    expect(queue.right, greaterThan(boardRect.left));
  }

  testWidgets('AC-UI-03 compact 360x780: one column, actions in the AppBar',
      (tester) async {
    await pumpGameAt(tester, const Size(360, 780));

    expect(tester.takeException(), isNull);
    expect(find.byKey(sidePanel), findsNothing);
    expectSingleColumn(tester);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Restart')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Quit')),
      findsOneWidget,
    );
    expect(find.text('3 turns'), findsOneWidget);
  });

  testWidgets('AC-UI-04 medium 700x1000: one column, board side <= 560',
      (tester) async {
    await pumpGameAt(tester, const Size(700, 1000));

    expect(tester.takeException(), isNull);
    expect(find.byKey(sidePanel), findsNothing);
    expectSingleColumn(tester);
    final size = tester.getSize(find.byKey(board));
    expect(size.width, lessThanOrEqualTo(560));
    expect(size.width, size.height);
  });

  testWidgets('AC-UI-05 expanded 1280x800: side panel right of the board',
      (tester) async {
    await pumpGameAt(tester, const Size(1280, 800));

    expect(tester.takeException(), isNull);
    expect(find.byKey(sidePanel), findsOneWidget);
    expect(inPanel(find.text('3 turns')), findsOneWidget);
    expect(inPanel(find.byType(NextQueueRow)), findsOneWidget);
    expect(inPanel(find.text('Restart')), findsOneWidget);
    expect(inPanel(find.text('Quit')), findsOneWidget);
    // 같은 동작 버튼이 상단 바와 패널에 중복되지 않는다.
    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Quit'), findsOneWidget);

    final boardRect = tester.getRect(find.byKey(board));
    final panelRect = tester.getRect(find.byKey(sidePanel));
    expect(boardRect.right, lessThanOrEqualTo(panelRect.left));
    expect(boardRect.width, lessThanOrEqualTo(640));
  });

  group('AC-UI-25 low-height landscape', () {
    final cases = <Size, (double, double)>{
      const Size(568, 320): (304, 31.5),
      const Size(740, 360): (344, 36),
    };

    for (final entry in cases.entries) {
      final viewport = entry.key;
      final (minBoard, minCell) = entry.value;

      testWidgets(
          '${viewport.width.toInt()}x${viewport.height.toInt()}: '
          'no AppBar, two panes, board >= $minBoard', (tester) async {
        await pumpGameAt(tester, viewport);

        expect(tester.takeException(), isNull);
        expect(find.byType(AppBar), findsNothing);
        expect(find.byKey(sidePanel), findsOneWidget);

        final boardRect = tester.getRect(find.byKey(board));
        final panelRect = tester.getRect(find.byKey(sidePanel));
        expect(boardRect.right, lessThanOrEqualTo(panelRect.left));
        expect(panelRect.right, lessThanOrEqualTo(viewport.width));
        expect(panelRect.bottom, lessThanOrEqualTo(viewport.height));

        expect(inPanel(find.text('Summing')), findsOneWidget);
        expect(inPanel(find.text('3 turns')), findsOneWidget);
        expect(inPanel(find.byType(NextQueueRow)), findsOneWidget);
        expect(inPanel(find.text('Restart')), findsOneWidget);
        expect(inPanel(find.text('Quit')), findsOneWidget);

        final label = tester.getRect(inPanel(find.text('Next:')));
        final slot0 = tester.getRect(
          inPanel(find.byKey(const ValueKey('queue.slot.0'))),
        );
        expect(label.bottom, lessThanOrEqualTo(slot0.top));

        expect(boardRect.width, greaterThanOrEqualTo(minBoard));
        expect(boardRect.width, boardRect.height);
        final cell = tester.getSize(find.byKey(const ValueKey('cell.0')));
        expect(cell.width, greaterThanOrEqualTo(minCell));
        expect(cell.height, greaterThanOrEqualTo(minCell));
      });
    }

    testWidgets('1280x400 (wide but low) also uses the low-height layout',
        (tester) async {
      await pumpGameAt(tester, const Size(1280, 400));

      expect(tester.takeException(), isNull);
      expect(find.byType(AppBar), findsNothing);
      expect(find.byKey(sidePanel), findsOneWidget);
    });
  });

  testWidgets('resizing across 839/840 changes only the layout, not the run',
      (tester) async {
    final container = await pumpGameAt(tester, const Size(839, 800));
    expect(find.byKey(sidePanel), findsNothing);

    tester.view.physicalSize = const Size(840, 800);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(sidePanel), findsOneWidget);

    tester.view.physicalSize = const Size(839, 800);
    await tester.pumpAndSettle();
    expect(find.byKey(sidePanel), findsNothing);
    expect(find.text('3 turns'), findsOneWidget);
    expect(container.read(gameSessionProvider)!.turnCount, 3);
  });
}
