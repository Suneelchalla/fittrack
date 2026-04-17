class CalorieCalculator {
  static double estimate({
    required double met,
    required double weightKg,
    required double durationMin,
  }) {
    return met * weightKg * (durationMin / 60);
  }

  static double pace(double distanceKm, double durationMin) {
    if (distanceKm == 0) return 0;
    return durationMin / distanceKm;
  }

  static double speed(double distanceKm, double durationMin) {
    if (durationMin == 0) return 0;
    return distanceKm / (durationMin / 60);
  }
}
