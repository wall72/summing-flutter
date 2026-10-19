import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/presentation/game/game_page.dart';
import 'package:summing_flutter/presentation/game/widgets/next_queue_row.dart';
import 'package:summing_flutter/presentation/menu/menu_page.dart';
import 'package:summing_flutter/presentation/scores/scores_page.dart';
import 'package:summing_flutter/presentation/theme/app_theme.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

import '../support/test_overrides.dart';

/// 화면별 반응형 배치 (SPEC-UI-001 AC-UI-06, 07, 25, `design.md` §4, §5).
///
/// 실제 앱과 같은 글자 폭·높이로 넘침을 보려고 번들 Nunito를 불러와 앱 테마로 그린다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    ByteData bytes(String path) =>
        ByteData.sublistView(Uint8List.fromList(File(path).readAsBytesSync()));
    final loader = FontLoader(AppTypeScale.fontFamily)
      ..addFont(Future.value(bytes('assets/fonts/Nunito-Regular.ttf')))
      ..addFont(Future.value(bytes('assets/fonts/Nunito-ExtraBold.ttf')));
    await loader.load();
  });

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

  void setViewport(WidgetTester tester, Size viewport) {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<FakePorts> pumpScreen(
    WidgetTester tester,
    Size viewport,
    Widget home, {
    GameState? saved,
    List<int> scores = const [],
    bool resume = false,
  }) async {
    setViewport(tester, viewport);
    final fakes = FakePorts();
    fakes.gameSave.stored = saved;
    fakes.highScores.scores = scores;
    final container = ProviderContainer(overrides: fakes.overrides());
    addTearDown(container.dispose);
    await container.read(gameAudioProvider.future);
    if (resume) {
      await container.read(gameSessionProvider.notifier).resumeGame();
    }

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: home),
      ),
    );
    await tester.pumpAndSettle();
    return fakes;
  }

  String label(Size s) => '${s.width.toInt()}x${s.height.toInt()}';

  /// [inner]가 [outer] 안에 있는지 (반올림 오차 0.01 허용).
  void expectInside(Rect inner, Rect outer, {String? reason}) {
    const eps = 0.01;
    expect(inner.left, greaterThanOrEqualTo(outer.left - eps), reason: reason);
    expect(inner.top, greaterThanOrEqualTo(outer.top - eps), reason: reason);
    expect(inner.right, lessThanOrEqualTo(outer.right + eps), reason: reason);
    expect(inner.bottom, lessThanOrEqualTo(outer.bottom + eps), reason: reason);
  }

  Finder inPanel(Finder matching) =>
      find.descendant(of: find.byKey(sidePanel), matching: matching);

  // AC-UI-06의 뷰포트 8종 + 저높이 패널 폭 경계(design.md §4 표의 531×320, 561×320).
  const viewports = [
    Size(320, 568),
    Size(360, 780),
    Size(480, 320),
    Size(531, 320),
    Size(561, 320),
    Size(568, 320),
    Size(740, 360),
    Size(800, 1280),
    Size(1280, 800),
    Size(1920, 1080),
  ];

  group('AC-UI-06 no overflow at every viewport', () {
    for (final viewport in viewports) {
      final screen = Offset.zero & viewport;
      final lowHeight = viewport.height < 480 && viewport.width >= 480;

      testWidgets('${label(viewport)}: GamePage board inside the viewport',
          (tester) async {
        await pumpScreen(
          tester,
          viewport,
          const GamePage(),
          saved: playingAtTurn3(),
          resume: true,
        );

        expect(tester.takeException(), isNull);
        expectInside(tester.getRect(find.byKey(board)), screen);

        if (lowHeight) {
          // 저높이 가로 패널 예산 (design.md §4): 폭 200 이상, 큐 184가 안쪽에 들어가고
          // 필요 높이(244)가 패널 높이(높이 − 12) 안이라 스크롤 없이 다 보인다.
          final panel = tester.getRect(find.byKey(sidePanel));
          expectInside(panel, screen);
          expect(panel.width, greaterThanOrEqualTo(200));
          expectInside(tester.getRect(inPanel(find.byType(NextQueueRow))),
              panel.deflate(6));
          final scroll = tester.state<ScrollableState>(
            inPanel(find.byType(Scrollable)).first,
          );
          expect(scroll.position.maxScrollExtent, 0);
        }
      });

      testWidgets('${label(viewport)}: MenuPage', (tester) async {
        await pumpScreen(
          tester,
          viewport,
          const MenuPage(),
          saved: playingAtTurn3(),
        );

        expect(tester.takeException(), isNull);
        for (final card in tester.widgetList(find.byType(Card))) {
          final rect = tester.getRect(find.byWidget(card));
          if (lowHeight) {
            // 저높이 가로: 카드가 화면 안에 있고 카드 안에서 스크롤한다.
            expectInside(rect, screen);
          } else {
            // 그 밖: 가로로는 넘치지 않고, 높이가 모자라면 바깥이 세로 스크롤한다.
            expect(rect.left, greaterThanOrEqualTo(0));
            expect(rect.right, lessThanOrEqualTo(viewport.width));
          }
        }
      });

      testWidgets('${label(viewport)}: ScoresPage with scores', (tester) async {
        await pumpScreen(
          tester,
          viewport,
          const ScoresPage(),
          scores: List<int>.generate(10, (i) => 20 + i),
        );

        expect(tester.takeException(), isNull);
        expectInside(tester.getRect(find.byType(ListView)), screen);
      });
    }

    for (final viewport in [const Size(480, 320), const Size(320, 568)]) {
      testWidgets('${label(viewport)}: How to Play sheet', (tester) async {
        await pumpScreen(tester, viewport, const MenuPage());
        await tester.ensureVisible(find.text('How to Play'));
        await tester.tap(find.text('How to Play'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Board'), findsOneWidget);
      });
    }
  });

  group('AC-UI-07 compact cells are at least 36', () {
    for (final viewport in const [
      Size(360, 640),
      Size(360, 780),
      Size(599, 640),
    ]) {
      testWidgets(label(viewport), (tester) async {
        await pumpScreen(
          tester,
          viewport,
          const GamePage(),
          saved: playingAtTurn3(),
          resume: true,
        );

        expect(tester.takeException(), isNull);
        final cell = tester.getSize(find.byKey(const ValueKey('cell.0')));
        expect(cell.width, greaterThanOrEqualTo(36));
        expect(cell.height, greaterThanOrEqualTo(36));
      });
    }
  });

  group('MenuPage layout (design.md §4)', () {
    Finder inCard(int index, Finder matching) => find.descendant(
          of: find.byType(Card).at(index),
          matching: matching,
        );

    for (final viewport in const [Size(360, 780), Size(700, 1000)]) {
      testWidgets('${label(viewport)}: one centered card, max width 440',
          (tester) async {
        await pumpScreen(tester, viewport, const MenuPage());

        expect(find.byType(Card), findsOneWidget);
        final card = tester.getRect(find.byType(Card));
        expect(card.width, lessThanOrEqualTo(440));
        expect(card.center.dx, moreOrLessEquals(viewport.width / 2));
        for (final text in ['New Game', 'Resume Game', 'Music']) {
          expect(inCard(0, find.text(text)), findsOneWidget, reason: text);
        }
        // 버튼은 세로로 쌓인다.
        expect(
          tester.getRect(find.text('New Game')).bottom,
          lessThanOrEqualTo(tester.getRect(find.text('Resume Game')).top),
        );
      });
    }

    testWidgets('320x480 (short compact): the card scrolls', (tester) async {
      await pumpScreen(tester, const Size(320, 480), const MenuPage());

      expect(tester.takeException(), isNull);
      expect(
        find.ancestor(
          of: find.byType(Card),
          matching: find.byType(Scrollable),
        ),
        findsWidgets,
      );
      await tester.scrollUntilVisible(find.text('Sound effects'), 100);
      expect(tester.takeException(), isNull);
    });

    for (final viewport in const [
      Size(1280, 800),
      Size(480, 320),
      Size(568, 320),
      Size(740, 360),
    ]) {
      final lowHeight = viewport.height < 480;
      testWidgets(
          '${label(viewport)}: two cards side by side '
          '(start buttons | settings + How to Play)', (tester) async {
        await pumpScreen(tester, viewport, const MenuPage());

        expect(tester.takeException(), isNull);
        expect(find.byType(Card), findsNWidgets(2));
        final left = tester.getRect(find.byType(Card).at(0));
        final right = tester.getRect(find.byType(Card).at(1));
        expect(left.right, lessThanOrEqualTo(right.left));

        for (final text in ['Summing', 'New Game', 'Resume Game', 'Scores']) {
          expect(inCard(0, find.text(text)), findsOneWidget, reason: text);
        }
        for (final text in ['How to Play', 'Music', 'Sound effects']) {
          expect(inCard(1, find.text(text)), findsOneWidget, reason: text);
        }

        if (lowHeight) {
          // 저높이 가로: 카드마다 세로 스크롤.
          expect(inCard(0, find.byType(Scrollable)), findsOneWidget);
          expect(inCard(1, find.byType(Scrollable)), findsOneWidget);
        }
      });
    }

    testWidgets('480x320: the start card scrolls to the last button',
        (tester) async {
      await pumpScreen(tester, const Size(480, 320), const MenuPage());

      await tester.scrollUntilVisible(
        find.text('Scores'),
        100,
        scrollable: find
            .descendant(
              of: find.byType(Card).at(0),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(tester.takeException(), isNull);
      expectInside(
        tester.getRect(find.text('Scores')),
        Offset.zero & const Size(480, 320),
      );
    });
  });

  group('ScoresPage layout (design.md §4, §5)', () {
    testWidgets('1280x800: list is at most 560 wide and centered',
        (tester) async {
      await pumpScreen(
        tester,
        const Size(1280, 800),
        const ScoresPage(),
        scores: const [12, 15],
      );

      final list = tester.getRect(find.byType(ListView));
      expect(list.width, lessThanOrEqualTo(560));
      expect(list.center.dx, moreOrLessEquals(640));
    });

    testWidgets('480x320: a long list scrolls without overflow',
        (tester) async {
      await pumpScreen(
        tester,
        const Size(480, 320),
        const ScoresPage(),
        scores: List<int>.generate(10, (i) => 20 + i),
      );

      await tester.scrollUntilVisible(find.text('29 turns'), 100);
      expect(tester.takeException(), isNull);
    });

    for (final brightness in Brightness.values) {
      testWidgets('${brightness.name}: CircleAvatar uses the queue-head tokens',
          (tester) async {
        setViewport(tester, const Size(360, 780));
        final fakes = FakePorts()..highScores.scores = [12];
        final container = ProviderContainer(overrides: fakes.overrides());
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: brightness == Brightness.dark
                  ? AppTheme.dark
                  : AppTheme.light,
              home: const ScoresPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final palette =
            brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
        final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
        expect(avatar.backgroundColor, palette.queueHeadContainer);
        expect(avatar.foregroundColor, palette.onQueueHead);
      });
    }
  });

  group('How to Play sheet (design.md §5)', () {
    for (final brightness in Brightness.values) {
      testWidgets('${brightness.name}: titles onSurface, body onSurfaceVariant',
          (tester) async {
        setViewport(tester, const Size(360, 780));
        final container = ProviderContainer(overrides: FakePorts().overrides());
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: brightness == Brightness.dark
                  ? AppTheme.dark
                  : AppTheme.light,
              home: const MenuPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('How to Play'));
        await tester.tap(find.text('How to Play'));
        await tester.pumpAndSettle();

        final palette =
            brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
        Color? colorOf(Finder f) =>
            tester.renderObject<RenderParagraph>(f).text.style?.color;

        final sheet = find.byType(BottomSheet);
        expect(
          colorOf(find.descendant(of: sheet, matching: find.text('Board'))),
          palette.onSurface,
        );
        expect(
          colorOf(find.descendant(
            of: sheet,
            matching: find.textContaining('The board is 9×9'),
          )),
          palette.onSurfaceVariant,
        );
      });
    }
  });
}
