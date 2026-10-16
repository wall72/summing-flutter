import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/presentation/menu/menu_page.dart';
import 'package:summing_flutter/presentation/scores/scores_page.dart';
import 'package:summing_flutter/presentation/theme/app_theme.dart';

import '../../support/test_overrides.dart';

/// 메뉴·점수판·How to Play 시트 화면의 텍스트 대비 (SPEC-UI-001 AC-UI-02).
/// 게임 화면 세 가지는 `app_theme_test.dart`가 검사한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  Future<FakePorts> pumpScreen(
    WidgetTester tester,
    Widget home,
    ThemeMode mode, {
    GameState? saved,
    List<int> scores = const [],
  }) async {
    final fakes = FakePorts();
    fakes.gameSave.stored = saved;
    fakes.highScores.scores = scores;
    final container = ProviderContainer(overrides: fakes.overrides());
    addTearDown(container.dispose);
    await container.read(gameAudioProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return fakes;
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    group('AC-UI-02 ${mode.name}', () {
      testWidgets('MenuPage with Resume enabled', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpScreen(tester, const MenuPage(), mode,
            saved: playingAtTurn3());
        expect(find.text('Resume Game (3 turns)'), findsOneWidget);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });

      testWidgets('MenuPage with the SnackBar showing', (tester) async {
        final handle = tester.ensureSemantics();
        final fakes = await pumpScreen(tester, const MenuPage(), mode,
            saved: playingAtTurn3());
        // 저장이 사라진 뒤 Resume을 누르면 불러오기에 실패해 SnackBar가 뜬다.
        fakes.gameSave.stored = null;
        await tester.tap(find.text('Resume Game (3 turns)'));
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsOneWidget);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });

      testWidgets('MenuPage with the How to Play sheet open', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpScreen(tester, const MenuPage(), mode,
            saved: playingAtTurn3());
        await tester.ensureVisible(find.text('How to Play'));
        await tester.tap(find.text('How to Play'));
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsOneWidget);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });

      testWidgets('ScoresPage with score rows', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpScreen(tester, const ScoresPage(), mode,
            scores: const [12, 15, 21]);
        expect(find.text('12 turns'), findsOneWidget);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    });
  }
}
