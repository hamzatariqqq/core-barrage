import 'dart:math';

import 'package:flame/components.dart';

import '../../components/pickups/battlefield_pickups.dart';
import '../../components/player/player_vehicle.dart';

class BattlefieldPickupSpawner extends Component {
  BattlefieldPickupSpawner({
    required this.gameSize,
    required this.level,
    required this.onCoinsCollected,
    required this.onMissileReady,
  });

  final Vector2 gameSize;
  final int level;

  final void Function(int amount) onCoinsCollected;
  final void Function() onMissileReady;

  final Random _random = Random();

  double _elapsed = 0;
  bool _stopped = false;

  bool _crateOneDone = false;
  bool _coinLineDone = false;
  bool _firepowerDone = false;
  bool _crateTwoDone = false;
  bool _missileDone = false;
  bool _armyDone = false;

  // ============================================================
  // ROAD
  // ============================================================

  double get _roadLeft => gameSize.x * .27;

  double get _roadRight => gameSize.x * .73;

  double get _roadWidth => _roadRight - _roadLeft;

  double _roadX(double lane) {
    return _roadLeft + _roadWidth * lane;
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    if (_stopped) return;

    _elapsed += dt;

    if (level == 1) {
      _updateLevel1();
      return;
    }

    if (level == 2) {
      _updateLevel2();
      return;
    }

    _updateStandardLevels();
  }

  // ============================================================
  // LEVEL 1
  // ============================================================

  void _updateLevel1() {
    if (_elapsed >= 16.0 && !_crateOneDone) {
      _crateOneDone = true;

      _spawnCrateLane(
        count: 2,
      );
    }

    // Only 4 guaranteed gameplay coins.
    if (_elapsed >= 25.0 && !_coinLineDone) {
      _coinLineDone = true;

      _spawnCoinLine(
        coinCount: 1,
        coinValue: 4,
      );
    }

    if (_elapsed >= 31.0 && !_firepowerDone) {
      _firepowerDone = true;

      _spawnPickup(
        type: BattlefieldPickupType.firepower,
        value: 1,
        x: _roadX(
          _random.nextBool() ? .38 : .62,
        ),
      );
    }

    if (_elapsed >= 46.0 && !_missileDone) {
      _missileDone = true;

      _spawnPickup(
        type: BattlefieldPickupType.missile,
        value: 1,
        x: _roadX(.5),
      );
    }
  }

  // ============================================================
  // LEVEL 2
  // ============================================================

  void _updateLevel2() {
    if (_elapsed >= 12.0 && !_crateOneDone) {
      _crateOneDone = true;

      _spawnCrateLane(
        count: 2,
      );
    }

    if (_elapsed >= 23.0 && !_firepowerDone) {
      _firepowerDone = true;

      _spawnPickup(
        type: BattlefieldPickupType.firepower,
        value: 1,
        x: _roadX(
          _random.nextBool() ? .34 : .66,
        ),
      );
    }

    // Only 4 guaranteed gameplay coins.
    if (_elapsed >= 34.0 && !_coinLineDone) {
      _coinLineDone = true;

      _spawnCoinLine(
        coinCount: 1,
        coinValue: 4,
      );
    }

    if (_elapsed >= 43.0 && !_crateTwoDone) {
      _crateTwoDone = true;

      _spawnCrateLane(
        count: 2,
      );
    }

    if (_elapsed >= 52.0 && !_missileDone) {
      _missileDone = true;

      _spawnPickup(
        type: BattlefieldPickupType.missile,
        value: 1,
        x: _roadX(.5),
      );
    }

    if (_elapsed >= 60.0 && !_armyDone) {
      _armyDone = true;

      _spawnPickup(
        type: BattlefieldPickupType.army,
        value: 2,
        x: _roadX(
          _random.nextBool() ? .38 : .62,
        ),
      );
    }
  }

  // ============================================================
  // LEVELS 3–15
  // ============================================================

  void _updateStandardLevels() {
    if (_elapsed >= 13.0 && !_crateOneDone) {
      _crateOneDone = true;

      _spawnCrateLane(
        count: level >= 10 ? 3 : 2,
      );
    }

    // Only ONE guaranteed coin pickup per mission.
    if (_elapsed >= 28.0 && !_coinLineDone) {
      _coinLineDone = true;

      _spawnCoinLine(
        coinCount: 1,
        coinValue: _coinValueForLevel(),
      );
    }

    if (_elapsed >= 36.0 && !_firepowerDone) {
      _firepowerDone = true;

      _spawnPickup(
        type: BattlefieldPickupType.firepower,
        value: 1,
        x: _roadX(
          _random.nextBool() ? .32 : .68,
        ),
      );
    }

    if (_elapsed >= 48.0 && !_crateTwoDone) {
      _crateTwoDone = true;

      _spawnCrateLane(
        count: level >= 10 ? 3 : 2,
      );
    }

    if (_elapsed >= 58.0 && !_missileDone) {
      _missileDone = true;

      _spawnPickup(
        type: BattlefieldPickupType.missile,
        value: 1,
        x: _roadX(.5),
      );
    }

    if (_elapsed >= 68.0 && !_armyDone) {
      _armyDone = true;

      _spawnPickup(
        type: BattlefieldPickupType.army,
        value: _armyPickupForLevel(),
        x: _roadX(
          _random.nextBool() ? .37 : .63,
        ),
      );
    }
  }

  // ============================================================
  // VERY LIMITED GAMEPLAY COINS
  // ============================================================

  int _coinValueForLevel() {
    if (level <= 3) {
      return 4;
    }

    if (level <= 6) {
      return 5;
    }

    if (level <= 9) {
      return 6;
    }

    if (level <= 12) {
      return 7;
    }

    if (level <= 14) {
      return 8;
    }

    return 10;
  }

  // ============================================================
  // LIMITED ARMY PICKUPS
  // ============================================================

  int _armyPickupForLevel() {
    if (level <= 5) {
      return 2;
    }

    if (level <= 10) {
      return 3;
    }

    return 4;
  }

  // ============================================================
  // SPAWN PICKUP
  // ============================================================

  void _spawnPickup({
    required BattlefieldPickupType type,
    required int value,
    required double x,
    double y = -65,
  }) {
    if (_stopped) return;

    parent?.add(
      BattlefieldPickup(
        position: Vector2(
          x,
          y,
        ),
        type: type,
        value: value,
        scrollSpeed: 118 + level * 1.5,
        onCollected: (
            BattlefieldPickupType pickupType,
            int pickupValue,
            PlayerVehicle player,
            ) {
          _handlePickup(
            pickupType,
            pickupValue,
            player,
          );
        },
      ),
    );
  }

  // ============================================================
  // PICKUP EFFECT
  // ============================================================

  void _handlePickup(
      BattlefieldPickupType type,
      int value,
      PlayerVehicle player,
      ) {
    if (_stopped || !player.isMounted) {
      return;
    }

    switch (type) {
      case BattlefieldPickupType.coin:
        onCoinsCollected(value);
        break;

      case BattlefieldPickupType.missile:
        onMissileReady();
        break;

      case BattlefieldPickupType.firepower:
      // Small temporary boost.
        player.applyFirepowerMultiplier(
          1.10,
        );
        break;

      case BattlefieldPickupType.army:
        player.addArmy(value);
        break;
    }
  }

  // ============================================================
  // COIN LINE
  // ============================================================

  void _spawnCoinLine({
    required int coinCount,
    required int coinValue,
  }) {
    if (_stopped) return;

    final leftRoute = _random.nextBool();

    final centerX = _roadX(
      leftRoute ? .34 : .66,
    );

    for (int i = 0; i < coinCount; i++) {
      add(
        TimerComponent(
          period: i * .22,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) return;

            final denominator = max(
              1,
              coinCount - 1,
            );

            final curve = sin(
              i / denominator * pi,
            ) *
                10;

            _spawnPickup(
              type: BattlefieldPickupType.coin,
              value: coinValue,
              x: centerX +
                  (leftRoute
                      ? curve
                      : -curve),
              y: -60 - i * 18,
            );
          },
        ),
      );
    }
  }

  // ============================================================
  // CRATES
  // ============================================================

  void _spawnCrateLane({
    required int count,
  }) {
    if (_stopped) return;

    final availableLanes = <double>[
      .24,
      .50,
      .76,
    ];

    availableLanes.shuffle(
      _random,
    );

    final safeLane = availableLanes.first;

    final dangerousLanes = availableLanes
        .where(
          (lane) => lane != safeLane,
    )
        .toList();

    for (int i = 0; i < count; i++) {
      final lane = dangerousLanes[
      i % dangerousLanes.length];

      final row =
          i ~/ dangerousLanes.length;

      parent?.add(
        BattleSupplyCrate(
          position: Vector2(
            _roadX(lane),
            -75 - row * 78,
          ),
          scrollSpeed:
          112 + level * 1.7,
          health:
          125 + level * 6,
          onDestroyed: (
              Vector2 position,
              ) {
            if (_stopped) return;

            // Extremely rare crate coin.
            // Old chance: 12%
            // New chance: 3%
            if (_random.nextDouble() <
                .03) {
              _spawnPickup(
                type:
                BattlefieldPickupType
                    .coin,
                value:
                _crateCoinValue(),
                x: position.x,
                y: position.y,
              );
            }
          },
        ),
      );
    }

    // Extremely rare safe-route coin.
    // Old chance: 8%
    // New chance: 2%
    if (_random.nextDouble() < .02) {
      _spawnPickup(
        type:
        BattlefieldPickupType.coin,
        value:
        _safeLaneCoinValue(),
        x: _roadX(safeLane),
        y: -135,
      );
    }
  }

  // ============================================================
  // RARE CRATE COIN VALUES
  // ============================================================

  int _crateCoinValue() {
    if (level <= 5) {
      return 2;
    }

    if (level <= 10) {
      return 3;
    }

    return 4;
  }

  int _safeLaneCoinValue() {
    if (level <= 5) {
      return 2;
    }

    if (level <= 10) {
      return 3;
    }

    return 5;
  }

  // ============================================================
  // STOP
  // ============================================================

  void stop() {
    _stopped = true;
  }
}