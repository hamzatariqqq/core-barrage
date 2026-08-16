import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../bullets/player_bullet.dart';
import 'blue_soldier.dart';

class PlayerVehicle extends RectangleComponent
    with DragCallbacks, CollisionCallbacks {
  PlayerVehicle({
    required Vector2 position,
    required this.minX,
    required this.maxX,
  }) : super(
    position: position,
    size: Vector2(60, 80),
    anchor: Anchor.center,
    paint: Paint()..color = const Color(0xFF238BFF),
  );

  final double minX;
  final double maxX;

  int armyCount = 1;
  double _shootTimer = 0;

  late final TextComponent armyText;
  final List<BlueSoldier> _soldiers = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());

    armyText = TextComponent(
      text: 'ARMY: $armyCount',
      position: Vector2(size.x / 2, size.y + 5),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(armyText);

    _refreshArmy();
  }

  void addSoldiers(int amount) {
    armyCount += amount;
    armyText.text = 'ARMY: $armyCount';
    _refreshArmy();
  }

  void multiplyArmy(int multiplier) {
    armyCount *= multiplier;
    armyText.text = 'ARMY: $armyCount';
    _refreshArmy();
  }

  void _refreshArmy() {
    for (final soldier in _soldiers) {
      soldier.removeFromParent();
    }

    _soldiers.clear();

    final visibleCount = armyCount.clamp(0, 20);

    for (int i = 0; i < visibleCount; i++) {
      final row = i ~/ 5;
      final column = i % 5;

      final soldier = BlueSoldier(
        position: Vector2(
          2 + (column * 14),
          -25 - (row * 20),
        ),
      );

      _soldiers.add(soldier);
      add(soldier);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _shootTimer += dt;

    if (_shootTimer >= 0.35) {
      _shootTimer = 0;

      parent?.add(
        PlayerBullet(
          position: Vector2(
            position.x,
            position.y - size.y / 2,
          ),
        ),
      );
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position.x += event.localDelta.x;
    position.x = position.x.clamp(minX, maxX);
  }
}