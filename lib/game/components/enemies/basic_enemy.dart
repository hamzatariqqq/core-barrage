import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'enemy_config.dart';

class BasicEnemy extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<FlameGame> {
  BasicEnemy({
    required Vector2 position,
    required EnemyConfig config,
  })  : health = config.health,
        speed = config.speed,
        super(
        position: position,
        size: Vector2(42, 52),
        anchor: Anchor.center,
        priority: 10,
      );

  double health;
  final double speed;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());

    final image = await game.images.load(
      'enemies/basic/red_enemy_run.png',
    );

    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.10,
        textureSize: Vector2(256, 256),
        loop: true,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += speed * dt;

    if (position.y > 1000) {
      removeFromParent();
    }
  }

  void takeDamage(double damage) {
    health -= damage;

    if (health <= 0) {
      removeFromParent();
    }
  }
}