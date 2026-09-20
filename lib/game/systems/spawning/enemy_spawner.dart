import 'dart:math';

import 'package:flame/components.dart';

import '../../components/enemies/basic_enemy.dart';
import '../../components/enemies/enemy_config.dart';
import '../level/level_1_director.dart';

class EnemySpawner extends Component {
  EnemySpawner({
    required this.gameSize,
    this.currentLevel = 1,
  });

  final Vector2 gameSize;
  final int currentLevel;

  final Random _random = Random();

  bool _stopped = false;

  // ============================================================
  // ENEMY ASSET
  // ============================================================

  String? get _enemyAsset {
    switch (currentLevel) {
      case 1:
      // Level 1 keeps the original red enemy animation.
        return null;

      case 2:
        return 'enemies/enemy_02_run.png';

      case 3:
        return 'enemies/enemy_03_run.png';

      case 4:
        return 'enemies/enemy_04_run.png';

      case 5:
        return 'enemies/enemy_05_run.png';

      case 6:
        return 'enemies/enemy_06_run.png';

      case 7:
        return 'enemies/enemy_07_run.png';

      case 8:
        return 'enemies/enemy_08_run.png';

      case 9:
        return 'enemies/enemy_09_run.png';

      case 10:
        return 'enemies/enemy_10_run.png';

      case 11:
        return 'enemies/enemy_11_run.png';

      case 12:
        return 'enemies/enemy_12_run.png';

      case 13:
        return 'enemies/enemy_13_run.png';

      case 14:
        return 'enemies/enemy_14_run.png';

      case 15:
        return 'enemies/enemy_15_run.png';

      default:
        return null;
    }
  }

  // ============================================================
  // LEVEL DIFFICULTY
  // ============================================================

  double get _difficulty {
    switch (currentLevel) {
      case 1:
        return .72;
      case 2:
        return .80;
      case 3:
        return .88;
      case 4:
        return .96;
      case 5:
        return 1.04;
      case 6:
        return 1.12;
      case 7:
        return 1.20;
      case 8:
        return 1.28;
      case 9:
        return 1.36;
      case 10:
        return 1.45;
      case 11:
        return 1.54;
      case 12:
        return 1.63;
      case 13:
        return 1.72;
      case 14:
        return 1.82;
      case 15:
        return 1.94;
      default:
        return 1.0;
    }
  }

  int get _extraEnemyCount {
    if (currentLevel <= 2) {
      return 0;
    }

    if (currentLevel <= 4) {
      return 1;
    }

    if (currentLevel <= 7) {
      return 2;
    }

    if (currentLevel <= 10) {
      return 3;
    }

    if (currentLevel <= 13) {
      return 4;
    }

    return 5;
  }

  double get _healthMultiplier {
    return .80 + (_difficulty * .20);
  }

  double get _speedMultiplier {
    return .88 + (_difficulty * .12);
  }

  // ============================================================
  // STOP
  // ============================================================

  void stop() {
    _stopped = true;
  }

  // ============================================================
  // DIRECTOR WAVE
  //
  // IMPORTANT:
  // CoreBarrageGame sends Level1Wave here.
  // Keep this exact type.
  // ============================================================

  void spawnWave(
      Level1Wave wave,
      ) {
    if (_stopped) {
      return;
    }

    switch (wave) {
      case Level1Wave.light:
        _spawnLightWave();
        break;

      case Level1Wave.medium:
        _spawnMediumWave();
        break;

      case Level1Wave.heavy:
        _spawnHeavyWave();
        break;
    }
  }

  // ============================================================
  // LIGHT
  // ============================================================

  void _spawnLightWave() {
    // Level 1 intentionally starts gently.
    if (currentLevel == 1) {
      _spawnFormation(
        count: 3,
        type: EnemyType.normal,
        health: 58,
        speed: 48,
        spacing: .34,
      );

      return;
    }

    final count = 4 + _extraEnemyCount;

    _spawnMixedFormation(
      count: count,
      stage: 1,
    );
  }

  // ============================================================
  // MEDIUM
  // ============================================================

  void _spawnMediumWave() {
    if (currentLevel == 1) {
      _spawnFormation(
        count: 5,
        type: EnemyType.normal,
        health: 72,
        speed: 52,
        spacing: .31,
      );

      return;
    }

    final count = 5 + _extraEnemyCount;

    _spawnMixedFormation(
      count: count,
      stage: 2,
    );
  }

  // ============================================================
  // HEAVY
  // ============================================================

  void _spawnHeavyWave() {
    if (currentLevel == 1) {
      const total = 6;

      for (int i = 0; i < total; i++) {
        final delay = i * .30;

        _scheduleEnemy(
          delay: delay,
          type:
          i == 3
              ? EnemyType.heavy
              : EnemyType.normal,
          health:
          i == 3
              ? 145
              : 82,
          speed:
          i == 3
              ? 42
              : 53,
          index: i,
          total: total,
        );
      }

      return;
    }

    final count = 6 + _extraEnemyCount;

    _spawnMixedFormation(
      count: count,
      stage: 3,
    );
  }

  // ============================================================
  // MIXED FORMATION — LEVELS 2–15
  // ============================================================

  void _spawnMixedFormation({
    required int count,
    required int stage,
  }) {
    for (int i = 0; i < count; i++) {
      EnemyType type = EnemyType.normal;

      // --------------------------------------------------------
      // RUNNERS
      // Gradually introduced.
      // --------------------------------------------------------

      if (currentLevel >= 3) {
        if (stage == 1) {
          if (currentLevel >= 6 &&
              i == count - 1) {
            type = EnemyType.runner;
          }
        } else if (stage == 2) {
          if (i % 4 == 1) {
            type = EnemyType.runner;
          }
        } else {
          if (i % 4 == 1) {
            type = EnemyType.runner;
          }
        }
      }

      // --------------------------------------------------------
      // HEAVIES
      // --------------------------------------------------------

      if (stage >= 2 &&
          currentLevel >= 4) {
        if (i == count - 1) {
          type = EnemyType.heavy;
        }
      }

      if (stage == 3 &&
          currentLevel >= 7) {
        if (i == 2 ||
            i == count - 1) {
          type = EnemyType.heavy;
        }
      }

      if (stage == 3 &&
          currentLevel >= 12) {
        if (i == 2 ||
            i == 6 ||
            i == count - 1) {
          type = EnemyType.heavy;
        }
      }

      final stats = _statsFor(
        type: type,
        stage: stage,
      );

      final delay =
          i * _spawnSpacing;

      _scheduleEnemy(
        delay: delay,
        type: type,
        health: stats.health,
        speed: stats.speed,
        index: i,
        total: count,
      );
    }
  }

  // ============================================================
  // STATS
  // ============================================================

  _EnemyStats _statsFor({
    required EnemyType type,
    required int stage,
  }) {
    double health;
    double speed;

    switch (stage) {
      case 1:
        health = 72;
        speed = 53;
        break;

      case 2:
        health = 84;
        speed = 55;
        break;

      case 3:
      default:
        health = 96;
        speed = 56;
        break;
    }

    health *= _healthMultiplier;
    speed *= _speedMultiplier;

    switch (type) {
      case EnemyType.runner:
        health *= .78;
        speed *= 1.17;
        break;

      case EnemyType.heavy:
        health *= 1.55;
        speed *= .84;
        break;

      case EnemyType.normal:
        break;
    }

    return _EnemyStats(
      health: health,
      speed: speed,
    );
  }

  // ============================================================
  // SPAWN SPACING
  // ============================================================

  double get _spawnSpacing {
    if (currentLevel <= 2) {
      return .31;
    }

    if (currentLevel <= 7) {
      return .28;
    }

    if (currentLevel <= 11) {
      return .26;
    }

    return .24;
  }

  // ============================================================
  // SIMPLE FORMATION
  // ============================================================

  void _spawnFormation({
    required int count,
    required EnemyType type,
    required double health,
    required double speed,
    required double spacing,
  }) {
    for (int i = 0; i < count; i++) {
      _scheduleEnemy(
        delay: i * spacing,
        type: type,
        health: health,
        speed: speed,
        index: i,
        total: count,
      );
    }
  }

  // ============================================================
  // DELAYED SPAWN
  // ============================================================

  void _scheduleEnemy({
    required double delay,
    required EnemyType type,
    required double health,
    required double speed,
    required int index,
    required int total,
  }) {
    if (delay <= 0) {
      _spawnEnemy(
        type: type,
        health: health,
        speed: speed,
        index: index,
        total: total,
      );

      return;
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
            type: type,
            health: health,
            speed: speed,
            index: index,
            total: total,
          );
        },
      ),
    );
  }

  // ============================================================
  // SPAWN ENEMY
  // ============================================================

  void _spawnEnemy({
    required EnemyType type,
    required double health,
    required double speed,
    required int index,
    required int total,
  }) {
    if (_stopped) {
      return;
    }

    final currentWorld = parent;

    if (currentWorld == null) {
      return;
    }

    // ----------------------------------------------------------
    // ROAD BOUNDS
    // ----------------------------------------------------------

    final roadLeft =
        gameSize.x * .29;

    final roadRight =
        gameSize.x * .71;

    final roadWidth =
        roadRight - roadLeft;

    // ----------------------------------------------------------
    // LANES
    // ----------------------------------------------------------

    int lanes;

    if (total <= 4) {
      lanes = 3;
    } else {
      lanes = 4;
    }

    final lane =
        index % lanes;

    final laneWidth =
        roadWidth / lanes;

    double x =
        roadLeft +
            laneWidth * lane +
            laneWidth / 2;

    // Small natural variation.
    x +=
        (_random.nextDouble() - .5) *
            9;

    x = x
        .clamp(
      roadLeft + 18,
      roadRight - 18,
    )
        .toDouble();

    // ----------------------------------------------------------
    // ROW POSITION
    // ----------------------------------------------------------

    final row =
        index ~/ lanes;

    double rowSpacing;

    if (currentLevel <= 2) {
      rowSpacing = 62;
    } else if (currentLevel <= 7) {
      rowSpacing = 59;
    } else {
      rowSpacing = 56;
    }

    final y =
        -78.0 -
            row * rowSpacing -
            _random.nextDouble() * 8;

    // ----------------------------------------------------------
    // ADD
    //
    // Existing BasicEnemy API uses:
    // imagePath:
    //
    // NOT:
    // spriteAsset:
    // ----------------------------------------------------------

    currentWorld.add(
      BasicEnemy(
        position: Vector2(
          x,
          y,
        ),
        config: EnemyConfig(
          health: health,
          speed: speed,
        ),
        type: type,
        imagePath: _enemyAsset,
      ),
    );
  }
}

// ============================================================
// INTERNAL STATS
// ============================================================

class _EnemyStats {
  const _EnemyStats({
    required this.health,
    required this.speed,
  });

  final double health;
  final double speed;
}