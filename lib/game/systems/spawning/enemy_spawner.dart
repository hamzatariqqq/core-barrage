import 'dart:math';

import 'package:flame/components.dart';

import '../../components/enemies/basic_enemy.dart';
import '../../components/enemies/enemy_config.dart';

class EnemySpawner extends Component {
  EnemySpawner({
    required this.gameSize,
  });

  final Vector2 gameSize;

  final Random _random = Random();

  double _timer = 0;
  double _levelTime = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;
    _levelTime += dt;

    final interval = _spawnInterval;

    if (_timer >= interval) {
      _timer = 0;
      _spawnEnemy();
    }
  }

  double get _spawnInterval {
    if (_levelTime < 15) {
      return 1.6;
    }

    if (_levelTime < 30) {
      return 1.25;
    }

    return 0.95;
  }

  EnemyConfig get _enemyConfig {
    // Stage 1
    if (_levelTime < 15) {
      return const EnemyConfig(
        health: 100,
        speed: 50,
      );
    }

    // Stage 2
    if (_levelTime < 30) {
      return const EnemyConfig(
        health: 150,
        speed: 65,
      );
    }

    // Stage 3
    return const EnemyConfig(
      health: 200,
      speed: 80,
    );
  }

  void _spawnEnemy() {
    final x =
        70 + _random.nextDouble() * (gameSize.x - 140);

    parent?.add(
      BasicEnemy(
        position: Vector2(x, -40),
        config: _enemyConfig,
      ),
    );
  }
}