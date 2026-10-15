import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/infrastructure/audio/audio_providers.dart';
import 'package:summing_flutter/presentation/common/game_lifecycle_listener.dart';

import '../../support/pre_refactor_fakes.dart';

/// 생명주기 → 오디오 suspend/resume 고정 (AC-ARCH-15).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('inactive does not suspend; paused then resumed does',
      (tester) async {
    final fakes = await PreRefactorFakes.create();
    final container = ProviderContainer(overrides: fakes.overrides());
    addTearDown(container.dispose);
    await container.read(gameAudioServiceProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const GameLifecycleListener(
          child: MaterialApp(home: SizedBox.shrink()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    fakes.log.clear();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();
    expect(fakes.log.where((e) => e == 'suspend'), isEmpty);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(
      fakes.log.where((e) => e == 'suspend' || e == 'resume').toList(),
      ['suspend', 'resume'],
    );
  });
}
