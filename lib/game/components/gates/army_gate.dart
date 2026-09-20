import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../player/player_vehicle.dart';

enum ArmyGateType {
  addArmy,
  multiplyArmy,
  firepower,

  // Old Level 2 compatibility.
  addSoldiers,
}

class ArmyGate extends PositionComponent
    with CollisionCallbacks {
  ArmyGate({
    required Vector2 position,
    String? label,
    required this.type,
    required this.value,
    this.choiceId = 0,

    // New API.
    double? fallSpeed,

    // Old API compatibility.
    double? speed,

    // Optional so older spawners still compile.
    this.onCollected,
  })  : label = label ??
      _automaticLabel(
        type,
        value,
      ),
        fallSpeed =
            fallSpeed ??
                speed ??
                138,
        super(
        position: position,
        size: Vector2(
          76,
          72,
        ),
        anchor: Anchor.center,
        priority: 120,
      );

  final String label;

  final ArmyGateType type;

  final double value;

  final int choiceId;

  final double fallSpeed;

  final void Function(
      ArmyGate gate,
      )? onCollected;

  bool _collected = false;

  double _time = 0;

  // ============================================================
  // AUTO LABEL
  //
  // Old Level 2 spawner doesn't send label.
  // ============================================================

  static String _automaticLabel(
      ArmyGateType type,
      double value,
      ) {
    switch (type) {
      case ArmyGateType.addArmy:
      case ArmyGateType.addSoldiers:
        return '+${value.round()}';

      case ArmyGateType.multiplyArmy:
      case ArmyGateType.firepower:
        return 'x${value.toStringAsFixed(
          value % 1 == 0 ? 0 : 1,
        )}';
    }
  }

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      RectangleHitbox(
        position:
        size / 2,
        size: Vector2(
          68,
          60,
        ),
        anchor:
        Anchor.center,
        collisionType:
        CollisionType.passive,
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  String get _title {
    switch (type) {
      case ArmyGateType.addArmy:
      case ArmyGateType.addSoldiers:
      case ArmyGateType.multiplyArmy:
        return 'ARMY';

      case ArmyGateType.firepower:
        return 'FIRE';
    }
  }

  // ============================================================
  // VALUE
  // ============================================================

  String get _displayValue {
    switch (type) {
      case ArmyGateType.addArmy:
      case ArmyGateType.addSoldiers:
        if (label.startsWith('+')) {
          return label;
        }

        return '+${value.round()}';

      case ArmyGateType.multiplyArmy:
      case ArmyGateType.firepower:
        if (label.toLowerCase().startsWith(
          'x',
        )) {
          return label;
        }

        return 'x${value.toStringAsFixed(
          value % 1 == 0 ? 0 : 1,
        )}';
    }
  }

  bool get _isFirepower =>
      type ==
          ArmyGateType.firepower;

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(
      double dt,
      ) {
    super.update(dt);

    if (_collected) {
      return;
    }

    _time += dt;

    position.y +=
        fallSpeed * dt;

    // Dynamic cleanup works on different screen sizes too.
    if (position.y >
        1800) {
      removeFromParent();
    }
  }

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(
      Canvas canvas,
      ) {
    super.render(canvas);

    final pulse =
        .5 +
            sin(
              _time * 4,
            ) *
                .5;

    final accent =
    _isFirepower
        ? const Color(
      0xFFFFC83D,
    )
        : const Color(
      0xFF27D8FF,
    );

    final darkAccent =
    _isFirepower
        ? const Color(
      0xFF654500,
    )
        : const Color(
      0xFF004863,
    );

    final rect =
    Rect.fromLTWH(
      2,
      4,
      size.x - 4,
      size.y - 8,
    );

    final body =
    RRect.fromRectAndRadius(
      rect,
      const Radius.circular(
        14,
      ),
    );

    // ==========================================================
    // SHADOW
    // ==========================================================

    canvas.drawRRect(
      body,
      Paint()
        ..color =
        Colors.black.withValues(
          alpha: .38,
        )
        ..maskFilter =
        const MaskFilter.blur(
          BlurStyle.normal,
          7,
        ),
    );

    // ==========================================================
    // BODY
    // ==========================================================

    canvas.drawRRect(
      body,
      Paint()
        ..shader =
        LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: [
            darkAccent,
            const Color(
              0xFF07141E,
            ),
          ],
        ).createShader(
          rect,
        ),
    );

    // ==========================================================
    // OUTER BORDER
    // ==========================================================

    canvas.drawRRect(
      body,
      Paint()
        ..color =
        accent.withValues(
          alpha:
          .78 +
              pulse * .18,
        )
        ..style =
            PaintingStyle.stroke
        ..strokeWidth = 2.1,
    );

    // ==========================================================
    // INNER BORDER
    // ==========================================================

    final innerRect =
    Rect.fromLTWH(
      7,
      9,
      size.x - 14,
      size.y - 18,
    );

    final inner =
    RRect.fromRectAndRadius(
      innerRect,
      const Radius.circular(
        10,
      ),
    );

    canvas.drawRRect(
      inner,
      Paint()
        ..color =
        accent.withValues(
          alpha: .17,
        )
        ..style =
            PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // ==========================================================
    // VALUE
    // ==========================================================

    final valuePainter =
    TextPainter(
      text: TextSpan(
        text:
        _displayValue,
        style:
        TextStyle(
          color:
          Colors.white,
          fontSize: 21,
          fontWeight:
          FontWeight.w900,
          height: 1,
          shadows: [
            Shadow(
              color:
              accent.withValues(
                alpha: .8,
              ),
              blurRadius: 7,
            ),
          ],
        ),
      ),
      textDirection:
      TextDirection.ltr,
      textAlign:
      TextAlign.center,
    );

    valuePainter.layout(
      maxWidth:
      size.x - 8,
    );

    valuePainter.paint(
      canvas,
      Offset(
        (size.x -
            valuePainter.width) /
            2,
        15,
      ),
    );

    // ==========================================================
    // TYPE
    // ==========================================================

    final typePainter =
    TextPainter(
      text: TextSpan(
        text: _title,
        style:
        TextStyle(
          color: accent,
          fontSize: 8,
          fontWeight:
          FontWeight.w900,
          letterSpacing: .8,
        ),
      ),
      textDirection:
      TextDirection.ltr,
    );

    typePainter.layout();

    typePainter.paint(
      canvas,
      Offset(
        (size.x -
            typePainter.width) /
            2,
        44,
      ),
    );

    // ==========================================================
    // ENERGY STRIP
    // ==========================================================

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          18,
          size.y - 10,
          size.x - 36,
          3,
        ),
        const Radius.circular(
          3,
        ),
      ),
      Paint()
        ..color =
        accent.withValues(
          alpha:
          .6 +
              pulse * .25,
        ),
    );
  }

  // ============================================================
  // DEFAULT EFFECT
  //
  // Important:
  // Old spawners without onCollected still work.
  // ============================================================

  void _applyDefault(
      PlayerVehicle player,
      ) {
    switch (type) {
      case ArmyGateType.addArmy:
      case ArmyGateType.addSoldiers:
        player.addArmy(
          value.round(),
        );
        break;

      case ArmyGateType.multiplyArmy:
        player.multiplyArmy(
          max(
            2,
            value.round(),
          ),
        );
        break;

      case ArmyGateType.firepower:
        player.applyFirepowerMultiplier(
          value,
        );
        break;
    }
  }

  // ============================================================
  // COLLECT
  // ============================================================

  void collect({
    PlayerVehicle? player,
  }) {
    if (_collected) {
      return;
    }

    _collected = true;

    // New spawner handles its own reward.
    if (onCollected != null) {
      onCollected!(
        this,
      );
    } else if (player != null) {
      // Old Level 2 spawner compatibility.
      _applyDefault(
        player,
      );
    }

    add(
      ScaleEffect.to(
        Vector2.all(
          1.15,
        ),
        EffectController(
          duration: .07,
          reverseDuration: .08,
        ),
        onComplete: () {
          removeFromParent();
        },
      ),
    );
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

    if (_collected) {
      return;
    }

    if (other
    is PlayerVehicle) {
      collect(
        player: other,
      );
    }
  }
}