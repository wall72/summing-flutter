import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/main.dart';
import 'package:summing_flutter/presentation/game/game_page.dart';
import 'package:summing_flutter/presentation/game/widgets/end_overlay.dart';
import 'package:summing_flutter/presentation/scores/scores_page.dart';
import 'package:summing_flutter/presentation/theme/app_theme.dart';

import '../../support/test_overrides.dart';

/// 화면 전환과 종료 오버레이 진입 (SPEC-UI-001 AC-UI-20, AC-UI-14 감속 모드).
///
/// 절반 시점 기대값: easeOutCubic(0.5) = 0.875 → opacity 0.875,
/// scale 0.96 + 0.04 × 0.875 = 0.995 (`design.md` §6).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const halfOpacity = 0.875;
  const halfScale = 0.995;

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
    final cells = List<SummingCell>.filled(
      CellIndex.cellCount,
      const SummingCell.filled(0),
    );
    cells[0] = SummingCell.empty;
    return GameState(
      board: Board.fromCells(cells),
      queue: NextQueue(const [5, 1, 2, 3]),
      turnCount: 9,
    );
  }

  /// 실제 앱 루트(`SummingApp`)를 fake 포트로 그린다. 감속 모드는 플랫폼 접근성 설정으로 켠다.
  Future<void> pumpApp(
    WidgetTester tester, {
    bool reduceMotion = false,
  }) async {
    if (reduceMotion) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
    }
    final fakes = FakePorts();
    final container = ProviderContainer(overrides: fakes.overrides());
    addTearDown(container.dispose);
    await container.read(gameAudioProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SummingApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// [state]로 이어 받은 GamePage를 바로 그린다 (종료 오버레이 검사용).
  Future<ProviderContainer> pumpGame(
    WidgetTester tester,
    GameState state, {
    bool disableAnimations = false,
  }) async {
    final fakes = FakePorts();
    fakes.gameSave.stored = state;
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

  /// [target]에 가장 가까운 조상 [FadeTransition]의 opacity.
  double fadeOf(WidgetTester tester, Finder target) => tester
      .widget<FadeTransition>(
        find.ancestor(of: target, matching: find.byType(FadeTransition)).first,
      )
      .opacity
      .value;

  /// [target]에 가장 가까운 조상 [ScaleTransition]의 scale.
  double scaleOf(WidgetTester tester, Finder target) => tester
      .widget<ScaleTransition>(
        find.ancestor(of: target, matching: find.byType(ScaleTransition)).first,
      )
      .scale
      .value;

  group('AC-UI-20 screen transitions', () {
    final cases = <String, ({String button, Finder page})>{
      'MenuPage → GamePage': (
        button: 'New Game',
        page: find.byType(GamePage),
      ),
      'MenuPage → ScoresPage': (
        button: 'Scores',
        page: find.byType(ScoresPage),
      ),
    };

    for (final entry in cases.entries) {
      testWidgets('${entry.key}: page 320ms fade + scale, easeOutCubic',
          (tester) async {
        await pumpApp(tester);

        await tester.tap(find.text(entry.value.button));
        await tester.pump();
        // 첫 프레임에서는 HeroController가 새 route를 offstage로 둔다. 그래도 전환은 이 프레임에 시작한다.
        await tester.pump(const Duration(milliseconds: 160));

        final page = entry.value.page;
        expect(page, findsOneWidget);
        final route = ModalRoute.of(tester.element(page))! as PageRoute<void>;
        expect(route.transitionDuration, const Duration(milliseconds: 320));
        expect(fadeOf(tester, page), closeTo(halfOpacity, 0.01));
        expect(scaleOf(tester, page), closeTo(halfScale, 0.001));

        await tester.pumpAndSettle();
        expect(fadeOf(tester, page), 1.0);
        expect(scaleOf(tester, page), 1.0);
      });
    }

    testWidgets('end overlay: emphasized 300ms fade + scale, easeOutCubic',
        (tester) async {
      await pumpGame(tester, oneMoveFromComplete());
      expect(find.byType(EndOverlay), findsNothing);

      await tester.tap(find.byKey(const ValueKey('cell.40')));
      await tester.pump();

      final title = find.text('Complete!');
      expect(title, findsOneWidget);

      await tester.pump(const Duration(milliseconds: 150));
      expect(fadeOf(tester, title), closeTo(halfOpacity, 0.01));
      expect(scaleOf(tester, title), closeTo(halfScale, 0.001));

      await tester.pumpAndSettle();
      expect(fadeOf(tester, title), 1.0);
      expect(scaleOf(tester, title), 1.0);
    });

    testWidgets('end overlay buttons respond while the entrance runs',
        (tester) async {
      final container = await pumpGame(tester, oneMoveFromComplete());

      await tester.tap(find.byKey(const ValueKey('cell.40')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Play again'));
      await tester.pumpAndSettle();

      expect(find.byType(EndOverlay), findsNothing);
      expect(container.read(gameSessionProvider)!.turnCount, 0);
    });

    testWidgets('Back returns to MenuPage through the reverse transition',
        (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Scores'));
      await tester.pumpAndSettle();
      expect(find.byType(ScoresPage), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ScoresPage), findsNothing);
      expect(find.text('New Game'), findsOneWidget);
    });
  });

  group('AC-UI-14 reduced motion', () {
    testWidgets('MenuPage → GamePage: final frame after two pumps',
        (tester) async {
      await pumpApp(tester, reduceMotion: true);

      await tester.tap(find.text('New Game'));
      await tester.pump();
      await tester.pump();

      final page = find.byType(GamePage);
      expect(page, findsOneWidget);
      final route = ModalRoute.of(tester.element(page))! as PageRoute<void>;
      expect(route.transitionDuration, Duration.zero);
      expect(fadeOf(tester, page), 1.0);
      expect(scaleOf(tester, page), 1.0);
      expect(tester.hasRunningAnimations, isFalse);
    });

    for (final entry in {
      'complete': (oneMoveFromComplete(), 40, 'Complete!'),
      'gameOver': (oneMoveFromGameOver(), 0, 'Game Over'),
    }.entries) {
      testWidgets('${entry.key} overlay: opacity 1.0 after two pumps',
          (tester) async {
        final (state, cell, titleText) = entry.value;
        await pumpGame(tester, state, disableAnimations: true);

        await tester.tap(find.byKey(ValueKey('cell.$cell')));
        await tester.pump();
        await tester.pump();

        final title = find.text(titleText);
        expect(title, findsOneWidget);
        expect(fadeOf(tester, title), 1.0);
        expect(scaleOf(tester, title), 1.0);
        expect(tester.hasRunningAnimations, isFalse);
      });
    }
  });
}
