import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../components/player/blue_soldier.dart';
import '../../components/player/player_vehicle.dart';
import '../level/level_2_director.dart';

enum _Level2GateReward {
  addArmy,
  multiplyArmy,
  firepower,
}

class Level2GateSpawner extends Component {
  Level2GateSpawner({
    required this.gameSize,
  });

  final Vector2 gameSize;

  bool _stopped = false;
  int _pairCounter = 0;

  void stop() {
    _stopped = true;
  }

  // ============================================================
  // SPAWN GATE
  //
  // BALANCE PHILOSOPHY:
  // - Gates are useful, but no longer overpower permanent upgrades.
  // - No repeated x2 firepower.
  // - No huge +20 / +30 / +45 army rewards.
  // - Army multiplication is reserved for future/special use.
  // ============================================================

  void spawnGate(Level2Gate gate) {
    if (_stopped) {
      return;
    }

    switch (gate) {
    // --------------------------------------------------------
    // FIRST CHOICE
    //
    // Small army boost OR modest temporary mission firepower.
    // --------------------------------------------------------

      case Level2Gate.firstChoice:
        _spawnPair(
          leftLabel: '+5',
          leftSubtitle: 'ARMY',
          leftReward: _Level2GateReward.addArmy,
          leftValue: 5.0,
          rightLabel: '+25%',
          rightSubtitle: 'FIREPOWER',
          rightReward: _Level2GateReward.firepower,
          rightValue: 1.25,
          movement: 12,
        );
        break;

    // --------------------------------------------------------
    // SECOND CHOICE
    //
    // Both are controlled army rewards.
    // No x2 army snowball.
    // --------------------------------------------------------

      case Level2Gate.secondChoice:
        _spawnPair(
          leftLabel: '+7',
          leftSubtitle: 'ARMY',
          leftReward: _Level2GateReward.addArmy,
          leftValue: 7.0,
          rightLabel: '+5',
          rightSubtitle: 'ARMY',
          rightReward: _Level2GateReward.addArmy,
          rightValue: 5.0,
          movement: 17,
        );
        break;

    // --------------------------------------------------------
    // THIRD CHOICE
    //
    // Slightly larger army reward OR modest firepower.
    // --------------------------------------------------------

      case Level2Gate.thirdChoice:
        _spawnPair(
          leftLabel: '+8',
          leftSubtitle: 'ARMY',
          leftReward: _Level2GateReward.addArmy,
          leftValue: 8.0,
          rightLabel: '+20%',
          rightSubtitle: 'FIREPOWER',
          rightReward: _Level2GateReward.firepower,
          rightValue: 1.20,
          movement: 20,
        );
        break;

    // --------------------------------------------------------
    // FINAL CHOICE
    //
    // Helpful before final assault, but not enough to make
    // the boss trivial.
    // --------------------------------------------------------

      case Level2Gate.finalChoice:
        _spawnPair(
          leftLabel: '+10',
          leftSubtitle: 'ARMY',
          leftReward: _Level2GateReward.addArmy,
          leftValue: 10.0,
          rightLabel: '+7',
          rightSubtitle: 'ARMY',
          rightReward: _Level2GateReward.addArmy,
          rightValue: 7.0,
          movement: 11,
        );
        break;
    }
  }

  // ============================================================
  // SPAWN PAIR
  // ============================================================

  void _spawnPair({
    required String leftLabel,
    required String leftSubtitle,
    required _Level2GateReward leftReward,
    required double leftValue,
    required String rightLabel,
    required String rightSubtitle,
    required _Level2GateReward rightReward,
    required double rightValue,
    required double movement,
  }) {
    if (_stopped) {
      return;
    }

    _pairCounter++;

    final pairId = _pairCounter;

    final leftBaseX =
        gameSize.x * .42;

    final rightBaseX =
        gameSize.x * .58;

    parent?.add(
      _MovingLevel2Gate(
        position: Vector2(
          leftBaseX,
          -82,
        ),
        baseX: leftBaseX,
        roadLeft: gameSize.x * .29,
        roadRight: gameSize.x * .71,
        pairId: pairId,
        phase: 0,
        movementAmplitude: movement,
        label: leftLabel,
        subtitle: leftSubtitle,
        reward: leftReward,
        value: leftValue,
        accent: const Color(
          0xFF32CFFF,
        ),
      ),
    );

    parent?.add(
      _MovingLevel2Gate(
        position: Vector2(
          rightBaseX,
          -82,
        ),
        baseX: rightBaseX,
        roadLeft: gameSize.x * .29,
        roadRight: gameSize.x * .71,
        pairId: pairId,
        phase: pi,
        movementAmplitude: movement,
        label: rightLabel,
        subtitle: rightSubtitle,
        reward: rightReward,
        value: rightValue,
        accent: const Color(
          0xFF47E7A3,
        ),
      ),
    );
  }
}

// ============================================================
// MOVING LEVEL 2 GATE
// ============================================================

class _MovingLevel2Gate extends PositionComponent
    with CollisionCallbacks {
  _MovingLevel2Gate({
    required Vector2 position,
    required this.baseX,
    required this.roadLeft,
    required this.roadRight,
    required this.pairId,
    required this.phase,
    required this.movementAmplitude,
    required this.label,
    required this.subtitle,
    required this.reward,
    required this.value,
    required this.accent,
  }) : super(
    position: position,
    size: Vector2(
      100,
      84,
    ),
    anchor: Anchor.center,
    priority: 70,
  );

  final double baseX;
  final double roadLeft;
  final double roadRight;

  final int pairId;

  final double phase;
  final double movementAmplitude;

  final String label;
  final String subtitle;

  final _Level2GateReward reward;

  // Double now allows values such as:
  // 1.20 = +20% firepower
  // 1.25 = +25% firepower
  //
  // Army rewards are converted back to integer.
  final double value;

  final Color accent;

  bool _used = false;

  double _time = 0;

  static const double _scrollSpeed =
  118;

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      RectangleHitbox(
        position: Vector2(
          7,
          6,
        ),
        size: Vector2(
          size.x - 14,
          size.y - 12,
        ),
      ),
    );
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    if (_used) {
      return;
    }

    _time += dt;

    position.y +=
        _scrollSpeed * dt;

    final movingX =
        baseX +
            sin(
              _time * 2.25 +
                  phase,
            ) *
                movementAmplitude;

    position.x =
        movingX.clamp(
          roadLeft,
          roadRight,
        );

    if (position.y > 1000) {
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

    if (_used) {
      return;
    }

    // Vehicle directly crosses gate.
    if (other is PlayerVehicle) {
      _activate(
        other,
      );

      return;
    }

    // Soldier can also trigger the gate.
    if (other is BlueSoldier) {
      final world =
          parent;

      if (world == null) {
        return;
      }

      final players =
      world.children
          .whereType<PlayerVehicle>()
          .where(
            (player) =>
        player.isMounted,
      )
          .toList();

      if (players.isNotEmpty) {
        _activate(
          players.first,
        );
      }
    }
  }

  // ============================================================
  // ACTIVATE
  // ============================================================

  void _activate(
      PlayerVehicle player,
      ) {
    if (_used ||
        !player.isMounted) {
      return;
    }

    _used = true;

    switch (reward) {
    // --------------------------------------------------------
    // ADD ARMY
    // --------------------------------------------------------

      case _Level2GateReward.addArmy:
        player.addArmy(
          value.round(),
        );
        break;

    // --------------------------------------------------------
    // MULTIPLY ARMY
    //
    // Kept for API compatibility / future special gates.
    // Current normal Level 2 gate table does not use it.
    // --------------------------------------------------------

      case _Level2GateReward.multiplyArmy:
        player.multiplyArmy(
          value.round(),
        );
        break;

    // --------------------------------------------------------
    // FIREPOWER
    //
    // Old values:
    // 2.0 = x2
    //
    // New balanced values:
    // 1.20 = +20%
    // 1.25 = +25%
    // --------------------------------------------------------

      case _Level2GateReward.firepower:
        player.applyFirepowerMultiplier(
          value,
        );
        break;
    }

    // ==========================================================
    // FEEDBACK FLASH
    // ==========================================================

    parent?.add(
      _Level2GateFlash(
        position:
        position.clone(),
        accent:
        accent,
      ),
    );

    // ==========================================================
    // REMOVE BOTH GATES FROM THIS CHOICE
    // ==========================================================

    final world =
        parent;

    if (world != null) {
      final pair =
      world.children
          .whereType<
          _MovingLevel2Gate>()
          .where(
            (gate) =>
        gate.pairId ==
            pairId,
      )
          .toList();

      for (final gate in pair) {
        gate._used = true;
        gate.removeFromParent();
      }
    } else {
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
    super.render(
      canvas,
    );

    final rect =
    Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y,
    );

    final body =
    RRect.fromRectAndRadius(
      rect,
      const Radius.circular(
        13,
      ),
    );

    // ==========================================================
    // BODY
    // ==========================================================

    canvas.drawRRect(
      body,
      Paint()
        ..color =
        const Color(
          0xEE0A1B27,
        ),
    );

    // ==========================================================
    // BORDER
    // ==========================================================

    canvas.drawRRect(
      body,
      Paint()
        ..color =
        accent.withValues(
          alpha: .86,
        )
        ..style =
            PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // ==========================================================
    // INDUSTRIAL TOP RAIL
    // ==========================================================

    canvas.drawRect(
      Rect.fromLTWH(
        8,
        8,
        size.x - 16,
        8,
      ),
      Paint()
        ..color =
        accent.withValues(
          alpha: .55,
        ),
    );

    // ==========================================================
    // SIDE PILLARS
    // ==========================================================

    final pillarPaint =
    Paint()
      ..color =
      const Color(
        0xFF273B47,
      );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          4,
          18,
          10,
          size.y - 24,
        ),
        const Radius.circular(
          4,
        ),
      ),
      pillarPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.x - 14,
          18,
          10,
          size.y - 24,
        ),
        const Radius.circular(
          4,
        ),
      ),
      pillarPaint,
    );

    // ==========================================================
    // MAIN VALUE
    // ==========================================================

    _drawCenteredText(
      canvas,
      text: label,
      y: 24,
      fontSize: 25,
      color: Colors.white,
      weight: FontWeight.w900,
    );

    // ==========================================================
    // SUBTITLE
    // ==========================================================

    _drawCenteredText(
      canvas,
      text: subtitle,
      y: 55,
      fontSize: 9,
      color: accent,
      weight: FontWeight.w900,
      spacing: 1.1,
    );
  }

  // ============================================================
  // TEXT
  // ============================================================

  void _drawCenteredText(
      Canvas canvas, {
        required String text,
        required double y,
        required double fontSize,
        required Color color,
        required FontWeight weight,
        double spacing = 0,
      }) {
    final painter =
    TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          letterSpacing: spacing,
        ),
      ),
      textDirection:
      TextDirection.ltr,
      textAlign:
      TextAlign.center,
    );

    painter.layout();

    painter.paint(
      canvas,
      Offset(
        (size.x -
            painter.width) /
            2,
        y,
      ),
    );
  }
}

// ============================================================
// GATE ACTIVATION FLASH
// ============================================================

class _Level2GateFlash
    extends PositionComponent {
  _Level2GateFlash({
    required Vector2 position,
    required this.accent,
  }) : super(
    position: position,
    size: Vector2.all(
      30,
    ),
    anchor: Anchor.center,
    priority: 500,
  );

  final Color accent;

  double _time = 0;

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;

    if (_time >= .35) {
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
    final progress =
    (_time / .35).clamp(
      0.0,
      1.0,
    );

    final radius =
        18 +
            progress * 42;

    canvas.drawCircle(
      Offset(
        size.x / 2,
        size.y / 2,
      ),
      radius,
      Paint()
        ..color =
        accent.withValues(
          alpha:
          (1 - progress) *
              .55,
        )
        ..style =
            PaintingStyle.stroke
        ..strokeWidth =
            5 *
                (1 - progress),
    );
  }
}