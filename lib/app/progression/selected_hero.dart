class SelectedHero {
  SelectedHero._();

  static const int volt = 0;
  static const int brute = 1;
  static const int nova = 2;
  static const int ghost = 3;
  static const int viper = 4;
  static const int titan = 5;

  static int current = volt;

  static void select(int hero) {
    current = hero.clamp(volt, titan);
  }
}