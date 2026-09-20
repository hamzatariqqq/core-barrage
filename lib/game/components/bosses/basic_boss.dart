import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../player/player_vehicle.dart';
import 'boss_projectile.dart';

enum BossMovementState {
  entering,
  fighting,
  charging,
  returning,
  dead,
}

class BasicBoss extends PositionComponent
    with CollisionCallbacks, HasGameReference<FlameGame> {
  BasicBoss({
    required Vector2 position,
    required this.level,
    required this.onDefeated,
  }) : super(
    position: position,
    size: Vector2(
      150,
      150,
    ),
    anchor: Anchor.center,
    priority: 120,
  ) {
    health = maxHealthValue;
  }

  final int level;

  final void Function() onDefeated;

  // ============================================================
  // BASE VALUES
  // ============================================================

  static const double maxHealth = 2200;

  late double health;

  double get maxHealthValue {
    switch (level) {
      case 1:
        return 1100;

      case 2:
        return 1250;

      case 3:
        return 1400;

      case 4:
        return 1550;

      case 5:
        return 1850;

      case 6:
        return 1950;

      case 7:
        return 2050;

      case 8:
        return 2150;

      case 9:
        return 2250;

      case 10:
        return 2550;

      case 11:
        return 2650;

      case 12:
        return 2775;

      case 13:
        return 2900;

      case 14:
        return 3050;

      case 15:
        return 3500;

      default:
        return maxHealth;
    }
  }

  double get _damageMultiplier {
    switch (level) {
      case 1:
        return 0.68;

      case 2:
        return 0.75;

      case 3:
        return 0.82;

      case 4:
        return 0.90;

      case 5:
        return 1.00;

      case 6:
        return 1.05;

      case 7:
        return 1.10;

      case 8:
        return 1.15;

      case 9:
        return 1.20;

      case 10:
        return 1.30;

      case 11:
        return 1.34;

      case 12:
        return 1.38;

      case 13:
        return 1.43;

      case 14:
        return 1.48;

      case 15:
        return 1.58;

      default:
        return 1.0;
    }
  }

  double get _fireRateMultiplier {
    switch (level) {
      case 1:
        return 1.28;

      case 2:
        return 1.20;

      case 3:
        return 1.14;

      case 4:
        return 1.08;

      case 5:
        return 1.02;

      case 6:
        return 0.98;

      case 7:
        return 0.95;

      case 8:
        return 0.92;

      case 9:
        return 0.89;

      case 10:
        return 0.85;

      case 11:
        return 0.82;

      case 12:
        return 0.79;

      case 13:
        return 0.76;

      case 14:
        return 0.73;

      case 15:
        return 0.68;

      default:
        return 1.0;
    }
  }

  double get _movementMultiplier {
    if (level <= 2) {
      return 0.82;
    }

    if (level <= 5) {
      return 0.90;
    }

    if (level <= 9) {
      return 1.00;
    }

    if (level <= 12) {
      return 1.08;
    }

    return 1.15;
  }

  bool _dead = false;

  BossMovementState _state =
      BossMovementState.entering;

  final Random _random = Random();

  double _time = 0;

  double _targetX = 0;

  double _fightY = 0;

  double _returnY = 0;

  double _chargeTimer = 0;

  double _nextCharge = 5.2;

  double _patrolTimer = 0;

  double _shootTimer = 0;

  double _nextShot = 1.25;

  int _shotCount = 0;

  double _contactCooldown = 0;

  bool _chargeDamageDone = false;

  bool get _isRaging =>
      health <= maxHealthValue * 0.50;

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _fightY =
        game.size.y * 0.29;

    _returnY = _fightY;

    _targetX =
        game.size.x / 2;

    _shootTimer =
    level == 1
        ? 1.25
        : 0.70;

    add(
      RectangleHitbox(
        position: Vector2(
          26,
          28,
        ),
        size: Vector2(
          size.x - 52,
          size.y - 48,
        ),
      ),
    );
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(
      double dt,
      ) {
    super.update(dt);

    if (_dead) {
      return;
    }

    _time += dt;

    if (_contactCooldown > 0) {
      _contactCooldown -= dt;
    }

    switch (_state) {
      case BossMovementState.entering:
        _updateEntering(dt);
        break;

      case BossMovementState.fighting:
        _updateFighting(dt);
        break;

      case BossMovementState.charging:
        _updateCharging(dt);
        break;

      case BossMovementState.returning:
        _updateReturning(dt);
        break;

      case BossMovementState.dead:
        break;
    }
  }

  // ============================================================
  // ENTER
  // ============================================================

  void _updateEntering(
      double dt,
      ) {
    position.y +=
        115 *
            _movementMultiplier *
            dt;

    if (position.y >= _fightY) {
      position.y = _fightY;

      _state =
          BossMovementState.fighting;

      _choosePatrolTarget();
    }
  }

  // ============================================================
  // FIGHT
  // ============================================================

  void _updateFighting(
      double dt,
      ) {
    _patrolTimer += dt;

    final difference =
        _targetX -
            position.x;

    if (difference.abs() > 3) {
      position.x +=
          difference.sign *
              58 *
              _movementMultiplier *
              dt;
    }

    if (_patrolTimer >
        (_isRaging
            ? 1.25
            : 1.7) ||
        difference.abs() < 4) {
      _patrolTimer = 0;

      _choosePatrolTarget();
    }

    position.y =
        _fightY +
            sin(_time * 1.4) * 7;

    // ----------------------------------------------------------
    // SHOOT
    // ----------------------------------------------------------

    _shootTimer += dt;

    if (_shootTimer >= _nextShot) {
      _shootTimer = 0;

      final baseShot =
      _isRaging
          ? 0.90
          : 1.35;

      _nextShot =
          (baseShot +
              _random.nextDouble() *
                  0.35) *
              _fireRateMultiplier;

      _shotCount++;

      // Spread attack appears later in game.
      if (level >= 5 &&
          _isRaging &&
          _shotCount % 3 == 0) {
        _fireSpread();
      } else {
        _fireAtPlayer();
      }
    }

    // ----------------------------------------------------------
    // CHARGE
    // ----------------------------------------------------------

    _chargeTimer += dt;

    if (_chargeTimer >= _nextCharge) {
      _chargeTimer = 0;

      double baseChargeDelay;

      if (level <= 2) {
        baseChargeDelay = 6.8;
      } else if (level <= 5) {
        baseChargeDelay = 6.0;
      } else if (level <= 9) {
        baseChargeDelay = 5.2;
      } else if (level <= 12) {
        baseChargeDelay = 4.6;
      } else {
        baseChargeDelay = 4.0;
      }

      _nextCharge =
          baseChargeDelay +
              _random.nextDouble() *
                  1.5;

      _chargeDamageDone = false;

      _state =
          BossMovementState.charging;
    }
  }

  // ============================================================
  // PROJECTILE
  // ============================================================

  void _fireAtPlayer() {
    final player =
    _findPlayer();

    final currentWorld =
        parent;

    if (player == null ||
        currentWorld == null) {
      return;
    }

    final origin =
    Vector2(
      position.x,
      position.y +
          size.y * 0.22,
    );

    final direction =
        player.position -
            origin;

    if (direction.length2 <= 0.001) {
      return;
    }

    final baseDamage =
    _isRaging
        ? 13.0
        : 10.0;

    currentWorld.add(
      BossProjectile(
        position:
        origin.clone(),
        direction:
        direction,
        damage:
        baseDamage *
            _damageMultiplier,
      ),
    );
  }

  // ============================================================
  // SPREAD
  // ============================================================

  void _fireSpread() {
    final player =
    _findPlayer();

    final currentWorld =
        parent;

    if (player == null ||
        currentWorld == null) {
      return;
    }

    final origin =
    Vector2(
      position.x,
      position.y +
          size.y * 0.22,
    );

    final baseDirection =
        player.position -
            origin;

    if (baseDirection.length2 <=
        0.001) {
      return;
    }

    baseDirection.normalize();

    const angles =
    <double>[
      -0.18,
      0.0,
      0.18,
    ];

    for (final angle in angles) {
      final cosA =
      cos(angle);

      final sinA =
      sin(angle);

      final direction =
      Vector2(
        baseDirection.x *
            cosA -
            baseDirection.y *
                sinA,
        baseDirection.x *
            sinA +
            baseDirection.y *
                cosA,
      );

      currentWorld.add(
        BossProjectile(
          position:
          origin.clone(),
          direction:
          direction,
          damage:
          8 *
              _damageMultiplier,
        ),
      );
    }
  }

  // ============================================================
  // CHARGE
  // ============================================================

  void _updateCharging(
      double dt,
      ) {
    final player =
    _findPlayer();

    if (player == null) {
      _state =
          BossMovementState.returning;

      return;
    }

    final maximumChargeY =
        game.size.y * 0.73;

    final wantedChargeY =
        player.position.y - 45;

    final targetY =
    wantedChargeY <
        maximumChargeY
        ? wantedChargeY
        : maximumChargeY;

    final target =
    Vector2(
      player.position.x,
      targetY,
    );

    final direction =
        target -
            position;

    if (direction.length > 12) {
      direction.normalize();

      position +=
          direction *
              235 *
              _movementMultiplier *
              dt;

      return;
    }

    if (!_chargeDamageDone) {
      _chargeDamageDone = true;

      final xDistance =
      (player.position.x -
          position.x)
          .abs();

      final yDistance =
      (player.position.y -
          position.y)
          .abs();

      if (xDistance < 78 &&
          yDistance < 150) {
        player.takeDamage(
          (18 *
              _damageMultiplier)
              .clamp(
            10.0,
            30.0,
          ),
        );
      }
    }

    _state =
        BossMovementState.returning;
  }

  // ============================================================
  // RETURN
  // ============================================================

  void _updateReturning(
      double dt,
      ) {
    final target =
    Vector2(
      game.size.x / 2,
      _returnY,
    );

    final direction =
        target -
            position;

    if (direction.length > 7) {
      direction.normalize();

      position +=
          direction *
              175 *
              _movementMultiplier *
              dt;

      return;
    }

    position = target;

    _state =
        BossMovementState.fighting;

    _choosePatrolTarget();

    _shootTimer = 0;
  }

  // ============================================================
  // PATROL
  // ============================================================

  void _choosePatrolTarget() {
    final left =
        game.size.x * 0.30;

    final right =
        game.size.x * 0.70;

    _targetX =
        left +
            _random.nextDouble() *
                (right - left);
  }

  // ============================================================
  // PLAYER
  // ============================================================

  PlayerVehicle? _findPlayer() {
    final currentWorld =
        parent;

    if (currentWorld == null) {
      return null;
    }

    final players =
    currentWorld.children
        .whereType<PlayerVehicle>()
        .where(
          (player) =>
      player.isMounted,
    );

    if (players.isEmpty) {
      return null;
    }

    return players.first;
  }

  // ============================================================
  // COLLISION
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

    if (_dead ||
        _contactCooldown > 0) {
      return;
    }

    if (other is PlayerVehicle) {
      final baseDamage =
      _state ==
          BossMovementState
              .charging
          ? 22.0
          : 9.0;

      other.takeDamage(
        baseDamage *
            _damageMultiplier,
      );

      _contactCooldown = 0.8;

      _chargeDamageDone = true;
    }
  }

  // ============================================================
  // DAMAGE
  // ============================================================

  void takeDamage(
      double damage,
      ) {
    if (_dead ||
        damage <= 0) {
      return;
    }

    health -= damage;

    if (health <= 0) {
      health = 0;

      _die();
    }
  }

  // ============================================================
  // DEATH
  // ============================================================

  void _die() {
    if (_dead) {
      return;
    }

    _dead = true;

    _state =
        BossMovementState.dead;

    onDefeated();

    removeFromParent();
  }
}