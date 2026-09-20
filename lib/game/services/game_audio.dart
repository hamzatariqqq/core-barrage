import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';

class GameAudio {
  GameAudio._();

  static final GameAudio instance = GameAudio._();

  bool _initialized = false;
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  double _masterVolume = 1.0;

  AudioPool? _shotPool;
  AudioPool? _hitPool;
  AudioPool? _destroyPool;

  DateTime _lastShot =
  DateTime.fromMillisecondsSinceEpoch(0);

  DateTime _lastHit =
  DateTime.fromMillisecondsSinceEpoch(0);

  DateTime _lastDestroy =
  DateTime.fromMillisecondsSinceEpoch(0);

  DateTime _lastGate =
  DateTime.fromMillisecondsSinceEpoch(0);

  DateTime _lastBossWarning =
  DateTime.fromMillisecondsSinceEpoch(0);

  DateTime _lastBossRage =
  DateTime.fromMillisecondsSinceEpoch(0);

  DateTime _lastButton =
  DateTime.fromMillisecondsSinceEpoch(0);

  // ============================================================
  // SETTINGS
  // ============================================================

  bool get soundEnabled => _soundEnabled;

  bool get hapticsEnabled => _hapticsEnabled;

  double get masterVolume => _masterVolume;

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
  }

  void setHapticsEnabled(bool value) {
    _hapticsEnabled = value;
  }

  void setMasterVolume(double value) {
    _masterVolume = value.clamp(
      0.0,
      1.0,
    );
  }

  double _volume(double value) {
    if (!_soundEnabled) {
      return 0;
    }

    return (value * _masterVolume).clamp(
      0.0,
      1.0,
    );
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    try {
      await FlameAudio.audioCache.loadAll(
        const [
          'sfx/player_shot.wav',
          'sfx/enemy_hit.wav',
          'sfx/enemy_destroy.wav',
          'sfx/missile_launch.wav',
          'sfx/missile_explosion.wav',
          'sfx/freeze.wav',
          'sfx/gate_positive.wav',
          'sfx/boss_warning.wav',
          'sfx/boss_rage.wav',
          'sfx/victory.wav',
          'sfx/defeat.wav',
        ],
      );

      // Rapid sounds use pools to prevent unnecessary
      // audio-player creation during heavy combat.
      _shotPool = await FlameAudio.createPool(
        'sfx/player_shot.wav',
        maxPlayers: 3,
      );

      _hitPool = await FlameAudio.createPool(
        'sfx/enemy_hit.wav',
        maxPlayers: 3,
      );

      _destroyPool = await FlameAudio.createPool(
        'sfx/enemy_destroy.wav',
        maxPlayers: 3,
      );
    } catch (_) {
      // Audio should never prevent the game from starting.
    }
  }

  // ============================================================
  // PLAYER SHOT
  // ============================================================

  Future<void> playerShot() async {
    if (!_soundEnabled) {
      return;
    }

    final now = DateTime.now();

    if (now.difference(_lastShot).inMilliseconds < 190) {
      return;
    }

    _lastShot = now;

    try {
      await _shotPool?.start(
        volume: _volume(0.18),
      );
    } catch (_) {}
  }

  // ============================================================
  // ENEMY HIT
  // ============================================================

  Future<void> enemyHit() async {
    if (!_soundEnabled) {
      return;
    }

    final now = DateTime.now();

    if (now.difference(_lastHit).inMilliseconds < 180) {
      return;
    }

    _lastHit = now;

    try {
      await _hitPool?.start(
        volume: _volume(0.13),
      );
    } catch (_) {}
  }

  // ============================================================
  // ENEMY DESTROY
  // ============================================================

  Future<void> enemyDestroy() async {
    final now = DateTime.now();

    if (now.difference(_lastDestroy).inMilliseconds < 145) {
      return;
    }

    _lastDestroy = now;

    if (_soundEnabled) {
      try {
        await _destroyPool?.start(
          volume: _volume(0.34),
        );
      } catch (_) {}
    }

    _lightImpact();
  }

  // ============================================================
  // GATE
  // ============================================================

  Future<void> gatePositive() async {
    final now = DateTime.now();

    if (now.difference(_lastGate).inMilliseconds < 300) {
      return;
    }

    _lastGate = now;

    if (_soundEnabled) {
      try {
        await FlameAudio.play(
          'sfx/gate_positive.wav',
          volume: _volume(0.43),
        );
      } catch (_) {}
    }

    _selectionImpact();
  }

  // ============================================================
  // MISSILE
  // ============================================================

  Future<void> missileLaunch() async {
    if (_soundEnabled) {
      try {
        await FlameAudio.play(
          'sfx/missile_launch.wav',
          volume: _volume(0.56),
        );
      } catch (_) {}
    }

    _mediumImpact();
  }

  Future<void> missileExplosion() async {
    if (_soundEnabled) {
      try {
        await FlameAudio.play(
          'sfx/missile_explosion.wav',
          volume: _volume(0.72),
        );
      } catch (_) {}
    }

    // Missile is the strongest normal combat feedback.
    _heavyImpact();

    Future<void>.delayed(
      const Duration(
        milliseconds: 90,
      ),
          () {
        _mediumImpact();
      },
    );
  }

  // ============================================================
  // FREEZE
  // ============================================================

  Future<void> freeze() async {
    if (_soundEnabled) {
      try {
        await FlameAudio.play(
          'sfx/freeze.wav',
          volume: _volume(0.53),
        );
      } catch (_) {}
    }

    _mediumImpact();

    Future<void>.delayed(
      const Duration(
        milliseconds: 85,
      ),
          () {
        _selectionImpact();
      },
    );
  }

  // ============================================================
  // BOSS WARNING
  // ============================================================

  Future<void> bossWarning() async {
    final now = DateTime.now();

    if (now
        .difference(_lastBossWarning)
        .inMilliseconds <
        1200) {
      return;
    }

    _lastBossWarning = now;

    if (_soundEnabled) {
      try {
        await FlameAudio.play(
          'sfx/boss_warning.wav',
          volume: _volume(0.68),
        );
      } catch (_) {}
    }

    _heavyImpact();

    Future<void>.delayed(
      const Duration(
        milliseconds: 140,
      ),
          () {
        _mediumImpact();
      },
    );
  }

  // ============================================================
  // BOSS RAGE
  // ============================================================

  Future<void> bossRage() async {
    final now = DateTime.now();

    if (now.difference(_lastBossRage).inMilliseconds < 900) {
      return;
    }

    _lastBossRage = now;

    if (_soundEnabled) {
      try {
        await FlameAudio.play(
          'sfx/boss_rage.wav',
          volume: _volume(0.72),
        );
      } catch (_) {}
    }

    _heavyImpact();

    Future<void>.delayed(
      const Duration(
        milliseconds: 110,
      ),
          () {
        _heavyImpact();
      },
    );
  }

  // ============================================================
  // VICTORY
  // ============================================================

  Future<void> victory() async {
    await Future<void>.delayed(
      const Duration(
        milliseconds: 120,
      ),
    );

    if (_soundEnabled) {
      try {
        await FlameAudio.play(
          'sfx/victory.wav',
          volume: _volume(0.88),
        );
      } catch (_) {}
    }

    _mediumImpact();

    Future<void>.delayed(
      const Duration(
        milliseconds: 140,
      ),
          () {
        _lightImpact();
      },
    );

    Future<void>.delayed(
      const Duration(
        milliseconds: 280,
      ),
          () {
        _lightImpact();
      },
    );
  }

  // ============================================================
  // DEFEAT
  // ============================================================

  Future<void> defeat() async {
    await Future<void>.delayed(
      const Duration(
        milliseconds: 120,
      ),
    );

    if (_soundEnabled) {
      try {
        await FlameAudio.play(
          'sfx/defeat.wav',
          volume: _volume(0.82),
        );
      } catch (_) {}
    }

    _heavyImpact();

    Future<void>.delayed(
      const Duration(
        milliseconds: 180,
      ),
          () {
        _mediumImpact();
      },
    );
  }

  // ============================================================
  // UI BUTTON FEEDBACK
  // ============================================================

  void buttonTap() {
    final now = DateTime.now();

    if (now.difference(_lastButton).inMilliseconds < 70) {
      return;
    }

    _lastButton = now;

    _selectionImpact();
  }

  // ============================================================
  // HAPTICS
  // ============================================================

  void _selectionImpact() {
    if (!_hapticsEnabled) {
      return;
    }

    unawaited(
      HapticFeedback.selectionClick(),
    );
  }

  void _lightImpact() {
    if (!_hapticsEnabled) {
      return;
    }

    unawaited(
      HapticFeedback.lightImpact(),
    );
  }

  void _mediumImpact() {
    if (!_hapticsEnabled) {
      return;
    }

    unawaited(
      HapticFeedback.mediumImpact(),
    );
  }

  void _heavyImpact() {
    if (!_hapticsEnabled) {
      return;
    }

    unawaited(
      HapticFeedback.heavyImpact(),
    );
  }
}