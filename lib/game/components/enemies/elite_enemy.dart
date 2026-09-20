import 'dart:math';

import 'package:flutter/material.dart';

import 'basic_enemy.dart';
import 'enemy_config.dart';

class EliteEnemy extends BasicEnemy {
  EliteEnemy({
    required super.position,
    double difficulty = 1.0,
  })  : _difficulty = difficulty,
        super(
        type: EnemyType.heavy,
        config: EnemyConfig(
          health: 280 * difficulty,
          speed: 52 + difficulty * 5,
        ),
      );

  final double _difficulty;

  double _pulse = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(
      size.x / 2,
      size.y / 2,
    );

    final glow =
        0.35 +
            sin(_pulse * 4) * 0.12;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx,
          size.y * .83,
        ),
        width: size.x * .72,
        height: size.y * .16,
      ),
      Paint()
        ..color =
        Colors.black.withValues(
          alpha: .30,
        ),
    );

    canvas.drawCircle(
      center,
      size.x * .42,
      Paint()
        ..color =
        const Color(
          0xFFFF303E,
        ).withValues(
          alpha:
          glow.clamp(
            .12,
            .55,
          ),
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center,
          width: size.x * .62,
          height: size.y * .66,
        ),
        const Radius.circular(
          10,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF531E28,
        ),
    );

    canvas.drawCircle(
      Offset(
        center.dx - size.x * .27,
        center.dy - size.y * .11,
      ),
      size.x * .14,
      Paint()
        ..color =
        const Color(
          0xFF8C2936,
        ),
    );

    canvas.drawCircle(
      Offset(
        center.dx + size.x * .27,
        center.dy - size.y * .11,
      ),
      size.x * .14,
      Paint()
        ..color =
        const Color(
          0xFF8C2936,
        ),
    );

    canvas.drawCircle(
      Offset(
        center.dx,
        center.dy - size.y * .29,
      ),
      size.x * .19,
      Paint()
        ..color =
        const Color(
          0xFF272E37,
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            center.dx,
            center.dy -
                size.y * .29,
          ),
          width: size.x * .26,
          height: 5,
        ),
        const Radius.circular(
          3,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFFFF3747,
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x * .60,
          size.y * .43,
          size.x * .34,
          8,
        ),
        const Radius.circular(
          3,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF171C22,
        ),
    );

    canvas.drawCircle(
      Offset(
        center.dx,
        center.dy,
      ),
      5 + _difficulty,
      Paint()
        ..color =
        const Color(
          0xFFFFC638,
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x * .17,
          3,
          size.x * .66,
          4,
        ),
        const Radius.circular(
          3,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFFFF3747,
        ),
    );
  }
}