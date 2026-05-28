import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  AudioManager._();

  static const String bgGame = 'bg_game.mp3';
  static const String sfxSlide = 'slide.mp3';
  static const String combo1Hit = 'combo1_hit.mp3';
  static const String combo2Hit = 'combo2_hit.mp3';
  static const String combo3Hit = 'combo3_hit.mp3';
  static const String winLevel = 'win_level.mp3';
  static const double defaultBgmVolume = 0.35;
  static const double defaultSfxVolume = 0.75;
  static const double defaultComboSfxVolume = 0.8;
  static const double defaultWinningSfxVolume = 0.85;

  static Future<void>? _initialization;
  static Future<void>? _startingBgm;
  static DateTime? _lastSlideSfxPlayedAt;
  static bool _isBgmPlaying = false;
  static bool _isPausedByLifecycle = false;
  static bool _isAppActive = true;
  static bool _isWinningSfxPlaying = false;

  static Future<void> init() {
    return _initialization ??= _initialize();
  }

  static Future<void> _initialize() async {
    FlameAudio.updatePrefix('assets/music/');
    await FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([
      bgGame,
      sfxSlide,
      combo1Hit,
      combo2Hit,
      combo3Hit,
      winLevel,
    ]);
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

  static Future<void> playComboHitSfx(int comboCount) async {
    if (comboCount <= 0) {
      return;
    }
    await init();

    final sfx = _comboHitSfxFor(comboCount);
    unawaited(FlameAudio.play(sfx, volume: defaultComboSfxVolume));
  }

  static Future<void> playWinningSfx() async {
    await init();
    if (_isWinningSfxPlaying) {
      return;
    }

    _isWinningSfxPlaying = true;
    unawaited(_playWinningSfxWithBgmPause());
  }

  static Future<void> _playWinningSfxWithBgmPause() async {
    final startingBgm = _startingBgm;
    if (startingBgm != null) {
      await startingBgm;
    }

    final shouldResumeBgm =
        _isBgmPlaying && !_isPausedByLifecycle && _isAppActive;
    AudioPlayer? player;
    try {
      if (shouldResumeBgm) {
        await FlameAudio.bgm.pause();
      }

      player = await FlameAudio.play(
        winLevel,
        volume: defaultWinningSfxVolume,
      );
      await player.onPlayerComplete.first.timeout(
        const Duration(seconds: 8),
      );
    } catch (_) {
      // Keep audio state recoverable even if a platform completion event is lost.
    } finally {
      await player?.dispose();
      _isWinningSfxPlaying = false;
      if (shouldResumeBgm && _isAppActive && !_isPausedByLifecycle) {
        await FlameAudio.bgm.resume();
      }
    }
  }

  static String _comboHitSfxFor(int comboCount) {
    return switch ((comboCount - 1) % 3) {
      0 => combo1Hit,
      1 => combo2Hit,
      _ => combo3Hit,
    };
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
