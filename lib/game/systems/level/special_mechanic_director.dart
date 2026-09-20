import 'package:flame/components.dart';

import 'level_gameplay_config.dart';

enum SpecialMechanicEventType {
  none,
  movingGate,
  mineField,
  turretWave,
  bossPressure,
  speedBoost,
  barricadeWave,
  eliteWave,
  riskyGate,
  majorBossPressure,
  airstrike,
  shieldGate,
  enemyVehicle,
  highRiskAssault,
  finalCommandAssault,
}

class SpecialMechanicEvent {
  const SpecialMechanicEvent({
    required this.type,
    required this.intensity,
    required this.index,
  });

  final SpecialMechanicEventType type;
  final double intensity;
  final int index;
}

class SpecialMechanicDirector extends Component {
  SpecialMechanicDirector({
    required this.config,
    required this.onEvent,
  });

  final LevelGameplayConfig config;

  final void Function(
      SpecialMechanicEvent event,
      ) onEvent;

  double _elapsed = 0;

  bool _stopped = false;

  bool _eventOneTriggered = false;
  bool _eventTwoTriggered = false;
  bool _eventThreeTriggered = false;

  // ============================================================
  // UPDATE
  //
  // Special mechanics are deliberately separated so the road
  // does not become overloaded with hazards at the same time.
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    if (_stopped) {
      return;
    }

    _elapsed += dt;

    if (config.duration <= 0) {
      return;
    }

    final progress = (_elapsed / config.duration).clamp(
      0.0,
      1.0,
    );

    // First special encounter.
    if (!_eventOneTriggered &&
        progress >= _firstEventProgress) {
      _eventOneTriggered = true;

      _trigger(
        index: 1,
      );
    }

    // Stronger second encounter.
    if (!_eventTwoTriggered &&
        progress >= _secondEventProgress) {
      _eventTwoTriggered = true;

      _trigger(
        index: 2,
      );
    }

    // Third encounter only appears in later levels.
    if (!_eventThreeTriggered &&
        config.level >= 7 &&
        progress >= _thirdEventProgress) {
      _eventThreeTriggered = true;

      _trigger(
        index: 3,
      );
    }
  }

  // ============================================================
  // EVENT TIMING
  // ============================================================

  double get _firstEventProgress {
    if (config.level <= 3) {
      return .30;
    }

    if (config.level <= 6) {
      return .27;
    }

    if (config.level <= 10) {
      return .25;
    }

    return .24;
  }

  double get _secondEventProgress {
    if (config.level <= 3) {
      return .64;
    }

    if (config.level <= 6) {
      return .59;
    }

    if (config.level <= 10) {
      return .56;
    }

    return .54;
  }

  double get _thirdEventProgress {
    if (config.level <= 9) {
      return .82;
    }

    if (config.level <= 12) {
      return .79;
    }

    return .77;
  }

  // ============================================================
  // TRIGGER
  // ============================================================

  void _trigger({
    required int index,
  }) {
    if (_stopped) {
      return;
    }

    final type = _eventTypeForFeature(
      config.feature,
    );

    if (type == SpecialMechanicEventType.none) {
      return;
    }

    onEvent(
      SpecialMechanicEvent(
        type: type,
        intensity: _calculateIntensity(
          index,
        ),
        index: index,
      ),
    );
  }

  // ============================================================
  // LEVEL FEATURE -> GAMEPLAY EVENT
  // ============================================================

  SpecialMechanicEventType _eventTypeForFeature(
      LevelSpecialFeature feature,
      ) {
    switch (feature) {
      case LevelSpecialFeature.basicAssault:
        return SpecialMechanicEventType.none;

      case LevelSpecialFeature.movingGates:
        return SpecialMechanicEventType.movingGate;

      case LevelSpecialFeature.mines:
        return SpecialMechanicEventType.mineField;

      case LevelSpecialFeature.turrets:
        return SpecialMechanicEventType.turretWave;

      case LevelSpecialFeature.bossRush:
        return SpecialMechanicEventType.bossPressure;

      case LevelSpecialFeature.speedBoost:
        return SpecialMechanicEventType.speedBoost;

      case LevelSpecialFeature.barricades:
        return SpecialMechanicEventType.barricadeWave;

      case LevelSpecialFeature.eliteEnemies:
        return SpecialMechanicEventType.eliteWave;

      case LevelSpecialFeature.riskyGates:
        return SpecialMechanicEventType.riskyGate;

      case LevelSpecialFeature.majorBoss:
        return SpecialMechanicEventType.majorBossPressure;

      case LevelSpecialFeature.airstrikes:
        return SpecialMechanicEventType.airstrike;

      case LevelSpecialFeature.shieldGates:
        return SpecialMechanicEventType.shieldGate;

      case LevelSpecialFeature.enemyVehicles:
        return SpecialMechanicEventType.enemyVehicle;

      case LevelSpecialFeature.highRisk:
        return SpecialMechanicEventType.highRiskAssault;

      case LevelSpecialFeature.finalCommand:
        return SpecialMechanicEventType.finalCommandAssault;
    }
  }

  // ============================================================
  // SMOOTH INTENSITY
  //
  // Difficulty still increases every level, but individual
  // mechanic encounters do not jump too sharply.
  // ============================================================

  double _calculateIntensity(
      int index,
      ) {
    double result = config.enemyDifficulty;

    if (index == 1) {
      result *= .90;
    } else if (index == 2) {
      result *= .98;
    } else {
      result *= 1.05;
    }

    if (config.usesPressureFamily) {
      result *= 1.03;
    }

    return result.clamp(
      .65,
      2.05,
    );
  }

  // ============================================================
  // MANUAL TRIGGER
  // ============================================================

  void triggerNow({
    int index = 1,
  }) {
    if (_stopped) {
      return;
    }

    _trigger(
      index: index,
    );
  }

  // ============================================================
  // STOP
  // ============================================================

  void stop() {
    _stopped = true;
  }
}