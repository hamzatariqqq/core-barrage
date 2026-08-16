import 'dart:math';

import 'package:flame/components.dart';

import '../../components/enemies/basic_enemy.dart';

class EnemySpawner extends Component {
  EnemySpawner({
    required this.gameSize,
  });

  final Vector2 gameSize;

  final Random _random = Random();
  double _timer = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;

    if (_timer >= 1.5) {
      _timer = 0;

      final x = 70 + _random.nextDouble() * (gameSize.x - 140);

      parent?.add(
        BasicEnemy(
          position: Vector2(x, -40),
        ),
      );
    }
  }
}