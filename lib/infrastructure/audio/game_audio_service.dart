import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../persistence/settings_store.dart';
import 'game_audio_assets.dart';

/// BGM loop + placement / match SFX (PRD §7.4).
///
/// Audio failures never propagate: SFX falls back to [SystemSoundType.click].
class GameAudioService {
  GameAudioService({required SettingsStore settingsStore})
      : _settings = settingsStore;

  final SettingsStore _settings;

  AudioPlayer? _bgm;
  AudioPlayer? _sfx;
  var _initialized = false;
  var _playersBroken = false;

  /// True while the app is in the background; BGM must not play then.
  var _suspended = false;

  /// Web blocks autoplay until a user gesture; mobile can start BGM immediately.
  var _userGestureUnlockedAudio = !kIsWeb;

  Future<void> init() async {
    if (_initialized || _playersBroken) return;
    try {
      final bgm = AudioPlayer(playerId: 'bgm');
      final sfx = AudioPlayer(playerId: 'sfx');
      _bgm = bgm;
      _sfx = sfx;
      await bgm.setPlayerMode(PlayerMode.mediaPlayer);
      await sfx.setPlayerMode(PlayerMode.lowLatency);
      await bgm.setReleaseMode(ReleaseMode.loop);
      await sfx.setReleaseMode(ReleaseMode.release);
      _initialized = true;
    } on Object catch (e, st) {
      _playersBroken = true;
      _bgm = null;
      _sfx = null;
      _log('AudioPlayer init failed', e, st);
    }
  }

  Future<void> dispose() async {
    await _guard(() async => _bgm?.dispose());
    await _guard(() async => _sfx?.dispose());
    _bgm = null;
    _sfx = null;
    _initialized = false;
    _playersBroken = false;
  }

  /// Call after [SettingsStore.save], on startup, or when returning to foreground.
  Future<void> applySettingsAndSyncBgm() async {
    if (_playersBroken) return;

    final shouldPlay =
        _settings.load().musicOn && !_suspended && _userGestureUnlockedAudio;
    if (!shouldPlay) {
      await stopBgm();
      return;
    }

    try {
      await init();
      final bgm = _bgm;
      if (bgm == null) return;
      if (bgm.state == PlayerState.playing) return;
      await bgm.play(AssetSource(GameAudioAssets.bgm));
    } on Object catch (e, st) {
      _log('BGM play failed', e, st);
    }
  }

  Future<void> stopBgm() => _guard(() async => _bgm?.stop());

  /// App went to background: silence BGM (store policy / battery).
  Future<void> suspend() async {
    _suspended = true;
    await _guard(() async => _bgm?.pause());
  }

  /// App returned to foreground.
  Future<void> resume() async {
    if (!_suspended) return;
    _suspended = false;
    await applySettingsAndSyncBgm();
  }

  Future<void> playTap() => _playSfx(GameAudioAssets.tap);

  Future<void> playMatch() => _playSfx(GameAudioAssets.match);

  Future<void> _playSfx(String assetPath) async {
    if (!_settings.load().soundOn || _suspended) return;

    try {
      await init();
      final sfx = _sfx;
      if (sfx == null) {
        _systemClickFallback();
        return;
      }
      await sfx.stop();
      await sfx.play(AssetSource(assetPath));
    } on Object catch (e, st) {
      _log('SFX play failed', e, st);
      _systemClickFallback();
    }
  }

  void _systemClickFallback() {
    try {
      SystemSound.play(SystemSoundType.click);
    } on Object {
      // Best effort only.
    }
  }

  /// Call once after a pointer/keyboard interaction on web (e.g. first tap on the app).
  /// Idempotent; safe to call multiple times.
  Future<void> notifyUserGesture() async {
    if (_userGestureUnlockedAudio) return;
    _userGestureUnlockedAudio = true;
    await applySettingsAndSyncBgm();
  }

  static Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on Object {
      // Best effort only.
    }
  }

  static void _log(String message, Object e, StackTrace st) {
    if (kDebugMode) debugPrint('GameAudioService: $message: $e\n$st');
  }
}
