import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/activity_log.dart';

class ActivityLogsNotifier extends StateNotifier<List<ActivityLog>> {
  ActivityLogsNotifier() : super([]) { _load(); }

  Future<void> _load() async {
    final box = await Hive.openBox<Map>('activity_logs');
    final logs = box.values
        .map((m) => ActivityLog.fromMap(Map<String, dynamic>.from(m)))
        .toList();
    logs.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    state = logs;
  }

  Future<void> addLog(ActivityLog log) async {
    final box = await Hive.openBox<Map>('activity_logs');
    await box.put(log.id, log.toMap());
    await _load();
  }

  Future<void> delete(String id) async {
    final box = await Hive.openBox<Map>('activity_logs');
    await box.delete(id);
    await _load();
  }
}

final activityLogsProvider =
    StateNotifierProvider<ActivityLogsNotifier, List<ActivityLog>>(
        (_) => ActivityLogsNotifier());

final todayCaloriesProvider = Provider<double>((ref) {
  final logs = ref.watch(activityLogsProvider);
  final now = DateTime.now();
  return logs
      .where((l) => l.loggedAt.day == now.day &&
          l.loggedAt.month == now.month &&
          l.loggedAt.year == now.year)
      .fold(0.0, (s, l) => s + l.caloriesBurned);
});

final weeklyLogsProvider = Provider<List<ActivityLog>>((ref) {
  final logs = ref.watch(activityLogsProvider);
  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  return logs.where((l) => l.loggedAt.isAfter(weekAgo)).toList();
});
