class MealEntry {
  final String id;
  final String name;
  final double proteinG;
  final double? calories;
  final String mealType;
  final DateTime loggedAt;

  const MealEntry({
    required this.id,
    required this.name,
    required this.proteinG,
    this.calories,
    required this.mealType,
    required this.loggedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name,
    'proteinG': proteinG, 'calories': calories,
    'mealType': mealType,
    'loggedAt': loggedAt.toIso8601String(),
  };

  factory MealEntry.fromMap(Map<String, dynamic> map) => MealEntry(
    id: map['id'] as String,
    name: map['name'] as String,
    proteinG: (map['proteinG'] as num).toDouble(),
    calories: map['calories'] != null ? (map['calories'] as num).toDouble() : null,
    mealType: map['mealType'] as String,
    loggedAt: DateTime.parse(map['loggedAt'] as String),
  );
}
