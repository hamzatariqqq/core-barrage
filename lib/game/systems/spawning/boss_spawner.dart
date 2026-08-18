import 'package:flame/components.dart';

import '../../components/bosses/basic_boss.dart';

class BossSpawner extends Component {
  BossSpawner({
    required this.gameSize,
    required this.onBossSpawned,
    required this.onBossDefeated,
  });

  final Vector2 gameSize;
  final void Function(BasicBoss boss) onBossSpawned;
  final void Function() onBossDefeated;

  double _timer = 0;
  bool _spawned = false;

  static const double spawnAfterSeconds = 45;

  @override
  void update(double dt) {
    super.update(dt);

    if (_spawned) return;

    _timer += dt;

    if (_timer >= spawnAfterSeconds) {
      _spawned = true;

      final boss = BasicBoss(
        position: Vector2(
          gameSize.x / 2,
          120,
        ),
        onBossDefeated: onBossDefeated,
      );

      parent?.add(boss);

      onBossSpawned(boss);
    }
  }
}