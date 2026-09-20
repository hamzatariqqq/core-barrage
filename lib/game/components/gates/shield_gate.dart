import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../player/blue_soldier.dart';
import '../player/player_vehicle.dart';

class ShieldGate extends PositionComponent
    with CollisionCallbacks {
  ShieldGate({
    required Vector2 position,
    this.scrollSpeed = 110,
  }) : super(
    position: position,
    size: Vector2(
      112,
      88,
    ),
    anchor: Anchor.center,
    priority: 44,
  );

  final double scrollSpeed;

  bool _used = false;

  double _time = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      RectangleHitbox(
        position:
        Vector2(
          8,
          8,
        ),
        size:
        Vector2(
          size.x - 16,
          size.y - 16,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;

    position.y +=
        scrollSpeed * dt;

    if (position.y >
        1100) {
      removeFromParent();
    }
  }

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

    if (_used) {
      return;
    }

    if (other
    is PlayerVehicle) {
      _activate(
        other,
      );

      return;
    }

    // The player's visible formation can reach
    // the gate slightly before the tank.
    if (other
    is BlueSoldier) {
      final world =
          parent;

      if (world == null) {
        return;
      }

      final players =
      world.children
          .whereType<
          PlayerVehicle>()
          .where(
            (
            vehicle,
            ) =>
        vehicle
            .isMounted,
      )
          .toList();

      if (players
          .isNotEmpty) {
        _activate(
          players.first,
        );
      }
    }
  }

  void _activate(
      PlayerVehicle player,
      ) {
    if (_used) {
      return;
    }

    _used = true;

    // Defensive bonus remains useful even after
    // shield charges are consumed.
    player.addArmy(
      6,
    );

    parent?.add(
      PlayerBattleShield(
        player: player,
        charges: 5,
        duration: 10,
      ),
    );

    parent?.add(
      ShieldGateFlash(
        position:
        position.clone(),
      ),
    );

    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final pulse =
        .50 +
            sin(_time * 5) *
                .16;

    final glow =
    pulse.clamp(
      .2,
      .8,
    );

    final center =
    Offset(
      size.x / 2,
      size.y / 2,
    );

    // Outer glow.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          2,
          2,
          size.x - 4,
          size.y - 4,
        ),
        const Radius.circular(
          17,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF20D8FF,
        ).withValues(
          alpha:
          glow * .25,
        ),
    );

    // Gate frame.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          6,
          6,
          size.x - 12,
          size.y - 12,
        ),
        const Radius.circular(
          15,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF1A516B,
        ),
    );

    // Inner portal.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          13,
          13,
          size.x - 26,
          size.y - 26,
        ),
        const Radius.circular(
          12,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF0A2639,
        ).withValues(
          alpha: .92,
        ),
    );

    // Shield symbol.
    final shieldPath =
    Path();

    shieldPath.moveTo(
      center.dx,
      center.dy - 24,
    );

    shieldPath.lineTo(
      center.dx + 21,
      center.dy - 14,
    );

    shieldPath.lineTo(
      center.dx + 17,
      center.dy + 12,
    );

    shieldPath.quadraticBezierTo(
      center.dx,
      center.dy + 31,
      center.dx - 17,
      center.dy + 12,
    );

    shieldPath.lineTo(
      center.dx - 21,
      center.dy - 14,
    );

    shieldPath.close();

    canvas.drawPath(
      shieldPath,
      Paint()
        ..color =
        const Color(
          0xFF3DEAFF,
        ).withValues(
          alpha: glow,
        ),
    );

    canvas.drawPath(
      shieldPath,
      Paint()
        ..color =
        Colors.white
            .withValues(
          alpha: .75,
        )
        ..style =
            PaintingStyle
                .stroke
        ..strokeWidth = 2,
    );

    final textPainter =
    TextPainter(
      text:
      const TextSpan(
        text:
        'SHIELD',
        style:
        TextStyle(
          color:
          Colors.white,
          fontSize:
          12,
          fontWeight:
          FontWeight.w900,
        ),
      ),
      textDirection:
      TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx -
            textPainter.width /
                2,
        size.y - 21,
      ),
    );
  }
}

class PlayerBattleShield
    extends PositionComponent
    with CollisionCallbacks {
  PlayerBattleShield({
    required this.player,
    this.charges = 5,
    this.duration = 10,
  }) : _remainingCharges =
      charges,
        super(
        size:
        Vector2.all(
          130,
        ),
        anchor:
        Anchor.center,
        priority: 120,
      );

  final PlayerVehicle player;

  final int charges;

  final double duration;

  int _remainingCharges;

  double _elapsed = 0;

  double _pulse = 0;

  double _hitFlash = 0;

  bool _dead = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    position.setFrom(
      player.position,
    );

    add(
      CircleHitbox(
        radius: 60,
        position:
        size / 2,
        anchor:
        Anchor.center,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_dead) {
      return;
    }

    if (!player.isMounted) {
      removeFromParent();
      return;
    }

    _elapsed += dt;

    _pulse += dt;

    if (_hitFlash > 0) {
      _hitFlash -= dt;
    }

    position.setFrom(
      player.position,
    );

    if (_elapsed >=
        duration ||
        _remainingCharges <=
            0) {
      _dead = true;

      removeFromParent();
    }
  }

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

    if (other ==
        player ||
        other
        is BlueSoldier ||
        other
        is ShieldGate ||
        other
        is PlayerBattleShield) {
      return;
    }

    // Shield only destroys hostile projectile-like
    // components. This keeps enemies/gates/objects intact.
    final typeName =
    other.runtimeType
        .toString()
        .toLowerCase();

    final hostileProjectile =
        typeName.contains(
          'enemyprojectile',
        ) ||
            typeName.contains(
              'turretbullet',
            ) ||
            typeName.contains(
              'enemybullet',
            ) ||
            typeName.contains(
              'vehiclebullet',
            ) ||
            typeName.contains(
              'missileprojectile',
            );

    if (!hostileProjectile) {
      return;
    }

    _remainingCharges--;

    _hitFlash = .18;

    other
        .removeFromParent();

    parent?.add(
      ShieldBlockEffect(
        position:
        other.position
            .clone(),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center =
    Offset(
      size.x / 2,
      size.y / 2,
    );

    final pulse =
        .20 +
            sin(_pulse * 5) *
                .07;

    final flash =
    _hitFlash > 0
        ? .55
        : 0.0;

    canvas.drawCircle(
      center,
      59,
      Paint()
        ..color =
        const Color(
          0xFF2CE8FF,
        ).withValues(
          alpha:
          (pulse + flash)
              .clamp(
            .12,
            .75,
          ),
        ),
    );

    canvas.drawCircle(
      center,
      59,
      Paint()
        ..color =
        Colors.white
            .withValues(
          alpha:
          _hitFlash > 0
              ? .95
              : .42,
        )
        ..style =
            PaintingStyle
                .stroke
        ..strokeWidth =
        _hitFlash > 0
            ? 4
            : 2,
    );

    final textPainter =
    TextPainter(
      text:
      TextSpan(
        text:
        '$_remainingCharges',
        style:
        const TextStyle(
          color:
          Colors.white,
          fontSize:
          12,
          fontWeight:
          FontWeight.w900,
        ),
      ),
      textDirection:
      TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx -
            textPainter.width /
                2,
        center.dy - 6,
      ),
    );
  }
}

class ShieldBlockEffect
    extends PositionComponent {
  ShieldBlockEffect({
    required Vector2 position,
  }) : super(
    position: position,
    size:
    Vector2.all(
      70,
    ),
    anchor:
    Anchor.center,
    priority: 300,
  );

  double _life = 0;

  static const double
  _duration = .25;

  @override
  void update(double dt) {
    super.update(dt);

    _life += dt;

    if (_life >=
        _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress =
    (_life /
        _duration)
        .clamp(
      0.0,
      1.0,
    );

    final alpha =
        1.0 - progress;

    canvas.drawCircle(
      Offset(
        size.x / 2,
        size.y / 2,
      ),
      8 + progress * 24,
      Paint()
        ..color =
        const Color(
          0xFF59E9FF,
        ).withValues(
          alpha: alpha,
        )
        ..style =
            PaintingStyle
                .stroke
        ..strokeWidth = 4,
    );
  }
}

class ShieldGateFlash
    extends PositionComponent {
  ShieldGateFlash({
    required Vector2 position,
  }) : super(
    position: position,
    size:
    Vector2.all(
      120,
    ),
    anchor:
    Anchor.center,
    priority: 220,
  );

  double _life = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _life += dt;

    if (_life >= .35) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress =
    (_life / .35)
        .clamp(
      0.0,
      1.0,
    );

    final alpha =
        1 - progress;

    canvas.drawCircle(
      Offset(
        size.x / 2,
        size.y / 2,
      ),
      18 + progress * 45,
      Paint()
        ..color =
        const Color(
          0xFF33E6FF,
        ).withValues(
          alpha: alpha,
        ),
    );
  }
}