class SelectedLevel {
  SelectedLevel._();

  static int current = 1;

  static void select(int level) {
    current = level.clamp(1, 15);
  }
}