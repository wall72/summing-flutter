/// Paths for [AssetSource] (relative to the project `assets/` folder).
///
/// Registered in `pubspec.yaml` under `flutter: assets:`.
///
/// BGM: same as original iOS (`bg_music.mp3`).
/// SFX: original used `.aif`; we ship **`.wav`** (converted from those files) for
/// decoders that often lack AIFF support.
abstract final class GameAudioAssets {
  static const bgm = 'audio/bg_music.mp3';
  static const tap = 'audio/tap_sound.wav';
  static const match = 'audio/clap_sound.wav';
}
