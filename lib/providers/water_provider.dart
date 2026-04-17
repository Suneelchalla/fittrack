import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/water_log.dart';

class WaterLogsNotifier extends StateNotifier<List<WaterLog>> {
  WaterLogsNotifier() : super([]) { _load(); }

  Future<void> _load() async {
    final box = await Hive.openBox<Map>('water_logs');
    final logs = box.values
        .map((m) => WaterLog.fromMap(Map<String, dynamic>.from(m)))
        .toList();
    logs.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    state = logs;
  }

  Future<void> addLog(WaterLog log) async {
    final box = await Hive.openBox<Map>('water_logs');
    await box.put(log.id, log.toMap());
    await _load();
  }
}

final waterLogsProvider =
    StateNotifierProvider<WaterLogsNotifier, List<WaterLog>>(
        (_) => WaterLogsNotifier());

final todayWaterMlProvider = Provider<double>((ref) {
  final logs = ref.watch(waterLogsProvider);
  final now = DateTime.now();
  return logs
      .where((l) => l.loggedAt.day == now.day &&
          l.loggedAt.month == now.month &&
          l.loggedAt.year == now.year)
      .fold(0.0, (s, l) => s + l.amountMl);
});
