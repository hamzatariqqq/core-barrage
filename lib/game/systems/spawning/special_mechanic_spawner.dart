import 'dart:math';

import 'package:flame/components.dart';

import '../../components/enemies/elite_enemy.dart';
import '../../components/enemies/enemy_assault_vehicle.dart';
import '../../components/gates/shield_gate.dart';
import '../../components/hazards/airstrike_zone.dart';
import '../../components/hazards/battle_barricade.dart';
import '../../components/hazards/battle_mine.dart';
import '../../components/hazards/enemy_turret.dart';

import '../level/special_mechanic_director.dart';

class SpecialMechanicSpawner extends Component {
  SpecialMechanicSpawner({
    required this.gameSize,
  });

  final Vector2 gameSize;
  final Random _random = Random();

  bool _stopped = false;

  double get _roadLeft => gameSize.x * .28;
  double get _roadRight => gameSize.x * .72;
  double get _roadWidth => _roadRight - _roadLeft;

  // ============================================================
  // MAIN EVENT
  // ============================================================

  void spawn(
      SpecialMechanicEvent event,
      ) {
    if (_stopped) {
      return;
    }

    switch (event.type) {
      case SpecialMechanicEventType.none:
        return;

      case SpecialMechanicEventType.movingGate:
      // Level 2 already owns its moving-gate sequence.
        return;

      case SpecialMechanicEventType.mineField:
        _spawnMineField(event);
        return;

      case SpecialMechanicEventType.turretWave:
        _spawnTurretWave(event);
        return;

      case SpecialMechanicEventType.bossPressure:
        _spawnBossPressure(event);
        return;

      case SpecialMechanicEventType.speedBoost:
        _spawnFastMineLane(event);
        return;

      case SpecialMechanicEventType.barricadeWave:
        _spawnBarricadeWave(event);
        return;

      case SpecialMechanicEventType.eliteWave:
        _spawnEliteWave(event);
        return;

      case SpecialMechanicEventType.riskyGate:
        _spawnRiskZone(event);
        return;

      case SpecialMechanicEventType.majorBossPressure:
        _spawnMajorPressure(event);
        return;

      case SpecialMechanicEventType.airstrike:
        _spawnAirstrike(event);
        return;

      case SpecialMechanicEventType.shieldGate:
        _spawnShieldGate(event);
        return;

      case SpecialMechanicEventType.enemyVehicle:
        _spawnVehicleAssault(event);
        return;

      case SpecialMechanicEventType.highRiskAssault:
        _spawnHighRisk(event);
        return;

      case SpecialMechanicEventType.finalCommandAssault:
        _spawnFinalCommand(event);
        return;
    }
  }

  // ============================================================
  // LEVEL 3 — MINES
  // ============================================================

  void _spawnMineField(
      SpecialMechanicEvent event,
      ) {
    final count = event.index == 1
        ? 3
        : event.index == 2
        ? 4
        : 5;

    for (int i = 0; i < count; i++) {
      add(
        TimerComponent(
          period: i * .32,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            parent?.add(
              BattleMine(
                position: Vector2(
                  _randomRoadX(),
                  -55 - (i % 2) * 46,
                ),
                damage: 12 + event.intensity * 5,
                scrollSpeed: 96 + event.intensity * 6,
              ),
            );
          },
        ),
      );
    }
  }

  // ============================================================
  // LEVEL 6 — SPEED / FAST LANE
  // ============================================================

  void _spawnFastMineLane(
      SpecialMechanicEvent event,
      ) {
    final lane = _random.nextBool() ? .40 : .60;

    final count = event.index == 1
        ? 3
        : event.index == 2
        ? 4
        : 5;

    for (int i = 0; i < count; i++) {
      add(
        TimerComponent(
          period: i * .27,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            parent?.add(
              BattleMine(
                position: Vector2(
                  gameSize.x * lane,
                  -45 - i * 58,
                ),
                scrollSpeed: 125 + event.intensity * 5,
                damage: 14 + event.intensity * 5,
              ),
            );
          },
        ),
      );
    }
  }

  // ============================================================
  // LEVEL 4 — TURRETS
  // ============================================================

  void _spawnTurretWave(
      SpecialMechanicEvent event,
      ) {
    final count = event.index == 1 ? 1 : 2;

    for (int i = 0; i < count; i++) {
      add(
        TimerComponent(
          period: i * .95,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            final fraction = count == 1
                ? .50
                : i == 0
                ? .40
                : .60;

            parent?.add(
              EnemyTurret(
                position: Vector2(
                  gameSize.x * fraction,
                  -75 - i * 55,
                ),
                fireInterval: max(
                  1.35,
                  2.45 - event.intensity * .35,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  // ============================================================
  // LEVEL 7 — BARRICADES
  // ============================================================

  void _spawnBarricadeWave(
      SpecialMechanicEvent event,
      ) {
    final count = event.index == 1 ? 2 : 3;

    final fractions = count == 2
        ? <double>[.39, .61]
        : <double>[.36, .50, .64];

    for (int i = 0; i < count; i++) {
      parent?.add(
        BattleBarricade(
          position: Vector2(
            gameSize.x * fractions[i],
            -75 - i * 70,
          ),
          damage: 9 + event.intensity * 3,
          scrollSpeed: 94 + event.intensity * 5,
        ),
      );
    }
  }

  // ============================================================
  // LEVEL 5 — BOSS PRESSURE
  // ============================================================

  void _spawnBossPressure(
      SpecialMechanicEvent event,
      ) {
    _spawnTurretWave(
      SpecialMechanicEvent(
        type: SpecialMechanicEventType.turretWave,
        intensity: event.intensity * .88,
        index: event.index == 1 ? 1 : 2,
      ),
    );

    add(
      TimerComponent(
        period: 1.25,
        removeOnFinish: true,
        onTick: () {
          if (_stopped) {
            return;
          }

          _spawnBarricadeWave(
            SpecialMechanicEvent(
              type: SpecialMechanicEventType.barricadeWave,
              intensity: event.intensity * .82,
              index: 1,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // LEVEL 8 — ELITE ENEMIES
  // ============================================================

  void _spawnEliteWave(
      SpecialMechanicEvent event,
      ) {
    final count = event.index == 1
        ? 1
        : event.index == 2
        ? 2
        : 3;

    final positions = count == 1
        ? <double>[.50]
        : count == 2
        ? <double>[.42, .58]
        : <double>[.38, .50, .62];

    for (int i = 0; i < count; i++) {
      add(
        TimerComponent(
          period: i * .72,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            parent?.add(
              EliteEnemy(
                position: Vector2(
                  gameSize.x * positions[i],
                  -90 - (i % 2) * 58,
                ),
                difficulty: event.intensity * .90,
              ),
            );
          },
        ),
      );
    }

    // Turret support only for the final encounter.
    if (event.index >= 3) {
      add(
        TimerComponent(
          period: 1.8,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            parent?.add(
              EnemyTurret(
                position: Vector2(
                  gameSize.x * .50,
                  -110,
                ),
                fireInterval: max(
                  1.25,
                  2.05 - event.intensity * .25,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  // ============================================================
  // LEVEL 9 — RISK ZONE
  // ============================================================

  void _spawnRiskZone(
      SpecialMechanicEvent event,
      ) {
    final reducedEvent = SpecialMechanicEvent(
      type: SpecialMechanicEventType.mineField,
      intensity: event.intensity * .82,
      index: event.index == 1 ? 1 : 2,
    );

    _spawnMineField(
      reducedEvent,
    );

    add(
      TimerComponent(
        period: 1.35,
        removeOnFinish: true,
        onTick: () {
          if (_stopped) {
            return;
          }

          _spawnBarricadeWave(
            SpecialMechanicEvent(
              type: SpecialMechanicEventType.barricadeWave,
              intensity: event.intensity * .78,
              index: 1,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // LEVEL 10 — MAJOR BOSS PRESSURE
  // ============================================================

  void _spawnMajorPressure(
      SpecialMechanicEvent event,
      ) {
    _spawnTurretWave(
      SpecialMechanicEvent(
        type: SpecialMechanicEventType.turretWave,
        intensity: event.intensity * .92,
        index: event.index == 1 ? 1 : 2,
      ),
    );

    add(
      TimerComponent(
        period: 1.3,
        removeOnFinish: true,
        onTick: () {
          if (_stopped) {
            return;
          }

          _spawnBarricadeWave(
            SpecialMechanicEvent(
              type: SpecialMechanicEventType.barricadeWave,
              intensity: event.intensity * .84,
              index: event.index >= 2 ? 2 : 1,
            ),
          );
        },
      ),
    );

    // Airstrike appears only from encounter 2 onward.
    if (event.index >= 2) {
      add(
        TimerComponent(
          period: 2.4,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            _spawnAirstrike(
              SpecialMechanicEvent(
                type: SpecialMechanicEventType.airstrike,
                intensity: event.intensity * .75,
                index: 1,
              ),
            );
          },
        ),
      );
    }
  }

  // ============================================================
  // LEVEL 11 — AIRSTRIKES
  // ============================================================

  void _spawnAirstrike(
      SpecialMechanicEvent event,
      ) {
    final count = event.index == 1 ? 1 : 2;

    for (int i = 0; i < count; i++) {
      add(
        TimerComponent(
          period: i * .85,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            parent?.add(
              AirstrikeZone(
                position: Vector2(
                  _randomRoadX(),
                  gameSize.y *
                      (.48 + _random.nextDouble() * .18),
                ),
                radius: 48 + event.intensity * 3,
                warningDuration: max(
                  1.10,
                  2.15 - event.intensity * .28,
                ),
                damage: 18 + event.intensity * 6,
              ),
            );
          },
        ),
      );
    }
  }

  // ============================================================
  // LEVEL 12 — SHIELD GATE
  // ============================================================

  void _spawnShieldGate(
      SpecialMechanicEvent event,
      ) {
    parent?.add(
      ShieldGate(
        position: Vector2(
          gameSize.x * .50,
          -85,
        ),
        scrollSpeed: 100 + event.intensity * 3,
      ),
    );

    // Side barricades only after the first introduction.
    if (event.index >= 2) {
      add(
        TimerComponent(
          period: .75,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            parent?.add(
              BattleBarricade(
                position: Vector2(
                  gameSize.x * .34,
                  -110,
                ),
                scrollSpeed: 98,
                damage: 12,
              ),
            );

            parent?.add(
              BattleBarricade(
                position: Vector2(
                  gameSize.x * .66,
                  -110,
                ),
                scrollSpeed: 98,
                damage: 12,
              ),
            );
          },
        ),
      );
    }

    // Turret only in the third encounter.
    if (event.index >= 3) {
      add(
        TimerComponent(
          period: 1.8,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            parent?.add(
              EnemyTurret(
                position: Vector2(
                  gameSize.x * .50,
                  -155,
                ),
                fireInterval: 1.75,
              ),
            );
          },
        ),
      );
    }
  }

  // ============================================================
  // LEVEL 13 — ENEMY VEHICLES
  // ============================================================

  void _spawnVehicleAssault(
      SpecialMechanicEvent event,
      ) {
    final count = event.index >= 3 ? 2 : 1;

    final fractions = count == 1
        ? <double>[.50]
        : <double>[.42, .58];

    for (int i = 0; i < count; i++) {
      add(
        TimerComponent(
          period: i * 1.25,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            parent?.add(
              EnemyAssaultVehicle(
                position: Vector2(
                  gameSize.x * fractions[i],
                  -105 - i * 82,
                ),
                difficulty: event.intensity * .88,
              ),
            );
          },
        ),
      );
    }

    // Escort elites appear from encounter 2.
    if (event.index >= 2) {
      add(
        TimerComponent(
          period: 1.1,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            parent?.add(
              EliteEnemy(
                position: Vector2(
                  gameSize.x * .40,
                  -155,
                ),
                difficulty: event.intensity * .68,
              ),
            );

            parent?.add(
              EliteEnemy(
                position: Vector2(
                  gameSize.x * .60,
                  -155,
                ),
                difficulty: event.intensity * .68,
              ),
            );
          },
        ),
      );
    }
  }

  // ============================================================
  // LEVEL 14 — HIGH RISK
  //
  // Hazards arrive in stages instead of stacking instantly.
  // ============================================================

  void _spawnHighRisk(
      SpecialMechanicEvent event,
      ) {
    // Encounter 1 — mines followed by light elite pressure.
    if (event.index == 1) {
      _spawnMineField(
        SpecialMechanicEvent(
          type: SpecialMechanicEventType.mineField,
          intensity: event.intensity * .72,
          index: 1,
        ),
      );

      add(
        TimerComponent(
          period: 1.25,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            _spawnEliteWave(
              SpecialMechanicEvent(
                type: SpecialMechanicEventType.eliteWave,
                intensity: event.intensity * .72,
                index: 1,
              ),
            );
          },
        ),
      );

      return;
    }

    // Encounter 2 — elites followed by a warning airstrike.
    if (event.index == 2) {
      _spawnEliteWave(
        SpecialMechanicEvent(
          type: SpecialMechanicEventType.eliteWave,
          intensity: event.intensity * .74,
          index: 2,
        ),
      );

      add(
        TimerComponent(
          period: 1.65,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            _spawnAirstrike(
              SpecialMechanicEvent(
                type: SpecialMechanicEventType.airstrike,
                intensity: event.intensity * .72,
                index: 1,
              ),
            );
          },
        ),
      );

      return;
    }

    // Encounter 3 — strongest Level 14 encounter,
    // but every hazard remains staggered.
    _spawnMineField(
      SpecialMechanicEvent(
        type: SpecialMechanicEventType.mineField,
        intensity: event.intensity * .76,
        index: 2,
      ),
    );

    add(
      TimerComponent(
        period: 1.55,
        removeOnFinish: true,
        onTick: () {
          if (_stopped) {
            return;
          }

          _spawnEliteWave(
            SpecialMechanicEvent(
              type: SpecialMechanicEventType.eliteWave,
              intensity: event.intensity * .76,
              index: 2,
            ),
          );
        },
      ),
    );

    add(
      TimerComponent(
        period: 3.20,
        removeOnFinish: true,
        onTick: () {
          if (_stopped) {
            return;
          }

          _spawnAirstrike(
            SpecialMechanicEvent(
              type: SpecialMechanicEventType.airstrike,
              intensity: event.intensity * .74,
              index: 1,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // LEVEL 15 — FINAL COMMAND
  //
  // The strongest mission, but encounters are staged so the
  // player always has a chance to react.
  // ============================================================

  void _spawnFinalCommand(
      SpecialMechanicEvent event,
      ) {
    // ----------------------------------------------------------
    // EVENT 1 — COMMAND FRONT LINE
    // ----------------------------------------------------------

    if (event.index == 1) {
      _spawnEliteWave(
        SpecialMechanicEvent(
          type: SpecialMechanicEventType.eliteWave,
          intensity: event.intensity * .74,
          index: 2,
        ),
      );

      add(
        TimerComponent(
          period: 1.60,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            _spawnTurretWave(
              SpecialMechanicEvent(
                type: SpecialMechanicEventType.turretWave,
                intensity: event.intensity * .70,
                index: 1,
              ),
            );
          },
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // EVENT 2 — ARMORED ASSAULT
    // ----------------------------------------------------------

    if (event.index == 2) {
      _spawnVehicleAssault(
        SpecialMechanicEvent(
          type: SpecialMechanicEventType.enemyVehicle,
          intensity: event.intensity * .74,
          index: 2,
        ),
      );

      add(
        TimerComponent(
          period: 2.00,
          removeOnFinish: true,
          onTick: () {
            if (_stopped) {
              return;
            }

            _spawnMineField(
              SpecialMechanicEvent(
                type: SpecialMechanicEventType.mineField,
                intensity: event.intensity * .68,
                index: 2,
              ),
            );
          },
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // EVENT 3 — FINAL PRE-BOSS COMMAND
    // ----------------------------------------------------------

    _spawnEliteWave(
      SpecialMechanicEvent(
        type: SpecialMechanicEventType.eliteWave,
        intensity: event.intensity * .78,
        index: 2,
      ),
    );

    add(
      TimerComponent(
        period: 1.50,
        removeOnFinish: true,
        onTick: () {
          if (_stopped) {
            return;
          }

          _spawnVehicleAssault(
            SpecialMechanicEvent(
              type: SpecialMechanicEventType.enemyVehicle,
              intensity: event.intensity * .76,
              index: 2,
            ),
          );
        },
      ),
    );

    add(
      TimerComponent(
        period: 3.20,
        removeOnFinish: true,
        onTick: () {
          if (_stopped) {
            return;
          }

          _spawnTurretWave(
            SpecialMechanicEvent(
              type: SpecialMechanicEventType.turretWave,
              intensity: event.intensity * .72,
              index: 2,
            ),
          );
        },
      ),
    );

    add(
      TimerComponent(
        period: 4.80,
        removeOnFinish: true,
        onTick: () {
          if (_stopped) {
            return;
          }

          _spawnAirstrike(
            SpecialMechanicEvent(
              type: SpecialMechanicEventType.airstrike,
              intensity: event.intensity * .70,
              index: 1,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // RANDOM ROAD POSITION
  // ============================================================

  double _randomRoadX() {
    return _roadLeft +
        _random.nextDouble() * _roadWidth;
  }

  // ============================================================
  // STOP
  // ============================================================

  void stop() {
    _stopped = true;
  }
}