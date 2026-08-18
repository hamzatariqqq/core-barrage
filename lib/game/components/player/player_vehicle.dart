import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../bullets/player_bullet.dart';
import '../enemies/basic_enemy.dart';
import 'player_health.dart';

class PlayerVehicle extends SpriteComponent
    with DragCallbacks, CollisionCallbacks, HasGameReference<FlameGame> {
  PlayerVehicle({
    required Vector2 position,
    required this.minX,
    required this.maxX,
    required this.onPlayerDead,
  }) : super(
    position: position,
    size: Vector2(64, 96),
    anchor: Anchor.center,
    priority: 20,
  );

  final double minX;
  final double maxX;
  final VoidCallback onPlayerDead;

  int armyCount = 1;

  double _shootTimer = 0;
  bool _dead = false;

  final PlayerHealth health = PlayerHealth(maxHealth: 100);

  late final TextComponent armyText;
  late final TextComponent healthText;

  late final Sprite _muzzleFlashSprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final vehicleImage = await game.images.load(
      'player/vehicle/blue_vehicle.png',
    );

    sprite = Sprite(vehicleImage);

    final muzzleImage = await game.images.load(
      'effects/combat/muzzle_flash.png',
    );

    _muzzleFlashSprite = Sprite(muzzleImage);

    add(
      RectangleHitbox(
        size: Vector2(50, 78),
        position: Vector2(7, 9),
      ),
    );

    // HP above vehicle
    healthText = TextComponent(
      text: 'HP ${health.currentHealth.toInt()}',
      position: Vector2(
        size.x / 2,
        -10,
      ),
      anchor: Anchor.bottomCenter,
      priority: 100,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(healthText);

    // Army count below vehicle
    armyText = TextComponent(
      text: 'ARMY: $armyCount',
      position: Vector2(
        size.x / 2,
        size.y + 5,
      ),
      anchor: Anchor.topCenter,
      priority: 100,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(armyText);
  }

  void addSoldiers(int amount) {
    armyCount += amount;
    armyText.text = 'ARMY: $armyCount';
  }

  void multiplyArmy(int multiplier) {
    armyCount *= multiplier;
    armyText.text = 'ARMY: $armyCount';
  }

  void takeDamage(double damage) {
    if (_dead) return;

    health.takeDamage(damage);

    healthText.text =
    'HP ${health.currentHealth.toInt()}';

    if (health.isDead) {
      _dead = true;

      onPlayerDead();

      removeFromParent();
    }
  }

  int get _fireStreams {
    if (armyCount >= 100) return 5;
    if (armyCount >= 50) return 4;
    if (armyCount >= 25) return 3;
    if (armyCount >= 10) return 2;

    return 1;
  }

  void _showMuzzleFlash(double offsetX) {
    final flash = SpriteComponent(
      sprite: _muzzleFlashSprite,
      position: Vector2(
        position.x + offsetX,
        position.y - size.y / 2 - 5,
      ),

      // Smaller so multiple flashes don't merge together
      size: Vector2(11, 18),

      anchor: Anchor.center,
      priority: 50,
    );

    parent?.add(flash);

    Future.delayed(
      const Duration(milliseconds: 60),
          () {
        if (flash.isMounted) {
          flash.removeFromParent();
        }
      },
    );
  }

  void _shoot() {
    final streams = _fireStreams;

    // More space between weapon streams
    const spacing = 18.0;

    final totalWidth =
        (streams - 1) * spacing;

    for (int i = 0; i < streams; i++) {
      final offsetX =
          (i * spacing) - (totalWidth / 2);

      _showMuzzleFlash(offsetX);

      parent?.add(
        PlayerBullet(
          position: Vector2(
            position.x + offsetX,
            position.y - size.y / 2 - 5,
          ),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_dead) return;

    _shootTimer += dt;

    if (_shootTimer >= 0.35) {
      _shootTimer = 0;
      _shoot();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(
      intersectionPoints,
      other,
    );

    if (other is BasicEnemy) {
      takeDamage(20);
      other.removeFromParent();
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position.x += event.localDelta.x;

    position.x =
        position.x.clamp(minX, maxX);
  }
}