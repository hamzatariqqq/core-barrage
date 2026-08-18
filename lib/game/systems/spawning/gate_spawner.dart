import 'package:flame/components.dart';

import '../../components/gates/army_gate.dart';

class GateSpawner extends Component {
  GateSpawner({
    required this.gameSize,
  });

  final Vector2 gameSize;

  double _time = 0;

  bool _firstGateDone = false;
  bool _secondGateDone = false;
  bool _thirdGateDone = false;

  @override
  void update(double dt) {
    super.update(dt);

    _time += dt;

    if (_time >= 10 && !_firstGateDone) {
      _firstGateDone = true;

      _spawnPair(
        leftValue: 5,
        leftType: ArmyGateType.add,
        rightValue: 10,
        rightType: ArmyGateType.add,
      );
    }

    if (_time >= 25 && !_secondGateDone) {
      _secondGateDone = true;

      _spawnPair(
        leftValue: 10,
        leftType: ArmyGateType.add,
        rightValue: 20,
        rightType: ArmyGateType.add,
      );
    }

    if (_time >= 40 && !_thirdGateDone) {
      _thirdGateDone = true;

      _spawnPair(
        leftValue: 20,
        leftType: ArmyGateType.add,
        rightValue: 2,
        rightType: ArmyGateType.multiply,
      );
    }
  }

  void _spawnPair({
    required int leftValue,
    required ArmyGateType leftType,
    required int rightValue,
    required ArmyGateType rightType,
  }) {
    parent?.add(
      ArmyGate(
        position: Vector2(
          gameSize.x * 0.27,
          -50,
        ),
        value: leftValue,
        type: leftType,
      ),
    );

    parent?.add(
      ArmyGate(
        position: Vector2(
          gameSize.x * 0.73,
          -50,
        ),
        value: rightValue,
        type: rightType,
      ),
    );
  }
}