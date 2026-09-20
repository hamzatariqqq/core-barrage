class SelectedVehicle {
  SelectedVehicle._();

  static const int thunder = 0;
  static const int striker = 1;
  static const int titan = 2;
  static const int phantom = 3;
  static const int razor = 4;
  static const int colossus = 5;

  static int current = thunder;

  static void select(int vehicle) {
    current = vehicle.clamp(thunder, colossus);
  }
}