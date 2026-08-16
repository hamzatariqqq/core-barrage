import 'dart:math';

import 'package:flame/components.dart';

import '../../components/gates/army_gate.dart';

class GateSpawner extends Component {
  GateSpawner({
    required this.gameSize,
  });

  final Vector2 gameSize;

  final Random _random = Random();

  double _timer = 0;
  static const double spawnInterval = 8;

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;

    if (_timer >= spawnInterval) {
      _timer = 0;
      _spawnGatePair();
    }
  }

  void _spawnGatePair() {
    final leftValue = _random.nextBool() ? 10 : 20;
    final multiplier = _random.nextBool() ? 2 : 3;

    parent?.add(
      ArmyGate(
        position: Vector2(gameSize.x * 0.35, -50),
        value: leftValue,
        type: ArmyGateType.add,
      ),
    );

    parent?.add(
      ArmyGate(
        position: Vector2(gameSize.x * 0.65, -50),
        value: multiplier,
        type: ArmyGateType.multiply,
      ),
    );
  }
}