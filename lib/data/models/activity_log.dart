class ActivityLog {
  final String id;
  final String type;
  final double durationMin;
  final double distanceKm;
  final double caloriesBurned;
  final DateTime loggedAt;
  final String? notes;

  const ActivityLog({
    required this.id,
    required this.type,
    required this.durationMin,
    required this.distanceKm,
    required this.caloriesBurned,
    required this.loggedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'type': type,
    'durationMin': durationMin, 'distanceKm': distanceKm,
    'caloriesBurned': caloriesBurned,
    'loggedAt': loggedAt.toIso8601String(),
    'notes': notes,
  };

  factory ActivityLog.fromMap(Map<String, dynamic> map) => ActivityLog(
    id: map['id'] as String,
    type: map['type'] as String,
    durationMin: (map['durationMin'] as num).toDouble(),
    distanceKm: (map['distanceKm'] as num).toDouble(),
    caloriesBurned: (map['caloriesBurned'] as num).toDouble(),
    loggedAt: DateTime.parse(map['loggedAt'] as String),
    notes: map['notes'] as String?,
  );
}
