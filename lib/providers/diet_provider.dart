import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/meal_entry.dart';

class MealEntriesNotifier extends StateNotifier<List<MealEntry>> {
  MealEntriesNotifier() : super([]) { _load(); }

  Future<void> _load() async {
    final box = await Hive.openBox<Map>('meal_entries');
    final entries = box.values
        .map((m) => MealEntry.fromMap(Map<String, dynamic>.from(m)))
        .toList();
    entries.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    state = entries;
  }

  Future<void> addEntry(MealEntry entry) async {
    final box = await Hive.openBox<Map>('meal_entries');
    await box.put(entry.id, entry.toMap());
    await _load();
  }

  Future<void> removeEntry(String id) async {
    final box = await Hive.openBox<Map>('meal_entries');
    await box.delete(id);
    await _load();
  }
}

final mealEntriesProvider =
    StateNotifierProvider<MealEntriesNotifier, List<MealEntry>>(
        (_) => MealEntriesNotifier());

final todayProteinProvider = Provider<double>((ref) {
  final meals = ref.watch(mealEntriesProvider);
  final now = DateTime.now();
  return meals
      .where((m) => m.loggedAt.day == now.day &&
          m.loggedAt.month == now.month &&
          m.loggedAt.year == now.year)
      .fold(0.0, (s, m) => s + m.proteinG);
});

final todayCaloriesFromFoodProvider = Provider<double>((ref) {
  final meals = ref.watch(mealEntriesProvider);
  final now = DateTime.now();
  return meals
      .where((m) => m.loggedAt.day == now.day &&
          m.loggedAt.month == now.month &&
          m.loggedAt.year == now.year)
      .fold(0.0, (s, m) => s + (m.calories ?? 0));
});
