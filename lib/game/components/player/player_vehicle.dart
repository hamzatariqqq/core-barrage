import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../app/progression/game_progress.dart';

import '../bullets/player_bullet.dart';
import '../enemies/basic_enemy.dart';

import 'blue_soldier.dart';
import 'player_health.dart';

class PlayerVehicle extends SpriteComponent
    with
        DragCallbacks,
        CollisionCallbacks,
        HasGameReference<FlameGame> {
  PlayerVehicle({
    required Vector2 position,
    required this.minX,
    required this.maxX,
    required this.onPlayerDead,
  }) : super(
    position: position,
    size: Vector2(
      72,
      104,
    ),
    anchor: Anchor.center,
    priority: 20,
  );

  final double minX;
  final double maxX;

  final VoidCallback onPlayerDead;

  final GameProgress progress =
      GameProgress.instance;

  // ============================================================
  // ARMY
  // ============================================================

  final List<BlueSoldier> _soldiers = [];

  late int armyCount;

  // ============================================================
  // HEALTH
  // ============================================================

  late final PlayerHealth health;

  bool _dead = false;

  // ============================================================
  // VEHICLE FIRING
  // ============================================================

  double _shootTimer = 0;

  double _gateFirepowerMultiplier = 1.0;

  late final Sprite _muzzleFlashSprite;

  // ============================================================
  // SQUAD FIRING
  // ============================================================

  double _squadVolleyTimer = 0;

  int _squadVolleyIndex = 0;

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    armyCount =
        progress.startingArmy;

    health =
        PlayerHealth(
          maxHealth:
          progress.maxHealth,
        );

    final vehicleImage =
    await game.images.load(
      'player/vehicle/blue_vehicle.png',
    );

    sprite =
        Sprite(
          vehicleImage,
        );

    final muzzleImage =
    await game.images.load(
      'effects/combat/muzzle_flash.png',
    );

    _muzzleFlashSprite =
        Sprite(
          muzzleImage,
        );

    add(
      RectangleHitbox(
        position:
        Vector2(
          10,
          12,
        ),
        size:
        Vector2(
          52,
          80,
        ),
      ),
    );

    _syncArmyVisuals();
  }

  // ============================================================
  // VISIBLE SOLDIER LIMIT
  //
  // Mathematical army can reach 250.
  //
  // We deliberately render only a controlled tactical squad.
  // ============================================================

  int get _visibleSoldierTarget {
    if (armyCount <= 5) {
      return armyCount;
    }

    if (armyCount <= 8) {
      return 6;
    }

    if (armyCount <= 15) {
      return 8;
    }

    if (armyCount <= 30) {
      return 10;
    }

    if (armyCount <= 60) {
      return 12;
    }

    return 14;
  }

  // ============================================================
  // CREATE / REMOVE SOLDIER VISUALS
  // ============================================================

  void _syncArmyVisuals() {
    if (_dead) {
      return;
    }

    final target =
        _visibleSoldierTarget;

    while (_soldiers.length <
        target) {
      final soldier =
      BlueSoldier(
        position:
        position.clone(),
        onKilled:
        _onSoldierKilled,
      );

      _soldiers.add(
        soldier,
      );

      parent?.add(
        soldier,
      );
    }

    while (_soldiers.length >
        target) {
      final soldier =
      _soldiers.removeLast();

      soldier.removeFromParent();
    }

    _updateArmyFormation();
  }

  // ============================================================
  // SOLDIER LOST
  // ============================================================

  void _onSoldierKilled(
      BlueSoldier soldier,
      ) {
    _soldiers.remove(
      soldier,
    );

    if (armyCount > 1) {
      armyCount--;
    }

    _syncArmyVisuals();
  }

  // ============================================================
  // TACTICAL FORMATION
  //
  // Soldiers stay ahead of the vehicle.
  // Formation grows naturally instead of becoming a huge block.
  // ============================================================

  void _updateArmyFormation() {
    if (_soldiers.isEmpty) {
      return;
    }

    const rowSizes = [
      3,
      4,
      4,
      3,
    ];

    const horizontalSpacing =
    31.0;

    const verticalSpacing =
    34.0;

    const firstRowDistance =
    83.0;

    int soldierIndex = 0;

    for (int row = 0;
    row < rowSizes.length;
    row++) {
      if (soldierIndex >=
          _soldiers.length) {
        break;
      }

      final remaining =
          _soldiers.length -
              soldierIndex;

      final count =
      min(
        rowSizes[row],
        remaining,
      );

      final rowWidth =
          (count - 1) *
              horizontalSpacing;

      for (int column = 0;
      column < count;
      column++) {
        if (soldierIndex >=
            _soldiers.length) {
          break;
        }

        var xOffset =
            column *
                horizontalSpacing -
                rowWidth / 2;

        // Small stagger makes formation less robotic.
        if (row.isOdd) {
          xOffset += 4;
        }

        final yOffset =
            firstRowDistance +
                row *
                    verticalSpacing;

        final target =
        Vector2(
          position.x +
              xOffset,
          position.y -
              yOffset,
        );

        _soldiers[soldierIndex]
            .setFormationPosition(
          target,
        );

        soldierIndex++;
      }
    }
  }

  // ============================================================
  // SQUAD VOLLEY INTERVAL
  //
  // Army size improves squad pressure without spawning
  // hundreds of bullets.
  // ============================================================

  double get _squadVolleyInterval {
    if (armyCount >= 100) {
      return .72;
    }

    if (armyCount >= 60) {
      return .80;
    }

    if (armyCount >= 30) {
      return .90;
    }

    if (armyCount >= 15) {
      return 1.02;
    }

    return 1.15;
  }

  // ============================================================
  // SOLDIERS PER VOLLEY
  // ============================================================

  int get _soldiersPerVolley {
    if (_soldiers.isEmpty) {
      return 0;
    }

    if (armyCount >= 100) {
      return min(
        6,
        _soldiers.length,
      );
    }

    if (armyCount >= 60) {
      return min(
        5,
        _soldiers.length,
      );
    }

    if (armyCount >= 30) {
      return min(
        4,
        _soldiers.length,
      );
    }

    if (armyCount >= 15) {
      return min(
        3,
        _soldiers.length,
      );
    }

    return min(
      2,
      _soldiers.length,
    );
  }

  // ============================================================
  // TACTICAL SQUAD VOLLEY
  //
  // Replaces old electricity system.
  //
  // Soldiers now:
  // - recoil
  // - fire real bullets
  // - rotate firing members
  // - do not create electric beams
  // ============================================================

  void _fireSquadVolley() {
    if (_dead ||
        _soldiers.isEmpty) {
      return;
    }

    final currentWorld =
        parent;

    if (currentWorld == null) {
      return;
    }

    final enemies =
    currentWorld.children
        .whereType<BasicEnemy>()
        .where(
          (enemy) =>
      enemy.isMounted &&
          enemy.position.y <
              position.y,
    )
        .toList();

    if (enemies.isEmpty) {
      return;
    }

    const attackRange =
    430.0;

    final nearbyEnemies =
    enemies.where(
          (enemy) {
        return enemy.position
            .distanceTo(
          position,
        ) <=
            attackRange;
      },
    ).toList();

    if (nearbyEnemies.isEmpty) {
      return;
    }

    nearbyEnemies.sort(
          (a, b) {
        final distanceA =
        a.position.distanceTo(
          position,
        );

        final distanceB =
        b.position.distanceTo(
          position,
        );

        return distanceA.compareTo(
          distanceB,
        );
      },
    );

    final count =
        _soldiersPerVolley;

    if (count <= 0) {
      return;
    }

    for (int i = 0;
    i < count;
    i++) {
      final index =
          (_squadVolleyIndex + i) %
              _soldiers.length;

      final soldier =
      _soldiers[index];

      if (!soldier.isMounted) {
        continue;
      }

      soldier.fire();

      // Tiny muzzle effect from soldier weapon.
      parent?.add(
        _SquadMuzzleFlash(
          position:
          Vector2(
            soldier.position.x,
            soldier.position.y -
                13,
          ),
        ),
      );

      // Real projectile instead of direct/electric damage.
      parent?.add(
        PlayerBullet(
          position:
          Vector2(
            soldier.position.x,
            soldier.position.y -
                15,
          ),
        ),
      );
    }

    _squadVolleyIndex +=
        count;

    if (_squadVolleyIndex >=
        _soldiers.length) {
      _squadVolleyIndex %=
          _soldiers.length;
    }
  }

  // ============================================================
  // ADD SOLDIERS
  // ============================================================

  void addSoldiers(
      int amount,
      ) {
    if (_dead ||
        amount <= 0) {
      return;
    }

    armyCount += amount;

    armyCount =
        armyCount.clamp(
          1,
          250,
        );

    _syncArmyVisuals();
  }

  // ============================================================
  // MULTIPLY ARMY
  // ============================================================

  void multiplyArmy(
      int multiplier,
      ) {
    if (_dead ||
        multiplier <= 1) {
      return;
    }

    armyCount *=
        multiplier;

    armyCount =
        armyCount.clamp(
          1,
          250,
        );

    _syncArmyVisuals();
  }

  // ============================================================
  // LOSE SOLDIERS
  // ============================================================

  void loseSoldiers(
      int amount,
      ) {
    if (_dead ||
        amount <= 0) {
      return;
    }

    armyCount -= amount;

    if (armyCount < 1) {
      armyCount = 1;
    }

    _syncArmyVisuals();
  }

  // ============================================================
  // GATE COMPATIBILITY
  // ============================================================

  void addArmy(
      int amount,
      ) {
    if (_dead ||
        amount <= 0) {
      return;
    }

    addSoldiers(
      amount,
    );
  }

  void removeArmy(
      int amount,
      ) {
    if (_dead ||
        amount <= 0) {
      return;
    }

    loseSoldiers(
      amount,
    );
  }

  void applyFirepowerMultiplier(
      double multiplier,
      ) {
    if (_dead ||
        multiplier <= 1.0) {
      return;
    }

    _gateFirepowerMultiplier =
        (
            _gateFirepowerMultiplier *
                multiplier
        ).clamp(
          1.0,
          5.0,
        );
  }

  // ============================================================
  // PLAYER DAMAGE
  // ============================================================

  void takeDamage(
      double damage,
      ) {
    if (_dead) {
      return;
    }

    health.takeDamage(
      damage,
    );

    if (!health.isDead) {
      return;
    }

    _dead = true;

    for (final soldier
    in _soldiers) {
      soldier.removeFromParent();
    }

    _soldiers.clear();

    onPlayerDead();

    removeFromParent();
  }

  // ============================================================
  // VEHICLE FIRE STREAM COUNT
  // ============================================================

  int get _fireStreams {
    if (armyCount >= 120) {
      return 5;
    }

    if (armyCount >= 70) {
      return 4;
    }

    if (armyCount >= 35) {
      return 3;
    }

    if (armyCount >= 15) {
      return 2;
    }

    return 1;
  }

  // ============================================================
  // VEHICLE FIRE RATE
  // ============================================================

  double get _fireInterval {
    double interval;

    if (armyCount >= 120) {
      interval = .18;
    } else if (armyCount >=
        70) {
      interval = .21;
    } else if (armyCount >=
        35) {
      interval = .25;
    } else if (armyCount >=
        15) {
      interval = .29;
    } else {
      interval = .34;
    }

    return interval /
        progress
            .fireRateMultiplier /
        _gateFirepowerMultiplier;
  }

  // ============================================================
  // VEHICLE MUZZLE FLASH
  // ============================================================

  void _showMuzzleFlash(
      double offsetX,
      ) {
    final flash =
    SpriteComponent(
      sprite:
      _muzzleFlashSprite,
      position:
      Vector2(
        position.x +
            offsetX,
        position.y -
            size.y / 2 -
            6,
      ),
      size:
      Vector2(
        12,
        20,
      ),
      anchor:
      Anchor.center,
      priority: 80,
    );

    flash.add(
      RemoveEffect(
        delay: .055,
      ),
    );

    parent?.add(
      flash,
    );
  }

  // ============================================================
  // VEHICLE SHOOT
  // ============================================================

  void _shoot() {
    if (_dead) {
      return;
    }

    final streams =
        _fireStreams;

    const spacing =
    19.0;

    final width =
        (streams - 1) *
            spacing;

    for (int i = 0;
    i < streams;
    i++) {
      final offsetX =
          i * spacing -
              width / 2;

      _showMuzzleFlash(
        offsetX,
      );

      parent?.add(
        PlayerBullet(
          position:
          Vector2(
            position.x +
                offsetX,
            position.y -
                size.y / 2 -
                6,
          ),
        ),
      );
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(
      double dt,
      ) {
    super.update(
      dt,
    );

    if (_dead) {
      return;
    }

    // Main tank weapon.
    _shootTimer += dt;

    if (_shootTimer >=
        _fireInterval) {
      _shootTimer = 0;

      _shoot();
    }

    // Tactical squad fire.
    _squadVolleyTimer += dt;

    if (_squadVolleyTimer >=
        _squadVolleyInterval) {
      _squadVolleyTimer = 0;

      _fireSquadVolley();
    }

    _updateArmyFormation();
  }

  // ============================================================
  // ENEMY COLLISION
  // ============================================================

  @override
  void onCollisionStart(
      Set<Vector2>
      intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(
      intersectionPoints,
      other,
    );

    if (_dead) {
      return;
    }

    if (other
    is BasicEnemy) {
      if (armyCount > 1) {
        loseSoldiers(
          1,
        );
      } else {
        takeDamage(
          20,
        );
      }

      other.removeFromParent();
    }
  }

  // ============================================================
  // DRAG
  // ============================================================

  @override
  void onDragUpdate(
      DragUpdateEvent event,
      ) {
    if (_dead) {
      return;
    }

    position.x +=
        event.localDelta.x;

    position.x =
        position.x.clamp(
          minX,
          maxX,
        );

    _updateArmyFormation();
  }

  // ============================================================
  // REMOVE
  // ============================================================

  @override
  void onRemove() {
    for (final soldier
    in _soldiers) {
      soldier.removeFromParent();
    }

    _soldiers.clear();

    super.onRemove();
  }
}

// ============================================================
// SMALL SOLDIER MUZZLE FLASH
//
// Lightweight procedural effect.
// No extra asset is required.
// ============================================================

class _SquadMuzzleFlash
    extends PositionComponent {
  _SquadMuzzleFlash({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2.all(
      18,
    ),
    anchor: Anchor.center,
    priority: 90,
  );

  double _life = 0;

  static const double
  _duration = .09;

  @override
  void update(
      double dt,
      ) {
    super.update(
      dt,
    );

    _life += dt;

    if (_life >=
        _duration) {
      removeFromParent();
    }
  }

  @override
  void render(
      Canvas canvas,
      ) {
    super.render(
      canvas,
    );

    final progress =
    (_life / _duration)
        .clamp(
      0.0,
      1.0,
    );

    final alpha =
        1.0 - progress;

    final center =
    Offset(
      size.x / 2,
      size.y / 2,
    );

    canvas.drawCircle(
      center,
      7 * alpha,
      Paint()
        ..color =
        const Color(
          0xFFFFB52D,
        ).withValues(
          alpha: alpha,
        ),
    );

    canvas.drawCircle(
      center,
      3.5 * alpha,
      Paint()
        ..color =
        Colors.white
            .withValues(
          alpha: alpha,
        ),
    );
  }
}