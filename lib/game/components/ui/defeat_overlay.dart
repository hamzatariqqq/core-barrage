import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class DefeatOverlay extends PositionComponent {
  DefeatOverlay({
    required Vector2 gameSize,
    required this.onRetry,
  }) : super(
    position: Vector2.zero(),
    size: gameSize,
    priority: 1000,
  );

  final VoidCallback onRetry;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color(
            0xE9090C13,
          ),
      ),
    );

    // Red atmospheric glow.
    add(
      CircleComponent(
        radius: size.x * 0.48,
        position: Vector2(
          size.x / 2,
          size.y * 0.18,
        ),
        anchor: Anchor.center,
        paint: Paint()
          ..color = const Color(
            0x18FF3434,
          ),
      ),
    );

    add(
      TextComponent(
        text: 'DEFEAT',
        position: Vector2(
          size.x / 2,
          size.y * 0.18,
        ),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFF5353),
            fontSize: 43,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
              Shadow(
                color: Color(0xFFB71919),
                blurRadius: 14,
              ),
            ],
          ),
        ),
      ),
    );

    add(
      TextComponent(
        text: 'MISSION FAILED',
        position: Vector2(
          size.x / 2,
          size.y * 0.235,
        ),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFF9D9D),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.2,
          ),
        ),
      ),
    );

    final panelWidth =
    math.min(size.x - 36, 350.0);

    add(
      _DefeatPanel(
        position: Vector2(
          size.x / 2,
          size.y * 0.46,
        ),
        panelWidth: panelWidth,
      ),
    );

    // Main Retry.
    add(
      _DefeatButton(
        position: Vector2(
          size.x / 2,
          size.y * 0.68,
        ),
        size: Vector2(
          panelWidth,
          62,
        ),
        text: 'RETRY',
        topColor: const Color(
          0xFFFFD844,
        ),
        bottomColor: const Color(
          0xFFE89100,
        ),
        textColor: const Color(
          0xFF382500,
        ),
        onPressed: onRetry,
      ),
    );

    // Secondary retry.
    add(
      _DefeatButton(
        position: Vector2(
          size.x / 2,
          size.y * 0.77,
        ),
        size: Vector2(
          panelWidth,
          54,
        ),
        text: 'PLAY AGAIN',
        topColor: const Color(
          0xFF248EFF,
        ),
        bottomColor: const Color(
          0xFF0755B4,
        ),
        onPressed: onRetry,
      ),
    );

    add(
      TextComponent(
        text: 'UPGRADE YOUR ARMY AND TRY AGAIN',
        position: Vector2(
          size.x / 2,
          size.y * 0.84,
        ),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: TextStyle(
            color: Colors.white.withValues(
              alpha: 0.46,
            ),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DEFEAT PANEL
// ============================================================

class _DefeatPanel extends PositionComponent {
  _DefeatPanel({
    required Vector2 position,
    required this.panelWidth,
  }) : super(
    position: position,
    size: Vector2(
      panelWidth,
      190,
    ),
    anchor: Anchor.center,
  );

  final double panelWidth;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y,
    );

    final panel = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(20),
    );

    canvas.drawRRect(
      panel.shift(
        const Offset(0, 7),
      ),
      Paint()
        ..color = Colors.black.withValues(
          alpha: 0.55,
        ),
    );

    canvas.drawRRect(
      panel,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF352332),
            Color(0xFF171A29),
            Color(0xFF0A111C),
          ],
        ).createShader(rect),
    );

    canvas.drawRRect(
      panel,
      Paint()
        ..color = const Color(
          0xFF9A4148,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    _centerText(
      canvas,
      'BATTLE REPORT',
      22,
      11,
      const Color(0xFFFF9696),
    );

    // Broken/star style icon.
    canvas.drawCircle(
      Offset(
        size.x / 2,
        72,
      ),
      28,
      Paint()
        ..color = const Color(
          0xFF471C25,
        ),
    );

    canvas.drawCircle(
      Offset(
        size.x / 2,
        72,
      ),
      27,
      Paint()
        ..color = const Color(
          0xFFFF4E55,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final iconPainter = TextPainter(
      text: const TextSpan(
        text: '!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    iconPainter.paint(
      canvas,
      Offset(
        size.x / 2 -
            iconPainter.width / 2,
        49,
      ),
    );

    canvas.drawLine(
      Offset(18, 112),
      Offset(
        size.x - 18,
        112,
      ),
      Paint()
        ..color = Colors.white.withValues(
          alpha: 0.10,
        ),
    );

    _stat(
      canvas,
      x: size.x * 0.25,
      value: '0',
      label: 'STARS',
    );

    _stat(
      canvas,
      x: size.x * 0.50,
      value: 'FAILED',
      label: 'RESULT',
    );

    _stat(
      canvas,
      x: size.x * 0.75,
      value: 'RETRY',
      label: 'MISSION',
    );
  }

  void _stat(
      Canvas canvas, {
        required double x,
        required String value,
        required String label,
      }) {
    final valuePainter = TextPainter(
      text: TextSpan(
        text: value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    valuePainter.paint(
      canvas,
      Offset(
        x - valuePainter.width / 2,
        133,
      ),
    );

    final labelPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF9A7B84),
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    labelPainter.paint(
      canvas,
      Offset(
        x - labelPainter.width / 2,
        157,
      ),
    );
  }

  void _centerText(
      Canvas canvas,
      String text,
      double y,
      double fontSize,
      Color color,
      ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(
        size.x / 2 -
            painter.width / 2,
        y,
      ),
    );
  }
}

// ============================================================
// DEFEAT BUTTON
// ============================================================

class _DefeatButton extends PositionComponent
    with TapCallbacks {
  _DefeatButton({
    required Vector2 position,
    required Vector2 size,
    required this.text,
    required this.topColor,
    required this.bottomColor,
    required this.onPressed,
    this.textColor = Colors.white,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.center,
  );

  final String text;
  final Color topColor;
  final Color bottomColor;
  final Color textColor;
  final VoidCallback onPressed;

  bool _pressed = false;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final offset =
    _pressed ? 3.0 : 0.0;

    final rect = Rect.fromLTWH(
      0,
      offset,
      size.x,
      size.y - 4,
    );

    final button = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(14),
    );

    canvas.drawRRect(
      button.shift(
        const Offset(0, 5),
      ),
      Paint()
        ..color = Colors.black.withValues(
          alpha: 0.45,
        ),
    );

    canvas.drawRRect(
      button,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            topColor,
            bottomColor,
          ],
        ).createShader(rect),
    );

    canvas.drawRRect(
      button,
      Paint()
        ..color = Colors.white.withValues(
          alpha: 0.30,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 17,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
          shadows: const [
            Shadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(
        size.x / 2 -
            painter.width / 2,
        offset +
            size.y / 2 -
            painter.height / 2 -
            2,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    _pressed = true;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _pressed = false;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _pressed = false;
    onPressed();
  }
}