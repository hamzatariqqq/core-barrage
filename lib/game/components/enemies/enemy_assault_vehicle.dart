import 'dart:math';

import 'package:flutter/material.dart';

import 'basic_enemy.dart';
import 'enemy_config.dart';

class EnemyAssaultVehicle
    extends BasicEnemy {
  EnemyAssaultVehicle({
    required super.position,
    double difficulty = 1.0,
  })  : _difficulty = difficulty,
        super(
        type: EnemyType.heavy,
        config: EnemyConfig(
          health: 520 * difficulty,
          speed: 35 + difficulty * 3,
        ),
      );

  final double _difficulty;

  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center =
    Offset(
      size.x / 2,
      size.y / 2,
    );

    final pulse =
        .55 +
            sin(_time * 5) *
                .18;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx,
          size.y * .78,
        ),
        width:
        size.x * .92,
        height:
        size.y * .18,
      ),
      Paint()
        ..color =
        Colors.black
            .withValues(
          alpha: .38,
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x * .05,
          size.y * .29,
          size.x * .20,
          size.y * .55,
        ),
        const Radius.circular(
          7,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF171B20,
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x * .75,
          size.y * .29,
          size.x * .20,
          size.y * .55,
        ),
        const Radius.circular(
          7,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF171B20,
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            center.dx,
            center.dy +
                size.y * .08,
          ),
          width:
          size.x * .72,
          height:
          size.y * .55,
        ),
        const Radius.circular(
          10,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF643039,
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            center.dx,
            center.dy +
                size.y * .20,
          ),
          width:
          size.x * .58,
          height:
          size.y * .18,
        ),
        const Radius.circular(
          7,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF882F3D,
        ),
    );

    canvas.drawCircle(
      Offset(
        center.dx,
        center.dy -
            size.y * .14,
      ),
      size.x * .23,
      Paint()
        ..color =
        const Color(
          0xFF3A2228,
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx - 4,
          center.dy -
              size.y * .55,
          8,
          size.y * .39,
        ),
        const Radius.circular(
          4,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF191D22,
        ),
    );

    canvas.drawCircle(
      Offset(
        center.dx,
        center.dy -
            size.y * .10,
      ),
      6 + _difficulty,
      Paint()
        ..color =
        const Color(
          0xFFFF293B,
        ).withValues(
          alpha:
          pulse.clamp(
            .3,
            1,
          ),
        ),
    );

    canvas.drawCircle(
      Offset(
        center.dx,
        center.dy -
            size.y * .10,
      ),
      3,
      Paint()
        ..color =
            Colors.white,
    );

    canvas.drawCircle(
      Offset(
        size.x * .24,
        size.y * .63,
      ),
      4,
      Paint()
        ..color =
        const Color(
          0xFFFFA326,
        ),
    );

    canvas.drawCircle(
      Offset(
        size.x * .76,
        size.y * .63,
      ),
      4,
      Paint()
        ..color =
        const Color(
          0xFFFFA326,
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x * .12,
          2,
          size.x * .76,
          5,
        ),
        const Radius.circular(
          3,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFFFF344D,
        ),
    );
  }
}