import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BasicEnemy extends RectangleComponent with CollisionCallbacks {
  BasicEnemy({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(45, 55),
    anchor: Anchor.center,
    paint: Paint()..color = const Color(0xFFFF4355),
  );

  double health = 100;
  static const double speed = 50;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += speed * dt;

    if (position.y > 900) {
      removeFromParent();
    }
  }

  void takeDamage(double damage) {
    health -= damage;

    if (health <= 0) {
      removeFromParent();
    }
  }
}