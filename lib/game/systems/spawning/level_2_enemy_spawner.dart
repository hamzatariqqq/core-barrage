import 'dart:math';

import 'package:flame/components.dart';

import '../../components/enemies/basic_enemy.dart';
import '../../components/enemies/enemy_config.dart';

import '../../components/hazards/battle_barricade.dart';
import '../../components/hazards/enemy_turret.dart';

import '../level/level_2_director.dart';

class Level2EnemySpawner extends Component {
  Level2EnemySpawner({
    required this.gameSize,
  });

  final Vector2 gameSize;

  final Random _random = Random();

  bool _stopped = false;

  static const String _level2EnemyAsset =
      'enemies/enemy_02_run.png';

  static const double _roadLeft = 0.29;
  static const double _roadRight = 0.71;

  // ============================================================
  // STOP
  // ============================================================

  void stop() {
    _stopped = true;
  }

  // ============================================================
  // WAVES
  // ============================================================

  void spawnWave(
      Level2Wave wave,
      ) {
    if (_stopped) {
      return;
    }

    switch (wave) {
    // --------------------------------------------------------
    // SCOUT
    // Slight step above Level 1.
    // --------------------------------------------------------

      case Level2Wave.scout:
        _spawnWaveFormation(
          count: 4,
          baseHealth: 72,
          baseSpeed: 57,
          spawnSpacing: 0.30,
          runnerChance: 0.15,
          heavyChance: 0.00,
          pattern: _FormationPattern.vShape,
        );
        break;

    // --------------------------------------------------------
    // PRESSURE
    // Introduces first obstacle without overwhelming player.
    // --------------------------------------------------------

      case Level2Wave.pressure:
        _spawnWaveFormation(
          count: 5,
          baseHealth: 82,
          baseSpeed: 59,
          spawnSpacing: 0.28,
          runnerChance: 0.18,
          heavyChance: 0.00,
          pattern: _FormationPattern.staggered,
        );

        _spawnBarricades(
          count: 1,
          damage: 10,
          startY: -220,
        );
        break;

    // --------------------------------------------------------
    // ARMORED
    // First heavy + first turret.
    // --------------------------------------------------------

      case Level2Wave.armored:
        _spawnWaveFormation(
          count: 6,
          baseHealth: 96,
          baseSpeed: 58,
          spawnSpacing: 0.27,
          runnerChance: 0.15,
          heavyChance: 0.14,
          pattern: _FormationPattern.arrow,
        );

        _spawnBarricades(
          count: 1,
          damage: 12,
          startY: -245,
        );

        _spawnTurret(
          xFactor: 0.50,
          y: -345,
          fireInterval: 3.25,
        );
        break;

    // --------------------------------------------------------
    // ASSAULT
    // Moderate combined combat.
    // --------------------------------------------------------

      case Level2Wave.assault:
        _spawnWaveFormation(
          count: 7,
          baseHealth: 105,
          baseSpeed: 60,
          spawnSpacing: 0.25,
          runnerChance: 0.18,
          heavyChance: 0.15,
          pattern: _FormationPattern.staggered,
        );

        _spawnTurret(
          xFactor: 0.37,
          y: -365,
          fireInterval: 3.10,
        );
        break;

    // --------------------------------------------------------
    // FINAL ASSAULT
    // Hardest section of Level 2 but still fair.
    // --------------------------------------------------------

      case Level2Wave.finalAssault:
        _spawnWaveFormation(
          count: 8,
          baseHealth: 116,
          baseSpeed: 61,
          spawnSpacing: 0.24,
          runnerChance: 0.20,
          heavyChance: 0.18,
          pattern: _FormationPattern.arrow,
        );

        _spawnBarricades(
          count: 2,
          damage: 13,
          startY: -260,
        );

        _spawnTurret(
          xFactor: 0.64,
          y: -410,
          fireInterval: 2.95,
        );
        break;
    }
  }

  // ============================================================
  // FORMATION
  // ============================================================

  void _spawnWaveFormation({
    required int count,
    required double baseHealth,
    required double baseSpeed,
    required double spawnSpacing,
    required double runnerChance,
    required double heavyChance,
    required _FormationPattern pattern,
  }) {
    for (int i = 0; i < count; i++) {
      final delay = i * spawnSpacing;

      if (delay <= 0) {
        _spawnEnemy(
          index: i,
          count: count,
          baseHealth: baseHealth,
          baseSpeed: baseSpeed,
          runnerChance: runnerChance,
          heavyChance: heavyChance,
          pattern: pattern,
        );

        continue;
      }

      add(
        TimerComponent(
          period: delay,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            _spawnEnemy(
              index: i,
              count: count,
              baseHealth: baseHealth,
              baseSpeed: baseSpeed,
              runnerChance: runnerChance,
              heavyChance: heavyChance,
              pattern: pattern,
            );
          },
        ),
      );
    }
  }

  // ============================================================
  // SPAWN ENEMY
  // ============================================================

  void _spawnEnemy({
    required int index,
    required int count,
    required double baseHealth,
    required double baseSpeed,
    required double runnerChance,
    required double heavyChance,
    required _FormationPattern pattern,
  }) {
    if (_stopped) {
      return;
    }

    final currentWorld = parent;

    if (currentWorld == null) {
      return;
    }

    final build = _chooseEnemy(
      baseHealth: baseHealth,
      baseSpeed: baseSpeed,
      runnerChance: runnerChance,
      heavyChance: heavyChance,
    );

    final roadLeft =
        gameSize.x * _roadLeft;

    final roadRight =
        gameSize.x * _roadRight;

    final roadCenter =
        gameSize.x * 0.50;

    final roadHalfWidth =
        (roadRight - roadLeft) / 2;

    final formation = _formationOffset(
      index: index,
      count: count,
      pattern: pattern,
    );

    double x =
        roadCenter +
            formation.x * roadHalfWidth;

    x +=
        (_random.nextDouble() - 0.5) *
            7;

    x = x
        .clamp(
      roadLeft + 18,
      roadRight - 18,
    )
        .toDouble();

    final y =
        -95.0 -
            formation.y -
            _random.nextDouble() * 6;

    currentWorld.add(
      BasicEnemy(
        position: Vector2(
          x,
          y,
        ),
        config: EnemyConfig(
          health: build.health,
          speed: build.speed,
        ),
        type: build.type,
        imagePath: _level2EnemyAsset,
      ),
    );
  }

  // ============================================================
  // FORMATIONS
  // ============================================================

  Vector2 _formationOffset({
    required int index,
    required int count,
    required _FormationPattern pattern,
  }) {
    switch (pattern) {
      case _FormationPattern.vShape:
        final points = <Vector2>[
          Vector2(0, 0),
          Vector2(-0.35, 52),
          Vector2(0.35, 52),
          Vector2(-0.60, 104),
          Vector2(0.60, 104),
        ];

        return points[
        index % points.length];

      case _FormationPattern.arrow:
        final points = <Vector2>[
          Vector2(0, 0),
          Vector2(-0.30, 52),
          Vector2(0.30, 52),
          Vector2(-0.55, 104),
          Vector2(0, 104),
          Vector2(0.55, 104),
          Vector2(-0.32, 156),
          Vector2(0.32, 156),
        ];

        return points[
        index % points.length];

      case _FormationPattern.staggered:
        const xValues = <double>[
          -0.54,
          0.02,
          0.54,
          -0.26,
          0.28,
          -0.62,
          0.62,
          0.0,
        ];

        final row =
            index ~/ 3;

        return Vector2(
          xValues[
          index %
              xValues.length],
          row * 62 +
              (index % 2) * 14,
        );
    }
  }

  // ============================================================
  // ENEMY TYPE
  // ============================================================

  _EnemyBuild _chooseEnemy({
    required double baseHealth,
    required double baseSpeed,
    required double runnerChance,
    required double heavyChance,
  }) {
    final roll =
    _random.nextDouble();

    if (roll < heavyChance) {
      return _EnemyBuild(
        type: EnemyType.heavy,
        health:
        baseHealth * 1.40,
        speed:
        baseSpeed * 0.84,
      );
    }

    if (roll <
        heavyChance +
            runnerChance) {
      return _EnemyBuild(
        type: EnemyType.runner,
        health:
        baseHealth * 0.78,
        speed:
        baseSpeed * 1.17,
      );
    }

    return _EnemyBuild(
      type: EnemyType.normal,
      health: baseHealth,
      speed: baseSpeed,
    );
  }

  // ============================================================
  // BARRICADES
  // ============================================================

  void _spawnBarricades({
    required int count,
    required double damage,
    required double startY,
  }) {
    final currentWorld = parent;

    if (_stopped ||
        currentWorld == null) {
      return;
    }

    final roadLeft =
        gameSize.x * _roadLeft;

    final roadRight =
        gameSize.x * _roadRight;

    const laneFactors = <double>[
      0.27,
      0.72,
      0.48,
    ];

    for (int i = 0;
    i < count;
    i++) {
      final x =
          roadLeft +
              (roadRight - roadLeft) *
                  laneFactors[
                  i %
                      laneFactors.length];

      currentWorld.add(
        BattleBarricade(
          position: Vector2(
            x,
            startY - i * 118,
          ),
          scrollSpeed: 108,
          damage: damage,
        ),
      );
    }
  }

  // ============================================================
  // TURRET
  // ============================================================

  void _spawnTurret({
    required double xFactor,
    required double y,
    required double fireInterval,
  }) {
    final currentWorld = parent;

    if (_stopped ||
        currentWorld == null) {
      return;
    }

    currentWorld.add(
      EnemyTurret(
        position: Vector2(
          gameSize.x * xFactor,
          y,
        ),
        scrollSpeed: 102,
        fireInterval: fireInterval,
      ),
    );
  }
}

// ============================================================
// FORMATION TYPE
// ============================================================

enum _FormationPattern {
  vShape,
  staggered,
  arrow,
}

// ============================================================
// ENEMY BUILD
// ============================================================

class _EnemyBuild {
  const _EnemyBuild({
    required this.type,
    required this.health,
    required this.speed,
  });

  final EnemyType type;

  final double health;
  final double speed;
}