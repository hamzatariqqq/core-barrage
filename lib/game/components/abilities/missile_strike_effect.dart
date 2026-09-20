import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MissileStrikeEffect extends PositionComponent {
  MissileStrikeEffect({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2.all(320),
    anchor: Anchor.center,
    priority: 700,
  );

  double _time = 0;

  static const double duration = 0.65;

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;

    if (_time >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress =
    (_time / duration).clamp(0.0, 1.0);

    final opacity =
    (1.0 - progress).clamp(0.0, 1.0);

    final center = Offset(
      size.x / 2,
      size.y / 2,
    );

    // Flash
    if (progress < 0.18) {
      final flash =
          1 - (progress / 0.18);

      canvas.drawCircle(
        center,
        85,
        Paint()
          ..color = Colors.white.withValues(
            alpha: flash * 0.75,
          ),
      );
    }

    // Fireball
    canvas.drawCircle(
      center,
      25 + progress * 75,
      Paint()
        ..color = const Color(0xFFFF6A20)
            .withValues(
          alpha: opacity * 0.65,
        ),
    );

    canvas.drawCircle(
      center,
      16 + progress * 48,
      Paint()
        ..color = const Color(0xFFFFC449)
            .withValues(
          alpha: opacity * 0.85,
        ),
    );

    // Shockwave
    canvas.drawCircle(
      center,
      35 + progress * 115,
      Paint()
        ..color = const Color(0xFFFF9D35)
            .withValues(
          alpha: opacity * 0.75,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth =
            7 * (1 - progress),
    );

    // Debris
    for (int i = 0; i < 10; i++) {
      final angle =
          (pi * 2 / 10) * i;

      final distance =
          25 + progress * 110;

      final x =
          center.dx +
              cos(angle) * distance;

      final y =
          center.dy +
              sin(angle) * distance;

      canvas.drawCircle(
        Offset(x, y),
        2.5 + (1 - progress) * 3,
        Paint()
          ..color = const Color(0xFFFF783A)
              .withValues(
            alpha: opacity,
          ),
      );
    }
  }
}