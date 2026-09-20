import 'package:flutter/material.dart';

enum LevelAtmosphereType {
  desert,
  canyon,
  sandstorm,
  sunset,
  inferno,
  convoy,
  rocket,
  reinforcement,
  night,
  fortress,
  shield,
  firepower,
  citadel,
  finalStand,
  finalBoss,
}

enum BossVisualType {
  scout,
  ironWarden,
  duneHunter,
  redEye,
  heavyMech,
  convoyGuard,
  rocketAce,
  fieldCommander,
  eliteMajor,
  warTank,
  shieldMaster,
  gunnerPrime,
  fortressLord,
  executioner,
  desertWarden,
}

class LevelRuntimeConfig {
  const LevelRuntimeConfig({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.bossName,
    required this.reward,
    required this.accent,
    required this.secondaryAccent,
    required this.atmosphere,
    required this.bossVisual,
    required this.useLevel2Pattern,
  });

  final int level;

  final String title;
  final String subtitle;
  final String bossName;

  final int reward;

  final Color accent;
  final Color secondaryAccent;

  final LevelAtmosphereType atmosphere;
  final BossVisualType bossVisual;

  final bool useLevel2Pattern;

  static LevelRuntimeConfig forLevel(int level) {
    final safeLevel = level.clamp(1, 15);
    return configs[safeLevel - 1];
  }

  static const List<LevelRuntimeConfig> configs = [
    // ==========================================================
    // LEVEL 1
    // ==========================================================

    LevelRuntimeConfig(
      level: 1,
      title: 'FIRST ASSAULT',
      subtitle: 'DESERT OUTPOST',
      bossName: 'SCOUT CAPTAIN',
      reward: 15,
      accent: Color(0xFF24C8FF),
      secondaryAccent: Color(0xFF2778FF),
      atmosphere: LevelAtmosphereType.desert,
      bossVisual: BossVisualType.scout,
      useLevel2Pattern: false,
    ),

    // ==========================================================
    // LEVEL 2
    // ==========================================================

    LevelRuntimeConfig(
      level: 2,
      title: 'IRON PUSH',
      subtitle: 'ARMORED COLUMN',
      bossName: 'IRON WARDEN',
      reward: 18,
      accent: Color(0xFFFF9C35),
      secondaryAccent: Color(0xFFFF5638),
      atmosphere: LevelAtmosphereType.canyon,
      bossVisual: BossVisualType.ironWarden,
      useLevel2Pattern: true,
    ),

    // ==========================================================
    // LEVEL 3
    // ==========================================================

    LevelRuntimeConfig(
      level: 3,
      title: 'SANDSTORM RUN',
      subtitle: 'LOW VISIBILITY',
      bossName: 'DUNE HUNTER',
      reward: 20,
      accent: Color(0xFFFFCA52),
      secondaryAccent: Color(0xFFD98031),
      atmosphere: LevelAtmosphereType.sandstorm,
      bossVisual: BossVisualType.duneHunter,
      useLevel2Pattern: false,
    ),

    // ==========================================================
    // LEVEL 4
    // ==========================================================

    LevelRuntimeConfig(
      level: 4,
      title: 'CROSSFIRE',
      subtitle: 'RANGED AMBUSH',
      bossName: 'RED EYE',
      reward: 22,
      accent: Color(0xFFFF6659),
      secondaryAccent: Color(0xFFC91D32),
      atmosphere: LevelAtmosphereType.sunset,
      bossVisual: BossVisualType.redEye,
      useLevel2Pattern: true,
    ),

    // ==========================================================
    // LEVEL 5
    // ==========================================================

    LevelRuntimeConfig(
      level: 5,
      title: 'MECH BREAKER',
      subtitle: 'BOSS OPERATION',
      bossName: 'HEAVY MECH',
      reward: 28,
      accent: Color(0xFFFF4D3D),
      secondaryAccent: Color(0xFFFFA029),
      atmosphere: LevelAtmosphereType.inferno,
      bossVisual: BossVisualType.heavyMech,
      useLevel2Pattern: true,
    ),

    // ==========================================================
    // LEVEL 6
    // ==========================================================

    LevelRuntimeConfig(
      level: 6,
      title: 'BROKEN CONVOY',
      subtitle: 'WRECKAGE ZONE',
      bossName: 'CONVOY GUARD',
      reward: 25,
      accent: Color(0xFFFFA22F),
      secondaryAccent: Color(0xFF965435),
      atmosphere: LevelAtmosphereType.convoy,
      bossVisual: BossVisualType.convoyGuard,
      useLevel2Pattern: false,
    ),

    // ==========================================================
    // LEVEL 7
    // ==========================================================

    LevelRuntimeConfig(
      level: 7,
      title: 'ROCKET AMBUSH',
      subtitle: 'MISSILE VALLEY',
      bossName: 'ROCKET ACE',
      reward: 28,
      accent: Color(0xFFFF673C),
      secondaryAccent: Color(0xFFFFC42D),
      atmosphere: LevelAtmosphereType.rocket,
      bossVisual: BossVisualType.rocketAce,
      useLevel2Pattern: true,
    ),

    // ==========================================================
    // LEVEL 8
    // ==========================================================

    LevelRuntimeConfig(
      level: 8,
      title: 'REINFORCEMENT RUSH',
      subtitle: 'BUILD THE ARMY',
      bossName: 'FIELD COMMANDER',
      reward: 30,
      accent: Color(0xFF36E68B),
      secondaryAccent: Color(0xFF20AFFF),
      atmosphere: LevelAtmosphereType.reinforcement,
      bossVisual: BossVisualType.fieldCommander,
      useLevel2Pattern: false,
    ),

    // ==========================================================
    // LEVEL 9
    // ==========================================================

    LevelRuntimeConfig(
      level: 9,
      title: 'ELITE PATROL',
      subtitle: 'VETERAN ENEMIES',
      bossName: 'ELITE MAJOR',
      reward: 32,
      accent: Color(0xFFA76BFF),
      secondaryAccent: Color(0xFF4C69FF),
      atmosphere: LevelAtmosphereType.night,
      bossVisual: BossVisualType.eliteMajor,
      useLevel2Pattern: true,
    ),

    // ==========================================================
    // LEVEL 10
    // ==========================================================

    LevelRuntimeConfig(
      level: 10,
      title: 'ROCKET FORTRESS',
      subtitle: 'BOSS OPERATION',
      bossName: 'WAR TANK',
      reward: 40,
      accent: Color(0xFFFF443D),
      secondaryAccent: Color(0xFFFFA32A),
      atmosphere: LevelAtmosphereType.fortress,
      bossVisual: BossVisualType.warTank,
      useLevel2Pattern: true,
    ),

    // ==========================================================
    // LEVEL 11
    // ==========================================================

    LevelRuntimeConfig(
      level: 11,
      title: 'SHIELD LINE',
      subtitle: 'ARMORED DEFENSE',
      bossName: 'SHIELD MASTER',
      reward: 35,
      accent: Color(0xFF69A9FF),
      secondaryAccent: Color(0xFF325DFF),
      atmosphere: LevelAtmosphereType.shield,
      bossVisual: BossVisualType.shieldMaster,
      useLevel2Pattern: false,
    ),

    // ==========================================================
    // LEVEL 12
    // ==========================================================

    LevelRuntimeConfig(
      level: 12,
      title: 'FIREPOWER TRIAL',
      subtitle: 'WEAPON TEST',
      bossName: 'GUNNER PRIME',
      reward: 38,
      accent: Color(0xFFFFB32D),
      secondaryAccent: Color(0xFFFF5D30),
      atmosphere: LevelAtmosphereType.firepower,
      bossVisual: BossVisualType.gunnerPrime,
      useLevel2Pattern: true,
    ),

    // ==========================================================
    // LEVEL 13
    // ==========================================================

    LevelRuntimeConfig(
      level: 13,
      title: 'FORTRESS ROAD',
      subtitle: 'ENEMY STRONGHOLD',
      bossName: 'FORTRESS LORD',
      reward: 42,
      accent: Color(0xFF9C6AFF),
      secondaryAccent: Color(0xFFFF4F7A),
      atmosphere: LevelAtmosphereType.citadel,
      bossVisual: BossVisualType.fortressLord,
      useLevel2Pattern: false,
    ),

    // ==========================================================
    // LEVEL 14
    // ==========================================================

    LevelRuntimeConfig(
      level: 14,
      title: 'LAST STAND',
      subtitle: 'SURVIVAL OPERATION',
      bossName: 'THE EXECUTIONER',
      reward: 48,
      accent: Color(0xFFFF5650),
      secondaryAccent: Color(0xFF8A0E16),
      atmosphere: LevelAtmosphereType.finalStand,
      bossVisual: BossVisualType.executioner,
      useLevel2Pattern: true,
    ),

    // ==========================================================
    // LEVEL 15
    // ==========================================================

    LevelRuntimeConfig(
      level: 15,
      title: 'DESERT WARDEN',
      subtitle: 'FINAL BOSS',
      bossName: 'DESERT WARDEN',
      reward: 60,
      accent: Color(0xFFFFD33E),
      secondaryAccent: Color(0xFFFF372E),
      atmosphere: LevelAtmosphereType.finalBoss,
      bossVisual: BossVisualType.desertWarden,
      useLevel2Pattern: true,
    ),
  ];
}