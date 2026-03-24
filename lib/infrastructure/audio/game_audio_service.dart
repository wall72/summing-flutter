import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../persistence/settings_store.dart';
import 'audio_bundle_availability.dart';
import 'game_audio_assets.dart';

/// BGM loop + placement / match SFX (PRD §7.4).
///
/// Only calls [AssetSource] when [AssetBundle.load] succeeds for each file.
/// Otherwise skips native playback (no missing-asset / decoder errors).
/// SFX falls back to [SystemSoundType.click] when tap/match assets are absent.
class GameAudioService {
  GameAudioService({required SettingsStore settingsStore})
    : _settings = settingsStore;

  final SettingsStore _settings;

  AudioPlayer? _bgm;
  AudioPlayer? _sfx;
  var _initialized = false;
  var _playersBroken = false;
  AudioBundleAvailability? _bundle;

  /// Web blocks autoplay until a user gesture; desktop/mobile can start BGM immediately.
  var _userGestureUnlockedAudio = !kIsWeb;

  Future<AudioBundleAvailability> _availability() async {
    return _bundle ??= await AudioBundleAvailability.load(rootBundle);
  }

  Future<void> init() async {
    if (_initialized || _playersBroken) return;
    try {
      _bgm = AudioPlayer(playerId: 'bgm');
      _sfx = AudioPlayer(playerId: 'sfx');
      await _bgm!.setPlayerMode(PlayerMode.mediaPlayer);
      await _sfx!.setPlayerMode(PlayerMode.lowLatency);
      await _bgm!.setReleaseMode(ReleaseMode.loop);
      await _sfx!.setReleaseMode(ReleaseMode.release);
      await _bgm!.setVolume(1);
      await _sfx!.setVolume(1);
      _initialized = true;
    } on Object catch (e, st) {
      _playersBroken = true;
      _bgm = null;
      _sfx = null;
      if (kDebugMode) {
        debugPrint('GameAudioService: AudioPlayer init failed: $e\n$st');
      }
    }
  }

  Future<void> dispose() async {
    try {
      await _bgm?.dispose();
    } on Object {}
    try {
      await _sfx?.dispose();
    } on Object {}
    _bgm = null;
    _sfx = null;
    _initialized = false;
    _playersBroken = false;
    _bundle = null;
  }

  /// Call after [SettingsStore.save] or on startup.
  Future<void> applySettingsAndSyncBgm() async {
    final bundle = await _availability();
    if (_playersBroken) return;

    final musicOn = _settings.load().musicOn;
    if (!musicOn) {
      try {
        await _bgm?.stop();
      } on Object {}
      return;
    }

    if (!bundle.bgm) {
      try {
        await _bgm?.stop();
      } on Object {}
      return;
    }

    if (kIsWeb && !_userGestureUnlockedAudio) {
      if (kDebugMode) {
        debugPrint(
          'GameAudioService: BGM deferred (web autoplay — tap anywhere to start)',
        );
      }
      return;
    }

    try {
      await init();
      if (_playersBroken || _bgm == null) return;
      await _bgm!.stop();
      await _bgm!.play(AssetSource(GameAudioAssets.bgm));
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('GameAudioService: BGM play failed: $e\n$st');
      }
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgm?.stop();
    } on Object {}
  }

  Future<void> playTap() async => _playSfx(
        hasAsset: (b) => b.tap,
        assetPath: GameAudioAssets.tap,
      );

  Future<void> playMatch() async => _playSfx(
        hasAsset: (b) => b.match,
        assetPath: GameAudioAssets.match,
      );

  Future<void> _playSfx({
    required bool Function(AudioBundleAvailability b) hasAsset,
    required String assetPath,
  }) async {
    if (!_settings.load().soundOn) return;

    final bundle = await _availability();

    if (!_playersBroken && hasAsset(bundle)) {
      try {
        await init();
        if (_playersBroken || _sfx == null) {
          _systemClickFallback();
          return;
        }
        await _sfx!.stop();
        await _sfx!.play(AssetSource(assetPath));
      } on Object catch (e, st) {
        if (kDebugMode) {
          debugPrint('GameAudioService: SFX play failed: $e\n$st');
        }
        _systemClickFallback();
      }
      return;
    }

    _systemClickFallback();
  }

  void _systemClickFallback() {
    try {
      SystemSound.play(SystemSoundType.click);
    } on Object {}
  }

  /// Call once after a pointer/keyboard interaction on web (e.g. first tap on the app).
  /// Idempotent; safe to call multiple times.
  Future<void> notifyUserGesture() async {
    if (!kIsWeb) return;
    if (_userGestureUnlockedAudio) return;
    _userGestureUnlockedAudio = true;
    await applySettingsAndSyncBgm();
  }
}
