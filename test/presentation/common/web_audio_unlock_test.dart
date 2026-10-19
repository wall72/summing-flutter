import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/port_providers.dart';
import 'package:summing_flutter/application/ports.dart';
import 'package:summing_flutter/main.dart';
import 'package:summing_flutter/presentation/common/web_audio_unlock.dart';

import '../../support/test_overrides.dart';

/// 웹 첫 제스처 오디오 해제 (SPEC-UI-001 AC-UI-22, plan.md D-9).
///
/// `flutter test`에서는 `kIsWeb`가 항상 false이므로 같은 스위치를 직접 켜서 검사한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  int gestureCount(FakePorts fakes) =>
      fakes.log.where((e) => e == 'notifyUserGesture').length;

  group('app root', () {
    Future<FakePorts> pumpApp(WidgetTester tester,
        {required bool unlock}) async {
      final fakes = FakePorts();
      await tester.pumpWidget(
        ProviderScope(
          overrides: fakes.overrides(),
          child: SummingApp(webAudioUnlockEnabled: unlock),
        ),
      );
      await tester.pumpAndSettle();
      return fakes;
    }

    testWidgets('switch on: a pointer down anywhere notifies the audio port',
        (tester) async {
      final fakes = await pumpApp(tester, unlock: true);
      expect(gestureCount(fakes), 0);

      await tester.tapAt(const Offset(4, 300));
      await tester.pump();

      expect(gestureCount(fakes), greaterThanOrEqualTo(1));
    });

    testWidgets('switch off: a pointer down does not notify', (tester) async {
      final fakes = await pumpApp(tester, unlock: false);

      await tester.tapAt(const Offset(4, 300));
      await tester.pump();

      expect(gestureCount(fakes), 0);
    });

    test('production default is kIsWeb', () {
      expect(const SummingApp().webAudioUnlockEnabled, kIsWeb);
    });
  });

  group('WebAudioUnlock widget', () {
    Future<FakePorts> pumpUnlock(
      WidgetTester tester, {
      required bool enabled,
    }) async {
      final fakes = FakePorts();
      final container = ProviderContainer(overrides: fakes.overrides());
      addTearDown(container.dispose);
      await container.read(gameAudioProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: WebAudioUnlock(
              enabled: enabled,
              child: GestureDetector(
                key: const ValueKey('target'),
                onTap: () {},
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );
      return fakes;
    }

    testWidgets('does not swallow the gesture of the child', (tester) async {
      var taps = 0;
      final fakes = FakePorts();
      final container = ProviderContainer(overrides: fakes.overrides());
      addTearDown(container.dispose);
      await container.read(gameAudioProvider.future);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: WebAudioUnlock(
              enabled: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => taps++,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );

      await tester.tapAt(const Offset(10, 10));
      expect(taps, 1);
      expect(gestureCount(fakes), 1);
    });

    testWidgets('disabled returns the child without a Listener wrapper',
        (tester) async {
      final fakes = await pumpUnlock(tester, enabled: false);
      expect(
        find.ancestor(
          of: find.byKey(const ValueKey('target')),
          matching: find.byType(Listener),
        ),
        findsNothing,
      );
      await tester.tapAt(const Offset(10, 10));
      expect(gestureCount(fakes), 0);
    });

    testWidgets('audio port still loading: the gesture is dropped quietly',
        (tester) async {
      final fakes = FakePorts();
      await tester.pumpWidget(
        ProviderScope(
          // 끝나지 않는 Future: 포트가 아직 준비되지 않은 상태
          overrides: fakes.overrides(
            audioFuture: () => Completer<GameAudio>().future,
          ),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: WebAudioUnlock(enabled: true, child: SizedBox.expand()),
          ),
        ),
      );

      await tester.tapAt(const Offset(10, 10));
      expect(tester.takeException(), isNull);
      expect(gestureCount(fakes), 0);
    });
  });
}
