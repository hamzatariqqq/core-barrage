import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../app/progression/game_progress.dart';
import '../app/progression/level_progress.dart';
import '../app/progression/selected_level.dart';

import 'components/abilities/freeze_wave_effect.dart';
import 'components/abilities/missile_strike_effect.dart';

import 'components/bosses/basic_boss.dart';
import 'components/bosses/boss_battle_effect.dart';
import 'components/bosses/boss_entrance_warning.dart';
import 'components/bosses/boss_rage_banner.dart';
import 'components/bosses/boss_variant_visual.dart';
import 'components/bosses/iron_warden_aura.dart';

import 'components/effects/combat_impact_effect.dart';

import 'components/enemies/basic_enemy.dart';

import 'components/environment/level_2_atmosphere.dart';
import 'components/environment/level_atmosphere.dart';
import 'components/environment/level_image_background.dart';

import 'components/player/player_vehicle.dart';

import 'components/ui/game_hud.dart';
import 'components/ui/level_stage_banner.dart';

import 'services/game_audio.dart';

import 'systems/level/adaptive_level_director.dart';
import 'systems/level/level_1_director.dart';
import 'systems/level/level_2_director.dart';
import 'systems/level/level_asset_config.dart';
import 'systems/level/level_gameplay_config.dart';
import 'systems/level/level_manager.dart';
import 'systems/level/level_runtime_config.dart';
import 'systems/level/special_mechanic_director.dart';

import 'systems/spawning/battlefield_pickup_spawner.dart';
import 'systems/spawning/boss_spawner.dart';
import 'systems/spawning/enemy_spawner.dart';
import 'systems/spawning/gate_spawner.dart';
import 'systems/spawning/level_2_enemy_spawner.dart';
import 'systems/spawning/level_2_gate_spawner.dart';
import 'systems/spawning/special_mechanic_spawner.dart';

class CoreBarrageGame extends FlameGame
    with HasCollisionDetection {
  // ============================================================
  // PROGRESSION
  // ============================================================

  final GameProgress progress =
      GameProgress.instance;

  final LevelProgress levelProgress =
      LevelProgress.instance;

  // ============================================================
  // AUDIO
  // ============================================================

  final GameAudio audio =
      GameAudio.instance;

  // ============================================================
  // CURRENT LEVEL
  // ============================================================

  final int currentLevel =
      SelectedLevel.current;

  late final LevelRuntimeConfig levelConfig =
  LevelRuntimeConfig.forLevel(
    currentLevel,
  );

  late final LevelGameplayConfig gameplayConfig =
  LevelGameplayConfig.forLevel(
    currentLevel,
  );

  late final LevelAssetConfig assetConfig =
  LevelAssetConfig.forLevel(
    currentLevel,
  );

  int get victoryReward =>
      levelConfig.reward;

  String get levelTitle =>
      levelConfig.title;

  // ============================================================
  // STATE
  // ============================================================

  bool _gameOver = false;

  bool _rewardGiven = false;

  bool _bossRageShown = false;

  // ============================================================
  // PLAYER
  // ============================================================

  late PlayerVehicle player;

  // ============================================================
  // HUD
  // ============================================================

  late GameHud hud;

  // ============================================================
  // LEVEL
  // ============================================================

  late LevelManager levelManager;

  AdaptiveLevelDirector?
  adaptiveDirector;

  SpecialMechanicDirector?
  specialMechanicDirector;

  SpecialMechanicSpawner?
  specialMechanicSpawner;

  BattlefieldPickupSpawner?
  battlefieldPickupSpawner;

  // ============================================================
  // LEVEL 1
  // ============================================================

  Level1Director?
  level1Director;

  EnemySpawner?
  enemySpawner;

  GateSpawner?
  gateSpawner;

  // ============================================================
  // LEVEL 2
  // ============================================================

  Level2Director?
  level2Director;

  Level2EnemySpawner?
  level2EnemySpawner;

  Level2GateSpawner?
  level2GateSpawner;

  // ============================================================
  // BOSS
  // ============================================================

  late BossSpawner bossSpawner;

  BasicBoss?
  _activeBoss;

  IronWardenAura?
  _ironWardenAura;

  // ============================================================
  // ABILITIES
  // ============================================================

  double _missileCooldown =
  0;

  double _freezeCooldown =
  0;

  bool _freezeActive =
  false;

  double _freezeTimer =
  0;

  static const double
  _missileCooldownTime =
  12;

  static const double
  _freezeCooldownTime =
  15;

  static const double
  _freezeDuration =
  4;

  // ============================================================
  // BACKGROUND COLOR
  // ============================================================

  @override
  Color backgroundColor() {
    return Color.lerp(
      const Color(
        0xFF061018,
      ),
      levelConfig.secondaryAccent,
      .16,
    ) ??
        const Color(
          0xFF061018,
        );
  }

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ==========================================================
    // CAMERA
    //
    // World coordinates now match the visible game screen.
    // ==========================================================

    camera.viewfinder.anchor =
        Anchor.topLeft;

    camera.viewfinder.position =
        Vector2.zero();

    await audio.initialize();

    await _startLevel();
  }

  // ============================================================
  // START LEVEL
  // ============================================================

  Future<void> _startLevel() async {
    _gameOver =
    false;

    _rewardGiven =
    false;

    _bossRageShown =
    false;

    _missileCooldown =
    0;

    _freezeCooldown =
    0;

    _freezeActive =
    false;

    _freezeTimer =
    0;

    // ==========================================================
    // RESET DIRECTOR REFERENCES
    // ==========================================================

    level1Director =
    null;

    level2Director =
    null;

    enemySpawner =
    null;

    gateSpawner =
    null;

    level2EnemySpawner =
    null;

    level2GateSpawner =
    null;

    adaptiveDirector =
    null;

    specialMechanicDirector =
    null;

    specialMechanicSpawner =
    null;

    battlefieldPickupSpawner =
    null;

    _activeBoss =
    null;

    _ironWardenAura
        ?.removeFromParent();

    _ironWardenAura =
    null;

    // ==========================================================
    // OVERLAYS
    // ==========================================================

    overlays.remove(
      'pause',
    );

    overlays.remove(
      'victory',
    );

    overlays.remove(
      'defeat',
    );

    // ==========================================================
    // LEVEL MANAGER
    // ==========================================================

    levelManager =
        LevelManager();

    const double roadMargin =
    40.0;

    const double playerHalfWidth =
    30.0;

    // ==========================================================
    // BACKGROUND
    // ==========================================================

    debugPrint(
      'CORE BARRAGE: mounting background '
          '${assetConfig.background}',
    );

    double backgroundDuration;

    switch (currentLevel) {
      case 1:
        backgroundDuration = 55.0;
        break;

      case 2:
        backgroundDuration = 61.0;
        break;

      case 3:
        backgroundDuration = 60.0;
        break;

      default:
        backgroundDuration = 60.0;
        break;
    }

    await world.add(
      LevelImageBackground(
        gameSize: size,
        imagePath: assetConfig.background,
        scrollDuration: backgroundDuration,
      ),
    );
    debugPrint(
      'CORE BARRAGE: background mounted',
    );

    // ==========================================================
    // ATMOSPHERE
    // ==========================================================

    world.add(
      LevelAtmosphere(
        gameSize: size,
        config:
        levelConfig,
      ),
    );

    if (currentLevel == 2) {
      world.add(
        Level2Atmosphere(
          gameSize: size,
        ),
      );
    }

    // ==========================================================
    // HUD
    //
    // HUD belongs to camera viewport, not battlefield world.
    // ==========================================================

    hud =
        GameHud(
          gameSize: size,
          onPause:
          pauseGame,
          onMissile:
          activateMissile,
          onFreeze:
          activateFreeze,
          levelNumber:
          currentLevel,
          levelTitle:
          levelConfig.title,
          bossName:
          levelConfig.bossName,
          accent:
          levelConfig.accent,
        );

    await camera.viewport.add(
      hud,
    );

    hud.updateCoins(
      progress.coins,
    );

    // ==========================================================
    // PLAYER
    // ==========================================================

    player =
        PlayerVehicle(
          position:
          Vector2(
            size.x / 2,
            size.y - 155,
          ),
          minX:
          roadMargin +
              playerHalfWidth,
          maxX:
          size.x -
              roadMargin -
              playerHalfWidth,
          onPlayerDead:
          showDefeat,
        );

    await world.add(
      player,
    );

    // ==========================================================
    // PICKUPS + DESTRUCTIBLES
    // ==========================================================

    battlefieldPickupSpawner =
        BattlefieldPickupSpawner(
          gameSize: size,
          level:
          currentLevel,
          onCoinsCollected:
              (
              int amount,
              ) {
            unawaited(
              _collectBattleCoins(
                amount,
              ),
            );
          },
          onMissileReady:
              () {
            grantMissileReady();
          },
        );

    world.add(
      battlefieldPickupSpawner!,
    );

    // ==========================================================
    // LEVEL STARTING BONUSES
    // ==========================================================

    if (gameplayConfig
        .startingArmyBonus >
        0) {
      player.addArmy(
        gameplayConfig
            .startingArmyBonus,
      );
    }

    if (gameplayConfig
        .startingFirepower >
        1.0) {
      player
          .applyFirepowerMultiplier(
        gameplayConfig
            .startingFirepower,
      );
    }

    // ==========================================================
    // INTRO
    //
    // Levels 1 & 2 intentionally have no large opening banner.
    // Gameplay starts immediately.
    // ==========================================================

    switch (currentLevel) {
      case 1:
      case 2:
        break;

      case 3:
        _showStageBanner(
          title:
          'FROZEN OUTPOST',
          subtitle:
          'WHITEOUT PROTOCOL',
          accent:
          const Color(
            0xFFA6EDFF,
          ),
        );
        break;

      case 4:
        _showStageBanner(
          title:
          'JUNGLE WARZONE',
          subtitle:
          'AMBUSH TERRITORY',
          accent:
          const Color(
            0xFF52DF72,
          ),
        );
        break;

      case 5:
        _showStageBanner(
          title:
          'VOLCANIC ASSAULT',
          subtitle:
          'HEAVY MECH TERRITORY',
          accent:
          const Color(
            0xFFFF683D,
          ),
        );
        break;
    }

    // ==========================================================
    // BOSS SPAWNER
    // ==========================================================

    bossSpawner =
        BossSpawner(
          gameSize: size,
          currentLevel: currentLevel,

          // --------------------------------------------------------
          // BOSS SPAWNED
          // --------------------------------------------------------

          onBossSpawned:
              (
              BasicBoss boss,
              ) {
            if (_gameOver) {
              return;
            }

            _activeBoss =
                boss;

            world.add(
              BossVariantVisual(
                boss:
                boss,
                config:
                levelConfig,
              ),
            );

            unawaited(
              audio
                  .bossWarning(),
            );

            _showViewportComponent(
              BossEntranceWarning(
                gameSize: size,
              ),
            );

            _showViewportComponent(
              BossBattleEffect(
                gameSize: size,
              ),
            );

            // ------------------------------------------------------
            // LEVEL 2 IRON WARDEN AURA
            // ------------------------------------------------------

            if (currentLevel ==
                2) {
              final aura =
              IronWardenAura(
                position:
                boss.position
                    .clone(),
              );

              _ironWardenAura =
                  aura;

              world.add(
                aura,
              );
            }

            hud.showBoss();

            hud.updateBossHealth(
              health:
              boss.health,
              maxHealth:
              boss.maxHealthValue,
            );
          },

          // --------------------------------------------------------
          // BOSS DEFEATED
          // --------------------------------------------------------

          onBossDefeated:
              () {
            if (_gameOver) {
              return;
            }

            _activeBoss =
            null;

            _ironWardenAura
                ?.removeFromParent();

            _ironWardenAura =
            null;

            hud.hideBoss();

            showVictory();
          },
        );

    world.add(
      bossSpawner,
    );

    // ==========================================================
    // COMBAT FAMILY
    // ==========================================================

    if (gameplayConfig.pattern ==
        MissionCombatPattern
            .pressure) {
      _startLevel2();
    } else {
      _startLevel1();
    }

    // ==========================================================
    // ADAPTIVE LEVEL DIRECTOR
    // ==========================================================

    adaptiveDirector =
        AdaptiveLevelDirector(
          config:
          gameplayConfig,

          // --------------------------------------------------------
          // REINFORCEMENTS
          // --------------------------------------------------------

          onReinforcement:
              (
              int amount,
              ) {
            if (_gameOver ||
                !player.isMounted) {
              return;
            }

            player.addArmy(
              amount,
            );

            _showStageBanner(
              title:
              'REINFORCEMENTS',
              subtitle:
              '+$amount SOLDIERS',
              accent:
              const Color(
                0xFF37E88C,
              ),
            );
          },

          // --------------------------------------------------------
          // PRESSURE EVENT
          // --------------------------------------------------------

          onPressure:
              () {
            if (_gameOver) {
              return;
            }

            _showViewportComponent(
              CombatImpactEffect(
                gameSize: size,
                type:
                CombatImpactType
                    .bossRage,
              ),
            );
          },

          // --------------------------------------------------------
          // PROGRESS
          // --------------------------------------------------------

          onProgress:
              (
              double value,
              ) {
            if (_gameOver ||
                !hud.isMounted) {
              return;
            }

            hud.updateProgress(
              value,
            );
          },

          // --------------------------------------------------------
          // STAGE BANNER
          // --------------------------------------------------------

          onStageBanner:
              (
              String title,
              ) {
            if (_gameOver) {
              return;
            }

            _showStageBanner(
              title:
              title,
              subtitle:
              levelConfig.subtitle,
              accent:
              levelConfig.accent,
            );
          },
        );

    world.add(
      adaptiveDirector!,
    );

    // ==========================================================
    // SPECIAL MECHANICS
    // ==========================================================

    specialMechanicSpawner =
        SpecialMechanicSpawner(
          gameSize: size,
        );

    world.add(
      specialMechanicSpawner!,
    );

    specialMechanicDirector =
        SpecialMechanicDirector(
          config:
          gameplayConfig,
          onEvent:
              (
              SpecialMechanicEvent event,
              ) {
            if (_gameOver) {
              return;
            }

            specialMechanicSpawner
                ?.spawn(
              event,
            );
          },
        );

    world.add(
      specialMechanicDirector!,
    );
  }

  // ============================================================
  // LEVEL 1 FAMILY
  // ============================================================

  void _startLevel1() {
    enemySpawner =
        EnemySpawner(
          gameSize: size,
          currentLevel: currentLevel,
        );

    world.add(
      enemySpawner!,
    );

    gateSpawner =
        GateSpawner(
          gameSize: size,
        );

    world.add(
      gateSpawner!,
    );

    level1Director =
        Level1Director(
          // --------------------------------------------------------
          // WAVES
          // --------------------------------------------------------

          onWave:
              (
              Level1Wave wave,
              ) {
            if (_gameOver) {
              return;
            }

            enemySpawner
                ?.spawnWave(
              wave,
            );
          },

          // --------------------------------------------------------
          // GATES
          // --------------------------------------------------------

          onGate:
              (
              Level1Gate gate,
              ) {
            if (_gameOver) {
              return;
            }

            gateSpawner
                ?.spawnGate(
              gate,
            );
          },

          // --------------------------------------------------------
          // BOSS
          // --------------------------------------------------------

          onBoss:
              () {
            if (_gameOver) {
              return;
            }

            _startBossPhase();
          },

          // Adaptive director owns HUD progress.
          onProgress:
              (
              double value,
              ) {},

          // --------------------------------------------------------
          // LEVEL 1 STAGES
          // --------------------------------------------------------

          onStageChanged:
              (
              Level1Stage stage,
              ) {
            if (_gameOver) {
              return;
            }

            switch (stage) {
              case Level1Stage
                  .fortifiedApproach:
                _showStageBanner(
                  title:
                  'FORTRESS AHEAD',
                  subtitle:
                  'BREAK THE FINAL DEFENSE',
                  accent:
                  const Color(
                    0xFFFF9D32,
                  ),
                );
                break;

              case Level1Stage
                  .deployment:
              case Level1Stage
                  .firstGate:
              case Level1Stage
                  .firstCombat:
              case Level1Stage
                  .secondCombat:
              case Level1Stage
                  .secondGate:
              case Level1Stage
                  .heavyCombat:
              case Level1Stage
                  .thirdGate:
              case Level1Stage
                  .finalGate:
              case Level1Stage
                  .bossApproach:
              case Level1Stage
                  .complete:
                break;
            }
          },
        );

    world.add(
      level1Director!,
    );
  }

  // ============================================================
  // LEVEL 2 FAMILY
  // ============================================================

  void _startLevel2() {
    level2EnemySpawner =
        Level2EnemySpawner(
          gameSize: size,
        );

    world.add(
      level2EnemySpawner!,
    );

    level2GateSpawner =
        Level2GateSpawner(
          gameSize: size,
        );

    world.add(
      level2GateSpawner!,
    );

    level2Director =
        Level2Director(
          // --------------------------------------------------------
          // WAVES
          // --------------------------------------------------------

          onWave:
              (
              Level2Wave wave,
              ) {
            if (_gameOver) {
              return;
            }

            level2EnemySpawner
                ?.spawnWave(
              wave,
            );
          },

          // --------------------------------------------------------
          // GATES
          // --------------------------------------------------------

          onGate:
              (
              Level2Gate gate,
              ) {
            if (_gameOver) {
              return;
            }

            level2GateSpawner
                ?.spawnGate(
              gate,
            );
          },

          // --------------------------------------------------------
          // BOSS
          // --------------------------------------------------------

          onBoss:
              () {
            if (_gameOver) {
              return;
            }

            _startBossPhase();
          },

          // Adaptive director owns HUD progress.
          onProgress:
              (
              double value,
              ) {},

          // --------------------------------------------------------
          // LEVEL 2 STAGES
          // --------------------------------------------------------

          onStageChanged:
              (
              Level2Stage stage,
              ) {
            if (_gameOver) {
              return;
            }

            switch (stage) {
              case Level2Stage
                  .opening:
              case Level2Stage
                  .firstGate:
              case Level2Stage
                  .firstCombat:
                break;

              case Level2Stage
                  .pressure:
                _showStageBanner(
                  title:
                  'ENEMY PRESSURE',
                  subtitle:
                  'HOLD THE INDUSTRIAL ROAD',
                  accent:
                  const Color(
                    0xFFFFA23D,
                  ),
                );
                break;

              case Level2Stage
                  .secondGate:
                break;

              case Level2Stage
                  .armoredCombat:
                _showStageBanner(
                  title:
                  'ARMORED DEFENSE',
                  subtitle:
                  'BREAK THEIR LINE',
                  accent:
                  const Color(
                    0xFFFF724D,
                  ),
                );
                break;

              case Level2Stage
                  .thirdGate:
                break;

              case Level2Stage
                  .assault:
                break;

              case Level2Stage
                  .finalGate:
                break;

              case Level2Stage
                  .finalAssault:
                _showStageBanner(
                  title:
                  'FINAL ASSAULT',
                  subtitle:
                  'FORTRESS DEFENSE AHEAD',
                  accent:
                  const Color(
                    0xFFFF9D32,
                  ),
                );
                break;

              case Level2Stage
                  .bossApproach:
                break;

              case Level2Stage
                  .complete:
                break;
            }
          },
        );

    world.add(
      level2Director!,
    );
  }

  // ============================================================
  // BOSS PHASE
  // ============================================================

  void _startBossPhase() {
    if (_gameOver) {
      return;
    }

    adaptiveDirector
        ?.stop();

    specialMechanicDirector
        ?.stop();

    specialMechanicSpawner
        ?.stop();

    _stopBattleSpawners();

    _showStageBanner(
      title:
      'BOSS APPROACHING',
      subtitle:
      levelConfig.bossName,
      accent:
      levelConfig
          .secondaryAccent,
    );

    bossSpawner.spawnBoss();
  }

  // ============================================================
  // STOP SPAWNERS
  // ============================================================

  void _stopBattleSpawners() {
    enemySpawner
        ?.stop();

    gateSpawner
        ?.stop();

    level2EnemySpawner
        ?.stop();

    level2GateSpawner
        ?.stop();

    battlefieldPickupSpawner
        ?.stop();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(
      double dt,
      ) {
    super.update(
      dt,
    );

    if (_gameOver) {
      return;
    }

    levelManager.update(
      dt,
    );

    // ==========================================================
    // PLAYER HUD
    // ==========================================================

    if (player.isMounted &&
        hud.isMounted) {
      hud.updateHealth(
        player
            .health
            .currentHealth,
      );

      hud.updateArmy(
        player.armyCount,
      );
    }

    // ==========================================================
    // IRON WARDEN AURA
    // ==========================================================

    final activeBoss =
        _activeBoss;

    final aura =
        _ironWardenAura;

    if (currentLevel == 2 &&
        activeBoss != null &&
        activeBoss.isMounted &&
        aura != null &&
        aura.isMounted) {
      aura.position.setFrom(
        activeBoss.position,
      );
    }

    // ==========================================================
    // BOSS HEALTH
    // ==========================================================

    final bosses =
    world.children
        .whereType<
        BasicBoss>()
        .where(
          (
          boss,
          ) =>
      boss.isMounted,
    )
        .toList();

    if (bosses.isNotEmpty) {
      final boss =
          bosses.first;

      if (hud.isMounted) {
        hud.updateBossHealth(
          health:
          boss.health,
          maxHealth:
          boss.maxHealthValue,
        );
      }

      // --------------------------------------------------------
      // BOSS RAGE
      // --------------------------------------------------------

      if (!_bossRageShown &&
          boss.health <=
              boss.maxHealthValue *
                  .50) {
        _bossRageShown =
        true;

        unawaited(
          audio.bossRage(),
        );

        _showViewportComponent(
          BossRageBanner(
            gameSize: size,
          ),
        );

        _showViewportComponent(
          CombatImpactEffect(
            gameSize: size,
            type:
            CombatImpactType
                .bossRage,
          ),
        );
      }
    }

    // ==========================================================
    // MISSILE COOLDOWN
    // ==========================================================

    if (_missileCooldown >
        0) {
      _missileCooldown -=
          dt;

      if (_missileCooldown <
          0) {
        _missileCooldown =
        0;
      }
    }

    // ==========================================================
    // FREEZE COOLDOWN
    // ==========================================================

    if (_freezeCooldown >
        0) {
      _freezeCooldown -=
          dt;

      if (_freezeCooldown <
          0) {
        _freezeCooldown =
        0;
      }
    }

    // ==========================================================
    // FREEZE ACTIVE
    // ==========================================================

    if (_freezeActive) {
      _freezeTimer -=
          dt;

      final enemies =
      world.children
          .whereType<
          BasicEnemy>();

      for (final enemy
      in enemies) {
        if (enemy.isMounted) {
          enemy.setFrozen(
            true,
          );
        }
      }

      if (_freezeTimer <=
          0) {
        _freezeTimer =
        0;

        _freezeActive =
        false;

        final enemies =
        world.children
            .whereType<
            BasicEnemy>();

        for (final enemy
        in enemies) {
          if (enemy.isMounted) {
            enemy.setFrozen(
              false,
            );
          }
        }
      }
    }

    // ==========================================================
    // HUD COOLDOWNS
    // ==========================================================

    if (hud.isMounted) {
      hud.updateMissileCooldown(
        _missileCooldown,
      );

      hud.updateFreezeCooldown(
        _freezeCooldown,
      );
    }
  }

  // ============================================================
  // BATTLEFIELD COINS
  // ============================================================

  Future<void> _collectBattleCoins(
      int amount,
      ) async {
    if (_gameOver ||
        amount <= 0) {
      return;
    }

    await progress.addCoins(
      amount,
    );

    if (_gameOver ||
        !hud.isMounted) {
      return;
    }

    hud.updateCoins(
      progress.coins,
    );
  }

  // ============================================================
  // MISSILE PICKUP
  // ============================================================

  void grantMissileReady() {
    if (_gameOver) {
      return;
    }

    _missileCooldown =
    0;

    if (hud.isMounted) {
      hud.updateMissileCooldown(
        0,
      );
    }

    _showStageBanner(
      title:
      'MISSILE READY',
      subtitle:
      'HEAVY STRIKE AVAILABLE',
      accent:
      const Color(
        0xFFFF9D32,
      ),
    );
  }

  // ============================================================
  // MISSILE
  // ============================================================

  void activateMissile() {
    if (_gameOver ||
        _missileCooldown >
            0) {
      return;
    }

    _missileCooldown =
        _missileCooldownTime;

    unawaited(
      audio.missileLaunch(),
    );

    final enemies =
    world.children
        .whereType<
        BasicEnemy>()
        .where(
          (
          enemy,
          ) =>
      enemy.isMounted,
    )
        .toList();

    final bosses =
    world.children
        .whereType<
        BasicBoss>()
        .where(
          (
          boss,
          ) =>
      boss.isMounted,
    )
        .toList();

    Vector2 target;

    // ==========================================================
    // TARGET PRIORITY
    // ==========================================================

    if (bosses.isNotEmpty) {
      target =
          bosses
              .first
              .position
              .clone();
    } else if (enemies.isNotEmpty) {
      enemies.sort(
            (
            a,
            b,
            ) =>
            b.position.y
                .compareTo(
              a.position.y,
            ),
      );

      target =
          enemies
              .first
              .position
              .clone();
    } else {
      target =
          Vector2(
            size.x / 2,
            size.y * .42,
          );
    }

    // ==========================================================
    // MISSILE EFFECT
    // ==========================================================

    world.add(
      MissileStrikeEffect(
        position:
        target.clone(),
      ),
    );

    unawaited(
      audio.missileExplosion(),
    );

    _showViewportComponent(
      CombatImpactEffect(
        gameSize: size,
        type:
        CombatImpactType
            .missile,
        impactPosition:
        target.clone(),
      ),
    );

    // ==========================================================
    // ENEMY DAMAGE
    // ==========================================================

    const double blastRadius =
    165.0;

    for (final enemy
    in enemies) {
      if (!enemy.isMounted) {
        continue;
      }

      if (enemy.position
          .distanceTo(
        target,
      ) <=
          blastRadius) {
        enemy.takeDamage(
          260,
        );
      }
    }

    // ==========================================================
    // BOSS DAMAGE
    // ==========================================================

    for (final boss
    in bosses) {
      if (!boss.isMounted) {
        continue;
      }

      if (boss.position
          .distanceTo(
        target,
      ) <=
          190) {
        boss.takeDamage(
          320,
        );
      }
    }
  }

  // ============================================================
  // FREEZE
  // ============================================================

  void activateFreeze() {
    if (_gameOver ||
        _freezeCooldown >
            0) {
      return;
    }

    _freezeCooldown =
        _freezeCooldownTime;

    unawaited(
      audio.freeze(),
    );

    _freezeActive =
    true;

    _freezeTimer =
        _freezeDuration;

    final enemies =
    world.children
        .whereType<
        BasicEnemy>();

    for (final enemy
    in enemies) {
      if (enemy.isMounted) {
        enemy.setFrozen(
          true,
        );
      }
    }

    world.add(
      FreezeWaveEffect(
        position:
        Vector2(
          size.x / 2,
          size.y * .55,
        ),
      ),
    );
  }

  // ============================================================
  // PAUSE
  // ============================================================

  void pauseGame() {
    if (_gameOver ||
        paused) {
      return;
    }

    pauseEngine();

    overlays.add(
      'pause',
    );
  }

  // ============================================================
  // RESUME
  // ============================================================

  void resumeGame() {
    overlays.remove(
      'pause',
    );

    resumeEngine();
  }

  // ============================================================
  // RESTART FROM PAUSE
  // ============================================================

  void restartFromPause() {
    overlays.remove(
      'pause',
    );

    resumeEngine();

    restartLevel();
  }

  // ============================================================
  // VICTORY
  // ============================================================

  void showVictory() {
    if (_gameOver) {
      return;
    }

    _gameOver = true;

    adaptiveDirector?.stop();

    specialMechanicDirector?.stop();

    specialMechanicSpawner?.stop();

    unawaited(
      audio.victory(),
    );

    if (gameplayConfig.pattern ==
        MissionCombatPattern.pressure) {
      level2Director?.completeLevel();
    } else {
      level1Director?.completeLevel();
    }

    _stopBattleSpawners();

    _ironWardenAura?.removeFromParent();

    _ironWardenAura = null;

    _activeBoss = null;

    // ============================================================
    // VICTORY REWARD
    //
    // First completion:
    // 100% of level reward.
    //
    // Replay:
    // 30% of level reward.
    //
    // This prevents players from farming easy early levels
    // for the same reward as progressing through the campaign.
    // ============================================================

    if (!_rewardGiven) {
      _rewardGiven = true;

      final bool alreadyCompleted =
      levelProgress.isLevelCompleted(
        currentLevel,
      );

      final int reward;

      if (alreadyCompleted) {
        reward =
            (victoryReward * 0.10)
                .round()
                .clamp(
              1,
              victoryReward,
            );
      } else {
        reward = victoryReward;
      }

      unawaited(
        progress.addCoins(
          reward,
        ),
      );

      unawaited(
        levelProgress.completeLevel(
          currentLevel,
        ),
      );

      if (hud.isMounted) {
        hud.updateCoins(
          progress.coins,
        );
      }
    }

    pauseEngine();

    overlays.add(
      'victory',
    );
  }

  // ============================================================
  // DEFEAT
  // ============================================================

  void showDefeat() {
    if (_gameOver) {
      return;
    }

    _gameOver =
    true;

    adaptiveDirector
        ?.stop();

    specialMechanicDirector
        ?.stop();

    specialMechanicSpawner
        ?.stop();

    unawaited(
      audio.defeat(),
    );

    _stopBattleSpawners();

    _ironWardenAura
        ?.removeFromParent();

    _ironWardenAura =
    null;

    _activeBoss =
    null;

    pauseEngine();

    overlays.add(
      'defeat',
    );
  }

  // ============================================================
  // RESTART
  // ============================================================

  void restartLevel() {
    unawaited(
      _restartLevel(),
    );
  }

  Future<void> _restartLevel() async {
    overlays.remove(
      'pause',
    );

    overlays.remove(
      'victory',
    );

    overlays.remove(
      'defeat',
    );

    resumeEngine();

    // ==========================================================
    // STOP OLD SYSTEMS FIRST
    // ==========================================================

    adaptiveDirector
        ?.stop();

    specialMechanicDirector
        ?.stop();

    specialMechanicSpawner
        ?.stop();

    _stopBattleSpawners();

    level1Director
        ?.stop();

    level2Director
        ?.stop();

    // ==========================================================
    // REMOVE OLD WORLD
    // ==========================================================

    final oldWorldChildren =
    world.children
        .toList();

    world.removeAll(
      oldWorldChildren,
    );

    // ==========================================================
    // REMOVE OLD VIEWPORT COMPONENTS
    //
    // This removes the old HUD and temporary Flame UI.
    // Flutter overlays are handled separately above.
    // ==========================================================

    final oldViewportChildren =
    camera.viewport.children
        .toList();

    camera.viewport.removeAll(
      oldViewportChildren,
    );

    await Future<void>.delayed(
      Duration.zero,
    );

    await _startLevel();
  }

  // ============================================================
  // SCREEN-SPACE BANNER HELPER
  // ============================================================

  void _showStageBanner({
    required String title,
    required String subtitle,
    required Color accent,
  }) {
    if (_gameOver) {
      return;
    }

    camera.viewport.add(
      LevelStageBanner(
        gameSize: size,
        title:
        title,
        subtitle:
        subtitle,
        accent:
        accent,
      ),
    );
  }

  // ============================================================
  // SCREEN-SPACE COMPONENT HELPER
  // ============================================================

  void _showViewportComponent(
      Component component,
      ) {
    camera.viewport.add(
      component,
    );
  }
}


