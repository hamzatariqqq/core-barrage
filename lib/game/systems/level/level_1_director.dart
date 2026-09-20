import 'package:flame/components.dart';

enum Level1Stage {
  deployment,
  firstGate,
  firstCombat,
  secondGate,
  secondCombat,
  thirdGate,
  heavyCombat,
  finalGate,
  fortifiedApproach,
  bossApproach,
  complete,
}

enum Level1Wave {
  light,
  medium,
  heavy,
}

enum Level1Gate {
  firstChoice,
  secondChoice,
  thirdChoice,
  finalChoice,
}

class Level1Director extends Component {
  Level1Director({
    required this.onWave,
    required this.onGate,
    required this.onBoss,
    required this.onProgress,
    required this.onStageChanged,
  });

  final void Function(
      Level1Wave wave,
      ) onWave;

  final void Function(
      Level1Gate gate,
      ) onGate;

  final void Function() onBoss;

  final void Function(
      double progress,
      ) onProgress;

  final void Function(
      Level1Stage stage,
      ) onStageChanged;

  double _time = 0;

  bool _stopped = false;
  bool _completed = false;

  bool _deploymentDone = false;

  bool _firstGateDone = false;
  bool _firstWaveDone = false;

  bool _secondGateDone = false;
  bool _mediumWaveDone = false;

  bool _thirdGateDone = false;
  bool _heavyWaveDone = false;

  bool _finalGateDone = false;

  bool _fortifiedApproachDone = false;

  bool _bossDone = false;

  // More breathing room for the first level.
  static const double levelDuration = 64.0;

  @override
  void update(double dt) {
    super.update(dt);

    if (_stopped || _completed) {
      return;
    }

    _time += dt;

    onProgress(
      (_time / levelDuration).clamp(
        0.0,
        1.0,
      ),
    );

    // ==========================================================
    // DEPLOYMENT
    // ==========================================================

    if (_time >= 0.3 &&
        !_deploymentDone) {
      _deploymentDone = true;

      onStageChanged(
        Level1Stage.deployment,
      );
    }

    // ==========================================================
    // FIRST GATE
    // Give player power before first fight.
    // ==========================================================

    if (_time >= 2.0 &&
        !_firstGateDone) {
      _firstGateDone = true;

      onStageChanged(
        Level1Stage.firstGate,
      );

      onGate(
        Level1Gate.firstChoice,
      );
    }

    // ==========================================================
    // LIGHT WAVE
    // ==========================================================

    if (_time >= 8.0 &&
        !_firstWaveDone) {
      _firstWaveDone = true;

      onStageChanged(
        Level1Stage.firstCombat,
      );

      onWave(
        Level1Wave.light,
      );
    }

    // ==========================================================
    // SECOND GATE
    // ==========================================================

    if (_time >= 17.0 &&
        !_secondGateDone) {
      _secondGateDone = true;

      onStageChanged(
        Level1Stage.secondGate,
      );

      onGate(
        Level1Gate.secondChoice,
      );
    }

    // ==========================================================
    // MEDIUM WAVE
    // ==========================================================

    if (_time >= 25.0 &&
        !_mediumWaveDone) {
      _mediumWaveDone = true;

      onStageChanged(
        Level1Stage.secondCombat,
      );

      onWave(
        Level1Wave.medium,
      );
    }

    // ==========================================================
    // THIRD GATE
    // ==========================================================

    if (_time >= 35.0 &&
        !_thirdGateDone) {
      _thirdGateDone = true;

      onStageChanged(
        Level1Stage.thirdGate,
      );

      onGate(
        Level1Gate.thirdChoice,
      );
    }

    // ==========================================================
    // HEAVY WAVE
    // ==========================================================

    if (_time >= 43.0 &&
        !_heavyWaveDone) {
      _heavyWaveDone = true;

      onStageChanged(
        Level1Stage.heavyCombat,
      );

      onWave(
        Level1Wave.heavy,
      );
    }

    // ==========================================================
    // FINAL POWER GATE
    // ==========================================================

    if (_time >= 52.0 &&
        !_finalGateDone) {
      _finalGateDone = true;

      onStageChanged(
        Level1Stage.finalGate,
      );

      onGate(
        Level1Gate.finalChoice,
      );
    }

    // ==========================================================
    // BOSS WARNING
    // ==========================================================

    if (_time >= 58.0 &&
        !_fortifiedApproachDone) {
      _fortifiedApproachDone = true;

      onStageChanged(
        Level1Stage.fortifiedApproach,
      );
    }

    // ==========================================================
    // BOSS
    // ==========================================================

    if (_time >= 63.0 &&
        !_bossDone) {
      _bossDone = true;

      onStageChanged(
        Level1Stage.bossApproach,
      );

      onProgress(1.0);

      onBoss();
    }
  }

  void completeLevel() {
    if (_completed) {
      return;
    }

    _completed = true;
    _stopped = true;

    onProgress(1.0);

    onStageChanged(
      Level1Stage.complete,
    );
  }

  void stop() {
    _stopped = true;
  }
}