/// Paths for [AssetSource] (relative to the project `assets/` folder).
///
/// Add files under `assets/audio/` and register in `pubspec.yaml`:
/// ```yaml
/// flutter:
///   assets:
///     - assets/audio/
/// ```
///
/// BGM: same as original iOS (`bg_music.mp3`).
/// SFX: original used `.aif`; we ship **`.wav`** (converted from those files) for
/// Windows / Android / desktop decoders that often lack AIFF support.
///
/// [bundle*] keys are passed to [AssetBundle.load].
abstract final class GameAudioAssets {
  static const bundleBgm = 'assets/audio/bg_music.mp3';
  static const bundleTap = 'assets/audio/tap_sound.wav';
  static const bundleMatch = 'assets/audio/clap_sound.wav';

  /// Paths for [AssetSource] (relative to the `assets/` directory).
  static const bgm = 'audio/bg_music.mp3';
  static const tap = 'audio/tap_sound.wav';
  static const match = 'audio/clap_sound.wav';
}
