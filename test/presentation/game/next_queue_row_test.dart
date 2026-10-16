import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/presentation/game/game_page.dart';
import 'package:summing_flutter/presentation/game/widgets/next_queue_row.dart';
import 'package:summing_flutter/presentation/layout/breakpoints.dart';
import 'package:summing_flutter/presentation/theme/app_theme.dart';
import 'package:summing_flutter/presentation/theme/app_tokens.dart';

import '../../support/test_overrides.dart';

/// 큐 행 재스타일과 이동 연출 (SPEC-UI-001 AC-UI-14, 15, 25, `design.md` §5, §6).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pitch = GameLayout.queueSlotSize + GameLayout.queueSlotGap;

  Finder slot(int i) => find.descendant(
        of: find.byType(NextQueueRow),
        matching: find.byKey(ValueKey('queue.slot.$i')),
      );

  Future<void> pumpRow(
    WidgetTester tester,
    NextQueue queue, {
    ThemeData? theme,
    bool labelAbove = false,
    double slotSize = GameLayout.queueSlotSize,
    bool disableAnimations = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: child!,
        ),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: NextQueueRow(
              queue: queue,
              labelAbove: labelAbove,
              slotSize: slotSize,
            ),
          ),
        ),
      ),
    );
  }

  /// 큐 칸 [i]의 장식.
  BoxDecoration slotDecoration(WidgetTester tester, int i) {
    final decorations = tester
        .widgetList<DecoratedBox>(
          find.descendant(of: slot(i), matching: find.byType(DecoratedBox)),
        )
        .map((d) => d.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.color != null)
        .toList();
    expect(decorations, hasLength(1), reason: 'queue.slot.$i fill');
    return decorations.single;
  }

  group('styling (design.md §5)', () {
    for (final entry in {
      'light': (AppTheme.light, AppPalette.light),
      'dark': (AppTheme.dark, AppPalette.dark),
    }.entries) {
      testWidgets('${entry.key}: head slot queueHead tokens + 2px outline',
          (tester) async {
        final (theme, palette) = entry.value;
        await pumpRow(tester, NextQueue(const [1, 2, 3, 4]), theme: theme);

        for (var i = 0; i < NextQueue.length; i++) {
          expect(slot(i), findsOneWidget);
        }

        final head = slotDecoration(tester, 0);
        expect(head.color, palette.queueHeadContainer);
        final headBorder = head.border! as Border;
        expect(headBorder.top.color, palette.queueHeadOutline);
        expect(headBorder.top.width, 2);
        expect(head.borderRadius, BorderRadius.circular(AppRadius.sm));

        for (var i = 1; i < NextQueue.length; i++) {
          final d = slotDecoration(tester, i);
          expect(d.color, palette.surfaceContainer, reason: 'slot $i');
          expect(d.borderRadius, BorderRadius.circular(AppRadius.sm));
        }

        final headDigit = tester.widget<Text>(
          find.descendant(of: slot(0), matching: find.text('1')),
        );
        expect(headDigit.style?.color, palette.onQueueHead);
        expect(headDigit.style?.fontSize, AppTypeScale.queueDigit);
        expect(headDigit.style?.fontWeight, FontWeight.w800);
        final otherDigit = tester.widget<Text>(
          find.descendant(of: slot(1), matching: find.text('2')),
        );
        expect(otherDigit.style?.color, palette.onSurface);
      });
    }

    testWidgets('low-height panel: Next: on its own line, digit size 20',
        (tester) async {
      await pumpRow(
        tester,
        NextQueue(const [1, 2, 3, 4]),
        labelAbove: true,
        slotSize: GameLayout.lowHeightQueueSlotSize,
      );

      final label = tester.getRect(find.text('Next:'));
      expect(label.bottom, lessThanOrEqualTo(tester.getRect(slot(0)).top));
      expect(
        tester.getSize(slot(0)),
        const Size.square(GameLayout.lowHeightQueueSlotSize),
      );
      final digit = tester.widget<Text>(
        find.descendant(of: slot(0), matching: find.text('1')),
      );
      expect(digit.style?.fontSize, AppTypeScale.queueDigitCompact);
    });
  });

  group('queue shift slide (design.md §6)', () {
    testWidgets('after a shift the head slides in from one pitch right',
        (tester) async {
      final before = NextQueue(const [1, 2, 3, 4]);
      await pumpRow(tester, before);
      final x0 = tester.getTopLeft(slot(0)).dx;

      await pumpRow(tester, before.afterPlace(Random(1)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final x = tester.getTopLeft(slot(0)).dx;
      // easeOutCubic(0.5) = 0.875 → 남은 거리 0.125 × 칸 간격.
      expect(x, greaterThan(x0));
      expect(x, lessThan(x0 + pitch));
      expect(x, closeTo(x0 + pitch * 0.125, 0.5));

      await tester.pumpAndSettle();
      expect(tester.getTopLeft(slot(0)).dx, x0);
    });

    testWidgets('a second shift mid-slide restarts the slide', (tester) async {
      final first = NextQueue(const [1, 2, 3, 4]);
      await pumpRow(tester, first);
      final x0 = tester.getTopLeft(slot(0)).dx;

      final second = first.afterPlace(Random(1));
      await pumpRow(tester, second);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      await pumpRow(tester, second.afterPlace(Random(2)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 첫 이동은 이미 끝났을 시점이지만 두 번째 이동이 절반 지점에 있다.
      expect(tester.getTopLeft(slot(0)).dx, closeTo(x0 + pitch * 0.125, 0.5));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(slot(0)).dx, x0);
    });

    testWidgets('sliding slots are clipped to the queue row', (tester) async {
      final before = NextQueue(const [1, 2, 3, 4]);
      await pumpRow(tester, before);
      await pumpRow(tester, before.afterPlace(Random(1)));
      await tester.pump();

      final clip = find.ancestor(of: slot(3), matching: find.byType(ClipRect));
      expect(
        find.descendant(of: find.byType(NextQueueRow), matching: clip),
        findsOneWidget,
      );
    });

    testWidgets('a queue that did not shift (restart) does not slide',
        (tester) async {
      await pumpRow(tester, NextQueue(const [1, 2, 3, 4]));
      final x0 = tester.getTopLeft(slot(0)).dx;

      await pumpRow(tester, NextQueue(const [9, 9, 9, 9]));
      await tester.pump();
      expect(tester.getTopLeft(slot(0)).dx, x0);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('reduced motion: shift ends within two frames', (tester) async {
      final before = NextQueue(const [1, 2, 3, 4]);
      await pumpRow(tester, before, disableAnimations: true);
      final x0 = tester.getTopLeft(slot(0)).dx;

      await pumpRow(
        tester,
        before.afterPlace(Random(1)),
        disableAnimations: true,
      );
      await tester.pump();
      await tester.pump();

      expect(tester.getTopLeft(slot(0)).dx, x0);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('GamePage', () {
    GameState playing() {
      final cells =
          List<SummingCell>.filled(CellIndex.cellCount, SummingCell.empty);
      cells[0] = const SummingCell.filled(5);
      cells[40] = const SummingCell.filled(7);
      return GameState(
        board: Board.fromCells(cells),
        queue: NextQueue(const [1, 2, 3, 4]),
        turnCount: 3,
      );
    }

    Future<ProviderContainer> pumpGame(
      WidgetTester tester, {
      bool disableAnimations = false,
    }) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final fakes = FakePorts();
      fakes.gameSave.stored = playing();
      final container = ProviderContainer(overrides: fakes.overrides());
      addTearDown(container.dispose);
      await container.read(gameAudioProvider.future);
      await container.read(gameSessionProvider.notifier).resumeGame();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
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

    testWidgets('AC-UI-15 slide mid-way, rapid second tap, settles at x0',
        (tester) async {
      final container = await pumpGame(tester);
      final x0 = tester.getTopLeft(slot(0)).dx;

      await tester.tap(find.byKey(const ValueKey('cell.80')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final x = tester.getTopLeft(slot(0)).dx;
      expect(x, greaterThan(x0));
      expect(x, lessThan(x0 + pitch));

      // 200ms 안에 다른 빈 칸을 다시 탭한다.
      await tester.tap(find.byKey(const ValueKey('cell.72')));
      await tester.pump();
      expect(container.read(gameSessionProvider)!.turnCount, 5);

      await tester.pumpAndSettle();
      expect(tester.getTopLeft(slot(0)).dx, x0);
    });

    testWidgets('AC-UI-14 reduced motion: queue shift ends within two frames',
        (tester) async {
      final container = await pumpGame(tester, disableAnimations: true);
      final x0 = tester.getTopLeft(slot(0)).dx;

      await tester.tap(find.byKey(const ValueKey('cell.80')));
      await tester.pump();
      await tester.pump();

      expect(container.read(gameSessionProvider)!.turnCount, 4);
      expect(find.descendant(of: slot(0), matching: find.text('2')),
          findsOneWidget);
      expect(tester.getTopLeft(slot(0)).dx, x0);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
