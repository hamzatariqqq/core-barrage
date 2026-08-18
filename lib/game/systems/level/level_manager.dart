class LevelManager {
  double elapsedTime = 0;

  void update(double dt) {
    elapsedTime += dt;
  }

  int get stage {
    if (elapsedTime < 15) return 1;
    if (elapsedTime < 30) return 2;
    if (elapsedTime < 45) return 3;

    return 4; // Boss stage
  }

  double get progress {
    return (elapsedTime / 45).clamp(0.0, 1.0);
  }

  bool get bossStage => elapsedTime >= 45;
}