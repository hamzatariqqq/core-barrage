import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../player/player_vehicle.dart';

class EnemyProjectile extends PositionComponent
    with CollisionCallbacks, HasGameReference<FlameGame> {
  EnemyProjectile({
    required Vector2 position,
    required Vector2 direction,
    required this.damage,
  })  : _direction = direction.normalized(),
        super(
        position: position,
        size: Vector2(
          10,
          22,
        ),
        anchor: Anchor.center,
        priority: 220,
      );

  final Vector2 _direction;

  final double damage;

  static const double _speed =
  285;

  double _life = 0;

  bool _used = false;

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    angle =
        math.atan2(
          _direction.y,
          _direction.x,
        ) +
            math.pi / 2;

    add(
      RectangleHitbox(
        position: size / 2,
        size: Vector2(
          7,
          16,
        ),
        anchor: Anchor.center,
        collisionType:
        CollisionType.active,
      ),
    );
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(
      double dt,
      ) {
    super.update(
      dt,
    );

    if (_used) {
      return;
    }

    _life += dt;

    position +=
        _direction *
            _speed *
            dt;

    if (_life > 4 ||
        position.x < -60 ||
        position.x >
            game.size.x + 60 ||
        position.y < -60 ||
        position.y >
            game.size.y + 60) {
      removeFromParent();
    }
  }

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(
      Canvas canvas,
      ) {
    final center =
    Offset(
      size.x / 2,
      size.y / 2,
    );

    // Glow
    canvas.drawCircle(
      center,
      8,
      Paint()
        ..color =
        const Color(
          0xFFFF473D,
        ).withValues(
          alpha: 0.20,
        )
        ..maskFilter =
        const MaskFilter.blur(
          BlurStyle.normal,
          7,
        ),
    );

    // Trail
    final trailRect =
    Rect.fromCenter(
      center: Offset(
        size.x / 2,
        size.y * 0.72,
      ),
      width: 5,
      height: 17,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        trailRect,
        const Radius.circular(
          3,
        ),
      ),
      Paint()
        ..shader =
        const LinearGradient(
          begin:
          Alignment.topCenter,
          end:
          Alignment.bottomCenter,
          colors: [
            Color(
              0xFFFFF0A2,
            ),
            Color(
              0xFFFF7A35,
            ),
            Color(
              0x00FF3333,
            ),
          ],
        ).createShader(
          trailRect,
        ),
    );

    // Outer projectile
    canvas.drawCircle(
      Offset(
        size.x / 2,
        size.y * 0.32,
      ),
      4.2,
      Paint()
        ..color =
        const Color(
          0xFFFF453D,
        ),
    );

    // Bright core
    canvas.drawCircle(
      Offset(
        size.x / 2,
        size.y * 0.32,
      ),
      2,
      Paint()
        ..color =
        const Color(
          0xFFFFF0A8,
        ),
    );

    super.render(
      canvas,
    );
  }

  // ============================================================
  // COLLISION
  // ============================================================

  @override
  void onCollisionStart(
      Set<Vector2>
      intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(
      intersectionPoints,
      other,
    );

    if (_used) {
      return;
    }

    if (other
    is PlayerVehicle) {
      _used = true;

      other.takeDamage(
        damage,
      );

      removeFromParent();
    }
  }
}