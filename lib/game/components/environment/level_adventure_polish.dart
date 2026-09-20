import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LevelAdventurePolish extends PositionComponent {
  LevelAdventurePolish({
    required Vector2 gameSize,
    required this.level,
  }) : super(
    position: Vector2.zero(),
    size: gameSize,
    priority: 4,
  );

  final int level;

  final math.Random _random = math.Random(445);

  final List<_AdventureParticle> _particles = [];

  double _markerOffset = 0;
  double _edgeOffset = 0;
  double _pulse = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final count = switch (level) {
      2 => 24,
      3 => 42,
      4 => 30,
      5 => 38,
      _ => 20,
    };

    for (int i = 0; i < count; i++) {
      _particles.add(
        _AdventureParticle(
          x: _random.nextDouble() * size.x,
          y: _random.nextDouble() * size.y,
          speed: 40 + _random.nextDouble() * 120,
          drift: -26 + _random.nextDouble() * 52,
          radius: 1 + _random.nextDouble() * 3,
          rotation: _random.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _markerOffset += 230 * dt;
    _edgeOffset += 270 * dt;
    _pulse += dt * 3;

    if (_markerOffset >= 130) {
      _markerOffset -= 130;
    }

    if (_edgeOffset >= 100) {
      _edgeOffset -= 100;
    }

    for (final particle in _particles) {
      switch (level) {
      // Industrial sparks fall.
        case 2:
          particle.y += particle.speed * dt;
          particle.x += particle.drift * .25 * dt;
          break;

      // Snow falls with sideways wind.
        case 3:
          particle.y += particle.speed * .45 * dt;
          particle.x += particle.drift * .55 * dt;
          break;

      // Leaves fall slowly and drift.
        case 4:
          particle.y += particle.speed * .32 * dt;
          particle.x +=
              math.sin(particle.y * .02) * 18 * dt +
                  particle.drift * .20 * dt;
          particle.rotation += dt * 1.2;
          break;

      // Embers float upward.
        case 5:
          particle.y -= particle.speed * .55 * dt;
          particle.x += particle.drift * .12 * dt;
          break;

        default:
          particle.y += particle.speed * .3 * dt;
      }

      if (particle.y > size.y + 20) {
        particle.y = -20;
        particle.x = _random.nextDouble() * size.x;
      }

      if (particle.y < -20) {
        particle.y = size.y + 20;
        particle.x = _random.nextDouble() * size.x;
      }

      if (particle.x > size.x + 25) {
        particle.x = -25;
      }

      if (particle.x < -25) {
        particle.x = size.x + 25;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _drawWorldTint(canvas);
    _drawHorizon(canvas);
    _drawRoadMotion(canvas);
    _drawSideEnvironment(canvas);
    _drawParticles(canvas);
    _drawSpecialEffects(canvas);
    _drawVignette(canvas);
  }

  // ============================================================
  // WORLD TINT
  // ============================================================

  void _drawWorldTint(Canvas canvas) {
    final rect = Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y,
    );

    final colors = switch (level) {
    // Industrial
      2 => const [
        Color(0x263D9BD6),
        Color(0x141B3547),
        Color(0x10070D12),
      ],

    // Frozen
      3 => const [
        Color(0x445DD8FF),
        Color(0x2697DFFF),
        Color(0x18152B42),
      ],

    // Jungle
      4 => const [
        Color(0x3C3BBE66),
        Color(0x22418735),
        Color(0x19111D12),
      ],

    // Volcanic
      5 => const [
        Color(0x48FF552E),
        Color(0x30AE2419),
        Color(0x210C0504),
      ],

      _ => const [
        Colors.transparent,
        Colors.transparent,
      ],
    };

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(rect),
    );
  }

  // ============================================================
  // HORIZON
  // ============================================================

  void _drawHorizon(Canvas canvas) {
    final rect = Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y * .48,
    );

    final glow = switch (level) {
      2 => const Color(0xFF42C7FF),
      3 => const Color(0xFFB5ECFF),
      4 => const Color(0xFF69EB83),
      5 => const Color(0xFFFF6338),
      _ => Colors.white,
    };

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -1),
          radius: 1.1,
          colors: [
            glow.withValues(alpha: .24),
            glow.withValues(alpha: .06),
            Colors.transparent,
          ],
        ).createShader(rect),
    );
  }

  // ============================================================
  // ROAD MOVEMENT
  // ============================================================

  void _drawRoadMotion(Canvas canvas) {
    final centerX = size.x / 2;
    final horizonY = size.y * .13;
    final usableHeight = size.y - horizonY;

    for (int i = -2; i < 12; i++) {
      final raw = i * 130 + _markerOffset;

      final normalized =
          (raw / usableHeight) % 1.0;

      final perspective =
          normalized * normalized;

      final y =
          horizonY +
              perspective * usableHeight;

      final height =
          5 +
              perspective * 42;

      final width =
          1 +
              perspective * 4;

      final color = switch (level) {
        2 => const Color(0xFF57CFFF),
        3 => const Color(0xFFC7F3FF),
        4 => const Color(0xFF65DE74),
        5 => const Color(0xFFFF9A42),
        _ => Colors.white,
      };

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(
              centerX,
              y,
            ),
            width: width,
            height: height,
          ),
          const Radius.circular(3),
        ),
        Paint()
          ..color =
          color.withValues(
            alpha:
            .10 +
                perspective * .48,
          ),
      );
    }

    // Moving side indicators.
    for (int i = -2; i < 16; i++) {
      final raw =
          i * 100 +
              _edgeOffset;

      final normalized =
          (raw / usableHeight) % 1.0;

      final perspective =
          normalized * normalized;

      final y =
          horizonY +
              perspective * usableHeight;

      final roadWidth =
          size.x *
              (
                  .12 +
                      perspective * .28
              );

      final accent = switch (level) {
        2 => const Color(0xFF45C7FF),
        3 => const Color(0xFF9CE8FF),
        4 => const Color(0xFF50CE68),
        5 => const Color(0xFFFF623D),
        _ => Colors.white,
      };

      final paint =
      Paint()
        ..color =
        accent.withValues(
          alpha:
          .08 +
              perspective * .38,
        );

      canvas.drawCircle(
        Offset(
          centerX -
              roadWidth,
          y,
        ),
        1 +
            perspective * 4,
        paint,
      );

      canvas.drawCircle(
        Offset(
          centerX +
              roadWidth,
          y,
        ),
        1 +
            perspective * 4,
        paint,
      );
    }
  }

  // ============================================================
  // SIDE WORLD OBJECTS
  // ============================================================

  void _drawSideEnvironment(Canvas canvas) {
    switch (level) {
      case 2:
        _drawIndustrial(canvas);
        break;

      case 3:
        _drawFrozen(canvas);
        break;

      case 4:
        _drawJungle(canvas);
        break;

      case 5:
        _drawVolcanic(canvas);
        break;
    }
  }

  // ============================================================
  // INDUSTRIAL
  // ============================================================

  void _drawIndustrial(Canvas canvas) {
    final metalPaint =
    Paint()
      ..color =
      const Color(
        0xFF3C5360,
      ).withValues(
        alpha: .50,
      );

    final lightPaint =
    Paint()
      ..color =
      const Color(
        0xFF4DD2FF,
      ).withValues(
        alpha: .55,
      );

    for (double y = 130; y < size.y; y += 175) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            5,
            y,
            32,
            92,
          ),
          const Radius.circular(5),
        ),
        metalPaint,
      );

      canvas.drawRect(
        Rect.fromLTWH(
          14,
          y + 13,
          5,
          52,
        ),
        lightPaint,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.x - 37,
            y + 65,
            32,
            92,
          ),
          const Radius.circular(5),
        ),
        metalPaint,
      );

      canvas.drawRect(
        Rect.fromLTWH(
          size.x - 19,
          y + 78,
          5,
          52,
        ),
        lightPaint,
      );
    }
  }

  // ============================================================
  // FROZEN
  // ============================================================

  void _drawFrozen(Canvas canvas) {
    final icePaint =
    Paint()
      ..color =
      const Color(
        0xFFA5EBFF,
      ).withValues(
        alpha: .25,
      );

    for (double y = 150; y < size.y; y += 185) {
      final left =
      Path()
        ..moveTo(
          5,
          y + 55,
        )
        ..lineTo(
          34,
          y,
        )
        ..lineTo(
          48,
          y + 64,
        )
        ..close();

      canvas.drawPath(
        left,
        icePaint,
      );

      final right =
      Path()
        ..moveTo(
          size.x - 5,
          y + 55,
        )
        ..lineTo(
          size.x - 34,
          y + 15,
        )
        ..lineTo(
          size.x - 48,
          y + 70,
        )
        ..close();

      canvas.drawPath(
        right,
        icePaint,
      );
    }
  }

  // ============================================================
  // JUNGLE
  // ============================================================

  void _drawJungle(Canvas canvas) {
    final darkLeaf =
    Paint()
      ..color =
      const Color(
        0xFF173F22,
      ).withValues(
        alpha: .65,
      );

    final brightLeaf =
    Paint()
      ..color =
      const Color(
        0xFF45A94D,
      ).withValues(
        alpha: .38,
      );

    for (double y = 130; y < size.y; y += 115) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            15,
            y,
          ),
          width: 50,
          height: 28,
        ),
        darkLeaf,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            36,
            y + 22,
          ),
          width: 42,
          height: 22,
        ),
        brightLeaf,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            size.x - 15,
            y + 54,
          ),
          width: 50,
          height: 28,
        ),
        darkLeaf,
      );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            size.x - 38,
            y + 76,
          ),
          width: 42,
          height: 22,
        ),
        brightLeaf,
      );
    }
  }

  // ============================================================
  // VOLCANIC
  // ============================================================

  void _drawVolcanic(Canvas canvas) {
    final glow =
        .65 +
            math.sin(_pulse) * .20;

    final rockPaint =
    Paint()
      ..color =
      const Color(
        0xFF321817,
      ).withValues(
        alpha: .70,
      );

    final lavaPaint =
    Paint()
      ..color =
      const Color(
        0xFFFF5028,
      ).withValues(
        alpha: glow,
      )
      ..strokeWidth = 2.5
      ..style =
          PaintingStyle.stroke;

    for (double y = 140; y < size.y; y += 175) {
      canvas.drawCircle(
        Offset(
          20,
          y,
        ),
        28,
        rockPaint,
      );

      canvas.drawCircle(
        Offset(
          size.x - 20,
          y + 75,
        ),
        26,
        rockPaint,
      );

      canvas.drawLine(
        Offset(
          8,
          y - 15,
        ),
        Offset(
          34,
          y + 18,
        ),
        lavaPaint,
      );

      canvas.drawLine(
        Offset(
          size.x - 8,
          y + 55,
        ),
        Offset(
          size.x - 36,
          y + 92,
        ),
        lavaPaint,
      );
    }
  }

  // ============================================================
  // PARTICLES
  // ============================================================

  void _drawParticles(Canvas canvas) {
    for (final particle in _particles) {
      switch (level) {
      // Sparks
        case 2:
          canvas.drawLine(
            Offset(
              particle.x,
              particle.y,
            ),
            Offset(
              particle.x +
                  particle.drift * .08,
              particle.y + 9,
            ),
            Paint()
              ..color =
              const Color(
                0xFF7DE5FF,
              ).withValues(
                alpha: .35,
              )
              ..strokeWidth = 1.2,
          );
          break;

      // Snow
        case 3:
          canvas.drawCircle(
            Offset(
              particle.x,
              particle.y,
            ),
            particle.radius,
            Paint()
              ..color =
              Colors.white.withValues(
                alpha: .55,
              ),
          );
          break;

      // Leaves
        case 4:
          canvas.save();

          canvas.translate(
            particle.x,
            particle.y,
          );

          canvas.rotate(
            particle.rotation,
          );

          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width:
              particle.radius * 4,
              height:
              particle.radius * 2,
            ),
            Paint()
              ..color =
              const Color(
                0xFF5DD35B,
              ).withValues(
                alpha: .45,
              ),
          );

          canvas.restore();
          break;

      // Embers
        case 5:
          canvas.drawCircle(
            Offset(
              particle.x,
              particle.y,
            ),
            particle.radius,
            Paint()
              ..color =
              const Color(
                0xFFFF8736,
              ).withValues(
                alpha: .62,
              ),
          );

          canvas.drawCircle(
            Offset(
              particle.x,
              particle.y,
            ),
            particle.radius * 2.8,
            Paint()
              ..color =
              const Color(
                0xFFFF4A24,
              ).withValues(
                alpha: .10,
              ),
          );
          break;
      }
    }
  }

  // ============================================================
  // SPECIAL FULL-SCREEN EFFECT
  // ============================================================

  void _drawSpecialEffects(Canvas canvas) {
    final rect =
    Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y,
    );

    if (level == 3) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader =
          const LinearGradient(
            begin:
            Alignment.topLeft,
            end:
            Alignment.bottomRight,
            colors: [
              Color(
                0x12FFFFFF,
              ),
              Colors.transparent,
              Color(
                0x149AEAFF,
              ),
            ],
          ).createShader(rect),
      );
    }

    if (level == 4) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader =
          RadialGradient(
            center:
            const Alignment(
              -.3,
              -.5,
            ),
            radius: .9,
            colors: [
              const Color(
                0x224CE468,
              ),
              Colors.transparent,
            ],
          ).createShader(rect),
      );
    }

    if (level == 5) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader =
          RadialGradient(
            center:
            const Alignment(
              .25,
              -.7,
            ),
            radius: 1,
            colors: [
              const Color(
                0x32FF5E2D,
              ),
              Colors.transparent,
            ],
          ).createShader(rect),
      );
    }
  }

  // ============================================================
  // VIGNETTE
  // ============================================================

  void _drawVignette(Canvas canvas) {
    final rect =
    Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader =
        const RadialGradient(
          radius: .82,
          colors: [
            Colors.transparent,
            Color(
              0x15000000,
            ),
            Color(
              0x57000000,
            ),
          ],
          stops: [
            0,
            .67,
            1,
          ],
        ).createShader(rect),
    );
  }
}

class _AdventureParticle {
  _AdventureParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.drift,
    required this.radius,
    required this.rotation,
  });

  double x;
  double y;

  final double speed;
  final double drift;
  final double radius;

  double rotation;
}