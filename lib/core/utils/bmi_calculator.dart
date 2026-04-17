class BmiCalculator {
  static double calculate({required double weightKg, required double heightCm}) {
    if (heightCm == 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static String category(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal weight';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  static double dailyWaterTarget(double weightKg) {
    return (weightKg * 35).clamp(2000, 4000);
  }

  static double dailyProteinTarget(double weightKg, String goal) {
    if (goal == 'muscle_gain') return weightKg * 2.0;
    if (goal == 'fat_loss') return weightKg * 1.8;
    return weightKg * 1.6;
  }

  static double tdee({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    double bmr;
    if (gender == 'male') {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }
    const multipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };
    return bmr * (multipliers[activityLevel] ?? 1.55);
  }
}
