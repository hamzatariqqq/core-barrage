import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../bosses/basic_boss.dart';
import '../enemies/basic_enemy.dart';

class PlayerBullet extends RectangleComponent with CollisionCallbacks {
  PlayerBullet({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(8, 20),
    anchor: Anchor.center,
    paint: Paint()..color = const Color(0xFF5EDBFF),
  );

  static const double speed = 500;
  static const double damage = 50;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y -= speed * dt;

    if (position.y < -30) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is BasicEnemy) {
      other.takeDamage(damage);
      removeFromParent();
    }

    if (other is BasicBoss) {
      other.takeDamage(damage);
      removeFromParent();
    }
  }
}