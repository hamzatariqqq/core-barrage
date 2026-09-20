import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FreezeWaveEffect extends PositionComponent {
  FreezeWaveEffect({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2.all(420),
    anchor: Anchor.center,
    priority: 690,
  );

  double _time = 0;

  static const double duration = 0.75;

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
        1.0 - progress;

    final center = Offset(
      size.x / 2,
      size.y / 2,
    );

    // Main wave
    canvas.drawCircle(
      center,
      25 + progress * 170,
      Paint()
        ..color = const Color(0xFF37C8FF)
            .withValues(
          alpha: opacity * 0.70,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth =
            11 * (1 - progress),
    );

    // Inner wave
    canvas.drawCircle(
      center,
      15 + progress * 115,
      Paint()
        ..color = const Color(0xFFB7EEFF)
            .withValues(
          alpha: opacity * 0.65,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth =
            5 * (1 - progress),
    );

    // Ice flash
    if (progress < 0.25) {
      canvas.drawCircle(
        center,
        55,
        Paint()
          ..color = const Color(0xFF7CDBFF)
              .withValues(
            alpha:
            (1 - progress / 0.25) *
                0.25,
          ),
      );
    }
  }
}