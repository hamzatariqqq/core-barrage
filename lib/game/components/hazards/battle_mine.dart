import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../player/blue_soldier.dart';

class BattleMine extends PositionComponent
    with CollisionCallbacks {
  BattleMine({
    required Vector2 position,
    this.scrollSpeed = 115,
    this.damage = 30,
  }) : super(
    position: position,
    size: Vector2.all(34),
    anchor: Anchor.center,
    priority: 38,
  );

  final double scrollSpeed;
  final double damage;

  double _time = 0;

  bool _destroyed = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      CircleHitbox(
        radius: 13,
        position: size / 2,
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_destroyed) {
      return;
    }

    _time += dt;

    position.y +=
        scrollSpeed * dt;

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

    if (_destroyed) {
      return;
    }

    if (other is BlueSoldier) {
      other.hit(
        damage: damage,
      );

      _explode();
    }
  }

  void _explode() {
    if (_destroyed) {
      return;
    }

    _destroyed = true;

    parent?.add(
      _MineExplosion(
        position: position.clone(),
      ),
    );

    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final pulse =
        0.65 +
            sin(_time * 6) * 0.15;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          size.x / 2,
          size.y * .78,
        ),
        width: 28,
        height: 9,
      ),
      Paint()
        ..color =
        Colors.black.withValues(
          alpha: .35,
        ),
    );

    // Mine body
    canvas.drawCircle(
      Offset(
        size.x / 2,
        size.y / 2,
      ),
      12,
      Paint()
        ..color =
        const Color(
          0xFF202832,
        ),
    );

    canvas.drawCircle(
      Offset(
        size.x / 2,
        size.y / 2,
      ),
      8,
      Paint()
        ..color =
        const Color(
          0xFF394654,
        ),
    );

    // Warning light
    canvas.drawCircle(
      Offset(
        size.x / 2,
        size.y / 2,
      ),
      3.5,
      Paint()
        ..color =
        Colors.red.withValues(
          alpha: pulse.clamp(
            0.3,
            1.0,
          ),
        ),
    );

    final spikePaint =
    Paint()
      ..color =
      const Color(
        0xFF111820,
      )
      ..strokeWidth = 4
      ..strokeCap =
          StrokeCap.round;

    canvas.drawLine(
      const Offset(
        4,
        17,
      ),
      const Offset(
        30,
        17,
      ),
      spikePaint,
    );

    canvas.drawLine(
      const Offset(
        17,
        4,
      ),
      const Offset(
        17,
        30,
      ),
      spikePaint,
    );
  }
}

class _MineExplosion
    extends PositionComponent {
  _MineExplosion({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2.all(100),
    anchor: Anchor.center,
    priority: 90,
  );

  double _life = 0;

  static const double _duration =
  .32;

  @override
  void update(double dt) {
    super.update(dt);

    _life += dt;

    if (_life >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress =
    (_life / _duration)
        .clamp(
      0.0,
      1.0,
    );

    final radius =
        10 + progress * 38;

    final alpha =
        1 - progress;

    canvas.drawCircle(
      Offset(
        size.x / 2,
        size.y / 2,
      ),
      radius,
      Paint()
        ..color =
        Colors.orange.withValues(
          alpha: alpha,
        ),
    );

    canvas.drawCircle(
      Offset(
        size.x / 2,
        size.y / 2,
      ),
      radius * .55,
      Paint()
        ..color =
        Colors.yellow.withValues(
          alpha: alpha,
        ),
    );
  }
}