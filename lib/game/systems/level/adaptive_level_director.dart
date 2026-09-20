import 'package:flame/components.dart';

import 'level_gameplay_config.dart';

class AdaptiveLevelDirector extends Component {
  AdaptiveLevelDirector({
    required this.config,
    required this.onReinforcement,
    required this.onPressure,
    required this.onProgress,
    required this.onStageBanner,
  });

  final LevelGameplayConfig config;

  final void Function(int amount) onReinforcement;
  final void Function() onPressure;
  final void Function(double value) onProgress;
  final void Function(String title) onStageBanner;

  double _elapsed = 0;

  bool _stopped = false;

  bool _stageOneShown = false;
  bool _stageTwoShown = false;
  bool _stageThreeShown = false;

  bool _reinforcementGiven = false;

  bool _pressureOne = false;
  bool _pressureTwo = false;
  bool _pressureThree = false;

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    if (_stopped) {
      return;
    }

    _elapsed += dt;

    final duration = config.duration;

    final progress = (_elapsed / duration).clamp(
      0.0,
      1.0,
    );

    onProgress(progress);

    // ==========================================================
    // 4% — OPENING
    // ==========================================================

    if (!_stageOneShown &&
        progress >= 0.04) {
      _stageOneShown = true;

      onStageBanner(
        config.stageOne,
      );
    }

    // ==========================================================
    // 24% — ONE SMALL REINFORCEMENT
    //
    // Old system gave TWO automatic reinforcement drops.
    // We now give only one.
    // ==========================================================

    if (!_reinforcementGiven &&
        progress >= 0.24) {
      _reinforcementGiven = true;

      final int amount =
          config.reinforcementAmount;

      if (amount > 0) {
        onReinforcement(
          amount,
        );
      }
    }

    // ==========================================================
    // 31% — FIRST PRESSURE
    // ==========================================================

    if (!_pressureOne &&
        progress >= 0.31) {
      _pressureOne = true;

      if (config.level >= 2) {
        onPressure();
      }
    }

    // ==========================================================
    // 43% — MID LEVEL
    // ==========================================================

    if (!_stageTwoShown &&
        progress >= 0.43) {
      _stageTwoShown = true;

      onStageBanner(
        config.stageTwo,
      );
    }

    // ==========================================================
    // 61% — SECOND PRESSURE
    //
    // Starts earlier on later levels.
    // This replaces the old second free reinforcement.
    // ==========================================================

    if (!_pressureTwo &&
        progress >= 0.61) {
      _pressureTwo = true;

      if (config.level >= 4) {
        onPressure();
      }
    }

    // ==========================================================
    // 76% — FINAL APPROACH
    // ==========================================================

    if (!_stageThreeShown &&
        progress >= 0.76) {
      _stageThreeShown = true;

      onStageBanner(
        config.stageThree,
      );
    }

    // ==========================================================
    // 87% — LATE PRESSURE
    // ==========================================================

    if (!_pressureThree &&
        progress >= 0.87) {
      _pressureThree = true;

      if (config.level >= 8) {
        onPressure();
      }
    }

    // ==========================================================
    // COMPLETE PROGRESS
    //
    // Boss spawning remains controlled by the existing
    // Level1Director / Level2Director.
    // ==========================================================

    if (progress >= 1.0) {
      onProgress(
        1.0,
      );
    }
  }

  // ============================================================
  // STOP
  // ============================================================

  void stop() {
    _stopped = true;
  }
}