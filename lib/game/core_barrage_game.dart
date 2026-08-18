import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/bosses/basic_boss.dart';
import 'components/environment/scrolling_battlefield.dart';
import 'components/player/player_vehicle.dart';
import 'components/ui/defeat_overlay.dart';
import 'components/ui/victory_overlay.dart';
import 'systems/level/level_manager.dart';
import 'systems/spawning/boss_spawner.dart';
import 'systems/spawning/enemy_spawner.dart';
import 'systems/spawning/gate_spawner.dart';

class CoreBarrageGame extends FlameGame with HasCollisionDetection {
  late PlayerVehicle player;
  late LevelManager levelManager;

  bool _gameOver = false;

  late RectangleComponent progressBar;

  @override
  Color backgroundColor() => const Color(0xFF101827);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _startLevel();
  }

  Future<void> _startLevel() async {
    _gameOver = false;

    levelManager = LevelManager();

    const roadMargin = 40.0;
    const playerHalfWidth = 30.0;

    // Scrolling battlefield
    add(
      ScrollingBattlefield(
        gameSize: size,
      ),
    );

    // Level title
    add(
      TextComponent(
        text: 'LEVEL 1',
        position: Vector2(size.x / 2, 25),
        anchor: Anchor.center,
        priority: 500,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // Progress background
    add(
      RectangleComponent(
        position: Vector2(50, 45),
        size: Vector2(size.x - 100, 8),
        priority: 500,
        paint: Paint()..color = Colors.black54,
      ),
    );

    // Progress bar
    progressBar = RectangleComponent(
      position: Vector2(50, 45),
      size: Vector2(0, 8),
      priority: 501,
      paint: Paint()..color = const Color(0xFF238BFF),
    );

    add(progressBar);

    // Player
    player = PlayerVehicle(
      position: Vector2(
        size.x / 2,
        size.y - 100,
      ),
      minX: roadMargin + playerHalfWidth,
      maxX: size.x - roadMargin - playerHalfWidth,
      onPlayerDead: showDefeat,
    );

    add(player);

    // Enemies
    add(
      EnemySpawner(
        gameSize: size,
      ),
    );

    // Gates
    add(
      GateSpawner(
        gameSize: size,
      ),
    );

    // Boss
    add(
      BossSpawner(
        gameSize: size,
        onBossSpawned: (BasicBoss boss) {},
        onBossDefeated: showVictory,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_gameOver) return;

    levelManager.update(dt);

    final maxWidth = size.x - 100;

    progressBar.size.x =
        maxWidth * levelManager.progress;
  }

  void showDefeat() {
    if (_gameOver) return;

    _gameOver = true;

    add(
      DefeatOverlay(
        gameSize: size,
        onRetry: restartLevel,
      ),
    );
  }

  void showVictory() {
    if (_gameOver) return;

    _gameOver = true;

    add(
      VictoryOverlay(
        gameSize: size,
        onPlayAgain: restartLevel,
      ),
    );
  }

  void restartLevel() {
    removeAll(children.toList());
    _startLevel();
  }
}