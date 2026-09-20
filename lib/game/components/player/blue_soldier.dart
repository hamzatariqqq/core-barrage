import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class BlueSoldier extends SpriteComponent
    with CollisionCallbacks, HasGameReference<FlameGame> {
  BlueSoldier({
    required Vector2 position,
    required this.onKilled,
  }) : super(
    position: position,
    size: Vector2(
      30,
      30,
    ),
    anchor: Anchor.center,
    priority: 55,
  );

  final void Function(
      BlueSoldier soldier,
      ) onKilled;

  Vector2? _targetPosition;

  double _time = 0;

  double _recoil = 0;

  bool _dead = false;

  double _health = 30;

  final Random _random = Random();

  late final double _idleOffset;

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _idleOffset =
        _random.nextDouble() * 6;

    final image =
    await game.images.load(
      'player/run/blue_soldier_run.png',
    );

    // ==========================================================
    // USE ONLY FIRST FRAME
    //
    // Removes the old endless running animation.
    // ==========================================================

    final frameWidth =
        image.width / 8;

    sprite = Sprite(
      image,
      srcPosition: Vector2.zero(),
      srcSize: Vector2(
        frameWidth,
        image.height.toDouble(),
      ),
    );

    add(
      CircleHitbox(
        radius: 9,
        position: size / 2,
        anchor: Anchor.center,
      ),
    );
  }

  // ============================================================
  // FORMATION TARGET
  // ============================================================

  void setFormationPosition(
      Vector2 target,
      ) {
    _targetPosition =
        target.clone();
  }

  // ============================================================
  // FIRE RECOIL
  // ============================================================

  void fire() {
    if (_dead) {
      return;
    }

    _recoil = 1;
  }

  // ============================================================
  // DAMAGE
  // ============================================================

  void takeDamage(
      double damage,
      ) {
    if (_dead) {
      return;
    }

    _health -= damage;

    if (_health <= 0) {
      kill();
    }
  }

  // ============================================================
  // GENERAL HIT API
  // ============================================================

  void hit({
    double damage = 15,
  }) {
    takeDamage(
      damage,
    );
  }

  // ============================================================
  // BASIC ENEMY COMPATIBILITY
  //
  // basic_enemy.dart already calls:
  // other.hitByEnemy();
  // ============================================================

  void hitByEnemy() {
    if (_dead) {
      return;
    }

    takeDamage(
      30,
    );
  }

  // ============================================================
  // KILL
  // ============================================================

  void kill() {
    if (_dead) {
      return;
    }

    _dead = true;

    onKilled(
      this,
    );

    removeFromParent();
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

    final target =
        _targetPosition;

    if (target != null) {
      final delta =
          target - position;

      // Smooth squad movement instead of instant snapping.
      position +=
          delta *
              min(
                1.0,
                dt * 12,
              );
    }

    if (_recoil > 0) {
      _recoil -=
          dt * 7;

      if (_recoil < 0) {
        _recoil = 0;
      }
    }
  }

  // ============================================================
  // RENDER
  //
  // Static combat stance + subtle idle movement.
  // ============================================================

  @override
  void render(
      Canvas canvas,
      ) {
    final bob =
        sin(
          _time * 3.1 +
              _idleOffset,
        ) *
            1.2;

    final recoilOffset =
        _recoil * 2.2;

    canvas.save();

    canvas.translate(
      0,
      bob + recoilOffset,
    );

    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          size.x / 2,
          size.y * .82,
        ),
        width: 20,
        height: 6,
      ),
      Paint()
        ..color =
        Colors.black.withValues(
          alpha: .23,
        ),
    );

    super.render(
      canvas,
    );

    canvas.restore();
  }
}