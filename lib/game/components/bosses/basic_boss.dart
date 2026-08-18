import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class BasicBoss extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<FlameGame> {
  BasicBoss({
    required Vector2 position,
    required this.onBossDefeated,
  }) : super(
    position: position,
    size: Vector2(110, 130),
    anchor: Anchor.center,
    priority: 20,
  );

  final void Function() onBossDefeated;

  static const double maxHealth = 1000;
  double health = maxHealth;

  late final RectangleComponent healthBackground;
  late final RectangleComponent healthBar;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());

    final image = await game.images.load(
      'bosses/level_1/boss_run.png',
    );

    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.12,
        textureSize: Vector2(256, 256),
        loop: true,
      ),
    );

    healthBackground = RectangleComponent(
      position: Vector2(5, -18),
      size: Vector2(100, 10),
      paint: Paint()..color = Colors.black54,
    );

    healthBar = RectangleComponent(
      position: Vector2(5, -18),
      size: Vector2(100, 10),
      paint: Paint()..color = Colors.redAccent,
    );

    add(healthBackground);
    add(healthBar);

    add(
      TextComponent(
        text: 'BOSS',
        position: Vector2(size.x / 2, -35),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void takeDamage(double damage) {
    health -= damage;

    if (health < 0) {
      health = 0;
    }

    healthBar.size.x = 100 * (health / maxHealth);

    if (health <= 0) {
      onBossDefeated();
      removeFromParent();
    }
  }
}