import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../player/blue_soldier.dart';

class EnemyTurret extends PositionComponent {
  EnemyTurret({
    required Vector2 position,
    this.scrollSpeed = 65,
    this.fireInterval = 1.25,
  }) : super(
    position: position,
    size: Vector2.all(
      58,
    ),
    anchor: Anchor.center,
    priority: 43,
  );

  final double scrollSpeed;

  final double fireInterval;

  double _fireTimer = 0;

  double _rotation = 0;

  @override
  void update(double dt) {
    super.update(dt);

    position.y +=
        scrollSpeed * dt;

    _fireTimer += dt;

    _rotation +=
        dt * .5;

    if (_fireTimer >=
        fireInterval) {
      _fireTimer = 0;

      _fire();
    }

    if (position.y > 1100) {
      removeFromParent();
    }
  }

  void _fire() {
    final world =
        parent;

    if (world == null) {
      return;
    }

    world.add(
      EnemyTurretBullet(
        position:
        position +
            Vector2(
              0,
              24,
            ),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center =
    Offset(
      size.x / 2,
      size.y / 2,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + 18,
        ),
        width: 50,
        height: 16,
      ),
      Paint()
        ..color =
        Colors.black.withValues(
          alpha: .3,
        ),
    );

    canvas.drawCircle(
      center,
      22,
      Paint()
        ..color =
        const Color(
          0xFF692D35,
        ),
    );

    canvas.drawCircle(
      center,
      14,
      Paint()
        ..color =
        const Color(
          0xFF9B3C44,
        ),
    );

    canvas.save();

    canvas.translate(
      center.dx,
      center.dy,
    );

    canvas.rotate(
      sin(_rotation) * .12,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(
          -4,
          3,
          8,
          29,
        ),
        const Radius.circular(
          3,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF252D35,
        ),
    );

    canvas.restore();

    canvas.drawCircle(
      center,
      5,
      Paint()
        ..color =
            Colors.redAccent,
    );
  }
}

class EnemyTurretBullet
    extends PositionComponent
    with CollisionCallbacks {
  EnemyTurretBullet({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(
      8,
      18,
    ),
    anchor: Anchor.center,
    priority: 60,
  );

  static const double speed =
  360;

  bool _used = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      RectangleHitbox(
        size: size,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y +=
        speed * dt;

    if (position.y > 1100) {
      removeFromParent();
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

    if (_used) {
      return;
    }

    if (other is BlueSoldier) {
      _used = true;

      other.hit(
        damage: 18,
      );

      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          1,
          0,
          size.x - 2,
          size.y,
        ),
        const Radius.circular(
          4,
        ),
      ),
      Paint()
        ..color =
            Colors.orangeAccent,
    );
  }
}