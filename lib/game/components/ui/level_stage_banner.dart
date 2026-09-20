import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LevelStageBanner extends PositionComponent {
  LevelStageBanner({
    required this.gameSize,
    required this.title,
    required this.subtitle,
    required this.accent,
  }) : super(
    position: Vector2.zero(),
    size: gameSize,
    priority: 1500,
  );

  final Vector2 gameSize;

  final String title;
  final String subtitle;
  final Color accent;

  double _timer = 0;

  static const double _duration = 2.3;

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
    ((1.0 - progress) / 0.20).clamp(
      0.0,
      1.0,
    );

    final opacity =
    min(
      fadeIn,
      fadeOut,
    );

    final centerX =
        gameSize.x / 2;

    final targetY =
        gameSize.y * 0.26;

    final slideOffset =
        (1 - fadeIn) * 24;

    final centerY =
        targetY - slideOffset;

    final width =
    min(
      gameSize.x - 34,
      340.0,
    );

    const height = 92.0;

    final rect =
    Rect.fromCenter(
      center: Offset(
        centerX,
        centerY,
      ),
      width: width,
      height: height,
    );

    // ==========================================================
    // BACK SHADOW
    // ==========================================================

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
          0.50 * opacity,
        ),
    );

    // ==========================================================
    // OUTER GLOW
    // ==========================================================

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(5),
        const Radius.circular(
          23,
        ),
      ),
      Paint()
        ..color =
        accent.withValues(
          alpha:
          0.11 * opacity,
        ),
    );

    // ==========================================================
    // MAIN PANEL
    // ==========================================================

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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(
              0xF0253D4A,
            ).withValues(
              alpha: opacity,
            ),
            const Color(
              0xF20A1821,
            ).withValues(
              alpha: opacity,
            ),
          ],
        ).createShader(
          rect,
        ),
    );

    // ==========================================================
    // BORDER
    // ==========================================================

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(
          20,
        ),
      ),
      Paint()
        ..color =
        accent.withValues(
          alpha:
          0.78 * opacity,
        )
        ..style =
            PaintingStyle.stroke
        ..strokeWidth = 1.7,
    );

    // ==========================================================
    // TOP ACCENT LINE
    // ==========================================================

    final accentLine =
    Rect.fromLTWH(
      rect.left + 24,
      rect.top + 8,
      rect.width - 48,
      3,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        accentLine,
        const Radius.circular(
          2,
        ),
      ),
      Paint()
        ..shader =
        LinearGradient(
          colors: [
            Colors.transparent,
            accent.withValues(
              alpha:
              0.9 * opacity,
            ),
            Colors.transparent,
          ],
        ).createShader(
          accentLine,
        ),
    );

    // ==========================================================
    // LEFT WARNING MARKER
    // ==========================================================

    final leftMarker =
    Rect.fromLTWH(
      rect.left + 13,
      rect.center.dy - 21,
      5,
      42,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        leftMarker,
        const Radius.circular(
          3,
        ),
      ),
      Paint()
        ..color =
        accent.withValues(
          alpha:
          0.85 * opacity,
        ),
    );

    // ==========================================================
    // RIGHT WARNING MARKER
    // ==========================================================

    final rightMarker =
    Rect.fromLTWH(
      rect.right - 18,
      rect.center.dy - 21,
      5,
      42,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rightMarker,
        const Radius.circular(
          3,
        ),
      ),
      Paint()
        ..color =
        accent.withValues(
          alpha:
          0.85 * opacity,
        ),
    );

    // ==========================================================
    // SMALL STATUS LABEL
    // ==========================================================

    _drawCenteredText(
      canvas,
      'BATTLE UPDATE',
      Offset(
        centerX,
        rect.top + 21,
      ),
      8,
      accent.withValues(
        alpha: opacity,
      ),
      FontWeight.w900,
      letterSpacing: 1.8,
    );

    // ==========================================================
    // TITLE
    // ==========================================================

    _drawCenteredText(
      canvas,
      title,
      Offset(
        centerX,
        rect.top + 47,
      ),
      22,
      Colors.white.withValues(
        alpha: opacity,
      ),
      FontWeight.w900,
      letterSpacing: 1.0,
    );

    // ==========================================================
    // SUBTITLE
    // ==========================================================

    _drawCenteredText(
      canvas,
      subtitle,
      Offset(
        centerX,
        rect.top + 70,
      ),
      9,
      const Color(
        0xFFB7D6E3,
      ).withValues(
        alpha:
        opacity * 0.92,
      ),
      FontWeight.w800,
      letterSpacing: 1.3,
    );

    // ==========================================================
    // BOTTOM ENERGY LINE
    // ==========================================================

    final energyWidth =
        (rect.width - 70) *
            opacity;

    final energyRect =
    Rect.fromCenter(
      center: Offset(
        centerX,
        rect.bottom - 8,
      ),
      width:
      energyWidth,
      height: 2,
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
        accent.withValues(
          alpha:
          0.55 * opacity,
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