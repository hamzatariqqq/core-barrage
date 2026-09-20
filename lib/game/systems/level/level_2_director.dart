import 'package:flame/components.dart';

enum Level2Stage {
  opening,
  firstGate,
  firstCombat,
  pressure,
  secondGate,
  armoredCombat,
  thirdGate,
  assault,
  finalGate,
  finalAssault,
  bossApproach,
  complete,
}

enum Level2Wave {
  scout,
  pressure,
  armored,
  assault,
  finalAssault,
}

enum Level2Gate {
  firstChoice,
  secondChoice,
  thirdChoice,
  finalChoice,
}

class Level2Director extends Component {
  Level2Director({
    required this.onWave,
    required this.onGate,
    required this.onBoss,
    required this.onProgress,
    required this.onStageChanged,
  });

  final void Function(
      Level2Wave wave,
      ) onWave;

  final void Function(
      Level2Gate gate,
      ) onGate;

  final void Function() onBoss;

  final void Function(
      double progress,
      ) onProgress;

  final void Function(
      Level2Stage stage,
      ) onStageChanged;

  // ============================================================
  // LEVEL LENGTH
  // ============================================================

  // Level 2 stays slightly longer than Level 1,
  // but gives breathing room between combat sections.
  static const double levelDuration = 68.0;

  double _elapsed = 0;

  bool _stopped = false;

  Level2Stage _stage =
      Level2Stage.opening;

  // ============================================================
  // FLAGS
  // ============================================================

  bool _openingSent = false;

  bool _firstGate = false;
  bool _scout = false;
  bool _pressure = false;

  bool _secondGate = false;
  bool _armored = false;

  bool _thirdGate = false;
  bool _assault = false;

  bool _finalGate = false;
  bool _finalAssault = false;

  bool _boss = false;

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(
      double dt,
      ) {
    super.update(dt);

    if (_stopped) {
      return;
    }

    _elapsed += dt;

    final progress =
    (_elapsed / levelDuration)
        .clamp(
      0.0,
      1.0,
    )
        .toDouble();

    onProgress(progress);

    // ==========================================================
    // OPENING
    // ==========================================================

    if (!_openingSent &&
        _elapsed >= 0.25) {
      _openingSent = true;

      onStageChanged(
        Level2Stage.opening,
      );
    }

    // ==========================================================
    // FIRST GATE
    // ==========================================================

    if (!_firstGate &&
        _elapsed >= 2.2) {
      _firstGate = true;

      _setStage(
        Level2Stage.firstGate,
      );

      onGate(
        Level2Gate.firstChoice,
      );
    }

    // ==========================================================
    // SCOUT
    // ==========================================================

    if (!_scout &&
        _elapsed >= 8.0) {
      _scout = true;

      _setStage(
        Level2Stage.firstCombat,
      );

      onWave(
        Level2Wave.scout,
      );
    }

    // ==========================================================
    // PRESSURE
    // ==========================================================

    if (!_pressure &&
        _elapsed >= 16.0) {
      _pressure = true;

      _setStage(
        Level2Stage.pressure,
      );

      onWave(
        Level2Wave.pressure,
      );
    }

    // ==========================================================
    // SECOND GATE
    // ==========================================================

    if (!_secondGate &&
        _elapsed >= 25.0) {
      _secondGate = true;

      _setStage(
        Level2Stage.secondGate,
      );

      onGate(
        Level2Gate.secondChoice,
      );
    }

    // ==========================================================
    // ARMORED
    // ==========================================================

    if (!_armored &&
        _elapsed >= 31.0) {
      _armored = true;

      _setStage(
        Level2Stage.armoredCombat,
      );

      onWave(
        Level2Wave.armored,
      );
    }

    // ==========================================================
    // THIRD GATE
    // ==========================================================

    if (!_thirdGate &&
        _elapsed >= 40.0) {
      _thirdGate = true;

      _setStage(
        Level2Stage.thirdGate,
      );

      onGate(
        Level2Gate.thirdChoice,
      );
    }

    // ==========================================================
    // ASSAULT
    // ==========================================================

    if (!_assault &&
        _elapsed >= 46.0) {
      _assault = true;

      _setStage(
        Level2Stage.assault,
      );

      onWave(
        Level2Wave.assault,
      );
    }

    // ==========================================================
    // FINAL GATE
    // ==========================================================

    if (!_finalGate &&
        _elapsed >= 54.0) {
      _finalGate = true;

      _setStage(
        Level2Stage.finalGate,
      );

      onGate(
        Level2Gate.finalChoice,
      );
    }

    // ==========================================================
    // FINAL ASSAULT
    // ==========================================================

    if (!_finalAssault &&
        _elapsed >= 59.0) {
      _finalAssault = true;

      _setStage(
        Level2Stage.finalAssault,
      );

      onWave(
        Level2Wave.finalAssault,
      );
    }

    // ==========================================================
    // BOSS
    // ==========================================================

    if (!_boss &&
        _elapsed >= 67.0) {
      _boss = true;

      _setStage(
        Level2Stage.bossApproach,
      );

      onProgress(1.0);

      onBoss();
    }
  }

  // ============================================================
  // STAGE
  // ============================================================

  void _setStage(
      Level2Stage newStage,
      ) {
    if (_stage == newStage) {
      return;
    }

    _stage = newStage;

    onStageChanged(
      newStage,
    );
  }

  // ============================================================
  // COMPLETE
  // ============================================================

  void completeLevel() {
    if (_stopped) {
      return;
    }

    _setStage(
      Level2Stage.complete,
    );

    onProgress(1.0);

    stop();
  }

  // ============================================================
  // STOP
  // ============================================================

  void stop() {
    _stopped = true;
  }
}