import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class EnemyAttackWarning extends PositionComponent {
  EnemyAttackWarning({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2.all(36),
    anchor: Anchor.center,
    priority: 450,
  );

  double _time = 0;

  static const double _duration = 0.82;

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
    final center = Offset(
      size.x / 2,
      size.y / 2,
    );

    final progress =
    (_time / _duration).clamp(
      0.0,
      1.0,
    );

    final pulse =
        0.5 +
            0.5 *
                sin(
                  _time * 20,
                ).abs();

    final alpha =
    (1.0 - progress).clamp(
      0.15,
      1.0,
    );

    // ==========================================================
    // OUTER GLOW
    // ==========================================================

    canvas.drawCircle(
      center,
      16 + pulse * 3,
      Paint()
        ..color = const Color(
          0xFFFF3B45,
        ).withValues(
          alpha: alpha * 0.18,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          8,
        ),
    );

    // ==========================================================
    // OUTER TARGET RING
    // ==========================================================

    canvas.drawCircle(
      center,
      13 + pulse * 1.5,
      Paint()
        ..color = const Color(
          0xFFFF4651,
        ).withValues(
          alpha: alpha,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // ==========================================================
    // INNER TARGET RING
    // ==========================================================

    canvas.drawCircle(
      center,
      7,
      Paint()
        ..color = const Color(
          0xFFFFCE45,
        ).withValues(
          alpha: alpha * 0.9,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final crossPaint = Paint()
      ..color = const Color(
        0xFFFF5A62,
      ).withValues(
        alpha: alpha,
      )
      ..strokeWidth = 2;

    // Top
    canvas.drawLine(
      Offset(
        center.dx,
        0,
      ),
      Offset(
        center.dx,
        8,
      ),
      crossPaint,
    );

    // Bottom
    canvas.drawLine(
      Offset(
        center.dx,
        size.y - 8,
      ),
      Offset(
        center.dx,
        size.y,
      ),
      crossPaint,
    );

    // Left
    canvas.drawLine(
      Offset(
        0,
        center.dy,
      ),
      Offset(
        8,
        center.dy,
      ),
      crossPaint,
    );

    // Right
    canvas.drawLine(
      Offset(
        size.x - 8,
        center.dy,
      ),
      Offset(
        size.x,
        center.dy,
      ),
      crossPaint,
    );

    // ==========================================================
    // CENTER LOCK POINT
    // ==========================================================

    canvas.drawCircle(
      center,
      2.8,
      Paint()
        ..color = const Color(
          0xFFFFE06B,
        ).withValues(
          alpha: alpha,
        ),
    );

    // ==========================================================
    // SMALL WARNING TRIANGLE
    // ==========================================================

    final trianglePaint = Paint()
      ..color = const Color(
        0xFFFF4651,
      ).withValues(
        alpha: alpha,
      )
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(
        center.dx,
        -7,
      )
      ..lineTo(
        center.dx - 4,
        -1,
      )
      ..lineTo(
        center.dx + 4,
        -1,
      )
      ..close();

    canvas.drawPath(
      path,
      trianglePaint,
    );
  }
}