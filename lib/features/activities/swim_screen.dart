import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/calorie_calculator.dart';
import '../../data/models/activity_log.dart';
import '../../providers/user_provider.dart';
import '../../providers/activity_provider.dart';

class SwimScreen extends ConsumerStatefulWidget {
  const SwimScreen({super.key});
  @override
  ConsumerState<SwimScreen> createState() => _SwimScreenState();
}

class _SwimScreenState extends ConsumerState<SwimScreen> {
  int _durationMin = 30;
  int _laps = 20;
  String _stroke = 'Freestyle';

  static const _mets = {'Freestyle':6.0,'Breaststroke':5.3,'Backstroke':4.8,'Butterfly':13.8};
  static const _emojis = {'Freestyle':'🏊','Breaststroke':'🐸','Backstroke':'🔄','Butterfly':'🦋'};

  double get _distanceKm => (_laps * 25) / 1000;

  double get _calories {
    final p = ref.read(userProfileNotifierProvider);
    if (p == null) return 0;
    final w = p.useMetric ? p.weight : p.weight * 0.453592;
    return CalorieCalculator.estimate(met: _mets[_stroke]!, weightKg: w, durationMin: _durationMin.toDouble());
  }

  Future<void> _save() async {
    final log = ActivityLog(id: const Uuid().v4(), type: 'swim',
      durationMin: _durationMin.toDouble(), distanceKm: _distanceKm,
      caloriesBurned: _calories, loggedAt: DateTime.now(),
      notes: 'Stroke: $_stroke | Laps: $_laps');
    await ref.read(activityLogsProvider.notifier).addLog(log);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Swim saved — ${_calories.toStringAsFixed(0)} kcal!'),
          backgroundColor: AppTheme.accent, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(backgroundColor: AppTheme.background, elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded,
          color: AppTheme.textPrimary), onPressed: () => Navigator.pop(context)),
      title: const Text('Swim', style: TextStyle(color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700, fontSize: 20))),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            const Text('🌊', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _S('${_calories.toStringAsFixed(0)} kcal', 'Calories'),
              _S('${_distanceKm.toStringAsFixed(2)} km', 'Distance'),
              _S('$_laps laps', 'Laps'),
            ])])),
        const SizedBox(height: 20),
        GridView.count(crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.4,
          children: _mets.keys.map((s) {
            final sel = _stroke == s;
            return GestureDetector(onTap: () => setState(() => _stroke = s),
              child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF06B6D4) : AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sel ? Colors.transparent : Colors.white.withOpacity(0.1))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_emojis[s]!, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(s, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppTheme.textSecondary)),
                ])));
          }).toList()),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('DURATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _B(Icons.remove, () => setState(() => _durationMin = math.max(5, _durationMin - 5))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('$_durationMin min', style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
              _B(Icons.add, () => setState(() => _durationMin += 5)),
            ])])),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('LAPS (25m pool)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _B(Icons.remove, () => setState(() => _laps = math.max(1, _laps - 1))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('$_laps', style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
              _B(Icons.add, () => setState(() => _laps++)),
            ])])),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06B6D4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
            onPressed: _save,
            child: const Text('Save Swim', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)))),
      ]),
    ),
  );
}

class _S extends StatelessWidget {
  final String v, l;
  const _S(this.v, this.l);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(v, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
    Text(l, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75))),
  ]);
}

class _B extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _B(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(width: 40, height: 40,
      decoration: BoxDecoration(color: const Color(0xFF06B6D4).withOpacity(0.15),
          borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: const Color(0xFF06B6D4), size: 20)));
}
