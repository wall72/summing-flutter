import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:summing_flutter/application/port_providers.dart';

import 'audio/audio_providers.dart';
import 'persistence/persistence_providers.dart';

// @MX:ANCHOR: [AUTO] application 포트와 infrastructure 구현을 묶는 유일한 지점 (composition root 보조)
// @MX:REASON: lib/ 안에서 포트 provider를 override하는 곳은 이 목록뿐이다(AC-ARCH-14). lib/main.dart가 ProviderScope에 넘기며, 빠뜨린 포트는 런타임에 UnimplementedError가 된다
/// 앱 실행 시 포트 provider를 shared_preferences / audioplayers 구현에 연결한다.
final List<Override> appOverrides = [
  gameSaveRepositoryProvider.overrideWith(
    (ref) async => (await ref.watch(localPersistenceProvider.future)).gameSave,
  ),
  highScoreRepositoryProvider.overrideWith(
    (ref) async =>
        (await ref.watch(localPersistenceProvider.future)).highScores,
  ),
  settingsRepositoryProvider.overrideWith(
    (ref) async => (await ref.watch(localPersistenceProvider.future)).settings,
  ),
  gameAudioProvider.overrideWith(
    (ref) => ref.watch(gameAudioServiceProvider.future),
  ),
];
