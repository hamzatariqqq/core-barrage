import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Level2EnemyAura extends PositionComponent {
  Level2EnemyAura({
    required Vector2 position,
    required Vector2 size,
    required this.heavy,
    required this.runner,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.center,
    priority: 8,
  );

  final bool heavy;
  final bool runner;

  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final pulse =
        0.5 +
            (sin(_time * 5) * 0.5);

    final center = Offset(
      size.x / 2,
      size.y / 2,
    );

    final radius =
    heavy
        ? size.x * 0.62
        : size.x * 0.52;

    final accent =
    heavy
        ? const Color(0xFFFF6A2A)
        : runner
        ? const Color(0xFFFFB02E)
        : const Color(0xFFFF7C36);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = accent.withValues(
          alpha: 0.05 + (pulse * 0.05),
        ),
    );

    canvas.drawCircle(
      center,
      radius * 0.82,
      Paint()
        ..color = accent.withValues(
          alpha: 0.45 + (pulse * 0.18),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = heavy ? 2.2 : 1.4,
    );

    if (heavy) {
      canvas.drawCircle(
        center,
        radius * 0.52,
        Paint()
          ..color = const Color(
            0xFFFFD06A,
          ).withValues(
            alpha: 0.18 + (pulse * 0.08),
          ),
      );
    }

    if (runner) {
      final trailPaint =
      Paint()
        ..color = const Color(
          0xFFFFB52F,
        ).withValues(
          alpha: 0.20 + (pulse * 0.08),
        )
        ..strokeWidth = 2;

      canvas.drawLine(
        Offset(
          center.dx - 8,
          size.y - 2,
        ),
        Offset(
          center.dx - 8,
          size.y + 12,
        ),
        trailPaint,
      );

      canvas.drawLine(
        Offset(
          center.dx + 8,
          size.y - 2,
        ),
        Offset(
          center.dx + 8,
          size.y + 12,
        ),
        trailPaint,
      );
    }
  }
}