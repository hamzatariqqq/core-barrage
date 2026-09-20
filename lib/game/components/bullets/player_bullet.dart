import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../enemies/basic_enemy.dart';
import '../bosses/basic_boss.dart';

class PlayerBullet extends PositionComponent
    with CollisionCallbacks {
  PlayerBullet({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(
      10,
      26,
    ),
    anchor: Anchor.center,
    priority: 90,
  );

  static const double _speed = 560;

  static const double _enemyDamage = 34;

  static const double _bossDamage = 28;

  double _lifeTimer = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      RectangleHitbox(
        position: Vector2(
          2,
          2,
        ),
        size: Vector2(
          6,
          20,
        ),
      ),
    );
  }

  @override
  void update(
      double dt,
      ) {
    super.update(dt);

    _lifeTimer += dt;

    position.y -=
        _speed * dt;

    if (_lifeTimer > 2.2) {
      removeFromParent();
      return;
    }

    final gameSize =
        findGame()?.size;

    if (gameSize != null &&
        position.y < -40) {
      removeFromParent();
    }
  }

  @override
  void render(
      Canvas canvas,
      ) {
    super.render(canvas);

    final centerX =
        size.x / 2;

    // ==========================================================
    // OUTER ENERGY GLOW
    // ==========================================================

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          1,
          0,
          8,
          24,
        ),
        const Radius.circular(
          5,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0x5537D8FF,
        ),
    );

    // ==========================================================
    // MAIN BLUE PROJECTILE
    // ==========================================================

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          3,
          2,
          4,
          18,
        ),
        const Radius.circular(
          3,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF32D5FF,
        ),
    );

    // ==========================================================
    // WHITE HOT CORE
    // ==========================================================

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          4,
          3,
          2,
          12,
        ),
        const Radius.circular(
          2,
        ),
      ),
      Paint()
        ..color =
            Colors.white,
    );

    // ==========================================================
    // SMALL TRAIL
    // ==========================================================

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            centerX,
            22,
          ),
          width: 3,
          height: 8,
        ),
        const Radius.circular(
          2,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF27BFFF,
        ).withValues(
          alpha: 0.42,
        ),
    );
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(
      intersectionPoints,
      other,
    );

    if (other is BasicEnemy) {
      other.takeDamage(
        _enemyDamage,
      );

      removeFromParent();
      return;
    }

    if (other is BasicBoss) {
      other.takeDamage(
        _bossDamage,
      );

      removeFromParent();
    }
  }
}