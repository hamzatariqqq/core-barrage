import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../player/blue_soldier.dart';

class BattleBarricade extends PositionComponent
    with CollisionCallbacks {
  BattleBarricade({
    required Vector2 position,
    this.scrollSpeed = 110,
    this.damage = 18,
  }) : super(
    position: position,
    size: Vector2(
      82,
      34,
    ),
    anchor: Anchor.center,
    priority: 39,
  );

  final double scrollSpeed;
  final double damage;

  bool _destroyed = false;

  double _health = 90;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      RectangleHitbox(
        size: Vector2(
          72,
          24,
        ),
        position: Vector2(
          5,
          5,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y +=
        scrollSpeed * dt;

    if (position.y > 1100) {
      removeFromParent();
    }
  }

  void takeDamage(
      double amount,
      ) {
    if (_destroyed) {
      return;
    }

    _health -= amount;

    if (_health <= 0) {
      _destroy();
    }
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

    if (_destroyed) {
      return;
    }

    if (other is BlueSoldier) {
      other.hit(
        damage: damage,
      );

      takeDamage(
        30,
      );
    }
  }

  void _destroy() {
    if (_destroyed) {
      return;
    }

    _destroyed = true;

    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          3,
          22,
          size.x - 6,
          11,
        ),
        const Radius.circular(
          5,
        ),
      ),
      Paint()
        ..color =
        Colors.black.withValues(
          alpha: .3,
        ),
    );

    // Main barrier
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          2,
          5,
          size.x - 4,
          22,
        ),
        const Radius.circular(
          4,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF9E3F2D,
        ),
    );

    final stripePaint =
    Paint()
      ..color =
      const Color(
        0xFFFFB02E,
      )
      ..strokeWidth = 7;

    for (double x = 12;
    x < size.x;
    x += 24) {
      canvas.drawLine(
        Offset(
          x,
          7,
        ),
        Offset(
          x + 12,
          25,
        ),
        stripePaint,
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(
        8,
        27,
        7,
        7,
      ),
      Paint()
        ..color =
        const Color(
          0xFF303841,
        ),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.x - 15,
        27,
        7,
        7,
      ),
      Paint()
        ..color =
        const Color(
          0xFF303841,
        ),
    );
  }
}