import 'package:shared_preferences/shared_preferences.dart';

class LevelProgress {
  LevelProgress._();

  static final LevelProgress instance =
  LevelProgress._();

  static const int maxLevels = 15;

  static const String _highestUnlockedKey =
      'core_barrage_highest_unlocked_level';

  static const String _legacyHighestUnlockedKey =
      'highest_unlocked_level';

  int _highestUnlockedLevel = 1;

  final Map<int, int> _stars = {};

  bool _loaded = false;

  int get highestUnlockedLevel =>
      _highestUnlockedLevel;

  bool get loaded => _loaded;

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> load() async {
    final prefs =
    await SharedPreferences.getInstance();

    // Try our new key first.
    int? highest =
    prefs.getInt(_highestUnlockedKey);

    // Preserve older progress if the project used this key.
    highest ??=
        prefs.getInt(
          _legacyHighestUnlockedKey,
        );

    _highestUnlockedLevel =
        (highest ?? 1).clamp(
          1,
          maxLevels,
        );

    _stars.clear();

    for (
    int level = 1;
    level <= maxLevels;
    level++
    ) {
      final savedStars =
          prefs.getInt(
            _starsKey(level),
          ) ??
              0;

      _stars[level] =
          savedStars.clamp(
            0,
            3,
          );
    }

    _loaded = true;
  }

  // ============================================================
  // UNLOCK
  // ============================================================

  bool isLevelUnlocked(
      int level,
      ) {
    if (level < 1 ||
        level > maxLevels) {
      return false;
    }

    return level <=
        _highestUnlockedLevel;
  }

  // ============================================================
  // COMPLETED
  // ============================================================

  bool isLevelCompleted(
      int level,
      ) {
    return starsForLevel(level) > 0;
  }

  // ============================================================
  // STARS
  // ============================================================

  int starsForLevel(
      int level,
      ) {
    return _stars[level] ?? 0;
  }

  int get totalStars {
    int total = 0;

    for (
    int level = 1;
    level <= maxLevels;
    level++
    ) {
      total += starsForLevel(level);
    }

    return total;
  }

  // ============================================================
  // COMPLETE LEVEL
  // ============================================================

  Future<void> completeLevel(
      int level, {
        int stars = 3,
      }) async {
    if (level < 1 ||
        level > maxLevels) {
      return;
    }

    final prefs =
    await SharedPreferences.getInstance();

    final safeStars =
    stars.clamp(
      1,
      3,
    );

    final previous =
    starsForLevel(level);

    // Never replace a better result
    // with a worse result.
    if (safeStars > previous) {
      _stars[level] =
          safeStars;

      await prefs.setInt(
        _starsKey(level),
        safeStars,
      );
    }

    if (level <
        maxLevels) {
      final nextLevel =
          level + 1;

      if (nextLevel >
          _highestUnlockedLevel) {
        _highestUnlockedLevel =
            nextLevel;

        await prefs.setInt(
          _highestUnlockedKey,
          _highestUnlockedLevel,
        );
      }
    }

    _loaded = true;
  }

  // ============================================================
  // DEBUG RESET
  // ============================================================

  Future<void> reset() async {
    final prefs =
    await SharedPreferences.getInstance();

    _highestUnlockedLevel = 1;

    _stars.clear();

    await prefs.setInt(
      _highestUnlockedKey,
      1,
    );

    for (
    int level = 1;
    level <= maxLevels;
    level++
    ) {
      await prefs.remove(
        _starsKey(level),
      );
    }

    _loaded = true;
  }

  String _starsKey(
      int level,
      ) {
    return 'core_barrage_level_${level}_stars';
  }
}