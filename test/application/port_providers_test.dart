import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summing_flutter/application/port_providers.dart';

/// override 없이 포트 provider를 읽으면 UnimplementedError가 난다.
void main() {
  final unboundProviders = <String, FutureProvider<Object>>{
    'gameSaveRepositoryProvider': gameSaveRepositoryProvider,
    'highScoreRepositoryProvider': highScoreRepositoryProvider,
    'settingsRepositoryProvider': settingsRepositoryProvider,
    'gameAudioProvider': gameAudioProvider,
  };

  for (final entry in unboundProviders.entries) {
    test('${entry.key} throws UnimplementedError without an override',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await expectLater(
        container.read(entry.value.future),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            contains(entry.key),
          ),
        ),
      );
    });
  }
}
