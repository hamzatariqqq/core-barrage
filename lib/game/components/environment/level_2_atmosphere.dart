import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Level2Atmosphere
    extends PositionComponent {
  Level2Atmosphere({
    required this.gameSize,
  }) : super(
    position: Vector2.zero(),
    size: gameSize,
    priority: -850,
  );

  final Vector2 gameSize;

  final Random _random =
  Random(17);

  final List<_DustParticle>
  _particles = [];

  double _time = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    for (int i = 0;
    i < 32;
    i++) {
      _particles.add(
        _DustParticle(
          x:
          _random.nextDouble() *
              gameSize.x,
          y:
          _random.nextDouble() *
              gameSize.y,
          radius:
          0.8 +
              _random.nextDouble() *
                  2.2,
          speed:
          10 +
              _random.nextDouble() *
                  25,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;

    for (final particle
    in _particles) {
      particle.y +=
          particle.speed * dt;

      particle.x +=
          sin(
            _time * 0.8 +
                particle.y *
                    0.01,
          ) *
              4 *
              dt;

      if (particle.y >
          gameSize.y + 10) {
        particle.y = -10;

        particle.x =
            _random.nextDouble() *
                gameSize.x;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ==========================================================
    // WARM DESERT ATMOSPHERE
    // ==========================================================

    final screen =
    Rect.fromLTWH(
      0,
      0,
      gameSize.x,
      gameSize.y,
    );

    canvas.drawRect(
      screen,
      Paint()
        ..shader =
        const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(
              0x224E1A0C,
            ),
            Colors.transparent,
            Color(
              0x163C180D,
            ),
          ],
          stops: [
            0,
            0.48,
            1,
          ],
        ).createShader(
          screen,
        ),
    );

    // ==========================================================
    // SIDE ORANGE LIGHT
    // ==========================================================

    final leftGlow =
    Rect.fromLTWH(
      0,
      0,
      gameSize.x * 0.34,
      gameSize.y,
    );

    canvas.drawRect(
      leftGlow,
      Paint()
        ..shader =
        const LinearGradient(
          begin:
          Alignment.centerLeft,
          end:
          Alignment.centerRight,
          colors: [
            Color(
              0x284E210E,
            ),
            Colors.transparent,
          ],
        ).createShader(
          leftGlow,
        ),
    );

    final rightGlow =
    Rect.fromLTWH(
      gameSize.x * 0.66,
      0,
      gameSize.x * 0.34,
      gameSize.y,
    );

    canvas.drawRect(
      rightGlow,
      Paint()
        ..shader =
        const LinearGradient(
          begin:
          Alignment.centerRight,
          end:
          Alignment.centerLeft,
          colors: [
            Color(
              0x284E210E,
            ),
            Colors.transparent,
          ],
        ).createShader(
          rightGlow,
        ),
    );

    // ==========================================================
    // DUST
    // ==========================================================

    for (final particle
    in _particles) {
      canvas.drawCircle(
        Offset(
          particle.x,
          particle.y,
        ),
        particle.radius,
        Paint()
          ..color =
          const Color(
            0xFFD58A4E,
          ).withValues(
            alpha: 0.30,
          ),
      );
    }

    // ==========================================================
    // SUBTLE HORIZON HEAT
    // ==========================================================

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          gameSize.x / 2,
          gameSize.y * 0.17,
        ),
        width:
        gameSize.x * 0.72,
        height:
        95,
      ),
      Paint()
        ..color =
        const Color(
          0xFFCE7540,
        ).withValues(
          alpha: 0.055,
        ),
    );
  }
}

class _DustParticle {
  _DustParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
  });

  double x;
  double y;

  final double radius;
  final double speed;
}