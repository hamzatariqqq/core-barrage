import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EnemyDeathEffect extends PositionComponent {
  EnemyDeathEffect({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(60, 60),
    anchor: Anchor.center,
    priority: 100,
  );

  double _time = 0;

  static const double _duration = 0.28;

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;

    if (_time >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress =
    (_time / _duration).clamp(0.0, 1.0);

    final opacity =
    (1.0 - progress).clamp(0.0, 1.0);

    final center = Offset(
      size.x / 2,
      size.y / 2,
    );

    // Main red/orange burst
    canvas.drawCircle(
      center,
      8 + (progress * 18),
      Paint()
        ..color = Color.fromRGBO(
          255,
          70,
          35,
          opacity * 0.55,
        ),
    );

    // Bright center
    canvas.drawCircle(
      center,
      5 + (progress * 7),
      Paint()
        ..color = Color.fromRGBO(
          255,
          190,
          55,
          opacity,
        ),
    );

    // Four small particles
    final particlePaint = Paint()
      ..color = Color.fromRGBO(
        255,
        95,
        45,
        opacity,
      );

    final distance =
        8 + (progress * 22);

    canvas.drawCircle(
      center + Offset(distance, 0),
      3,
      particlePaint,
    );

    canvas.drawCircle(
      center + Offset(-distance, 0),
      3,
      particlePaint,
    );

    canvas.drawCircle(
      center + Offset(0, distance),
      3,
      particlePaint,
    );

    canvas.drawCircle(
      center + Offset(0, -distance),
      3,
      particlePaint,
    );
  }
}