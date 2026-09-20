class LevelAssetConfig {
  const LevelAssetConfig({
    required this.level,
    required this.background,
    required this.enemy,
    required this.boss,
  });

  final int level;
  final String background;
  final String enemy;
  final String boss;

  static LevelAssetConfig forLevel(
      int level,
      ) {
    final safeLevel =
    level.clamp(1, 15).toInt();

    final number =
    safeLevel.toString().padLeft(
      2,
      '0',
    );

    String background;

    if (safeLevel == 1) {
      background =
      'levels/level_01_scroll.png';
    } else if (safeLevel == 2) {
      background =
      'levels/level_02_scroll.png';
    } else if (safeLevel == 3) {
      background =
      'levels/level_03_scroll.png';
    } else {
      background =
      'levels/level_$number.png';
    }

    return LevelAssetConfig(
      level: safeLevel,
      background: background,
      enemy:
      'enemies/enemy_$number.png',
      boss:
      'bosses/boss_$number.png',
    );
  }
}