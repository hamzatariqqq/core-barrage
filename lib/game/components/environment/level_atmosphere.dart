import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../systems/level/level_runtime_config.dart';

class LevelAtmosphere extends PositionComponent {
  LevelAtmosphere({
    required Vector2 gameSize,
    required this.config,
  }) : super(
    position: Vector2.zero(),
    size: gameSize,
    priority: 2,
  );

  final LevelRuntimeConfig config;

  final math.Random _random =
  math.Random(17);

  late final List<_Particle> _particles;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _particles =
        List.generate(
          28,
              (index) {
            return _Particle(
              x: _random.nextDouble() *
                  size.x,
              y: _random.nextDouble() *
                  size.y,
              speed:
              12 +
                  _random.nextDouble() *
                      38,
              radius:
              1 +
                  _random.nextDouble() *
                      3,
            );
          },
        );
  }

  @override
  void update(
      double dt,
      ) {
    super.update(dt);


    for (final particle
    in _particles) {
      switch (config.atmosphere) {
        case LevelAtmosphereType.sandstorm:
        case LevelAtmosphereType.finalStand:
          particle.x +=
              particle.speed * dt *
                  1.8;

          particle.y +=
              particle.speed *
                  dt *
                  .32;
          break;

        case LevelAtmosphereType.inferno:
        case LevelAtmosphereType.firepower:
        case LevelAtmosphereType.finalBoss:
          particle.y -=
              particle.speed * dt;
          break;

        default:
          particle.y +=
              particle.speed *
                  dt *
                  .25;
      }

      if (particle.x >
          size.x + 20) {
        particle.x = -20;
      }

      if (particle.x < -20) {
        particle.x =
            size.x + 20;
      }

      if (particle.y >
          size.y + 20) {
        particle.y = -20;
      }

      if (particle.y < -20) {
        particle.y =
            size.y + 20;
      }
    }
  }

  @override
  void render(
      Canvas canvas,
      ) {
    super.render(canvas);

    final rect =
    Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y,
    );

    _drawTint(
      canvas,
      rect,
    );

    _drawEdgeEnvironment(
      canvas,
    );

    _drawParticles(
      canvas,
    );

    _drawTopLight(
      canvas,
      rect,
    );
  }

  void _drawTint(
      Canvas canvas,
      Rect rect,
      ) {
    final colors =
    _backgroundColors();

    canvas.drawRect(
      rect,
      Paint()
        ..shader =
        LinearGradient(
          begin:
          Alignment.topCenter,
          end:
          Alignment.bottomCenter,
          colors: colors,
        ).createShader(
          rect,
        ),
    );
  }

  List<Color> _backgroundColors() {
    switch (config.atmosphere) {
      case LevelAtmosphereType.desert:
        return const [
          Color(0x1239C8FF),
          Color(0x061A7DAA),
          Colors.transparent,
        ];

      case LevelAtmosphereType.canyon:
        return const [
          Color(0x28FF8432),
          Color(0x14984627),
          Colors.transparent,
        ];

      case LevelAtmosphereType.sandstorm:
        return const [
          Color(0x43D99F53),
          Color(0x246F4A25),
          Color(0x160F0B08),
        ];

      case LevelAtmosphereType.sunset:
        return const [
          Color(0x44FF6248),
          Color(0x24542B50),
          Color(0x1A110B1D),
        ];

      case LevelAtmosphereType.inferno:
        return const [
          Color(0x38FF3B27),
          Color(0x286D140D),
          Color(0x240B0808),
        ];

      case LevelAtmosphereType.convoy:
        return const [
          Color(0x248B775D),
          Color(0x16483C32),
          Colors.transparent,
        ];

      case LevelAtmosphereType.rocket:
        return const [
          Color(0x32FF702E),
          Color(0x1E8E2214),
          Color(0x160F1014),
        ];

      case LevelAtmosphereType.reinforcement:
        return const [
          Color(0x2533F29A),
          Color(0x16227AA3),
          Colors.transparent,
        ];

      case LevelAtmosphereType.night:
        return const [
          Color(0x3B5A43D8),
          Color(0x24101D4C),
          Color(0x24030610),
        ];

      case LevelAtmosphereType.fortress:
        return const [
          Color(0x31FF5B3D),
          Color(0x1D292A30),
          Color(0x2506090D),
        ];

      case LevelAtmosphereType.shield:
        return const [
          Color(0x2A3B8DFF),
          Color(0x18213B68),
          Colors.transparent,
        ];

      case LevelAtmosphereType.firepower:
        return const [
          Color(0x32FFC738),
          Color(0x20A63C1C),
          Color(0x180B0A09),
        ];

      case LevelAtmosphereType.citadel:
        return const [
          Color(0x329D63FF),
          Color(0x222F204D),
          Color(0x24070910),
        ];

      case LevelAtmosphereType.finalStand:
        return const [
          Color(0x35FF3D38),
          Color(0x28701418),
          Color(0x2B08080C),
        ];

      case LevelAtmosphereType.finalBoss:
        return const [
          Color(0x3DFFD238),
          Color(0x32BB2117),
          Color(0x30060102),
        ];
    }
  }

  void _drawTopLight(
      Canvas canvas,
      Rect rect,
      ) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader =
        RadialGradient(
          center:
          const Alignment(
            0,
            -1,
          ),
          radius: .85,
          colors: [
            config.accent
                .withValues(
              alpha: .16,
            ),
            Colors.transparent,
          ],
        ).createShader(
          rect,
        ),
    );
  }

  void _drawParticles(
      Canvas canvas,
      ) {
    Color particleColor;

    switch (config.atmosphere) {
      case LevelAtmosphereType.inferno:
      case LevelAtmosphereType.firepower:
      case LevelAtmosphereType.finalBoss:
        particleColor =
        const Color(
          0xFFFFA335,
        );
        break;

      case LevelAtmosphereType.sandstorm:
      case LevelAtmosphereType.finalStand:
        particleColor =
        const Color(
          0xFFD9A862,
        );
        break;

      case LevelAtmosphereType.night:
      case LevelAtmosphereType.citadel:
        particleColor =
        const Color(
          0xFF9E8CFF,
        );
        break;

      default:
        particleColor =
            config.accent;
    }

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
          particleColor
              .withValues(
            alpha: .22,
          ),
      );
    }
  }

  void _drawEdgeEnvironment(
      Canvas canvas,
      ) {
    final edgePaint =
    Paint()
      ..color =
      config
          .secondaryAccent
          .withValues(
        alpha: .12,
      );

    switch (config.atmosphere) {
      case LevelAtmosphereType.fortress:
      case LevelAtmosphereType.citadel:
      case LevelAtmosphereType.finalBoss:
        for (
        double y = 170;
        y < size.y - 170;
        y += 160
        ) {
          canvas.drawRect(
            Rect.fromLTWH(
              0,
              y,
              28,
              72,
            ),
            edgePaint,
          );

          canvas.drawRect(
            Rect.fromLTWH(
              size.x - 28,
              y + 40,
              28,
              72,
            ),
            edgePaint,
          );
        }
        break;

      case LevelAtmosphereType.convoy:
        for (
        double y = 220;
        y < size.y - 180;
        y += 230
        ) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                4,
                y,
                31,
                72,
              ),
              const Radius.circular(
                7,
              ),
            ),
            edgePaint,
          );

          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                size.x - 35,
                y + 90,
                31,
                72,
              ),
              const Radius.circular(
                7,
              ),
            ),
            edgePaint,
          );
        }
        break;

      default:
        for (
        double y = 170;
        y < size.y - 170;
        y += 175
        ) {
          canvas.drawCircle(
            Offset(
              20,
              y,
            ),
            17,
            edgePaint,
          );

          canvas.drawCircle(
            Offset(
              size.x - 20,
              y + 75,
            ),
            15,
            edgePaint,
          );
        }
    }
  }
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
  });

  double x;
  double y;

  final double speed;
  final double radius;
}