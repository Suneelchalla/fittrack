class WaterLog {
  final String id;
  final double amountMl;
  final DateTime loggedAt;

  const WaterLog({
    required this.id,
    required this.amountMl,
    required this.loggedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'amountMl': amountMl,
    'loggedAt': loggedAt.toIso8601String(),
  };

  factory WaterLog.fromMap(Map<String, dynamic> map) => WaterLog(
    id: map['id'] as String,
    amountMl: (map['amountMl'] as num).toDouble(),
    loggedAt: DateTime.parse(map['loggedAt'] as String),
  );
}
