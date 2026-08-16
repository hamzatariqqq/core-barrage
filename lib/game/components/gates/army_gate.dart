import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../player/player_vehicle.dart';

enum ArmyGateType {
  add,
  multiply,
}

class ArmyGate extends RectangleComponent with CollisionCallbacks {
  ArmyGate({
    required Vector2 position,
    required this.value,
    required this.type,
  }) : super(
    position: position,
    size: Vector2(100, 60),
    anchor: Anchor.center,
    paint: Paint()..color = const Color(0xFF36D17D),
  );

  final int value;
  final ArmyGateType type;

  bool _used = false;
  static const double speed = 100;

  String get label {
    if (type == ArmyGateType.add) {
      return '+$value SOLDIERS';
    }

    return 'x$value ARMY';
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox());

    add(
      TextComponent(
        text: label,
        position: size / 2,
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

  @override
  void update(double dt) {
    super.update(dt);

    position.y += speed * dt;

    if (position.y > 1000) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayerVehicle && !_used) {
      _used = true;

      if (type == ArmyGateType.add) {
        other.addSoldiers(value);
      } else {
        other.multiplyArmy(value);
      }

      removeFromParent();
    }
  }
}