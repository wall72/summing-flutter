import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/presentation/game/game_page.dart';
import 'package:summing_flutter/presentation/game/widgets/board_grid.dart';
import 'package:summing_flutter/presentation/theme/app_theme.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

import '../../support/test_overrides.dart';

/// 보드 재스타일과 셀 연출 (SPEC-UI-001 AC-UI-07, 12, 13, 14, 21, 25, `design.md` §2, §5, §7).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// 칸 [filled]만 숫자가 있는 보드 상태.
  GameState stateWith(
    Map<int, int> filled, {
    int turnCount = 3,
    List<int> queue = const [1, 2, 3, 4],
  }) {
    final cells =
        List<SummingCell>.filled(CellIndex.cellCount, SummingCell.empty);
    filled.forEach((i, v) => cells[i] = SummingCell.filled(v));
    return GameState(
      board: Board.fromCells(cells),
      queue: NextQueue(queue),
      turnCount: turnCount,
    );
  }

  Future<void> pumpBoard(
    WidgetTester tester,
    GameState game, {
    ThemeData? theme,
    double side = 380,
    void Function(int linear)? onCellTap,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox.square(
              dimension: side,
              child: BoardGrid(game: game, onCellTap: onCellTap ?? (_) {}),
            ),
          ),
        ),
      ),
    );
  }

  /// 지금 트리에 있는 셀 연출 키 (`cell.<i>.place`, `cell.<i>.match`).
  Set<String> effectKeys() {
    final pattern = RegExp(r'^cell\.\d+\.(place|match)$');
    return find
        .byWidgetPredicate((w) {
          final key = w.key;
          return key is ValueKey<String> && pattern.hasMatch(key.value);
        })
        .evaluate()
        .map((e) => (e.widget.key! as ValueKey<String>).value)
        .toSet();
  }

  /// 셀 채움과 외곽선을 그리는 장식.
  BoxDecoration cellDecoration(WidgetTester tester, int linear) {
    final decorations = find
        .descendant(
          of: find.byKey(ValueKey('cell.$linear')),
          matching: find.byWidgetPredicate(
            (w) => w is Ink && w.decoration is BoxDecoration,
          ),
        )
        .evaluate()
        .map((e) => (e.widget as Ink).decoration! as BoxDecoration)
        .toList();
    expect(decorations, hasLength(1), reason: 'cell.$linear fill decoration');
    return decorations.single;
  }

  group('frame and cell styling (design.md §2, §5)', () {
    testWidgets('frame padding 2, cell gap 2 → cell = (side - 20) / 9',
        (tester) async {
      await pumpBoard(tester, stateWith({40: 7}), side: 380);

      final cell0 = tester.getRect(find.byKey(const ValueKey('cell.0')));
      final cell1 = tester.getRect(find.byKey(const ValueKey('cell.1')));
      final cell9 = tester.getRect(find.byKey(const ValueKey('cell.9')));
      final boardRect = tester.getRect(find.byType(BoardGrid));

      expect(cell0.width, closeTo(40, 0.001));
      expect(cell0.height, closeTo(40, 0.001));
      expect(cell0.left - boardRect.left, closeTo(AppSpacing.hairline, 0.001));
      expect(cell0.top - boardRect.top, closeTo(AppSpacing.hairline, 0.001));
      expect(cell1.left - cell0.right, closeTo(AppSpacing.hairline, 0.001));
      expect(cell9.top - cell0.bottom, closeTo(AppSpacing.hairline, 0.001));
    });

    testWidgets('frame is surfaceContainer, clipped with radius 8',
        (tester) async {
      await pumpBoard(tester, stateWith({40: 7}));

      final clip = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byType(BoardGrid),
          matching: find.byType(ClipRRect),
        ),
      );
      expect(clip.borderRadius, BorderRadius.circular(AppRadius.frame));

      final frame = tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(BoardGrid),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.color == AppPalette.light.surfaceContainer);
      expect(frame, isNotEmpty);
    });

    for (final entry in {
      'light': (AppTheme.light, AppPalette.light),
      'dark': (AppTheme.dark, AppPalette.dark),
    }.entries) {
      testWidgets('${entry.key}: every cell has a 1px cellOutline, no shadow',
          (tester) async {
        final (theme, palette) = entry.value;
        await pumpBoard(tester, stateWith({40: 7}), theme: theme);

        for (var i = 0; i < CellIndex.cellCount; i++) {
          final d = cellDecoration(tester, i);
          final border = d.border! as Border;
          expect(border.top.color, palette.cellOutline, reason: 'cell.$i');
          expect(border.top.width, 1, reason: 'cell.$i');
          expect(d.borderRadius, BorderRadius.circular(AppRadius.xs));
          expect(d.boxShadow, isNull, reason: 'cell.$i has no shadow');
        }
        expect(cellDecoration(tester, 0).color, palette.cellEmpty);
        expect(cellDecoration(tester, 40).color, palette.cellFilled);
      });
    }

    for (final entry in {
      'light': (AppTheme.light, AppPalette.light),
      'dark': (AppTheme.dark, AppPalette.dark),
    }.entries) {
      testWidgets(
          '${entry.key}: hover/press brighten with cellFilled, '
          'focus adds no overlay', (tester) async {
        final (theme, palette) = entry.value;
        await pumpBoard(tester, stateWith({40: 7}), theme: theme);

        final inkWell = tester.widget<InkWell>(
          find.descendant(
            of: find.byKey(const ValueKey('cell.0')),
            matching: find.byType(InkWell),
          ),
        );
        final overlay = inkWell.overlayColor!;
        expect(
          overlay.resolve({WidgetState.hovered}),
          palette.cellFilled.withValues(alpha: AppStateLayer.hover),
        );
        expect(
          overlay.resolve({WidgetState.pressed}),
          palette.cellFilled.withValues(alpha: AppStateLayer.pressed),
        );
        expect(overlay.resolve({WidgetState.focused}), Colors.transparent);
      });
    }

    testWidgets('cell digit is onSurface, weight 800, size = cell × 0.5',
        (tester) async {
      await pumpBoard(tester, stateWith({40: 7}), side: 380);

      final text = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const ValueKey('cell.40')),
          matching: find.text('7'),
        ),
      );
      expect(text.style?.color, AppPalette.light.onSurface);
      expect(text.style?.fontWeight, FontWeight.w800);
      expect(text.style?.fontSize,
          closeTo(40 * AppTypeScale.cellDigitRatio, 0.001));
    });
  });

  group('AC-UI-12 previous-board comparison', () {
    testWidgets('one empty cell filled (turn +1) → place effect on it only',
        (tester) async {
      await pumpBoard(tester, stateWith({40: 7}, turnCount: 3));
      expect(effectKeys(), isEmpty);

      await pumpBoard(tester, stateWith({40: 7, 80: 1}, turnCount: 4));
      expect(effectKeys(), {'cell.80.place'});
    });

    testWidgets('k digit cells emptied (turn +1) → match effect on those only',
        (tester) async {
      await pumpBoard(tester, stateWith({0: 5, 40: 3, 41: 4}, turnCount: 3));

      await pumpBoard(tester, stateWith({0: 5}, turnCount: 4));
      expect(effectKeys(), {'cell.40.match', 'cell.41.match'});
    });

    testWidgets('board unchanged (turn +1, zero-clear match) → no cell effect',
        (tester) async {
      await pumpBoard(tester, stateWith({40: 7}, turnCount: 3));

      await pumpBoard(
        tester,
        stateWith({40: 7}, turnCount: 4, queue: const [2, 3, 4, 5]),
      );
      expect(effectKeys(), isEmpty);
    });

    testWidgets('cleared cell keeps the old digit under a matchFlash overlay',
        (tester) async {
      await pumpBoard(tester, stateWith({0: 5, 40: 3}, turnCount: 3));
      await pumpBoard(tester, stateWith({0: 5}, turnCount: 4));

      final overlay = find.byKey(const ValueKey('cell.40.match'));
      expect(
        find.descendant(of: overlay, matching: find.text('3')),
        findsOneWidget,
      );
      final flash = tester
          .widgetList<DecoratedBox>(
            find.descendant(of: overlay, matching: find.byType(DecoratedBox)),
          )
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.color);
      expect(flash, contains(AppPalette.light.matchFlash));
    });

    testWidgets('placed cell pops in on placeHighlight', (tester) async {
      await pumpBoard(tester, stateWith({40: 7}, turnCount: 3));
      await pumpBoard(tester, stateWith({40: 7, 80: 1}, turnCount: 4));

      final pop = find.byKey(const ValueKey('cell.80.place'));
      final fills = tester
          .widgetList<DecoratedBox>(
            find.descendant(of: pop, matching: find.byType(DecoratedBox)),
          )
          .map((d) => d.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.color);
      expect(fills, contains(AppPalette.light.placeHighlight));

      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('cell.80.place')), findsOneWidget);
      final opacity = tester.widget<Opacity>(
        find.descendant(of: pop, matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, 1.0);
    });

    testWidgets('placed cell: empty base under the pop, digit drawn once',
        (tester) async {
      await pumpBoard(tester, stateWith({40: 7}, turnCount: 3));
      await pumpBoard(tester, stateWith({40: 7, 80: 1}, turnCount: 4));

      // 바닥은 빈 칸으로 두고 그 위에서 채운 칸이 커지며 나타난다.
      expect(cellDecoration(tester, 80).color, AppPalette.light.cellEmpty);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('cell.80')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('cell.80.place')),
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a later move replaces the previous effect', (tester) async {
      await pumpBoard(tester, stateWith({40: 7}, turnCount: 3));
      await pumpBoard(tester, stateWith({40: 7, 80: 1}, turnCount: 4));
      await pumpBoard(tester, stateWith({40: 7, 80: 1, 72: 2}, turnCount: 5));

      expect(effectKeys(), {'cell.72.place'});
    });

    testWidgets('rebuilding with the same state keeps the effect',
        (tester) async {
      final previous = stateWith({40: 7}, turnCount: 3);
      final next = stateWith({40: 7, 80: 1}, turnCount: 4);
      await pumpBoard(tester, previous);
      await pumpBoard(tester, next);
      await pumpBoard(tester, next);

      expect(effectKeys(), {'cell.80.place'});
    });
  });

  group('AC-UI-13 restart / resume', () {
    testWidgets('restart (turnCount back to 0) → no cell effect',
        (tester) async {
      await pumpBoard(tester, stateWith({40: 7}, turnCount: 5));

      await pumpBoard(tester, stateWith({10: 1, 11: 2}, turnCount: 0));
      expect(effectKeys(), isEmpty);
    });

    testWidgets('resume (turnCount jumps by more than 1) → no cell effect',
        (tester) async {
      await pumpBoard(tester, stateWith({40: 7}, turnCount: 3));

      await pumpBoard(tester, stateWith({40: 7, 80: 1}, turnCount: 9));
      expect(effectKeys(), isEmpty);
    });

    testWidgets('same turnCount, different board (resume) → no cell effect',
        (tester) async {
      await pumpBoard(tester, stateWith({40: 7}, turnCount: 3));

      await pumpBoard(tester, stateWith({40: 7, 80: 1}, turnCount: 3));
      expect(effectKeys(), isEmpty);
    });
  });

  group('AC-UI-21 semantics', () {
    testWidgets('playing: empty cell is a tappable button, digit cell is not',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpBoard(tester, stateWith({40: 7}));

      expect(
        tester.getSemantics(find.byKey(const ValueKey('cell.0'))),
        matchesSemantics(
          label: 'Empty cell',
          isButton: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(find.byKey(const ValueKey('cell.40'))),
        matchesSemantics(label: '7'),
      );
      handle.dispose();
    });

    // gameOver는 모든 칸이 채워진 상태(GamePhase.fromBoard)라 빈 칸이 없다.
    // 플레이 중이 아닌 상태의 빈 칸은 complete(모든 칸이 빈 칸)에서만 생긴다.
    testWidgets('not playing (complete): empty cell is not a button',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpBoard(tester, stateWith({}));

      expect(
        tester.getSemantics(find.byKey(const ValueKey('cell.0'))),
        matchesSemantics(label: 'Empty cell'),
      );
      handle.dispose();
    });

    testWidgets('gameOver: digit cells have no tap action', (tester) async {
      final handle = tester.ensureSemantics();
      final full = {for (var i = 0; i < CellIndex.cellCount; i++) i: 1};
      final game = stateWith(full);
      expect(game.phase, GamePhase.gameOver);
      await pumpBoard(tester, game);

      expect(
        tester.getSemantics(find.byKey(const ValueKey('cell.0'))),
        matchesSemantics(label: '1'),
      );
      handle.dispose();
    });

    testWidgets('tapping an empty cell while playing calls onCellTap',
        (tester) async {
      final taps = <int>[];
      await pumpBoard(tester, stateWith({40: 7}), onCellTap: taps.add);

      await tester.tap(find.byKey(const ValueKey('cell.80')));
      await tester.tap(find.byKey(const ValueKey('cell.40')));
      expect(taps, [80]);
    });
  });

  group('GamePage integration', () {
    Future<ProviderContainer> pumpGame(
      WidgetTester tester,
      GameState saved, {
      Size viewport = const Size(360, 780),
      ThemeData? theme,
      bool disableAnimations = false,
    }) async {
      tester.view.physicalSize = viewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final fakes = FakePorts();
      fakes.gameSave.stored = saved;
      final container = ProviderContainer(overrides: fakes.overrides());
      addTearDown(container.dispose);
      await container.read(gameAudioProvider.future);
      await container.read(gameSessionProvider.notifier).resumeGame();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: theme ?? AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(disableAnimations: disableAnimations),
              child: ReducedMotionTheme(child: child!),
            ),
            home: const GamePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    for (final entry in {
      'light': (AppTheme.light, AppPalette.light),
      'dark': (AppTheme.dark, AppPalette.dark),
    }.entries) {
      testWidgets('${entry.key}: AC-UI-21 Tab focus shows a 2px focus ring',
          (tester) async {
        final (theme, palette) = entry.value;
        final container =
            await pumpGame(tester, stateWith({40: 7}), theme: theme);

        final ringPattern = RegExp(r'^cell\.\d+\.focusRing$');
        Finder rings() => find.byWidgetPredicate((w) {
              final key = w.key;
              return key is ValueKey<String> && ringPattern.hasMatch(key.value);
            });

        for (var i = 0; i < 20 && rings().evaluate().isEmpty; i++) {
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pump();
        }
        expect(rings(), findsOneWidget);

        final ring = tester.widget<DecoratedBox>(rings());
        final border = (ring.decoration as BoxDecoration).border! as Border;
        expect(border.top.width, 2);
        expect(border.top.color, palette.focus);

        // 링이 있는 칸은 빈 칸이다.
        final key = (ring.key! as ValueKey<String>).value;
        final linear = int.parse(key.split('.')[1]);
        expect(
          container.read(gameSessionProvider)!.board.cellAt(linear).isAssigned,
          isFalse,
        );
      });
    }

    testWidgets('placing on the focused cell with Enter drops its ring at once',
        (tester) async {
      final container = await pumpGame(tester, stateWith({40: 7}));

      final ringPattern = RegExp(r'^cell\.\d+\.focusRing$');
      Finder rings() => find.byWidgetPredicate((w) {
            final key = w.key;
            return key is ValueKey<String> && ringPattern.hasMatch(key.value);
          });
      for (var i = 0; i < 20 && rings().evaluate().isEmpty; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      expect(rings(), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(container.read(gameSessionProvider)!.turnCount, 4);
      expect(rings(), findsNothing);
    });

    group('AC-UI-14 reduced motion', () {
      testWidgets('non-match placement: final frame after two pumps',
          (tester) async {
        final container = await pumpGame(
          tester,
          stateWith({0: 5, 40: 7}),
          disableAnimations: true,
        );

        await tester.tap(find.byKey(const ValueKey('cell.80')));
        await tester.pump();
        await tester.pump();

        expect(container.read(gameSessionProvider)!.turnCount, 4);
        final pop = find.byKey(const ValueKey('cell.80.place'));
        expect(pop, findsOneWidget);
        expect(
          tester
              .widget<Opacity>(
                find.descendant(of: pop, matching: find.byType(Opacity)),
              )
              .opacity,
          1.0,
        );
        expect(tester.hasRunningAnimations, isFalse);
      });

      testWidgets('match clearing digit cells: cleared cells drawn empty',
          (tester) async {
        // 31의 이웃 40(3) + 41(4) = 7 = 큐 첫 숫자 → 매치로 두 칸이 비워진다.
        final container = await pumpGame(
          tester,
          stateWith({0: 5, 40: 3, 41: 4}, queue: const [7, 1, 2, 3]),
          disableAnimations: true,
        );
        final handle = tester.ensureSemantics();

        await tester.tap(find.byKey(const ValueKey('cell.31')));
        await tester.pump();
        await tester.pump();

        final game = container.read(gameSessionProvider)!;
        expect(game.turnCount, 4);
        expect(game.board.cellAt(40).isAssigned, isFalse);
        expect(find.byKey(const ValueKey('cell.40.match')), findsOneWidget);
        for (final i in [40, 41]) {
          final overlay = find.byKey(ValueKey('cell.$i.match'));
          expect(
            tester
                .widget<Opacity>(
                  find.descendant(of: overlay, matching: find.byType(Opacity)),
                )
                .opacity,
            0.0,
          );
          expect(
            tester.getSemantics(find.byKey(ValueKey('cell.$i'))),
            matchesSemantics(
              label: 'Empty cell',
              isButton: true,
              hasTapAction: true,
            ),
          );
        }
        expect(tester.hasRunningAnimations, isFalse);
        handle.dispose();
      });
    });

    group('cell size with the real frame (AC-UI-07, AC-UI-25)', () {
      // 설계값(design.md §4). 셀 = (보드 한 변 − 20) / 9.
      final cases = <Size, double>{
        const Size(360, 640): (348 - 20) / 9,
        const Size(360, 780): (348 - 20) / 9,
        const Size(568, 320): (308 - 20) / 9,
        const Size(740, 360): (348 - 20) / 9,
      };
      for (final entry in cases.entries) {
        final viewport = entry.key;
        testWidgets(
            '${viewport.width.toInt()}x${viewport.height.toInt()}: '
            'cell = ${entry.value.toStringAsFixed(2)}', (tester) async {
          await pumpGame(tester, stateWith({40: 7}), viewport: viewport);

          expect(tester.takeException(), isNull);
          final boardSide =
              tester.getSize(find.byKey(const ValueKey('game.board'))).width;
          final cell = tester.getSize(find.byKey(const ValueKey('cell.0')));
          // ignore: avoid_print
          print(
              'measured ${viewport.width.toInt()}x${viewport.height.toInt()}: '
              'board ${boardSide.toStringAsFixed(2)}, '
              'cell ${cell.width.toStringAsFixed(2)}x'
              '${cell.height.toStringAsFixed(2)}');
          expect(cell.width, closeTo((boardSide - 20) / 9, 0.01));
          expect(cell.width, closeTo(entry.value, 0.01));
          expect(cell.height, closeTo(entry.value, 0.01));
        });
      }

      testWidgets('599x640: cell = (board - 20) / 9 and >= 36', (tester) async {
        await pumpGame(
          tester,
          stateWith({40: 7}),
          viewport: const Size(599, 640),
        );

        final boardSide =
            tester.getSize(find.byKey(const ValueKey('game.board'))).width;
        final cell = tester.getSize(find.byKey(const ValueKey('cell.0')));
        // ignore: avoid_print
        print('measured 599x640: board ${boardSide.toStringAsFixed(2)}, '
            'cell ${cell.width.toStringAsFixed(2)}');
        expect(cell.width, closeTo((boardSide - 20) / 9, 0.01));
        expect(cell.width, greaterThanOrEqualTo(36));
      });
    });
  });
}
