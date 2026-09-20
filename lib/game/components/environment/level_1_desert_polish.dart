import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Level1DesertPolish extends PositionComponent {
  Level1DesertPolish({
    required Vector2 gameSize,
  }) : super(
    position: Vector2.zero(),
    size: gameSize,
    priority: 4,
  );

  final math.Random _random =
  math.Random(91);

  final List<_DustParticle> _dust = [];

  final List<_RoadDebris> _debris = [];

  double _roadOffset = 0;

  double _edgeOffset = 0;

  double _speedPulse = 0;


  static const double _roadSpeed =
  260;

  static const double _debrisSpeed =
  210;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ============================================================
    // DUST PARTICLES
    // ============================================================

    for (int i = 0; i < 34; i++) {
      _dust.add(
        _DustParticle(
          x:
          _random.nextDouble() *
              size.x,
          y:
          _random.nextDouble() *
              size.y,
          speed:
          45 +
              _random.nextDouble() *
                  100,
          radius:
          1 +
              _random.nextDouble() *
                  2.5,
          drift:
          -18 +
              _random.nextDouble() *
                  36,
        ),
      );
    }

    // ============================================================
    // SIDE DEBRIS
    // ============================================================

    for (int i = 0; i < 12; i++) {
      _debris.add(
        _RoadDebris(
          side:
          i.isEven
              ? -1
              : 1,
          y:
          _random.nextDouble() *
              size.y,
          size:
          5 +
              _random.nextDouble() *
                  12,
          speedMultiplier:
          .75 +
              _random.nextDouble() *
                  .65,
        ),
      );
    }
  }

  @override
  void update(
      double dt,
      ) {
    super.update(dt);
    
    _roadOffset +=
        _roadSpeed * dt;

    _edgeOffset +=
        _roadSpeed * 1.12 * dt;

    _speedPulse +=
        dt * 3.2;

    if (_roadOffset >= 150) {
      _roadOffset -= 150;
    }

    if (_edgeOffset >= 90) {
      _edgeOffset -= 90;
    }

    // ============================================================
    // DUST
    // ============================================================

    for (final particle in _dust) {
      particle.y +=
          particle.speed * dt;

      particle.x +=
          particle.drift * dt;

      if (particle.y >
          size.y + 12) {
        particle.y = -12;

        particle.x =
            _random.nextDouble() *
                size.x;
      }

      if (particle.x < -20) {
        particle.x =
            size.x + 20;
      }

      if (particle.x >
          size.x + 20) {
        particle.x = -20;
      }
    }

    // ============================================================
    // DEBRIS
    // ============================================================

    for (final debris in _debris) {
      debris.y +=
          _debrisSpeed *
              debris.speedMultiplier *
              dt;

      if (debris.y >
          size.y + 40) {
        debris.y =
            -80 -
                _random.nextDouble() *
                    260;

        debris.size =
            5 +
                _random.nextDouble() *
                    12;
      }
    }
  }

  @override
  void render(
      Canvas canvas,
      ) {
    super.render(canvas);

    _drawHorizonGlow(
      canvas,
    );

    _drawRoadDepth(
      canvas,
    );

    _drawRoadMarkers(
      canvas,
    );

    _drawRoadEdgeMotion(
      canvas,
    );

    _drawSideDebris(
      canvas,
    );

    _drawDust(
      canvas,
    );

    _drawSpeedLines(
      canvas,
    );

    _drawVignette(
      canvas,
    );
  }

  // ============================================================
  // HORIZON
  // ============================================================

  void _drawHorizonGlow(
      Canvas canvas,
      ) {
    final rect =
    Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y * .55,
    );

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
          radius: 1.15,
          colors: const [
            Color(
              0x45FFCC6D,
            ),
            Color(
              0x1838A4D3,
            ),
            Colors.transparent,
          ],
          stops: const [
            0,
            .35,
            1,
          ],
        ).createShader(
          rect,
        ),
    );
  }

  // ============================================================
  // ROAD DEPTH
  // ============================================================

  void _drawRoadDepth(
      Canvas canvas,
      ) {
    final path =
    Path();

    final horizonY =
        size.y * .12;

    final bottomY =
        size.y;

    final horizonHalfWidth =
        size.x * .12;

    final bottomHalfWidth =
        size.x * .38;

    path.moveTo(
      size.x / 2 -
          horizonHalfWidth,
      horizonY,
    );

    path.lineTo(
      size.x / 2 +
          horizonHalfWidth,
      horizonY,
    );

    path.lineTo(
      size.x / 2 +
          bottomHalfWidth,
      bottomY,
    );

    path.lineTo(
      size.x / 2 -
          bottomHalfWidth,
      bottomY,
    );

    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..shader =
        LinearGradient(
          begin:
          Alignment.topCenter,
          end:
          Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(
              alpha: .03,
            ),
            Colors.black.withValues(
              alpha: .15,
            ),
            Colors.black.withValues(
              alpha: .26,
            ),
          ],
        ).createShader(
          Rect.fromLTWH(
            0,
            horizonY,
            size.x,
            bottomY -
                horizonY,
          ),
        ),
    );
  }

  // ============================================================
  // MOVING ROAD MARKERS
  // ============================================================

  void _drawRoadMarkers(
      Canvas canvas,
      ) {
    final centerX =
        size.x / 2;

    final horizonY =
        size.y * .13;

    final usableHeight =
        size.y - horizonY;

    for (int i = -2; i < 11; i++) {
      final raw =
          i * 145 +
              _roadOffset;

      final normalized =
          (raw / usableHeight) %
              1.0;

      final perspective =
          normalized *
              normalized;

      final y =
          horizonY +
              perspective *
                  usableHeight;

      final markerHeight =
          6 +
              perspective * 48;

      final markerWidth =
          1.4 +
              perspective * 5;

      final opacity =
          .12 +
              perspective * .60;

      final rect =
      Rect.fromCenter(
        center: Offset(
          centerX,
          y,
        ),
        width:
        markerWidth,
        height:
        markerHeight,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(
            3,
          ),
        ),
        Paint()
          ..color =
          const Color(
            0xFFFFD458,
          ).withValues(
            alpha: opacity,
          ),
      );
    }
  }

  // ============================================================
  // ROAD EDGE LIGHTS
  // ============================================================

  void _drawRoadEdgeMotion(
      Canvas canvas,
      ) {
    final horizonY =
        size.y * .13;

    final usableHeight =
        size.y - horizonY;

    for (int i = -2; i < 16; i++) {
      final raw =
          i * 90 +
              _edgeOffset;

      final normalized =
          (raw / usableHeight) %
              1.0;

      final perspective =
          normalized *
              normalized;

      final y =
          horizonY +
              perspective *
                  usableHeight;

      final halfRoadWidth =
          size.x *
              (
                  .12 +
                      perspective * .27
              );

      final barWidth =
          4 +
              perspective * 18;

      final barHeight =
          1 +
              perspective * 4;

      final alpha =
          .08 +
              perspective * .48;

      final paint =
      Paint()
        ..color =
        const Color(
          0xFF46CAFF,
        ).withValues(
          alpha: alpha,
        );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(
              size.x / 2 -
                  halfRoadWidth,
              y,
            ),
            width: barWidth,
            height:
            barHeight,
          ),
          const Radius.circular(
            3,
          ),
        ),
        paint,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(
              size.x / 2 +
                  halfRoadWidth,
              y,
            ),
            width: barWidth,
            height:
            barHeight,
          ),
          const Radius.circular(
            3,
          ),
        ),
        paint,
      );
    }
  }

  // ============================================================
  // PASSING DESERT DEBRIS
  // ============================================================

  void _drawSideDebris(
      Canvas canvas,
      ) {
    for (final debris in _debris) {
      final progress =
      (debris.y / size.y)
          .clamp(
        0.0,
        1.0,
      );

      final perspective =
          progress *
              progress;

      final roadHalfWidth =
          size.x *
              (
                  .15 +
                      perspective * .27
              );

      final offset =
          24 +
              perspective * 28;

      final x =
          size.x / 2 +
              debris.side *
                  (
                      roadHalfWidth +
                          offset
                  );

      final visualSize =
          debris.size *
              (
                  .45 +
                      perspective * 1.35
              );

      final shadowRect =
      Rect.fromCenter(
        center: Offset(
          x + 3,
          debris.y + 4,
        ),
        width:
        visualSize * 1.6,
        height:
        visualSize * .6,
      );

      canvas.drawOval(
        shadowRect,
        Paint()
          ..color =
          Colors.black
              .withValues(
            alpha: .22,
          ),
      );

      final rockPath =
      Path();

      rockPath.moveTo(
        x -
            visualSize * .55,
        debris.y +
            visualSize * .35,
      );

      rockPath.lineTo(
        x -
            visualSize * .25,
        debris.y -
            visualSize * .48,
      );

      rockPath.lineTo(
        x +
            visualSize * .30,
        debris.y -
            visualSize * .38,
      );

      rockPath.lineTo(
        x +
            visualSize * .58,
        debris.y +
            visualSize * .30,
      );

      rockPath.close();

      canvas.drawPath(
        rockPath,
        Paint()
          ..color =
          const Color(
            0xFF7A492B,
          ).withValues(
            alpha: .88,
          ),
      );

      canvas.drawPath(
        rockPath,
        Paint()
          ..color =
          const Color(
            0xFFCE8752,
          ).withValues(
            alpha: .35,
          )
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  // ============================================================
  // DUST
  // ============================================================

  void _drawDust(
      Canvas canvas,
      ) {
    for (final particle in _dust) {
      final progress =
      (particle.y /
          size.y)
          .clamp(
        0.0,
        1.0,
      );

      final alpha =
          .05 +
              progress * .18;

      canvas.drawCircle(
        Offset(
          particle.x,
          particle.y,
        ),
        particle.radius *
            (
                .6 +
                    progress
            ),
        Paint()
          ..color =
          const Color(
            0xFFFFD29B,
          ).withValues(
            alpha: alpha,
          ),
      );
    }
  }

  // ============================================================
  // SPEED LINES
  // ============================================================

  void _drawSpeedLines(
      Canvas canvas,
      ) {
    final pulse =
        .5 +
            math.sin(
              _speedPulse,
            ) *
                .5;

    final paint =
    Paint()
      ..strokeCap =
          StrokeCap.round
      ..strokeWidth = 1.2;

    for (int i = 0; i < 10; i++) {
      final side =
      i.isEven
          ? -1
          : 1;

      final laneIndex =
          i ~/ 2;

      final y =
          size.y *
              (
                  .38 +
                      laneIndex * .12
              );

      final x =
      side < 0
          ? size.x *
          (
              .08 +
                  laneIndex *
                      .018
          )
          : size.x *
          (
              .92 -
                  laneIndex *
                      .018
          );

      final length =
          12 +
              laneIndex * 7;

      paint.color =
          const Color(
            0xFF8EDFFF,
          ).withValues(
            alpha:
            .05 +
                pulse * .08,
          );

      canvas.drawLine(
        Offset(
          x,
          y,
        ),
        Offset(
          x,
          y + length,
        ),
        paint,
      );
    }
  }

  // ============================================================
  // CINEMATIC VIGNETTE
  // ============================================================

  void _drawVignette(
      Canvas canvas,
      ) {
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
        RadialGradient(
          center:
          Alignment.center,
          radius: .78,
          colors: const [
            Colors.transparent,
            Color(
              0x10000000,
            ),
            Color(
              0x50000000,
            ),
          ],
          stops: const [
            0,
            .68,
            1,
          ],
        ).createShader(
          rect,
        ),
    );
  }
}

class _DustParticle {
  _DustParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.drift,
  });

  double x;
  double y;

  final double speed;
  final double radius;
  final double drift;
}

class _RoadDebris {
  _RoadDebris({
    required this.side,
    required this.y,
    required this.size,
    required this.speedMultiplier,
  });

  final int side;

  double y;
  double size;

  final double speedMultiplier;
}