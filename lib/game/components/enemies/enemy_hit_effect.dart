import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EnemyHitEffect extends PositionComponent {
  EnemyHitEffect({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(28),
          anchor: Anchor.center,
          priority: 30,
        );

  static const double _lifeSpan = 0.16;
  double _elapsed = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;

    if (_elapsed >= _lifeSpan) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (_elapsed / _lifeSpan).clamp(0.0, 1.0);
    final alpha = (255 * (1 - progress)).round();
    final radius = 5 + (1 - progress) * 18;

    final outerPaint = Paint()
      ..color = Color.fromARGB(alpha, 255, 170, 60)
      ..style = PaintingStyle.fill;

    final innerPaint = Paint()
      ..color = Color.fromARGB(alpha, 255, 230, 150)
      ..style = PaintingStyle.fill;

    final sparkPaint = Paint()
      ..color = Color.fromARGB(alpha, 255, 255, 255)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, radius, outerPaint);
    canvas.drawCircle(Offset.zero, radius * 0.45, innerPaint);

    for (final angle in [0, pi / 2, pi, 3 * pi / 2]) {
      final dx = cos(angle) * (radius + 5);
      final dy = sin(angle) * (radius + 5);
      canvas.drawCircle(Offset(dx, dy), 3.5, sparkPaint);
    }
  }
}
