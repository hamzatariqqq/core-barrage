import 'package:flutter/material.dart';

enum MissionTheme {
  desert,
  canyon,
  storm,
  dusk,
  fire,
  fortress,
  night,
  frozen,
  toxic,
  cyber,
}

class LevelDefinition {
  const LevelDefinition({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.bossName,
    required this.reward,
    required this.difficulty,
    required this.theme,
    required this.accent,
    required this.icon,
    required this.bossLevel,
  });

  final int level;

  final String title;
  final String subtitle;
  final String description;

  final String bossName;

  final int reward;
  final int difficulty;

  final MissionTheme theme;

  final Color accent;

  final IconData icon;

  final bool bossLevel;
}

class LevelCatalog {
  LevelCatalog._();

  static const int totalLevels = 15;

  static const List<LevelDefinition> levels = [
    // ============================================================
    // LEVEL 1
    // ============================================================

    LevelDefinition(
      level: 1,
      title: 'FIRST ASSAULT',
      subtitle: 'DESERT OUTPOST',
      description:
      'Break through the first enemy patrol and learn to use reinforcement gates.',
      bossName: 'SCOUT CAPTAIN',
      reward: 350,
      difficulty: 1,
      theme: MissionTheme.desert,
      accent: Color(0xFF22C6FF),
      icon: Icons.flag_rounded,
      bossLevel: false,
    ),

    // ============================================================
    // LEVEL 2
    // ============================================================

    LevelDefinition(
      level: 2,
      title: 'IRON PUSH',
      subtitle: 'ARMORED COLUMN',
      description:
      'Heavy infantry enters the battlefield. Build firepower before the final push.',
      bossName: 'IRON WARDEN',
      reward: 500,
      difficulty: 2,
      theme: MissionTheme.canyon,
      accent: Color(0xFFFF9B32),
      icon: Icons.shield_rounded,
      bossLevel: true,
    ),

    // ============================================================
    // LEVEL 3
    // ============================================================

    LevelDefinition(
      level: 3,
      title: 'SANDSTORM RUN',
      subtitle: 'LOW VISIBILITY',
      description:
      'Fast enemy runners attack through a violent desert storm.',
      bossName: 'DUNE HUNTER',
      reward: 575,
      difficulty: 2,
      theme: MissionTheme.storm,
      accent: Color(0xFFFFC64A),
      icon: Icons.air_rounded,
      bossLevel: false,
    ),

    // ============================================================
    // LEVEL 4
    // ============================================================

    LevelDefinition(
      level: 4,
      title: 'CROSSFIRE',
      subtitle: 'RANGED AMBUSH',
      description:
      'Enemy rifle squads attack from several lanes. Keep moving.',
      bossName: 'RED EYE',
      reward: 650,
      difficulty: 3,
      theme: MissionTheme.dusk,
      accent: Color(0xFFFF6F61),
      icon: Icons.gps_fixed_rounded,
      bossLevel: false,
    ),

    // ============================================================
    // LEVEL 5
    // ============================================================

    LevelDefinition(
      level: 5,
      title: 'MECH BREAKER',
      subtitle: 'BOSS OPERATION',
      description:
      'Destroy the Heavy Mech before it crushes your remaining army.',
      bossName: 'HEAVY MECH',
      reward: 800,
      difficulty: 3,
      theme: MissionTheme.fire,
      accent: Color(0xFFFF473D),
      icon: Icons.smart_toy_rounded,
      bossLevel: true,
    ),

    // ============================================================
    // LEVEL 6
    // ============================================================

    LevelDefinition(
      level: 6,
      title: 'BROKEN CONVOY',
      subtitle: 'WRECKAGE ZONE',
      description:
      'Fight through abandoned vehicles, broken defenses and narrow attack lanes.',
      bossName: 'CONVOY GUARD',
      reward: 875,
      difficulty: 4,
      theme: MissionTheme.canyon,
      accent: Color(0xFFFFA52E),
      icon: Icons.local_shipping_rounded,
      bossLevel: false,
    ),

    // ============================================================
    // LEVEL 7
    // ============================================================

    LevelDefinition(
      level: 7,
      title: 'ROCKET AMBUSH',
      subtitle: 'MISSILE VALLEY',
      description:
      'Incoming rockets force constant movement while heavy squads advance.',
      bossName: 'ROCKET ACE',
      reward: 950,
      difficulty: 4,
      theme: MissionTheme.fire,
      accent: Color(0xFFFF663C),
      icon: Icons.rocket_launch_rounded,
      bossLevel: false,
    ),

    // ============================================================
    // LEVEL 8
    // ============================================================

    LevelDefinition(
      level: 8,
      title: 'REINFORCEMENT RUSH',
      subtitle: 'BUILD THE ARMY',
      description:
      'Chain soldier gates together and create the largest squad yet.',
      bossName: 'FIELD COMMANDER',
      reward: 1050,
      difficulty: 4,
      theme: MissionTheme.desert,
      accent: Color(0xFF35E68A),
      icon: Icons.groups_rounded,
      bossLevel: false,
    ),

    // ============================================================
    // LEVEL 9
    // ============================================================

    LevelDefinition(
      level: 9,
      title: 'ELITE PATROL',
      subtitle: 'VETERAN ENEMIES',
      description:
      'Elite enemy formations hit harder and survive longer than normal squads.',
      bossName: 'ELITE MAJOR',
      reward: 1150,
      difficulty: 5,
      theme: MissionTheme.night,
      accent: Color(0xFFA768FF),
      icon: Icons.military_tech_rounded,
      bossLevel: false,
    ),

    // ============================================================
    // LEVEL 10
    // ============================================================

    LevelDefinition(
      level: 10,
      title: 'ROCKET FORTRESS',
      subtitle: 'BOSS OPERATION',
      description:
      'Storm the rocket fortress and destroy its armored command tank.',
      bossName: 'WAR TANK',
      reward: 1350,
      difficulty: 5,
      theme: MissionTheme.fortress,
      accent: Color(0xFFFF4238),
      icon: Icons.security_rounded,
      bossLevel: true,
    ),

    // ============================================================
    // LEVEL 11
    // ============================================================

    LevelDefinition(
      level: 11,
      title: 'SHIELD LINE',
      subtitle: 'ARMORED DEFENSE',
      description:
      'Shield squads block the road while ranged units attack behind them.',
      bossName: 'SHIELD MASTER',
      reward: 1450,
      difficulty: 6,
      theme: MissionTheme.night,
      accent: Color(0xFF6AA8FF),
      icon: Icons.shield_outlined,
      bossLevel: false,
    ),

    // ============================================================
    // LEVEL 12
    // ============================================================

    LevelDefinition(
      level: 12,
      title: 'FIREPOWER TRIAL',
      subtitle: 'WEAPON TEST',
      description:
      'Choose your firepower gates carefully and destroy reinforced attack waves.',
      bossName: 'GUNNER PRIME',
      reward: 1550,
      difficulty: 6,
      theme: MissionTheme.fire,
      accent: Color(0xFFFFB12D),
      icon: Icons.bolt_rounded,
      bossLevel: false,
    ),

    // ============================================================
    // LEVEL 13
    // ============================================================

    LevelDefinition(
      level: 13,
      title: 'FORTRESS ROAD',
      subtitle: 'ENEMY STRONGHOLD',
      description:
      'Push through dense defenses protecting the enemy command fortress.',
      bossName: 'FORTRESS LORD',
      reward: 1700,
      difficulty: 7,
      theme: MissionTheme.fortress,
      accent: Color(0xFF9D69FF),
      icon: Icons.castle_rounded,
      bossLevel: false,
    ),

    // ============================================================
    // LEVEL 14
    // ============================================================

    LevelDefinition(
      level: 14,
      title: 'LAST STAND',
      subtitle: 'SURVIVAL OPERATION',
      description:
      'Survive relentless enemy waves with limited time between attacks.',
      bossName: 'THE EXECUTIONER',
      reward: 1900,
      difficulty: 8,
      theme: MissionTheme.storm,
      accent: Color(0xFFFF5752),
      icon: Icons.warning_amber_rounded,
      bossLevel: false,
    ),

    // ============================================================
    // LEVEL 15
    // ============================================================

    LevelDefinition(
      level: 15,
      title: 'DESERT WARDEN',
      subtitle: 'FINAL BOSS',
      description:
      'Everything leads here. Defeat the Desert Warden and complete the campaign.',
      bossName: 'DESERT WARDEN',
      reward: 2500,
      difficulty: 10,
      theme: MissionTheme.fire,
      accent: Color(0xFFFFD23B),
      icon: Icons.workspace_premium_rounded,
      bossLevel: true,
    ),
  ];

  // ============================================================
  // GET LEVEL
  // ============================================================

  static LevelDefinition getLevel(
      int level,
      ) {
    final safeLevel =
    level.clamp(
      1,
      totalLevels,
    );

    return levels[safeLevel - 1];
  }

  // ============================================================
  // NEXT
  // ============================================================

  static LevelDefinition? nextLevel(
      int currentLevel,
      ) {
    if (currentLevel >=
        totalLevels) {
      return null;
    }

    return getLevel(
      currentLevel + 1,
    );
  }

  // ============================================================
  // PREVIOUS
  // ============================================================

  static LevelDefinition? previousLevel(
      int currentLevel,
      ) {
    if (currentLevel <= 1) {
      return null;
    }

    return getLevel(
      currentLevel - 1,
    );
  }

  // ============================================================
  // EXISTS
  // ============================================================

  static bool exists(
      int level,
      ) {
    return level >= 1 &&
        level <= totalLevels;
  }
}