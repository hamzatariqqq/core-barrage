import 'package:flame/components.dart';

import '../../components/bosses/basic_boss.dart';

class BossSpawner extends Component {
  BossSpawner({
    required this.gameSize,
    required this.currentLevel,
    required this.onBossSpawned,
    required this.onBossDefeated,
  });

  final Vector2 gameSize;

  final int currentLevel;

  final void Function(
      BasicBoss boss,
      ) onBossSpawned;

  final void Function()
  onBossDefeated;

  bool _spawned = false;

  BasicBoss? _boss;

  // ============================================================
  // SPAWN
  // ============================================================

  void spawnBoss() {
    if (_spawned) {
      return;
    }

    final world =
        parent;

    if (world == null) {
      return;
    }

    _spawned = true;

    final boss =
    BasicBoss(
      position:
      Vector2(
        gameSize.x / 2,
        -95,
      ),
      level:
      currentLevel,
      onDefeated:
      _handleBossDefeated,
    );

    _boss = boss;

    world.add(
      boss,
    );

    onBossSpawned(
      boss,
    );
  }

  // ============================================================
  // DEFEATED
  // ============================================================

  void _handleBossDefeated() {
    _boss = null;

    onBossDefeated();
  }

  // ============================================================
  // ACCESS
  // ============================================================

  BasicBoss? get activeBoss =>
      _boss;

  bool get hasSpawned =>
      _spawned;

  // ============================================================
  // RESET
  // ============================================================

  void reset() {
    final boss =
        _boss;

    if (boss != null &&
        boss.isMounted) {
      boss.removeFromParent();
    }

    _boss = null;

    _spawned = false;
  }
}