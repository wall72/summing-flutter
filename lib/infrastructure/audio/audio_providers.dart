import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../persistence/persistence_providers.dart';
import 'game_audio_service.dart';

/// Created after [localPersistenceProvider] is ready.
final gameAudioServiceProvider = FutureProvider<GameAudioService>((ref) async {
  final persistence = await ref.watch(localPersistenceProvider.future);
  final audio = GameAudioService(settingsStore: persistence.settings);
  await audio.init();
  await audio.applySettingsAndSyncBgm();
  ref.onDispose(() {
    unawaited(audio.dispose());
  });
  return audio;
});
