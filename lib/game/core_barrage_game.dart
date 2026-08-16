import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/gates/army_gate.dart';
import 'components/player/player_vehicle.dart';
import 'systems/spawning/enemy_spawner.dart';

class CoreBarrageGame extends FlameGame with HasCollisionDetection {
  @override
  Color backgroundColor() => const Color(0xFF101827);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    const roadMargin = 40.0;
    const playerHalfWidth = 30.0;

    add(
      RectangleComponent(
        position: Vector2(roadMargin, 0),
        size: Vector2(
          size.x - (roadMargin * 2),
          size.y,
        ),
        paint: Paint()..color = const Color(0xFF26364A),
      ),
    );

    add(
      ArmyGate(
        position: Vector2(size.x * 0.35, 180),
        value: 10,
        type: ArmyGateType.add,
      ),
    );

    add(
      ArmyGate(
        position: Vector2(size.x * 0.65, 180),
        value: 2,
        type: ArmyGateType.multiply,
      ),
    );

    add(
      PlayerVehicle(
        position: Vector2(size.x / 2, size.y - 100),
        minX: roadMargin + playerHalfWidth,
        maxX: size.x - roadMargin - playerHalfWidth,
      ),
    );

    add(
      EnemySpawner(
        gameSize: size,
      ),
    );
  }
}