class PlayerHealth {
  PlayerHealth({this.maxHealth = 100}) : currentHealth = maxHealth;

  final double maxHealth;
  double currentHealth;

  bool get isDead => currentHealth <= 0;

  void takeDamage(double damage) {
    currentHealth -= damage;

    if (currentHealth < 0) {
      currentHealth = 0;
    }
  }
}