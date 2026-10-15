import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/infrastructure/audio/audio_providers.dart';
import 'package:summing_flutter/presentation/menu/menu_page.dart';

import '../../support/pre_refactor_fakes.dart';

class _Menu {
  _Menu(this.fakes, this.container);

  final PreRefactorFakes fakes;
  final ProviderContainer container;
}

Future<_Menu> _pumpMenu(WidgetTester tester, {GameState? saved}) async {
  final fakes = await PreRefactorFakes.create();
  fakes.gameSave.stored = saved;
  final container = ProviderContainer(overrides: fakes.overrides());
  addTearDown(container.dispose);
  // 실제 앱은 시작 시 오디오를 미리 띄운다 (SummingApp).
  await container.read(gameAudioServiceProvider.future);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: MenuPage()),
    ),
  );
  await tester.pumpAndSettle();
  return _Menu(fakes, container);
}

GameState _playingSave(int turnCount) {
  final cells = List<SummingCell>.filled(CellIndex.cellCount, SummingCell.empty);
  cells[40] = const SummingCell.filled(7);
  return GameState(
    board: Board.fromCells(cells),
    queue: NextQueue(const [1, 2, 3, 4]),
    turnCount: turnCount,
  );
}

ButtonStyleButton _button(WidgetTester tester, String label) =>
    tester.widget<ButtonStyleButton>(
      find.ancestor(
        of: find.text(label),
        matching: find.bySubtype<ButtonStyleButton>(),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('settings toggles (AC-ARCH-08)', () {
    testWidgets('Music off saves first, then resyncs BGM once',
        (tester) async {
      final menu = await _pumpMenu(tester);
      menu.fakes.log.clear();

      await tester.tap(find.text('Music'));
      await tester.pumpAndSettle();

      expect(menu.fakes.log, [
        'save(AppSettings(musicOn: false, soundOn: true))',
        'applySettingsAndSyncBgm',
      ]);
    });

    testWidgets('Sound effects off saves without BGM resync', (tester) async {
      final menu = await _pumpMenu(tester);
      menu.fakes.log.clear();

      await tester.tap(find.text('Sound effects'));
      await tester.pumpAndSettle();

      expect(menu.fakes.log, [
        'save(AppSettings(musicOn: true, soundOn: false))',
      ]);
    });
  });

  group('resume button (AC-ARCH-09)', () {
    testWidgets('playing save with 3 turns enables Resume Game (3 turns)',
        (tester) async {
      await _pumpMenu(tester, saved: _playingSave(3));

      expect(find.text('Resume Game (3 turns)'), findsOneWidget);
      expect(_button(tester, 'Resume Game (3 turns)').enabled, isTrue);
    });

    testWidgets('no save shows a disabled Resume Game', (tester) async {
      await _pumpMenu(tester);

      expect(find.text('Resume Game'), findsOneWidget);
      expect(_button(tester, 'Resume Game').enabled, isFalse);
    });

    testWidgets('New Game then Quit enables Resume Game (0 turns)',
        (tester) async {
      await _pumpMenu(tester);

      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();
      expect(find.text('0 turns'), findsOneWidget);

      await tester.tap(find.text('Quit'));
      await tester.pumpAndSettle();

      expect(find.text('Resume Game (0 turns)'), findsOneWidget);
      expect(_button(tester, 'Resume Game (0 turns)').enabled, isTrue);
    });
  });
}
