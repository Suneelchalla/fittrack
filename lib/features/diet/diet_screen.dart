import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/meal_entry.dart';
import '../../providers/user_provider.dart';
import '../../providers/diet_provider.dart';

class DietScreen extends ConsumerStatefulWidget {
  const DietScreen({super.key});
  @override
  ConsumerState<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends ConsumerState<DietScreen> {
  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileNotifierProvider);
    final meals = ref.watch(mealEntriesProvider);
    final todayProtein = ref.watch(todayProteinProvider);
    final todayKcal = ref.watch(todayCaloriesFromFoodProvider);
    final proteinTarget = profile?.dailyProteinG ?? 144;
    final kcalTarget = profile?.dailyCalorieTarget ?? 2000;
    final now = DateTime.now();
    final todayMeals = meals.where((m) =>
        m.loggedAt.day == now.day && m.loggedAt.month == now.month).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background, elevation: 0,
        title: const Text('Diet', style: TextStyle(color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800, fontSize: 24)),
        actions: [IconButton(
          icon: const Icon(Icons.add_rounded, color: AppTheme.textPrimary, size: 28),
          onPressed: () => _showAdd(context))]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Today\'s Nutrition', style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w700, color: Colors.white)),
                Text('${todayMeals.length} meals', style: TextStyle(
                    fontSize: 12, color: Colors.white.withOpacity(0.75))),
              ]),
              const SizedBox(height: 16),
              _MacroBar('Protein', todayProtein, proteinTarget, 'g', Colors.white),
              const SizedBox(height: 10),
              _MacroBar('Calories', todayKcal, kcalTarget, 'kcal', const Color(0xFFFBBF24)),
            ])),
          const SizedBox(height: 20),
          for (final type in ['breakfast', 'lunch', 'dinner', 'snacks']) ...[
            _MealSection(
              type: type,
              meals: todayMeals.where((m) => m.mealType == type).toList(),
              onAdd: () => _showAdd(context, defaultType: type),
              onDelete: (id) => ref.read(mealEntriesProvider.notifier).removeEntry(id)),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  void _showAdd(BuildContext context, {String defaultType = 'breakfast'}) {
    final nameCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final kcalCtrl = TextEditingController();
    String mealType = defaultType;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(builder: (ctx, setSt) {
        final bottom = MediaQuery.of(ctx).viewInsets.bottom;
        return Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
          decoration: const BoxDecoration(color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Log Meal', style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              IconButton(icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                onPressed: () => Navigator.pop(ctx)),
            ]),
            const SizedBox(height: 12),
            SingleChildScrollView(scrollDirection: Axis.horizontal,
              child: Row(children: ['breakfast','lunch','dinner','snacks'].map((t) =>
                GestureDetector(
                  onTap: () => setSt(() => mealType = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: mealType == t ? AppTheme.accent : AppTheme.card,
                      borderRadius: BorderRadius.circular(20)),
                    child: Text(t[0].toUpperCase() + t.substring(1),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                            color: mealType == t ? Colors.white : AppTheme.textSecondary)),
                  ))).toList())),
            const SizedBox(height: 14),
            TextField(controller: nameCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(hintText: 'Food name',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                filled: true, fillColor: AppTheme.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12))),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(controller: proteinCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(hintText: 'Protein (g)',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true, fillColor: AppTheme.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: kcalCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(hintText: 'Calories (opt)',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true, fillColor: AppTheme.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)))),
            ]),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final protein = double.tryParse(proteinCtrl.text) ?? 0;
                  if (name.isEmpty || protein <= 0) return;
                  ref.read(mealEntriesProvider.notifier).addEntry(MealEntry(
                    id: const Uuid().v4(), name: name, proteinG: protein,
                    calories: double.tryParse(kcalCtrl.text),
                    mealType: mealType, loggedAt: DateTime.now()));
                  Navigator.pop(ctx);
                },
                child: const Text('Save Meal', style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)))),
          ]),
        );
      }),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label, unit;
  final double current, target;
  final Color color;
  const _MacroBar(this.label, this.current, this.target, this.unit, this.color);
  @override
  Widget build(BuildContext context) {
    final p = (current / target).clamp(0.0, 1.0);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
        Text('${current.toStringAsFixed(0)}/${target.toStringAsFixed(0)}$unit',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: p, minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.2), color: color)),
    ]);
  }
}

class _MealSection extends StatelessWidget {
  final String type;
  final List<MealEntry> meals;
  final VoidCallback onAdd;
  final void Function(String) onDelete;
  const _MealSection({required this.type, required this.meals,
      required this.onAdd, required this.onDelete});

  static const _emojis = {'breakfast':'🌅','lunch':'☀️','dinner':'🌙','snacks':'🍎'};
  static const _colors = {
    'breakfast': Color(0xFFF59E0B), 'lunch': Color(0xFF10B981),
    'dinner': Color(0xFF8B5CF6), 'snacks': Color(0xFFEF4444)};

  @override
  Widget build(BuildContext context) {
    final color = _colors[type]!;
    final total = meals.fold<double>(0, (s, m) => s + m.proteinG);
    return Container(
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Text(_emojis[type]!, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(type[0].toUpperCase() + type.substring(1),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              if (meals.isNotEmpty) Text('${total.toStringAsFixed(0)}g protein',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ])),
            GestureDetector(onTap: onAdd,
              child: Container(width: 30, height: 30,
                decoration: BoxDecoration(color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.add_rounded, color: color, size: 20))),
          ])),
        if (meals.isNotEmpty) ...[
          const Divider(height: 0, color: Colors.white12),
          ...meals.map((m) => Dismissible(
            key: Key(m.id), direction: DismissDirection.endToStart,
            background: Container(alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              color: const Color(0xFFEF4444).withOpacity(0.2),
              child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444))),
            onDismissed: (_) => onDelete(m.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.name, style: const TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  Text('${m.proteinG.toStringAsFixed(0)}g protein'
                      '${m.calories != null ? " • ${m.calories!.toStringAsFixed(0)} kcal" : ""}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ])),
              ])),
          )),
        ] else Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 14),
          child: Text('Tap + to add', style: const TextStyle(
              fontSize: 12, color: AppTheme.textSecondary))),
      ]),
    );
  }
}
