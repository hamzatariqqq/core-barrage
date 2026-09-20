import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class IronWardenAura extends PositionComponent {
  IronWardenAura({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2.all(190),
    anchor: Anchor.center,
    priority: 140,
  );

  double _time = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(
      size.x / 2,
      size.y / 2,
    );

    final pulse =
        (sin(_time * 3.2) + 1) / 2;

    final rotation =
        _time * 0.7;

    // ==========================================================
    // LARGE OUTER GLOW
    // ==========================================================

    final outerRadius =
        78 +
            pulse * 8;

    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..shader =
        RadialGradient(
          colors: [
            const Color(
              0x44FF7A32,
            ),
            const Color(
              0x22FF3B22,
            ),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: center,
            radius: outerRadius,
          ),
        ),
    );

    // ==========================================================
    // DARK ENERGY FIELD
    // ==========================================================

    canvas.drawCircle(
      center,
      61,
      Paint()
        ..color =
        const Color(
          0xFF260B08,
        ).withValues(
          alpha: 0.24,
        ),
    );

    // ==========================================================
    // ROTATING OUTER RING
    // ==========================================================

    canvas.save();

    canvas.translate(
      center.dx,
      center.dy,
    );

    canvas.rotate(
      rotation,
    );

    final outerRingPaint =
    Paint()
      ..color =
      const Color(
        0xFFFF7B34,
      ).withValues(
        alpha:
        0.58 +
            pulse * 0.18,
      )
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int i = 0; i < 6; i++) {
      final start =
          i *
              (pi * 2 / 6);

      canvas.drawArc(
        Rect.fromCircle(
          center: Offset.zero,
          radius: 70,
        ),
        start,
        0.55,
        false,
        outerRingPaint,
      );
    }

    canvas.restore();

    // ==========================================================
    // INNER ROTATING RING
    // ==========================================================

    canvas.save();

    canvas.translate(
      center.dx,
      center.dy,
    );

    canvas.rotate(
      -rotation * 1.4,
    );

    final innerRingPaint =
    Paint()
      ..color =
      const Color(
        0xFFFF3D28,
      ).withValues(
        alpha: 0.70,
      )
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 4; i++) {
      final start =
          i *
              (pi / 2);

      canvas.drawArc(
        Rect.fromCircle(
          center: Offset.zero,
          radius: 54,
        ),
        start,
        0.75,
        false,
        innerRingPaint,
      );
    }

    canvas.restore();

    // ==========================================================
    // ENERGY NODES
    // ==========================================================

    for (int i = 0; i < 6; i++) {
      final angle =
          (_time * 1.4) +
              i *
                  (pi * 2 / 6);

      final radius =
          67 +
              sin(
                _time * 2 +
                    i,
              ) *
                  4;

      final node = Offset(
        center.dx +
            cos(angle) *
                radius,
        center.dy +
            sin(angle) *
                radius,
      );

      canvas.drawCircle(
        node,
        6,
        Paint()
          ..color =
          const Color(
            0x55FF6A32,
          ),
      );

      canvas.drawCircle(
        node,
        3,
        Paint()
          ..color =
          const Color(
            0xFFFFB05B,
          ),
      );
    }

    // ==========================================================
    // CORE GLOW
    // ==========================================================

    final coreRadius =
        34 +
            pulse * 5;

    canvas.drawCircle(
      center,
      coreRadius,
      Paint()
        ..shader =
        RadialGradient(
          colors: [
            const Color(
              0x55FFB05A,
            ),
            const Color(
              0x22FF4B2A,
            ),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: center,
            radius: coreRadius,
          ),
        ),
    );

    // ==========================================================
    // FLOOR SHADOW
    // ==========================================================

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + 49,
        ),
        width: 120,
        height: 24,
      ),
      Paint()
        ..color =
        Colors.black.withValues(
          alpha: 0.36,
        ),
    );
  }
}