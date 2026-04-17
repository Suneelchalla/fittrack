import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/calorie_calculator.dart';
import '../../data/models/activity_log.dart';
import '../../providers/user_provider.dart';
import '../../providers/activity_provider.dart';

class CycleScreen extends ConsumerStatefulWidget {
  const CycleScreen({super.key});
  @override
  ConsumerState<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends ConsumerState<CycleScreen> {
  double _distanceKm = 10.0;
  int _durationMin = 30;
  String _intensity = 'Moderate';

  static const _mets = {'Light': 4.0, 'Moderate': 6.8, 'Intense': 10.0};
  static const _iColors = {'Light': Color(0xFF34D399), 'Moderate': Color(0xFFFBBF24), 'Intense': Color(0xFFEF4444)};

  double get _calories {
    final p = ref.read(userProfileNotifierProvider);
    if (p == null) return 0;
    final w = p.useMetric ? p.weight : p.weight * 0.453592;
    return CalorieCalculator.estimate(met: _mets[_intensity]!, weightKg: w, durationMin: _durationMin.toDouble());
  }

  double get _speed => _durationMin > 0 ? _distanceKm / (_durationMin / 60) : 0;

  Future<void> _save() async {
    final log = ActivityLog(id: const Uuid().v4(), type: 'cycle',
      durationMin: _durationMin.toDouble(), distanceKm: _distanceKm,
      caloriesBurned: _calories, loggedAt: DateTime.now(), notes: 'Intensity: $_intensity');
    await ref.read(activityLogsProvider.notifier).addLog(log);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ride saved — ${_calories.toStringAsFixed(0)} kcal!'),
          backgroundColor: AppTheme.accent, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(backgroundColor: AppTheme.background, elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded,
          color: AppTheme.textPrimary), onPressed: () => Navigator.pop(context)),
      title: const Text('Cycle', style: TextStyle(color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700, fontSize: 20))),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _S('${_calories.toStringAsFixed(0)}', 'kcal'),
            _S('${_speed.toStringAsFixed(1)}', 'km/h'),
            _S('${_distanceKm.toStringAsFixed(1)}', 'km'),
          ])),
        const SizedBox(height: 20),
        Row(children: ['Light','Moderate','Intense'].map((i) {
          final sel = _intensity == i;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _intensity = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: sel ? _iColors[i] : AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? Colors.transparent : Colors.white.withOpacity(0.1))),
              child: Text(i, textAlign: TextAlign.center, style: TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textSecondary)))));
        }).toList()),
        const SizedBox(height: 16),
        _C('Distance', '${_distanceKm.toStringAsFixed(1)} km',
          Slider(value: _distanceKm, min: 1, max: 150, divisions: 149,
            activeColor: const Color(0xFF0EA5E9), inactiveColor: AppTheme.card,
            onChanged: (v) => setState(() => _distanceKm = v))),
        const SizedBox(height: 12),
        _C('Duration', '$_durationMin min',
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _B(Icons.remove, () => setState(() => _durationMin = math.max(5, _durationMin - 5))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('$_durationMin min', style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))),
            _B(Icons.add, () => setState(() => _durationMin += 5)),
          ])),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
            onPressed: _save,
            child: const Text('Save Ride', style: TextStyle(
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
    Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
    Text(l, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8))),
  ]);
}

class _C extends StatelessWidget {
  final String label, value; final Widget child;
  const _C(this.label, this.value, this.child);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary, letterSpacing: 1.2)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accent)),
      ]),
      const SizedBox(height: 10), child,
    ]));
}

class _B extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _B(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap,
    child: Container(width: 40, height: 40,
      decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: AppTheme.accent, size: 20)));
}
