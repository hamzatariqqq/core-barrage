import 'package:shared_preferences/shared_preferences.dart';

class GameProgress {
  GameProgress._();

  static final GameProgress instance =
  GameProgress._();

  // ============================================================
  // SAVE KEYS
  // ============================================================

  static const String _coinsKey =
      'core_barrage_coins';

  static const String _damageLevelKey =
      'core_barrage_damage_level';

  static const String _fireRateLevelKey =
      'core_barrage_fire_rate_level';

  static const String _armyLevelKey =
      'core_barrage_army_level';

  static const String _healthLevelKey =
      'core_barrage_health_level';

  // ============================================================
  // DEFAULT PROGRESSION
  //
  // New players no longer begin with thousands of coins.
  // Existing saved players keep their current balance.
  // ============================================================

  static const int _defaultCoins = 200;

  static const int maxUpgradeLevel = 20;

  int _coins = _defaultCoins;

  int _damageLevel = 1;
  int _fireRateLevel = 1;
  int _armyLevel = 1;
  int _healthLevel = 1;

  // ============================================================
  // GETTERS
  // ============================================================

  int get coins => _coins;

  int get damageLevel => _damageLevel;

  int get fireRateLevel =>
      _fireRateLevel;

  int get armyLevel => _armyLevel;

  int get healthLevel =>
      _healthLevel;

  // ============================================================
  // PLAYER STATS
  // ============================================================

  int get startingArmy {
    return 6 +
        ((_armyLevel - 1) * 2);
  }

  double get maxHealth {
    return 100 +
        ((_healthLevel - 1) * 20);
  }

  double get fireRateMultiplier {
    return 1.0 +
        ((_fireRateLevel - 1) * 0.08);
  }

  double get damageMultiplier {
    return 1.0 +
        ((_damageLevel - 1) * 0.12);
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> load() async {
    final prefs =
    await SharedPreferences.getInstance();

    _coins =
        prefs.getInt(_coinsKey) ??
            _defaultCoins;

    _damageLevel =
        prefs.getInt(_damageLevelKey) ??
            1;

    _fireRateLevel =
        prefs.getInt(
          _fireRateLevelKey,
        ) ??
            1;

    _armyLevel =
        prefs.getInt(_armyLevelKey) ??
            1;

    _healthLevel =
        prefs.getInt(_healthLevelKey) ??
            1;

    _damageLevel =
        _damageLevel.clamp(
          1,
          maxUpgradeLevel,
        );

    _fireRateLevel =
        _fireRateLevel.clamp(
          1,
          maxUpgradeLevel,
        );

    _armyLevel =
        _armyLevel.clamp(
          1,
          maxUpgradeLevel,
        );

    _healthLevel =
        _healthLevel.clamp(
          1,
          maxUpgradeLevel,
        );

    if (_coins < 0) {
      _coins = 0;
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setInt(
      _coinsKey,
      _coins,
    );

    await prefs.setInt(
      _damageLevelKey,
      _damageLevel,
    );

    await prefs.setInt(
      _fireRateLevelKey,
      _fireRateLevel,
    );

    await prefs.setInt(
      _armyLevelKey,
      _armyLevel,
    );

    await prefs.setInt(
      _healthLevelKey,
      _healthLevel,
    );
  }

  // ============================================================
  // COINS
  // ============================================================

  Future<void> addCoins(
      int amount,
      ) async {
    if (amount <= 0) {
      return;
    }

    _coins += amount;

    await _save();
  }

  Future<bool> spendCoins(
      int amount,
      ) async {
    if (amount <= 0) {
      return false;
    }

    if (_coins < amount) {
      return false;
    }

    _coins -= amount;

    await _save();

    return true;
  }

  // ============================================================
  // UPGRADE COSTS
  //
  // Goal:
  // Early upgrades require actual gameplay.
  // Later upgrades become meaningful long-term progression.
  // ============================================================

  int damageUpgradeCost() {
    return _upgradeCost(
      _damageLevel,
    );
  }

  int fireRateUpgradeCost() {
    return _upgradeCost(
      _fireRateLevel,
    );
  }

  int armyUpgradeCost() {
    return _upgradeCost(
      _armyLevel,
    );
  }

  int healthUpgradeCost() {
    return _upgradeCost(
      _healthLevel,
    );
  }

  int _upgradeCost(
      int level,
      ) {
    if (level >= maxUpgradeLevel) {
      return 0;
    }

    // Level 1 -> 2 = 300
    // Level 2 -> 3 = 440
    // Level 3 -> 4 = 580
    // Level 5 -> 6 = 860
    // Level 10 -> 11 = 1560
    // Level 19 -> 20 = 2820

    return 300 +
        ((level - 1) * 140);
  }

  // ============================================================
  // DAMAGE
  // ============================================================

  Future<bool> upgradeDamage() async {
    if (_damageLevel >=
        maxUpgradeLevel) {
      return false;
    }

    final cost =
    damageUpgradeCost();

    if (_coins < cost) {
      return false;
    }

    _coins -= cost;

    _damageLevel++;

    await _save();

    return true;
  }

  // ============================================================
  // FIRE RATE
  // ============================================================

  Future<bool> upgradeFireRate() async {
    if (_fireRateLevel >=
        maxUpgradeLevel) {
      return false;
    }

    final cost =
    fireRateUpgradeCost();

    if (_coins < cost) {
      return false;
    }

    _coins -= cost;

    _fireRateLevel++;

    await _save();

    return true;
  }

  // ============================================================
  // STARTING ARMY
  // ============================================================

  Future<bool> upgradeArmy() async {
    if (_armyLevel >=
        maxUpgradeLevel) {
      return false;
    }

    final cost =
    armyUpgradeCost();

    if (_coins < cost) {
      return false;
    }

    _coins -= cost;

    _armyLevel++;

    await _save();

    return true;
  }

  // ============================================================
  // HEALTH / ARMOR
  // ============================================================

  Future<bool> upgradeHealth() async {
    if (_healthLevel >=
        maxUpgradeLevel) {
      return false;
    }

    final cost =
    healthUpgradeCost();

    if (_coins < cost) {
      return false;
    }

    _coins -= cost;

    _healthLevel++;

    await _save();

    return true;
  }
}