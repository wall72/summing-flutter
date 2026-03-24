import 'package:flutter/services.dart';

import 'game_audio_assets.dart';

/// Which packaged audio files exist (avoids [AssetSource] when absent).
///
/// Uses [AssetBundle.load] so it works when Flutter ships **AssetManifest.bin**
/// instead of `AssetManifest.json` (which would make JSON parsing fail and mute
/// all audio).
class AudioBundleAvailability {
  const AudioBundleAvailability({
    required this.bgm,
    required this.tap,
    required this.match,
  });

  final bool bgm;
  final bool tap;
  final bool match;

  static const none = AudioBundleAvailability(bgm: false, tap: false, match: false);

  static Future<AudioBundleAvailability> load(AssetBundle bundle) async {
    Future<bool> exists(String key) async {
      try {
        await bundle.load(key);
        return true;
      } on Object {
        return false;
      }
    }

    return AudioBundleAvailability(
      bgm: await exists(GameAudioAssets.bundleBgm),
      tap: await exists(GameAudioAssets.bundleTap),
      match: await exists(GameAudioAssets.bundleMatch),
    );
  }
}
