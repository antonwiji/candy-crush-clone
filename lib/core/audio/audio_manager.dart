import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  AudioManager._();

  static const String bgGame = 'bg_game.mp3';
  static const String sfxSlide = 'slide.mp3';
  static const double defaultBgmVolume = 0.35;
  static const double defaultSfxVolume = 0.75;

  static Future<void>? _initialization;
  static Future<void>? _startingBgm;
  static DateTime? _lastSlideSfxPlayedAt;
  static bool _isBgmPlaying = false;
  static bool _isPausedByLifecycle = false;
  static bool _isAppActive = true;

  static Future<void> init() {
    return _initialization ??= _initialize();
  }

  static Future<void> _initialize() async {
    FlameAudio.updatePrefix('assets/music/');
    await FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([bgGame, sfxSlide]);
  }

  static Future<void> playGlobalBgm() async {
    if (_isBgmPlaying) {
      return;
    }
    if (_startingBgm != null) {
      return _startingBgm!;
    }

    final startingBgm = _startBgm();
    _startingBgm = startingBgm;
    try {
      await startingBgm;
    } finally {
      if (identical(_startingBgm, startingBgm)) {
        _startingBgm = null;
      }
    }
  }

  static Future<void> _startBgm() async {
    await init();
    if (_isBgmPlaying) {
      return;
    }

    await FlameAudio.bgm.play(bgGame, volume: defaultBgmVolume);
    _isBgmPlaying = true;
    if (!_isAppActive) {
      await FlameAudio.bgm.pause();
      _isPausedByLifecycle = true;
    }
  }

  static Future<void> pauseBgmByLifecycle() async {
    _isAppActive = false;
    if (!_isBgmPlaying || _isPausedByLifecycle) {
      return;
    }

    await FlameAudio.bgm.pause();
    _isPausedByLifecycle = true;
  }

  static Future<void> playSlideSfx() async {
    await init();

    final now = DateTime.now();
    final lastPlayedAt = _lastSlideSfxPlayedAt;
    if (lastPlayedAt != null &&
        now.difference(lastPlayedAt).inMilliseconds < 100) {
      return;
    }

    _lastSlideSfxPlayedAt = now;
    unawaited(FlameAudio.play(sfxSlide, volume: defaultSfxVolume));
  }

  static Future<void> resumeBgmByLifecycle() async {
    _isAppActive = true;
    if (!_isBgmPlaying || !_isPausedByLifecycle) {
      return;
    }

    await FlameAudio.bgm.resume();
    _isPausedByLifecycle = false;
  }

  static Future<void> stopBgm() async {
    if (!_isBgmPlaying) {
      return;
    }

    await FlameAudio.bgm.stop();
    _isBgmPlaying = false;
    _isPausedByLifecycle = false;
  }

  static bool get isBgmPlaying => _isBgmPlaying;
}
