import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class VictoryOverlay extends PositionComponent {
  VictoryOverlay({
    required Vector2 gameSize,
    required this.onPlayAgain,
  }) : super(
    position: Vector2.zero(),
    size: gameSize,
    priority: 1000,
  );

  final void Function() onPlayAgain;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = Colors.black.withValues(alpha: 0.80),
      ),
    );

    add(
      TextComponent(
        text: 'VICTORY!',
        position: Vector2(size.x / 2, size.y / 2 - 70),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    add(
      TextComponent(
        text: 'BOSS DEFEATED',
        position: Vector2(size.x / 2, size.y / 2 - 20),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );

    add(
      _PlayAgainButton(
        position: Vector2(size.x / 2, size.y / 2 + 50),
        onPressed: onPlayAgain,
      ),
    );
  }
}

class _PlayAgainButton extends RectangleComponent with TapCallbacks {
  _PlayAgainButton({
    required Vector2 position,
    required this.onPressed,
  }) : super(
    position: position,
    size: Vector2(150, 50),
    anchor: Anchor.center,
    paint: Paint()..color = const Color(0xFF2D8CFF),
  );

  final void Function() onPressed;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      TextComponent(
        text: 'PLAY AGAIN',
        position: size / 2,
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    onPressed();
  }
}