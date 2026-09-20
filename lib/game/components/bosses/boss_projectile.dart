import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../player/player_vehicle.dart';

class BossProjectile extends PositionComponent
    with CollisionCallbacks {
  BossProjectile({
    required Vector2 position,
    required Vector2 direction,
    required this.damage,
  })  : _direction = direction.normalized(),
        super(
        position: position,
        size: Vector2(24, 36),
        anchor: Anchor.center,
        priority: 180,
      );

  final Vector2 _direction;
  final double damage;

  static const double _speed = 250;

  double _lifeTimer = 0;
  double _pulseTimer = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      CircleHitbox(
        radius: 8,
        position: Vector2(
          size.x / 2,
          size.y / 2,
        ),
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _lifeTimer += dt;
    _pulseTimer += dt;

    position +=
        _direction *
            _speed *
            dt;

    if (_lifeTimer > 4) {
      removeFromParent();
    }

    final gameSize =
        findGame()?.size;

    if (gameSize != null) {
      if (position.x < -80 ||
          position.x >
              gameSize.x + 80 ||
          position.y < -80 ||
          position.y >
              gameSize.y + 80) {
        removeFromParent();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final pulse =
        (sin(_pulseTimer * 8) + 1) /
            2;

    final center = Offset(
      size.x / 2,
      size.y / 2,
    );

    // ==========================================================
    // OUTER RED ENERGY GLOW
    // ==========================================================

    canvas.drawCircle(
      center,
      13 + pulse * 3,
      Paint()
        ..color =
        const Color(
          0x55FF2D22,
        ),
    );

    // ==========================================================
    // PROJECTILE BODY
    // ==========================================================

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: 12,
          height: 25,
        ),
        const Radius.circular(7),
      ),
      Paint()
        ..color =
        const Color(
          0xFFFF3A28,
        ),
    );

    // ==========================================================
    // HOT ORANGE CORE
    // ==========================================================

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: 6,
          height: 17,
        ),
        const Radius.circular(4),
      ),
      Paint()
        ..color =
        const Color(
          0xFFFFA33C,
        ),
    );

    // ==========================================================
    // WHITE CENTER
    // ==========================================================

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: 2.5,
          height: 10,
        ),
        const Radius.circular(2),
      ),
      Paint()
        ..color =
        Colors.white.withValues(
          alpha:
          0.75 +
              pulse * 0.25,
        ),
    );

    // ==========================================================
    // ENERGY TRAIL
    // ==========================================================

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x / 2 - 3,
          -8,
          6,
          18,
        ),
        const Radius.circular(4),
      ),
      Paint()
        ..color =
        const Color(
          0xFFFF6A34,
        ).withValues(
          alpha: 0.45,
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

    if (other is PlayerVehicle) {
      other.takeDamage(
        damage,
      );

      parent?.add(
        BossProjectileImpact(
          position:
          position.clone(),
        ),
      );

      removeFromParent();
    }
  }
}

// ============================================================
// IMPACT EFFECT
// ============================================================

class BossProjectileImpact
    extends PositionComponent {
  BossProjectileImpact({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2.all(50),
    anchor: Anchor.center,
    priority: 400,
  );

  double _timer = 0;

  static const double _duration =
  0.20;

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;

    if (_timer >=
        _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress =
    (_timer / _duration)
        .clamp(
      0.0,
      1.0,
    );

    final alpha =
        1 - progress;

    final radius =
        8 +
            progress * 24;

    final center =
    Offset(
      size.x / 2,
      size.y / 2,
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color =
        const Color(
          0xFFFF4D2E,
        ).withValues(
          alpha:
          alpha * 0.35,
        ),
    );

    canvas.drawCircle(
      center,
      radius * 0.45,
      Paint()
        ..color =
        const Color(
          0xFFFFB04A,
        ).withValues(
          alpha: alpha,
        ),
    );
  }
}