import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BossRageBanner extends PositionComponent {
  BossRageBanner({
    required this.gameSize,
  }) : super(
    position: Vector2.zero(),
    size: gameSize,
    priority: 1700,
  );

  final Vector2 gameSize;

  double _timer = 0;

  static const double _duration = 2.0;

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
    (progress / 0.12).clamp(
      0.0,
      1.0,
    );

    final fadeOut =
    ((1 - progress) / 0.22).clamp(
      0.0,
      1.0,
    );

    final opacity =
    min(
      fadeIn,
      fadeOut,
    );

    final pulse =
        (sin(_timer * 11) + 1) /
            2;

    // ==========================================================
    // SCREEN RAGE FLASH
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
          0xFFFF2018,
        ).withValues(
          alpha:
          opacity *
              (0.055 +
                  pulse * 0.035),
        ),
    );

    // ==========================================================
    // SIDE RED VIGNETTE
    // ==========================================================

    final leftRect =
    Rect.fromLTWH(
      0,
      0,
      gameSize.x * 0.26,
      gameSize.y,
    );

    canvas.drawRect(
      leftRect,
      Paint()
        ..shader =
        LinearGradient(
          begin:
          Alignment.centerLeft,
          end:
          Alignment.centerRight,
          colors: [
            const Color(
              0x55FF241C,
            ).withValues(
              alpha: opacity,
            ),
            Colors.transparent,
          ],
        ).createShader(
          leftRect,
        ),
    );

    final rightRect =
    Rect.fromLTWH(
      gameSize.x * 0.74,
      0,
      gameSize.x * 0.26,
      gameSize.y,
    );

    canvas.drawRect(
      rightRect,
      Paint()
        ..shader =
        LinearGradient(
          begin:
          Alignment.centerRight,
          end:
          Alignment.centerLeft,
          colors: [
            const Color(
              0x55FF241C,
            ).withValues(
              alpha: opacity,
            ),
            Colors.transparent,
          ],
        ).createShader(
          rightRect,
        ),
    );

    // ==========================================================
    // BANNER
    // ==========================================================

    final width =
    min(
      gameSize.x - 42,
      330.0,
    );

    const height = 96.0;

    final rect =
    Rect.fromCenter(
      center: Offset(
        gameSize.x / 2,
        gameSize.y * 0.30,
      ),
      width:
      width,
      height:
      height,
    );

    // Shadow.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.shift(
          const Offset(
            0,
            6,
          ),
        ),
        const Radius.circular(
          20,
        ),
      ),
      Paint()
        ..color =
        Colors.black.withValues(
          alpha:
          0.62 * opacity,
        ),
    );

    // Red glow.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(
          7 + pulse * 2,
        ),
        const Radius.circular(
          24,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFFFF3529,
        ).withValues(
          alpha:
          0.12 * opacity,
        ),
    );

    // Main panel.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(
          20,
        ),
      ),
      Paint()
        ..shader =
        LinearGradient(
          begin:
          Alignment.topCenter,
          end:
          Alignment.bottomCenter,
          colors: [
            const Color(
              0xF13D1B1D,
            ).withValues(
              alpha: opacity,
            ),
            const Color(
              0xFA12080A,
            ).withValues(
              alpha: opacity,
            ),
          ],
        ).createShader(
          rect,
        ),
    );

    // Border.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(
          20,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFFFF4938,
        ).withValues(
          alpha:
          0.85 * opacity,
        )
        ..style =
            PaintingStyle.stroke
        ..strokeWidth =
        2.2,
    );

    // ==========================================================
    // RAGE ICON
    // ==========================================================

    final iconCenter =
    Offset(
      rect.left + 42,
      rect.center.dy,
    );

    canvas.drawCircle(
      iconCenter,
      24,
      Paint()
        ..color =
        const Color(
          0xFF561817,
        ).withValues(
          alpha: opacity,
        ),
    );

    canvas.drawCircle(
      iconCenter,
      24,
      Paint()
        ..color =
        const Color(
          0xFFFF4A35,
        ).withValues(
          alpha:
          (0.65 +
              pulse * 0.25) *
              opacity,
        )
        ..style =
            PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    _drawCenteredText(
      canvas,
      '!',
      iconCenter,
      27,
      Colors.white.withValues(
        alpha: opacity,
      ),
      FontWeight.w900,
    );

    // ==========================================================
    // TEXT
    // ==========================================================

    final textCenterX =
        rect.left +
            77 +
            (rect.width - 88) / 2;

    _drawCenteredText(
      canvas,
      'RAGE MODE',
      Offset(
        textCenterX,
        rect.top + 35,
      ),
      23,
      Colors.white.withValues(
        alpha: opacity,
      ),
      FontWeight.w900,
      letterSpacing: 1.1,
    );

    _drawCenteredText(
      canvas,
      'BOSS POWER INCREASED',
      Offset(
        textCenterX,
        rect.top + 61,
      ),
      9,
      const Color(
        0xFFFF9E8D,
      ).withValues(
        alpha: opacity,
      ),
      FontWeight.w900,
      letterSpacing: 1.2,
    );

    // ==========================================================
    // ENERGY LINE
    // ==========================================================

    final line =
    Rect.fromLTWH(
      rect.left + 82,
      rect.bottom - 13,
      rect.width - 105,
      3,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        line,
        const Radius.circular(
          2,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFFFF4938,
        ).withValues(
          alpha:
          (0.55 +
              pulse * 0.30) *
              opacity,
        ),
    );
  }

  void _drawCenteredText(
      Canvas canvas,
      String text,
      Offset center,
      double size,
      Color color,
      FontWeight weight, {
        double letterSpacing = 0,
      }) {
    final painter =
    TextPainter(
      text:
      TextSpan(
        text:
        text,
        style:
        TextStyle(
          color:
          color,
          fontSize:
          size,
          fontWeight:
          weight,
          letterSpacing:
          letterSpacing,
          shadows:
          const [
            Shadow(
              color:
              Colors.black87,
              blurRadius:
              5,
            ),
          ],
        ),
      ),
      textDirection:
      TextDirection.ltr,
      textAlign:
      TextAlign.center,
    );

    painter.layout();

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