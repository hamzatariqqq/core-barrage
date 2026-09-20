import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScrollingBattlefield extends PositionComponent {
  ScrollingBattlefield({
    required this.gameSize,
  }) : super(
    position: Vector2.zero(),
    size: gameSize,
    priority: -1000,
  );

  final Vector2 gameSize;

  Sprite? _roadSprite;

  double _scrollY = 0.0;

  static const double _scrollSpeed = 95.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _roadSprite = await Sprite.load(
      'ui/gameplay/desert_road_seamless.png',
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _scrollY += _scrollSpeed * dt;

    if (_scrollY >= gameSize.y) {
      _scrollY -= gameSize.y;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final sprite = _roadSprite;

    if (sprite == null) {
      _drawFallback(canvas);
      return;
    }

    // Tile currently on screen.
    sprite.render(
      canvas,
      position: Vector2(
        0,
        _scrollY,
      ),
      size: Vector2(
        gameSize.x,
        gameSize.y + 2,
      ),
    );

    // Second identical tile directly above it.
    sprite.render(
      canvas,
      position: Vector2(
        0,
        _scrollY - gameSize.y,
      ),
      size: Vector2(
        gameSize.x,
        gameSize.y + 2,
      ),
    );

    _drawVignette(canvas);
  }

  void _drawVignette(Canvas canvas) {
    final rect = Rect.fromLTWH(
      0,
      0,
      gameSize.x,
      gameSize.y,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0x30000000),
            Colors.transparent,
            Colors.transparent,
            Color(0x30000000),
          ],
          stops: [
            0.0,
            0.10,
            0.90,
            1.0,
          ],
        ).createShader(rect),
    );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x16000000),
            Colors.transparent,
            Colors.transparent,
            Color(0x38000000),
          ],
          stops: [
            0.0,
            0.18,
            0.72,
            1.0,
          ],
        ).createShader(rect),
    );
  }

  void _drawFallback(Canvas canvas) {
    final rect = Rect.fromLTWH(
      0,
      0,
      gameSize.x,
      gameSize.y,
    );

    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(
          0xFF3B3F43,
        ),
    );
  }
}