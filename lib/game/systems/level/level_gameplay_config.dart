enum MissionCombatPattern {
  standard,
  pressure,
}

enum LevelSpecialFeature {
  basicAssault,
  movingGates,
  mines,
  turrets,
  bossRush,
  speedBoost,
  barricades,
  eliteEnemies,
  riskyGates,
  majorBoss,
  airstrikes,
  shieldGates,
  enemyVehicles,
  highRisk,
  finalCommand,
}

class LevelGameplayConfig {
  const LevelGameplayConfig({
    required this.level,
    required this.pattern,
    required this.duration,
    required this.startingArmyBonus,
    required this.startingFirepower,
    required this.reinforcementAmount,
    required this.enemyDifficulty,
    required this.pressureStrength,
    required this.feature,
    required this.stageOne,
    required this.stageTwo,
    required this.stageThree,
  });

  final int level;
  final MissionCombatPattern pattern;
  final double duration;

  final int startingArmyBonus;
  final double startingFirepower;

  final int reinforcementAmount;

  final double enemyDifficulty;
  final double pressureStrength;

  final LevelSpecialFeature feature;

  final String stageOne;
  final String stageTwo;
  final String stageThree;

  bool get isBossLevel =>
      level == 5 ||
          level == 10 ||
          level == 15;

  bool get isFinalLevel => level == 15;

  bool get usesPressureFamily =>
      pattern == MissionCombatPattern.pressure;

  static LevelGameplayConfig forLevel(int level) {
    final safeLevel = level.clamp(1, 15);

    switch (safeLevel) {
    // ========================================================
    // LEVEL 1
    // ========================================================

      case 1:
        return const LevelGameplayConfig(
          level: 1,
          pattern: MissionCombatPattern.standard,
          duration: 64,
          startingArmyBonus: 0,
          startingFirepower: 1.00,
          reinforcementAmount: 4,
          enemyDifficulty: 1.20,
          pressureStrength: 1.12,
          feature: LevelSpecialFeature.basicAssault,
          stageOne: 'FIRST CONTACT',
          stageTwo: 'FRONTLINE PUSH',
          stageThree: 'FINAL APPROACH',
        );

    // ========================================================
    // LEVEL 2
    // ========================================================

      case 2:
        return const LevelGameplayConfig(
          level: 2,
          pattern: MissionCombatPattern.pressure,
          duration: 70,
          startingArmyBonus: 0,
          startingFirepower: 1.00,
          reinforcementAmount: 4,
          enemyDifficulty: 1.50,
          pressureStrength: 1.35,
          feature: LevelSpecialFeature.movingGates,
          stageOne: 'IRON PUSH',
          stageTwo: 'BREAK THE LINE',
          stageThree: 'FORTRESS APPROACH',
        );

    // ========================================================
    // LEVEL 3
    // ========================================================

      case 3:
        return const LevelGameplayConfig(
          level: 3,
          pattern: MissionCombatPattern.standard,
          duration: 72,
          startingArmyBonus: 0,
          startingFirepower: 1.00,
          reinforcementAmount: 4,
          enemyDifficulty: 1.72,
          pressureStrength: 1.48,
          feature: LevelSpecialFeature.mines,
          stageOne: 'MINEFIELD',
          stageTwo: 'FROZEN CONTACT',
          stageThree: 'OUTPOST BREACH',
        );

    // ========================================================
    // LEVEL 4
    // ========================================================

      case 4:
        return const LevelGameplayConfig(
          level: 4,
          pattern: MissionCombatPattern.pressure,
          duration: 74,
          startingArmyBonus: 0,
          startingFirepower: 1.00,
          reinforcementAmount: 4,
          enemyDifficulty: 1.95,
          pressureStrength: 1.62,
          feature: LevelSpecialFeature.turrets,
          stageOne: 'JUNGLE CONTACT',
          stageTwo: 'TURRET ZONE',
          stageThree: 'AMBUSH BREAK',
        );

    // ========================================================
    // LEVEL 5 — FIRST BOSS
    // ========================================================

      case 5:
        return const LevelGameplayConfig(
          level: 5,
          pattern: MissionCombatPattern.standard,
          duration: 77,
          startingArmyBonus: 1,
          startingFirepower: 1.00,
          reinforcementAmount: 4,
          enemyDifficulty: 2.20,
          pressureStrength: 1.78,
          feature: LevelSpecialFeature.bossRush,
          stageOne: 'HEAVY RESISTANCE',
          stageTwo: 'MECH TERRITORY',
          stageThree: 'BOSS STRONGHOLD',
        );

    // ========================================================
    // LEVEL 6
    // ========================================================

      case 6:
        return const LevelGameplayConfig(
          level: 6,
          pattern: MissionCombatPattern.pressure,
          duration: 78,
          startingArmyBonus: 1,
          startingFirepower: 1.00,
          reinforcementAmount: 4,
          enemyDifficulty: 2.42,
          pressureStrength: 1.92,
          feature: LevelSpecialFeature.speedBoost,
          stageOne: 'HIGH SPEED PUSH',
          stageTwo: 'RAPID CONTACT',
          stageThree: 'FULL THROTTLE',
        );

    // ========================================================
    // LEVEL 7
    // ========================================================

      case 7:
        return const LevelGameplayConfig(
          level: 7,
          pattern: MissionCombatPattern.standard,
          duration: 80,
          startingArmyBonus: 1,
          startingFirepower: 1.00,
          reinforcementAmount: 4,
          enemyDifficulty: 2.65,
          pressureStrength: 2.08,
          feature: LevelSpecialFeature.barricades,
          stageOne: 'BLOCKADE',
          stageTwo: 'BARRICADE LINE',
          stageThree: 'BREAK THROUGH',
        );

    // ========================================================
    // LEVEL 8
    // ========================================================

      case 8:
        return const LevelGameplayConfig(
          level: 8,
          pattern: MissionCombatPattern.pressure,
          duration: 82,
          startingArmyBonus: 1,
          startingFirepower: 1.00,
          reinforcementAmount: 3,
          enemyDifficulty: 2.90,
          pressureStrength: 2.25,
          feature: LevelSpecialFeature.eliteEnemies,
          stageOne: 'ELITE CONTACT',
          stageTwo: 'SPECIAL FORCES',
          stageThree: 'ELITE STRONGHOLD',
        );

    // ========================================================
    // LEVEL 9
    // ========================================================

      case 9:
        return const LevelGameplayConfig(
          level: 9,
          pattern: MissionCombatPattern.standard,
          duration: 84,
          startingArmyBonus: 1,
          startingFirepower: 1.00,
          reinforcementAmount: 3,
          enemyDifficulty: 3.15,
          pressureStrength: 2.42,
          feature: LevelSpecialFeature.riskyGates,
          stageOne: 'RISK ZONE',
          stageTwo: 'TACTICAL CHOICE',
          stageThree: 'NO TURNING BACK',
        );

    // ========================================================
    // LEVEL 10 — MAJOR BOSS
    // ========================================================

      case 10:
        return const LevelGameplayConfig(
          level: 10,
          pattern: MissionCombatPattern.pressure,
          duration: 86,
          startingArmyBonus: 1,
          startingFirepower: 1.00,
          reinforcementAmount: 3,
          enemyDifficulty: 3.45,
          pressureStrength: 2.65,
          feature: LevelSpecialFeature.majorBoss,
          stageOne: 'WAR MACHINE',
          stageTwo: 'HEAVY ASSAULT',
          stageThree: 'COMMANDER AHEAD',
        );

    // ========================================================
    // LEVEL 11
    // ========================================================

      case 11:
        return const LevelGameplayConfig(
          level: 11,
          pattern: MissionCombatPattern.standard,
          duration: 88,
          startingArmyBonus: 1,
          startingFirepower: 1.00,
          reinforcementAmount: 3,
          enemyDifficulty: 3.75,
          pressureStrength: 2.85,
          feature: LevelSpecialFeature.airstrikes,
          stageOne: 'AIR THREAT',
          stageTwo: 'DANGER CLOSE',
          stageThree: 'SURVIVE THE STRIKE',
        );

    // ========================================================
    // LEVEL 12
    // ========================================================

      case 12:
        return const LevelGameplayConfig(
          level: 12,
          pattern: MissionCombatPattern.pressure,
          duration: 90,
          startingArmyBonus: 1,
          startingFirepower: 1.00,
          reinforcementAmount: 3,
          enemyDifficulty: 4.05,
          pressureStrength: 3.05,
          feature: LevelSpecialFeature.shieldGates,
          stageOne: 'SHIELD LINE',
          stageTwo: 'FORTIFIED PUSH',
          stageThree: 'SHIELDS DOWN',
        );

    // ========================================================
    // LEVEL 13
    // ========================================================

      case 13:
        return const LevelGameplayConfig(
          level: 13,
          pattern: MissionCombatPattern.standard,
          duration: 92,
          startingArmyBonus: 1,
          startingFirepower: 1.00,
          reinforcementAmount: 2,
          enemyDifficulty: 4.35,
          pressureStrength: 3.28,
          feature: LevelSpecialFeature.enemyVehicles,
          stageOne: 'ARMORED CONTACT',
          stageTwo: 'VEHICLE COLUMN',
          stageThree: 'CRUSH THE CONVOY',
        );

    // ========================================================
    // LEVEL 14
    // ========================================================

      case 14:
        return const LevelGameplayConfig(
          level: 14,
          pattern: MissionCombatPattern.pressure,
          duration: 95,
          startingArmyBonus: 1,
          startingFirepower: 1.00,
          reinforcementAmount: 2,
          enemyDifficulty: 4.70,
          pressureStrength: 3.55,
          feature: LevelSpecialFeature.highRisk,
          stageOne: 'RED ZONE',
          stageTwo: 'MAXIMUM PRESSURE',
          stageThree: 'FINAL DEFENSE',
        );

    // ========================================================
    // LEVEL 15 — FINAL BOSS
    // ========================================================

      case 15:
      default:
        return const LevelGameplayConfig(
          level: 15,
          pattern: MissionCombatPattern.pressure,
          duration: 100,
          startingArmyBonus: 1,
          startingFirepower: 1.00,
          reinforcementAmount: 2,
          enemyDifficulty: 5.10,
          pressureStrength: 3.90,
          feature: LevelSpecialFeature.finalCommand,
          stageOne: 'FINAL INVASION',
          stageTwo: 'COMMAND BASE',
          stageThree: 'DESTROY THE CORE',
        );
    }
  }
}