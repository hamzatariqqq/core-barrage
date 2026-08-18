import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class DefeatOverlay extends PositionComponent {
  DefeatOverlay({
    required Vector2 gameSize,
    required this.onRetry,
  }) : super(
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
        paint: Paint()..color = Colors.black.withValues(alpha: 0.75),
      ),
    );

    add(
      TextComponent(
        text: 'DEFEAT',
        position: Vector2(size.x / 2, size.y / 2 - 70),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 42,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    add(
      RetryButton(
        position: Vector2(size.x / 2, size.y / 2 + 20),
        onRetry: onRetry,
      ),
    );
  }
}

class RetryButton extends RectangleComponent with TapCallbacks {
  RetryButton({
    required Vector2 position,
    required this.onRetry,
  }) : super(
    position: position,
    size: Vector2(150, 55),
    anchor: Anchor.center,
    paint: Paint()..color = const Color(0xFF238BFF),
  );

  final VoidCallback onRetry;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      TextComponent(
        text: 'RETRY',
        position: size / 2,
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onRetry();
  }
}