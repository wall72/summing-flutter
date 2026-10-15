import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/infrastructure/audio/audio_providers.dart';
import 'package:summing_flutter/presentation/game/game_page.dart';

import '../../support/pre_refactor_fakes.dart';

/// 현재 동작 고정: Restart는 확인 없이 즉시 새 판을 시작한다 (AC-ARCH-16).
/// SPEC-UI-001 M1에서 확인 대화상자 흐름으로 의도적으로 바뀔 예정이다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Restart starts a new run immediately without a dialog',
      (tester) async {
    final fakes = await PreRefactorFakes.create();
    final cells =
        List<SummingCell>.filled(CellIndex.cellCount, SummingCell.empty);
    cells[40] = const SummingCell.filled(7);
    fakes.gameSave.stored = GameState(
      board: Board.fromCells(cells),
      queue: NextQueue(const [1, 2, 3, 4]),
      turnCount: 3,
    );
    final container = ProviderContainer(overrides: fakes.overrides());
    addTearDown(container.dispose);
    await container.read(gameAudioServiceProvider.future);
    await container.read(gameSessionProvider.notifier).resumeGame();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: GamePage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('3 turns'), findsOneWidget);
    fakes.log.clear();

    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(container.read(gameSessionProvider)!.turnCount, 0);
    expect(find.text('0 turns'), findsOneWidget);
    expect(fakes.log.where((e) => e == 'save').length, 1);
    expect(fakes.gameSave.saved.last.turnCount, 0);
  });
}
