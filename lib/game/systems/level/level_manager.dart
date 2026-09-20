class LevelManager {
  LevelManager();

  double _elapsedTime = 0;

  double get elapsedTime =>
      _elapsedTime;

  void update(double dt) {
    if (dt <= 0) {
      return;
    }

    _elapsedTime += dt;
  }

  void reset() {
    _elapsedTime = 0;
  }
}