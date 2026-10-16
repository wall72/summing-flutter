import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/game_session_notifier.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/presentation/game/game_page.dart';

import '../../support/test_overrides.dart';

/// 동작 고정 (AC-ARCH-16 → SPEC-UI-001 M1에서 의도적으로 변경).
/// 이전 단언 "Restart는 확인 없이 즉시 새 판을 시작한다"는
/// `.moai/specs/SPEC-ARCH-001/acceptance.md` §D.2와 SPEC-UI-001 `acceptance.md`
/// §D.2에 따라 확인 대화상자 흐름(AC-UI-08 ~ 11)으로 바뀌었다. 회귀가 아닌 계획된 변경이다.
/// playing 중 Restart → 확인 대화상자 → 확인하면 새 판 시작과 저장 1회.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Restart while playing asks for confirmation, then restarts',
      (tester) async {
    final fakes = FakePorts();
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
    await container.read(gameAudioProvider.future);
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

    // 확인 전에는 상태와 저장이 그대로다.
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(container.read(gameSessionProvider)!.turnCount, 3);
    expect(fakes.log.where((e) => e == 'save'), isEmpty);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Restart'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(container.read(gameSessionProvider)!.turnCount, 0);
    expect(find.text('0 turns'), findsOneWidget);
    expect(fakes.log.where((e) => e == 'save').length, 1);
    expect(fakes.gameSave.saved.last.turnCount, 0);
  });
}
