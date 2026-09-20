import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BossBattleEffect extends PositionComponent {
  BossBattleEffect({
    required this.gameSize,
  }) : super(
    position: Vector2.zero(),
    size: gameSize,
    priority: -70,
  );

  final Vector2 gameSize;

  double _time = 0;
  double _flashTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;
    _flashTimer += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final width = gameSize.x;
    final height = gameSize.y;

    final pulse =
        (sin(_time * 2.4) + 1) / 2;

    // ==========================================================
    // DARK BOSS PHASE TINT
    // ==========================================================

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        width,
        height,
      ),
      Paint()
        ..color =
        Colors.black.withValues(
          alpha: 0.10 + pulse * 0.05,
        ),
    );

    // ==========================================================
    // RED HORIZON PRESSURE
    // ==========================================================

    final horizonGlow =
    Rect.fromCenter(
      center: Offset(
        width / 2,
        height * 0.24,
      ),
      width: width * 0.88,
      height: height * 0.42,
    );

    canvas.drawOval(
      horizonGlow,
      Paint()
        ..shader =
        RadialGradient(
          colors: [
            const Color(
              0x44FF3528,
            ),
            const Color(
              0x18FF3D2D,
            ),
            Colors.transparent,
          ],
        ).createShader(
          horizonGlow,
        ),
    );

    // ==========================================================
    // SIDE DANGER GLOW
    // ==========================================================

    final leftRect =
    Rect.fromLTWH(
      0,
      0,
      width * 0.26,
      height,
    );

    canvas.drawRect(
      leftRect,
      Paint()
        ..shader =
        LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(
              0x22FF3328,
            ),
            Colors.transparent,
          ],
        ).createShader(
          leftRect,
        ),
    );

    final rightRect =
    Rect.fromLTWH(
      width * 0.74,
      0,
      width * 0.26,
      height,
    );

    canvas.drawRect(
      rightRect,
      Paint()
        ..shader =
        LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            const Color(
              0x22FF3328,
            ),
            Colors.transparent,
          ],
        ).createShader(
          rightRect,
        ),
    );

    // ==========================================================
    // MOVING DANGER LINES
    // ==========================================================

    for (int i = 0; i < 5; i++) {
      final y =
          height * 0.16 +
              (((i * 135) +
                  (_time * 45)) %
                  (height * 0.68));

      canvas.drawRect(
        Rect.fromLTWH(
          width * 0.14,
          y,
          width * 0.72,
          2,
        ),
        Paint()
          ..color =
          const Color(
            0xFFFF5A3B,
          ).withValues(
            alpha: 0.06,
          ),
      );
    }

    // ==========================================================
    // PERIODIC BOSS FLASH
    // ==========================================================

    final flashCycle =
        _flashTimer % 3.2;

    if (flashCycle < 0.12) {
      final strength =
          1 -
              (flashCycle /
                  0.12);

      canvas.drawRect(
        Rect.fromLTWH(
          0,
          0,
          width,
          height,
        ),
        Paint()
          ..color =
          const Color(
            0xFFFF573D,
          ).withValues(
            alpha:
            strength * 0.055,
          ),
      );
    }

    // ==========================================================
    // TOP VIGNETTE
    // ==========================================================

    final topVignette =
    Rect.fromLTWH(
      0,
      0,
      width,
      height * 0.24,
    );

    canvas.drawRect(
      topVignette,
      Paint()
        ..shader =
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(
              alpha: 0.32,
            ),
            Colors.transparent,
          ],
        ).createShader(
          topVignette,
        ),
    );

    // ==========================================================
    // BOTTOM VIGNETTE
    // ==========================================================

    final bottomVignette =
    Rect.fromLTWH(
      0,
      height * 0.70,
      width,
      height * 0.30,
    );

    canvas.drawRect(
      bottomVignette,
      Paint()
        ..shader =
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(
              alpha: 0.36,
            ),
          ],
        ).createShader(
          bottomVignette,
        ),
    );
  }
}