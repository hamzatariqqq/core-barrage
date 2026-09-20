import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BossEntranceWarning extends PositionComponent {
  BossEntranceWarning({
    required this.gameSize,
  }) : super(
    position: Vector2.zero(),
    size: gameSize,
    priority: 1600,
  );

  final Vector2 gameSize;

  double _timer = 0;

  static const double _duration = 2.2;

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;

    if (_timer >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress =
    (_timer / _duration).clamp(
      0.0,
      1.0,
    );

    final fadeIn =
    (progress / 0.16).clamp(
      0.0,
      1.0,
    );

    final fadeOut =
    ((1 - progress) / 0.20).clamp(
      0.0,
      1.0,
    );

    final opacity =
    min(
      fadeIn,
      fadeOut,
    );

    final pulse =
        (sin(_timer * 9) + 1) / 2;

    // ==========================================================
    // SCREEN RED FLASH
    // ==========================================================

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        gameSize.x,
        gameSize.y,
      ),
      Paint()
        ..color =
        const Color(
          0xFFFF2E2E,
        ).withValues(
          alpha:
          opacity *
              (0.05 +
                  pulse * 0.025),
        ),
    );

    // ==========================================================
    // MAIN WARNING PANEL
    // ==========================================================

    final width =
    min(
      gameSize.x - 32,
      350.0,
    );

    const height = 118.0;

    final centerY =
        gameSize.y * 0.29;

    final rect =
    Rect.fromCenter(
      center: Offset(
        gameSize.x / 2,
        centerY,
      ),
      width: width,
      height: height,
    );

    // Shadow.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.shift(
          const Offset(
            0,
            7,
          ),
        ),
        const Radius.circular(
          22,
        ),
      ),
      Paint()
        ..color =
        Colors.black.withValues(
          alpha:
          0.56 * opacity,
        ),
    );

    // Glow.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(7),
        const Radius.circular(
          25,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFFFF3B30,
        ).withValues(
          alpha:
          0.12 *
              opacity,
        ),
    );

    // Main panel.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(
          22,
        ),
      ),
      Paint()
        ..shader =
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(
              0xF2362023,
            ).withValues(
              alpha: opacity,
            ),
            const Color(
              0xFA12090C,
            ).withValues(
              alpha: opacity,
            ),
          ],
        ).createShader(
          rect,
        ),
    );

    // Red border.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(
          22,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFFFF4B3D,
        ).withValues(
          alpha:
          0.82 *
              opacity,
        )
        ..style =
            PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // ==========================================================
    // SIDE DANGER BARS
    // ==========================================================

    final leftBar =
    Rect.fromLTWH(
      rect.left + 12,
      rect.top + 18,
      6,
      rect.height - 36,
    );

    final rightBar =
    Rect.fromLTWH(
      rect.right - 18,
      rect.top + 18,
      6,
      rect.height - 36,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        leftBar,
        const Radius.circular(
          3,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFFFF4B3D,
        ).withValues(
          alpha:
          0.85 *
              opacity,
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rightBar,
        const Radius.circular(
          3,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFFFF4B3D,
        ).withValues(
          alpha:
          0.85 *
              opacity,
        ),
    );

    // ==========================================================
    // WARNING TRIANGLE
    // ==========================================================

    final iconCenter =
    Offset(
      rect.center.dx,
      rect.top + 28,
    );

    final triangle =
    Path()
      ..moveTo(
        iconCenter.dx,
        iconCenter.dy - 12,
      )
      ..lineTo(
        iconCenter.dx - 13,
        iconCenter.dy + 11,
      )
      ..lineTo(
        iconCenter.dx + 13,
        iconCenter.dy + 11,
      )
      ..close();

    canvas.drawPath(
      triangle,
      Paint()
        ..color =
        const Color(
          0xFFFF5448,
        ).withValues(
          alpha:
          opacity,
        ),
    );

    _drawCenteredText(
      canvas,
      '!',
      Offset(
        iconCenter.dx,
        iconCenter.dy + 2,
      ),
      16,
      Colors.white.withValues(
        alpha: opacity,
      ),
      FontWeight.w900,
    );

    // ==========================================================
    // TEXT
    // ==========================================================

    _drawCenteredText(
      canvas,
      'WARNING',
      Offset(
        rect.center.dx,
        rect.top + 55,
      ),
      9,
      const Color(
        0xFFFF8D79,
      ).withValues(
        alpha: opacity,
      ),
      FontWeight.w900,
      letterSpacing: 2.2,
    );

    _drawCenteredText(
      canvas,
      'BOSS INCOMING',
      Offset(
        rect.center.dx,
        rect.top + 78,
      ),
      24,
      Colors.white.withValues(
        alpha: opacity,
      ),
      FontWeight.w900,
      letterSpacing: 1.1,
    );

    _drawCenteredText(
      canvas,
      'PREPARE YOUR SQUAD',
      Offset(
        rect.center.dx,
        rect.top + 99,
      ),
      9,
      const Color(
        0xFFFFA998,
      ).withValues(
        alpha: opacity,
      ),
      FontWeight.w800,
      letterSpacing: 1.4,
    );

    // ==========================================================
    // BOTTOM ENERGY LINE
    // ==========================================================

    final energyRect =
    Rect.fromCenter(
      center: Offset(
        rect.center.dx,
        rect.bottom - 8,
      ),
      width:
      (rect.width - 80) *
          opacity,
      height: 2.5,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        energyRect,
        const Radius.circular(
          2,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFFFF4B3D,
        ).withValues(
          alpha:
          0.75 *
              opacity,
        ),
    );
  }

  void _drawCenteredText(
      Canvas canvas,
      String text,
      Offset center,
      double fontSize,
      Color color,
      FontWeight weight, {
        double letterSpacing = 0,
      }) {
    final painter =
    TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          letterSpacing:
          letterSpacing,
          shadows: const [
            Shadow(
              color:
              Colors.black87,
              blurRadius: 5,
            ),
          ],
        ),
      ),
      textDirection:
      TextDirection.ltr,
      textAlign:
      TextAlign.center,
    );

    painter.layout(
      maxWidth:
      gameSize.x - 70,
    );

    painter.paint(
      canvas,
      Offset(
        center.dx -
            painter.width / 2,
        center.dy -
            painter.height / 2,
      ),
    );
  }
}