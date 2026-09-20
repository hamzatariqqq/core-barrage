import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../../components/gates/army_gate.dart';
import '../../components/player/player_vehicle.dart';
import '../level/level_1_director.dart';

class GateSpawner extends Component
    with HasGameReference<FlameGame> {
  GateSpawner({
    required this.gameSize,
  });

  final Vector2 gameSize;

  bool _stopped = false;

  int _nextChoiceId = 1;

  // ============================================================
  // STOP
  // ============================================================

  void stop() {
    _stopped = true;

    final gates =
    game.children
        .whereType<ArmyGate>()
        .toList();

    for (final gate in gates) {
      gate.removeFromParent();
    }
  }

  // ============================================================
  // SPAWN DIRECTOR GATE
  // ============================================================

  void spawnGate(
      Level1Gate gate,
      ) {
    if (_stopped) {
      return;
    }

    // Never allow old gate choices to remain on screen when
    // another choice begins.
    _removeExistingGates();

    switch (gate) {
    // --------------------------------------------------------
    // FIRST
    // --------------------------------------------------------

      case Level1Gate.firstChoice:
        _spawnPair(
          leftLabel: '+10',
          leftType: ArmyGateType.addArmy,
          leftValue: 10,
          rightLabel: '+20',
          rightType: ArmyGateType.addArmy,
          rightValue: 20,
        );
        break;

    // --------------------------------------------------------
    // SECOND
    // --------------------------------------------------------

      case Level1Gate.secondChoice:
        _spawnPair(
          leftLabel: '+15',
          leftType: ArmyGateType.addArmy,
          leftValue: 15,
          rightLabel: 'x2',
          rightType: ArmyGateType.firepower,
          rightValue: 2,
        );
        break;

    // --------------------------------------------------------
    // THIRD
    // --------------------------------------------------------

      case Level1Gate.thirdChoice:
        _spawnPair(
          leftLabel: 'x2',
          leftType: ArmyGateType.multiplyArmy,
          leftValue: 2,
          rightLabel: '+30',
          rightType: ArmyGateType.addArmy,
          rightValue: 30,
        );
        break;

    // --------------------------------------------------------
    // FINAL
    // --------------------------------------------------------

      case Level1Gate.finalChoice:
        _spawnPair(
          leftLabel: '+40',
          leftType: ArmyGateType.addArmy,
          leftValue: 40,
          rightLabel: 'x2',
          rightType: ArmyGateType.firepower,
          rightValue: 2,
        );
        break;
    }
  }

  // ============================================================
  // SPAWN CENTERED PAIR
  // ============================================================

  void _spawnPair({
    required String leftLabel,
    required ArmyGateType leftType,
    required double leftValue,
    required String rightLabel,
    required ArmyGateType rightType,
    required double rightValue,
  }) {
    if (_stopped) {
      return;
    }

    final choiceId =
    _nextChoiceId++;

    const spawnY = -95.0;

    // ==========================================================
    // CENTER ROAD POSITION
    //
    // NOT:
    // 0.30 / 0.70
    // 0.34 / 0.66
    //
    // These remain around the middle.
    // ==========================================================

    final centerX =
        gameSize.x * 0.50;

    final pairSpacing =
        gameSize.x * 0.105;

    final leftX =
        centerX - pairSpacing;

    final rightX =
        centerX + pairSpacing;

    final leftGate =
    ArmyGate(
      position: Vector2(
        leftX,
        spawnY,
      ),
      label: leftLabel,
      type: leftType,
      value: leftValue,
      choiceId: choiceId,
      fallSpeed: 138,
      onCollected: _applyGate,
    );

    final rightGate =
    ArmyGate(
      position: Vector2(
        rightX,
        spawnY,
      ),
      label: rightLabel,
      type: rightType,
      value: rightValue,
      choiceId: choiceId,
      fallSpeed: 138,
      onCollected: _applyGate,
    );

    game.add(leftGate);
    game.add(rightGate);
  }

  // ============================================================
  // APPLY GATE
  // ============================================================

  void _applyGate(
      ArmyGate selected,
      ) {
    if (_stopped) {
      return;
    }

    final player =
    _findPlayer();

    if (player == null ||
        !player.isMounted) {
      return;
    }

    switch (selected.type) {
    // --------------------------------------------------------
    // ADD ARMY
    // --------------------------------------------------------

      case ArmyGateType.addArmy:
      case ArmyGateType.addSoldiers:
        player.addArmy(
          selected.value.round(),
        );
        break;

    // --------------------------------------------------------
    // MULTIPLY ARMY
    // --------------------------------------------------------

      case ArmyGateType.multiplyArmy:
        final currentArmy =
            player.armyCount;

        final targetArmy =
        (currentArmy *
            selected.value)
            .round();

        final amountToAdd =
            targetArmy -
                currentArmy;

        if (amountToAdd > 0) {
          player.addArmy(
            amountToAdd,
          );
        }

        break;

    // --------------------------------------------------------
    // FIREPOWER
    // --------------------------------------------------------

      case ArmyGateType.firepower:
        player.applyFirepowerMultiplier(
          selected.value,
        );
        break;
    }

    // Once one gate is selected, immediately remove its sibling.
    _removeChoice(
      selected.choiceId,
      selected,
    );
  }

  // ============================================================
  // FIND PLAYER
  // ============================================================

  PlayerVehicle? _findPlayer() {
    for (final child
    in game.children) {
      if (child
      is PlayerVehicle) {
        return child;
      }
    }

    return null;
  }

  // ============================================================
  // REMOVE SIBLING
  // ============================================================

  void _removeChoice(
      int choiceId,
      ArmyGate selected,
      ) {
    final gates =
    game.children
        .whereType<ArmyGate>()
        .toList();

    for (final gate in gates) {
      if (gate == selected) {
        continue;
      }

      if (gate.choiceId ==
          choiceId) {
        gate.removeFromParent();
      }
    }
  }

  // ============================================================
  // REMOVE OLD GATES
  // ============================================================

  void _removeExistingGates() {
    final gates =
    game.children
        .whereType<ArmyGate>()
        .toList();

    for (final gate in gates) {
      gate.removeFromParent();
    }
  }
}