import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../services/game_audio.dart';

import '../player/blue_soldier.dart';
import '../player/player_vehicle.dart';

import 'enemy_attack_warning.dart';
import 'enemy_config.dart';
import 'enemy_death_effect.dart';
import 'enemy_projectile.dart';

enum EnemyType {
  normal,
  runner,
  heavy,
}

class BasicEnemy extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<FlameGame> {
  BasicEnemy({
    required Vector2 position,
    required EnemyConfig config,
    this.type = EnemyType.normal,
    this.imagePath,
  })  : health = config.health,
        maxHealth = config.health,
        speed = config.speed,
        super(
        position: position,
        size: _sizeForType(type),

        // VERY IMPORTANT:
        // Position now represents the enemy's FEET.
        anchor: Anchor.bottomCenter,

        priority: 10,
      );

  final EnemyType type;
  final String? imagePath;

  final GameAudio audio = GameAudio.instance;

  double health;
  final double maxHealth;
  final double speed;

  bool isFrozen = false;
  bool _dead = false;

  final Random _random = Random();

  double _hitFlashTimer = 0;
  static const double _hitFlashDuration = 0.10;

  double _shootTimer = 0;
  double _warningTimer = 0;
  bool _warningActive = false;

  // ============================================================
  // SIZE
  // ============================================================

  static Vector2 _sizeForType(
      EnemyType type,
      ) {
    switch (type) {
      case EnemyType.runner:
        return Vector2(
          58,
          78,
        );

      case EnemyType.heavy:
        return Vector2(
          78,
          104,
        );

      case EnemyType.normal:
        return Vector2(
          66,
          90,
        );
    }
  }

  // ============================================================
  // RUN SPEED
  // ============================================================

  double get _runStepTime {
    switch (type) {
      case EnemyType.runner:
        return 0.060;

      case EnemyType.heavy:
        return 0.105;

      case EnemyType.normal:
        return 0.080;
    }
  }

  // ============================================================
  // FIRE RATE
  // ============================================================

  double get _fireInterval {
    switch (type) {
      case EnemyType.runner:
        return 2.8;

      case EnemyType.heavy:
        return 1.8;

      case EnemyType.normal:
        return 2.35;
    }
  }

  double get _projectileDamage {
    switch (type) {
      case EnemyType.runner:
        return 6;

      case EnemyType.heavy:
        return 14;

      case EnemyType.normal:
        return 9;
    }
  }

  double get _warningDuration {
    switch (type) {
      case EnemyType.runner:
        return 0.30;

      case EnemyType.heavy:
        return 0.52;

      case EnemyType.normal:
        return 0.40;
    }
  }

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await _loadAnimation();

    // ----------------------------------------------------------
    // HITBOX
    // ----------------------------------------------------------

    final Vector2 hitboxSize;

    switch (type) {
      case EnemyType.runner:
        hitboxSize = Vector2(
          29,
          46,
        );
        break;

      case EnemyType.heavy:
        hitboxSize = Vector2(
          43,
          64,
        );
        break;

      case EnemyType.normal:
        hitboxSize = Vector2(
          35,
          54,
        );
        break;
    }

    add(
      RectangleHitbox(
        position: Vector2(
          (size.x - hitboxSize.x) / 2,
          size.y - hitboxSize.y,
        ),
        size: hitboxSize,
      ),
    );

    _shootTimer =
        _random.nextDouble() *
            _fireInterval;

    _updatePerspective();
  }

  // ============================================================
  // LOAD ANIMATION
  // ============================================================

  Future<void> _loadAnimation() async {
    if (imagePath != null &&
        imagePath!.isNotEmpty) {
      await _loadLevel2Animation(
        imagePath!,
      );

      return;
    }

    await _loadOriginalAnimation();
  }

  // ============================================================
  // LEVEL 2 FRONT RUNNING SHEET
  //
  // 4 columns
  // 2 rows
  // 8 frames
  // ============================================================

  Future<void> _loadLevel2Animation(
      String path,
      ) async {
    final image =
    await game.images.load(
      path,
    );

    final frameWidth =
        image.width / 4;

    final frameHeight =
        image.height / 2;

    final List<Sprite> frames =
    [];

    for (int row = 0;
    row < 2;
    row++) {
      for (int column = 0;
      column < 4;
      column++) {
        frames.add(
          Sprite(
            image,
            srcPosition: Vector2(
              column *
                  frameWidth,
              row *
                  frameHeight,
            ),
            srcSize: Vector2(
              frameWidth,
              frameHeight,
            ),
          ),
        );
      }
    }

    animation =
        SpriteAnimation.spriteList(
          frames,
          stepTime:
          _runStepTime,
          loop: true,
        );
  }

  // ============================================================
  // ORIGINAL ENEMY
  // ============================================================

  Future<void> _loadOriginalAnimation() async {
    final image =
    await game.images.load(
      'enemies/basic/red_enemy_run.png',
    );

    animation =
        SpriteAnimation.fromFrameData(
          image,
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime:
            _runStepTime,
            textureSize:
            Vector2(
              256,
              256,
            ),
            loop: true,
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
    super.update(
      dt,
    );

    if (_dead) {
      return;
    }

    if (_hitFlashTimer > 0) {
      _hitFlashTimer -= dt;

      if (_hitFlashTimer < 0) {
        _hitFlashTimer = 0;
      }
    }

    if (isFrozen) {
      return;
    }

    // ==========================================================
    // ACTUAL ROAD MOVEMENT
    //
    // No fake bobbing.
    // No floating sine movement.
    // No side-to-side flying.
    //
    // The feet move down the road naturally.
    // ==========================================================

    position.y +=
        _movementSpeed *
            dt;

    _updatePerspective();

    // ==========================================================
    // ATTACK SYSTEM
    // ==========================================================

    if (_warningActive) {
      _warningTimer += dt;

      if (_warningTimer >=
          _warningDuration) {
        _warningTimer = 0;
        _warningActive = false;

        _fireProjectile();
      }

      return;
    }

    _shootTimer += dt;

    if (_shootTimer >=
        _fireInterval) {
      _shootTimer = 0;

      _startAttackWarning();
    }

    if (position.y >
        game.size.y + 120) {
      removeFromParent();
    }
  }

  // ============================================================
  // PERSPECTIVE
  //
  // Far enemy = small
  // Near enemy = large
  //
  // Because anchor = bottomCenter,
  // boots remain attached to road.
  // ============================================================

  void _updatePerspective() {
    final gameHeight =
        game.size.y;

    final horizon =
        gameHeight *
            0.10;

    final playerArea =
        gameHeight *
            0.88;

    final raw =
        (position.y - horizon) /
            (playerArea - horizon);

    final progress =
    raw
        .clamp(
      0.0,
      1.0,
    )
        .toDouble();

    final curved =
    pow(
      progress,
      1.35,
    ).toDouble();

    double minimumScale;
    double maximumScale;

    switch (type) {
      case EnemyType.runner:
        minimumScale = 0.46;
        maximumScale = 1.00;
        break;

      case EnemyType.heavy:
        minimumScale = 0.50;
        maximumScale = 1.08;
        break;

      case EnemyType.normal:
        minimumScale = 0.48;
        maximumScale = 1.04;
        break;
    }

    final enemyScale =
        minimumScale +
            (maximumScale -
                minimumScale) *
                curved;

    scale.setAll(
      enemyScale,
    );

    priority =
        20 +
            (progress * 200)
                .round();
  }

  // ============================================================
  // MOVEMENT SPEED
  //
  // Slightly faster as they get closer.
  // This gives road-depth feeling.
  // ============================================================

  double get _movementSpeed {
    final gameHeight =
        game.size.y;

    final horizon =
        gameHeight *
            0.10;

    final playerArea =
        gameHeight *
            0.88;

    final raw =
        (position.y - horizon) /
            (playerArea - horizon);

    final progress =
    raw
        .clamp(
      0.0,
      1.0,
    )
        .toDouble();

    double multiplier =
        0.78 +
            progress *
                0.38;

    switch (type) {
      case EnemyType.runner:
        multiplier *=
        1.10;
        break;

      case EnemyType.heavy:
        multiplier *=
        0.90;
        break;

      case EnemyType.normal:
        break;
    }

    return speed *
        multiplier;
  }

  // ============================================================
  // ATTACK WARNING
  // ============================================================

  void _startAttackWarning() {
    if (_dead ||
        isFrozen) {
      return;
    }

    final player =
    _findPlayer();

    if (player == null) {
      return;
    }

    if (position.y <
        game.size.y *
            0.20 ||
        position.y >
            game.size.y *
                0.72) {
      return;
    }

    _warningActive =
    true;

    _warningTimer =
    0;

    parent?.add(
      EnemyAttackWarning(
        position: Vector2(
          position.x,
          position.y -
              size.y *
                  0.80,
        ),
      ),
    );
  }

  // ============================================================
  // SHOOT
  // ============================================================

  void _fireProjectile() {
    if (_dead ||
        isFrozen) {
      return;
    }

    final player =
    _findPlayer();

    if (player == null ||
        !player.isMounted) {
      return;
    }

    final direction =
        player.position -
            position;

    parent?.add(
      EnemyProjectile(
        position: Vector2(
          position.x,
          position.y -
              size.y *
                  0.40,
        ),
        direction:
        direction,
        damage:
        _projectileDamage,
      ),
    );
  }

  // ============================================================
  // PLAYER
  // ============================================================

  PlayerVehicle? _findPlayer() {
    final currentWorld =
        parent;

    if (currentWorld ==
        null) {
      return null;
    }

    final players =
    currentWorld.children
        .whereType<
        PlayerVehicle>()
        .where(
          (
          player,
          ) =>
      player.isMounted,
    );

    if (players.isEmpty) {
      return null;
    }

    return players.first;
  }

  // ============================================================
  // FREEZE
  // ============================================================

  void setFrozen(
      bool value,
      ) {
    if (_dead) {
      return;
    }

    isFrozen = value;

    animationTicker
        ?.paused = value;

    if (value) {
      _warningActive =
      false;

      _warningTimer = 0;
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

    if (health < 0) {
      health = 0;
    }

    unawaited(
      audio.enemyHit(),
    );

    _hitFlashTimer =
        _hitFlashDuration;

    parent?.add(
      EnemyDamageNumber(
        position: Vector2(
          position.x,
          position.y -
              size.y,
        ),
        damage:
        damage.round(),
        critical:
        damage >= 100,
      ),
    );

    if (health <= 0) {
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

    unawaited(
      audio.enemyDestroy(),
    );

    parent?.add(
      EnemyDeathEffect(
        position:
        position.clone(),
      ),
    );

    removeFromParent();
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

    if (_dead) {
      return;
    }

    if (other
    is BlueSoldier) {
      other.hitByEnemy();

      _die();
    }
  }

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(
      Canvas canvas,
      ) {
    // ==========================================================
    // GROUND SHADOW
    //
    // Directly under boots.
    // This makes the enemy look connected to the road.
    // ==========================================================

    final shadowWidth =
        size.x *
            0.58;

    final shadowHeight =
        size.y *
            0.065;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          size.x / 2,
          size.y -
              3,
        ),
        width:
        shadowWidth,
        height:
        shadowHeight,
      ),
      Paint()
        ..color =
        Colors.black
            .withValues(
          alpha:
          0.34,
        ),
    );

    super.render(
      canvas,
    );

    if (_hitFlashTimer > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.x *
                0.12,
            size.y *
                0.08,
            size.x *
                0.76,
            size.y *
                0.84,
          ),
          const Radius.circular(
            8,
          ),
        ),
        Paint()
          ..color =
          Colors.white
              .withValues(
            alpha:
            0.24,
          ),
      );
    }

    _renderHealthBar(
      canvas,
    );
  }

  // ============================================================
  // HEALTH BAR
  // ============================================================

  void _renderHealthBar(
      Canvas canvas,
      ) {
    if (health >=
        maxHealth &&
        type !=
            EnemyType.heavy) {
      return;
    }

    final progress =
    (health / maxHealth)
        .clamp(
      0.0,
      1.0,
    )
        .toDouble();

    final barWidth =
    type ==
        EnemyType.heavy
        ? size.x *
        0.88
        : size.x *
        0.80;

    final barHeight =
    type ==
        EnemyType.heavy
        ? 6.0
        : 4.0;

    final left =
        (size.x -
            barWidth) /
            2;

    const top = -11.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left,
          top,
          barWidth,
          barHeight,
        ),
        const Radius.circular(
          4,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF26090C,
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left,
          top,
          barWidth *
              progress,
          barHeight,
        ),
        const Radius.circular(
          4,
        ),
      ),
      Paint()
        ..color =
        type ==
            EnemyType.heavy
            ? const Color(
          0xFFFF7B35,
        )
            : const Color(
          0xFFFF3B48,
        ),
    );
  }
}

// ============================================================
// DAMAGE NUMBER
// ============================================================

class EnemyDamageNumber
    extends TextComponent {
  EnemyDamageNumber({
    required Vector2 position,
    required int damage,
    required bool critical,
  })  : _critical = critical,
        super(
        text: critical
            ? '-$damage!'
            : '-$damage',
        position: position,
        anchor:
        Anchor.center,
        priority: 500,
        textRenderer:
        TextPaint(
          style:
          TextStyle(
            color: critical
                ? const Color(
              0xFFFFD23E,
            )
                : Colors.white,
            fontSize: critical
                ? 15
                : 11,
            fontWeight:
            FontWeight.w900,
            shadows:
            const [
              Shadow(
                color:
                Colors.black,
                blurRadius:
                4,
              ),
            ],
          ),
        ),
      );

  final bool _critical;

  double _timer = 0;

  static const double
  _duration = 0.55;

  @override
  void update(
      double dt,
      ) {
    super.update(
      dt,
    );

    _timer += dt;

    position.y -=
        (_critical
            ? 36
            : 27) *
            dt;

    if (_critical &&
        _timer < 0.12) {
      scale.setAll(
        1 +
            (_timer /
                0.12) *
                0.18,
      );
    }

    if (_timer >=
        _duration) {
      removeFromParent();
    }
  }
}