class UserProfile {
  final String name;
  final String gender;
  final int age;
  final double weight;
  final double height;
  final String fitnessGoal;
  final String activityLevel;
  final bool useMetric;
  final List<String> preferredActivities;
  final double dailyWaterMl;
  final double dailyProteinG;
  final double dailyCalorieTarget;

  const UserProfile({
    required this.name,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.fitnessGoal,
    required this.activityLevel,
    required this.useMetric,
    required this.preferredActivities,
    required this.dailyWaterMl,
    required this.dailyProteinG,
    required this.dailyCalorieTarget,
  });

  UserProfile copyWith({
    String? name, String? gender, int? age, double? weight, double? height,
    String? fitnessGoal, String? activityLevel, bool? useMetric,
    List<String>? preferredActivities, double? dailyWaterMl,
    double? dailyProteinG, double? dailyCalorieTarget,
  }) => UserProfile(
    name: name ?? this.name,
    gender: gender ?? this.gender,
    age: age ?? this.age,
    weight: weight ?? this.weight,
    height: height ?? this.height,
    fitnessGoal: fitnessGoal ?? this.fitnessGoal,
    activityLevel: activityLevel ?? this.activityLevel,
    useMetric: useMetric ?? this.useMetric,
    preferredActivities: preferredActivities ?? this.preferredActivities,
    dailyWaterMl: dailyWaterMl ?? this.dailyWaterMl,
    dailyProteinG: dailyProteinG ?? this.dailyProteinG,
    dailyCalorieTarget: dailyCalorieTarget ?? this.dailyCalorieTarget,
  );

  Map<String, dynamic> toMap() => {
    'name': name, 'gender': gender, 'age': age,
    'weight': weight, 'height': height,
    'fitnessGoal': fitnessGoal, 'activityLevel': activityLevel,
    'useMetric': useMetric,
    'preferredActivities': preferredActivities,
    'dailyWaterMl': dailyWaterMl,
    'dailyProteinG': dailyProteinG,
    'dailyCalorieTarget': dailyCalorieTarget,
  };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    name: map['name'] as String,
    gender: map['gender'] as String,
    age: map['age'] as int,
    weight: (map['weight'] as num).toDouble(),
    height: (map['height'] as num).toDouble(),
    fitnessGoal: map['fitnessGoal'] as String,
    activityLevel: map['activityLevel'] as String,
    useMetric: map['useMetric'] as bool,
    preferredActivities: List<String>.from(map['preferredActivities']),
    dailyWaterMl: (map['dailyWaterMl'] as num).toDouble(),
    dailyProteinG: (map['dailyProteinG'] as num).toDouble(),
    dailyCalorieTarget: (map['dailyCalorieTarget'] as num).toDouble(),
  );
}
