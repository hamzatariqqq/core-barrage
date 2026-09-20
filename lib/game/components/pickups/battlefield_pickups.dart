import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../bullets/player_bullet.dart';
import '../player/blue_soldier.dart';
import '../player/player_vehicle.dart';

// ============================================================
// PICKUP TYPE
// ============================================================

enum BattlefieldPickupType {
  coin,
  missile,
  firepower,
  army,
}

// ============================================================
// BATTLEFIELD PICKUP
// ============================================================

class BattlefieldPickup extends PositionComponent
    with CollisionCallbacks {
  BattlefieldPickup({
    required Vector2 position,
    required this.type,
    required this.value,
    required this.onCollected,
    this.scrollSpeed = 125,
  }) : super(
    position: position,
    size: Vector2(54, 54),
    anchor: Anchor.center,
    priority: 60,
  );

  final BattlefieldPickupType type;

  final int value;

  final double scrollSpeed;

  final void Function(
      BattlefieldPickupType type,
      int value,
      PlayerVehicle player,
      ) onCollected;

  bool _collected = false;

  double _time = 0;

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      CircleHitbox(
        radius: 23,
        position: size / 2,
        anchor: Anchor.center,
      ),
    );

    add(
      TextComponent(
        text: _symbol,
        position: size / 2,
        anchor: Anchor.center,
        priority: 2,
        textRenderer: TextPaint(
          style: TextStyle(
            color: Colors.white,
            fontSize: _symbolFontSize,
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(
                color: Colors.black87,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );

    add(
      TextComponent(
        text: _label,
        position: Vector2(
          size.x / 2,
          size.y + 9,
        ),
        anchor: Anchor.topCenter,
        priority: 3,
        textRenderer: TextPaint(
          style: TextStyle(
            color: _accent,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
            shadows: const [
              Shadow(
                color: Colors.black,
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // APPEARANCE
  // ============================================================

  String get _symbol {
    switch (type) {
      case BattlefieldPickupType.coin:
        return '\$';

      case BattlefieldPickupType.missile:
        return '▲';

      case BattlefieldPickupType.firepower:
        return '×2';

      case BattlefieldPickupType.army:
        return '+';
    }
  }

  double get _symbolFontSize {
    switch (type) {
      case BattlefieldPickupType.firepower:
        return 19;

      default:
        return 26;
    }
  }

  String get _label {
    switch (type) {
      case BattlefieldPickupType.coin:
        return '+$value COINS';

      case BattlefieldPickupType.missile:
        return 'MISSILE';

      case BattlefieldPickupType.firepower:
        return 'FIREPOWER';

      case BattlefieldPickupType.army:
        return '+$value ARMY';
    }
  }

  Color get _accent {
    switch (type) {
      case BattlefieldPickupType.coin:
        return const Color(
          0xFFFFD43B,
        );

      case BattlefieldPickupType.missile:
        return const Color(
          0xFFFF8C32,
        );

      case BattlefieldPickupType.firepower:
        return const Color(
          0xFF36D7FF,
        );

      case BattlefieldPickupType.army:
        return const Color(
          0xFF45E996,
        );
    }
  }

  Color get _darkAccent {
    switch (type) {
      case BattlefieldPickupType.coin:
        return const Color(
          0xFF8B6500,
        );

      case BattlefieldPickupType.missile:
        return const Color(
          0xFF8D351B,
        );

      case BattlefieldPickupType.firepower:
        return const Color(
          0xFF075785,
        );

      case BattlefieldPickupType.army:
        return const Color(
          0xFF087245,
        );
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    if (_collected) {
      return;
    }

    _time += dt;

    position.y +=
        scrollSpeed * dt;

    angle =
        sin(_time * 2.6) *
            .035;

    scale.setAll(
      1 +
          sin(_time * 4.5) *
              .035,
    );

    if (position.y >
        2200) {
      removeFromParent();
    }
  }

  // ============================================================
  // COLLISION
  // ============================================================

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(
      intersectionPoints,
      other,
    );

    if (_collected) {
      return;
    }

    PlayerVehicle? player;

    if (other is PlayerVehicle) {
      player = other;
    }

    if (other is BlueSoldier) {
      final parentComponent =
          parent;

      if (parentComponent != null) {
        for (final component
        in parentComponent.children) {
          if (component
          is PlayerVehicle) {
            player = component;

            break;
          }
        }
      }
    }

    if (player == null ||
        !player.isMounted) {
      return;
    }

    _collected = true;

    onCollected(
      type,
      value,
      player,
    );

    parent?.add(
      PickupBurst(
        position:
        position.clone(),
        color:
        _accent,
      ),
    );

    removeFromParent();
  }

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center =
    Offset(
      size.x / 2,
      size.y / 2,
    );

    canvas.drawCircle(
      center,
      27,
      Paint()
        ..color =
        Colors.black.withValues(
          alpha: .38,
        ),
    );

    canvas.drawCircle(
      center,
      24,
      Paint()
        ..color =
            _darkAccent,
    );

    canvas.drawCircle(
      center,
      19,
      Paint()
        ..color =
        _accent.withValues(
          alpha: .92,
        ),
    );

    canvas.drawCircle(
      center,
      24,
      Paint()
        ..style =
            PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color =
        _accent.withValues(
          alpha: .8,
        ),
    );

    canvas.drawCircle(
      Offset(
        center.dx - 6,
        center.dy - 7,
      ),
      4,
      Paint()
        ..color =
        Colors.white.withValues(
          alpha: .28,
        ),
    );
  }
}

// ============================================================
// DESTRUCTIBLE SUPPLY CRATE
// ============================================================

class BattleSupplyCrate extends PositionComponent
    with CollisionCallbacks {
  BattleSupplyCrate({
    required Vector2 position,
    required this.onDestroyed,
    this.scrollSpeed = 118,
    this.health = 120,
  }) : super(
    position: position,
    size: Vector2(
      62,
      58,
    ),
    anchor: Anchor.center,
    priority: 52,
  );

  final void Function(
      Vector2 position,
      ) onDestroyed;

  final double scrollSpeed;

  double health;

  bool _destroyed = false;

  double _hitFlash = 0;

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      RectangleHitbox(
        position:
        Vector2(
          5,
          5,
        ),
        size:
        Vector2(
          size.x - 10,
          size.y - 10,
        ),
      ),
    );
  }

  // ============================================================
  // DAMAGE
  // ============================================================

  void takeDamage(
      double amount,
      ) {
    if (_destroyed) {
      return;
    }

    health -= amount;

    _hitFlash = .09;

    if (health <= 0) {
      _destroy();
    }
  }

  void _destroy() {
    if (_destroyed) {
      return;
    }

    _destroyed = true;

    parent?.add(
      CrateBreakEffect(
        position:
        position.clone(),
      ),
    );

    onDestroyed(
      position.clone(),
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

    if (_destroyed) {
      return;
    }

    position.y +=
        scrollSpeed * dt;

    if (_hitFlash > 0) {
      _hitFlash -= dt;
    }

    if (position.y >
        2200) {
      removeFromParent();
    }
  }

  // ============================================================
  // COLLISION
  // ============================================================

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(
      intersectionPoints,
      other,
    );

    if (_destroyed) {
      return;
    }

    // Player bullets can destroy crates.
    if (other is PlayerBullet) {
      other.removeFromParent();

      takeDamage(
        45,
      );

      return;
    }

    // Soldiers can break through crates,
    // but it costs them health.
    if (other is BlueSoldier) {
      other.hit(
        damage: 12,
      );

      takeDamage(
        60,
      );

      return;
    }

    // Driving directly into a crate costs army.
    if (other is PlayerVehicle) {
      other.removeArmy(
        2,
      );

      takeDamage(
        200,
      );
    }
  }

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(
      Canvas canvas,
      ) {
    super.render(
      canvas,
    );

    final rect =
    Rect.fromLTWH(
      4,
      5,
      size.x - 8,
      size.y - 10,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(
          7,
        ),
      ),
      Paint()
        ..color =
        _hitFlash > 0
            ? Colors.white
            : const Color(
          0xFF76502C,
        ),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          8,
          9,
          size.x - 16,
          size.y - 18,
        ),
        const Radius.circular(
          5,
        ),
      ),
      Paint()
        ..style =
            PaintingStyle.stroke
        ..strokeWidth = 4
        ..color =
        const Color(
          0xFFB78447,
        ),
    );

    final stripePaint =
    Paint()
      ..color =
      const Color(
        0xFFFFC13A,
      );

    canvas.drawRect(
      Rect.fromLTWH(
        8,
        size.y / 2 - 5,
        size.x - 16,
        10,
      ),
      stripePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.x / 2 - 4,
        9,
        8,
        size.y - 18,
      ),
      Paint()
        ..color =
        const Color(
          0xFF35261C,
        ),
    );

    canvas.drawCircle(
      Offset(
        size.x / 2,
        size.y / 2,
      ),
      5,
      Paint()
        ..color =
        const Color(
          0xFF20262B,
        ),
    );

    // Small health bar.
    final healthProgress =
    (health / 120)
        .clamp(
      0.0,
      1.0,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          8,
          0,
          size.x - 16,
          4,
        ),
        const Radius.circular(
          2,
        ),
      ),
      Paint()
        ..color =
            Colors.black54,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          8,
          0,
          (size.x - 16) *
              healthProgress,
          4,
        ),
        const Radius.circular(
          2,
        ),
      ),
      Paint()
        ..color =
        const Color(
          0xFF45E58D,
        ),
    );
  }
}

// ============================================================
// PICKUP BURST
// ============================================================

class PickupBurst extends PositionComponent {
  PickupBurst({
    required Vector2 position,
    required this.color,
  }) : super(
    position: position,
    size: Vector2.all(
      80,
    ),
    anchor: Anchor.center,
    priority: 300,
  );

  final Color color;

  double _life = 0;

  static const double
  _duration = .38;

  @override
  void update(
      double dt,
      ) {
    super.update(dt);

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
    super.render(canvas);

    final progress =
    (_life / _duration)
        .clamp(
      0.0,
      1.0,
    );

    final alpha =
        1 - progress;

    final center =
    Offset(
      size.x / 2,
      size.y / 2,
    );

    canvas.drawCircle(
      center,
      14 +
          progress * 28,
      Paint()
        ..style =
            PaintingStyle.stroke
        ..strokeWidth =
            4 * alpha
        ..color =
        color.withValues(
          alpha: alpha,
        ),
    );

    for (int i = 0;
    i < 8;
    i++) {
      final angle =
          i *
              pi /
              4;

      final distance =
          15 +
              progress *
                  30;

      canvas.drawCircle(
        Offset(
          center.dx +
              cos(angle) *
                  distance,
          center.dy +
              sin(angle) *
                  distance,
        ),
        3.5 * alpha,
        Paint()
          ..color =
          color.withValues(
            alpha: alpha,
          ),
      );
    }
  }
}

// ============================================================
// CRATE BREAK EFFECT
// ============================================================

class CrateBreakEffect
    extends PositionComponent {
  CrateBreakEffect({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2.all(
      90,
    ),
    anchor: Anchor.center,
    priority: 220,
  );

  double _life = 0;

  static const double
  _duration = .45;

  @override
  void update(
      double dt,
      ) {
    super.update(dt);

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
    super.render(canvas);

    final progress =
    (_life / _duration)
        .clamp(
      0.0,
      1.0,
    );

    final alpha =
        1 - progress;

    final center =
    Offset(
      size.x / 2,
      size.y / 2,
    );

    for (int i = 0;
    i < 7;
    i++) {
      final angle =
          i *
              pi /
              3.5;

      final distance =
          progress *
              42;

      final offset =
      Offset(
        center.dx +
            cos(angle) *
                distance,
        center.dy +
            sin(angle) *
                distance,
      );

      canvas.save();

      canvas.translate(
        offset.dx,
        offset.dy,
      );

      canvas.rotate(
        angle +
            progress *
                2,
      );

      canvas.drawRect(
        const Rect.fromLTWH(
          -5,
          -4,
          10,
          8,
        ),
        Paint()
          ..color =
          const Color(
            0xFFB17A3E,
          ).withValues(
            alpha: alpha,
          ),
      );

      canvas.restore();
    }

    canvas.drawCircle(
      center,
      11 +
          progress * 15,
      Paint()
        ..color =
        const Color(
          0xFFFFB13C,
        ).withValues(
          alpha:
          alpha * .45,
        ),
    );
  }
}