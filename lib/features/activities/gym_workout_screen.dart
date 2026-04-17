import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/activity_log.dart';
import '../../providers/activity_provider.dart';

class GymWorkoutScreen extends ConsumerStatefulWidget {
  const GymWorkoutScreen({super.key});
  @override
  ConsumerState<GymWorkoutScreen> createState() => _GymWorkoutScreenState();
}

class _GymWorkoutScreenState extends ConsumerState<GymWorkoutScreen> {
  int _dayIndex = DateTime.now().weekday - 1;
  final Set<String> _done = {};
  bool _timerActive = false;
  int _timerSec = 90;
  Timer? _timer;

  static const _days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
  static const _splits = [
    'Chest & Shoulders','Back & Arms','Legs & Abs',
    'Chest & Shoulders','Back & Arms','Legs & Abs','Rest & Mobility'
  ];
  static const _workouts = {
    'Chest & Shoulders': [
      ['Bench Press','🏋️','Chest','4','8-10','120'],
      ['Incline DB Press','💪','Upper Chest','3','10-12','90'],
      ['Shoulder Press','⬆️','Shoulders','4','8-10','90'],
      ['Lateral Raises','↔️','Side Delts','3','12-15','60'],
      ['Cable Flyes','🔄','Chest','3','12-15','60'],
    ],
    'Back & Arms': [
      ['Pull-Ups','🔝','Back','4','6-10','120'],
      ['Barbell Row','🚣','Back','4','8-10','90'],
      ['Bicep Curls','💪','Biceps','3','12','60'],
      ['Tricep Pushdown','⬇️','Triceps','3','12','60'],
      ['Face Pulls','🎯','Rear Delts','3','15','45'],
    ],
    'Legs & Abs': [
      ['Squats','🦵','Quads','4','8-10','120'],
      ['Romanian Deadlift','🏋️','Hamstrings','3','10','90'],
      ['Leg Press','🦿','Quads','3','12','90'],
      ['Calf Raises','🦶','Calves','4','15','45'],
      ['Plank','🧱','Core','3','60s','30'],
    ],
    'Rest & Mobility': [
      ['Hip Circles','🔵','Hips','2','10 each','20'],
      ['Cat-Cow','🐱','Spine','2','10','15'],
      ['Foam Rolling','🪵','Full Body','1','5 min','0'],
    ],
  };

  void _startTimer(int sec) {
    _timer?.cancel();
    setState(() { _timerActive = true; _timerSec = sec; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _timerSec--);
      if (_timerSec <= 0) { t.cancel(); setState(() => _timerActive = false); }
    });
  }

  Future<void> _saveSession() async {
    final split = _splits[_dayIndex];
    final exercises = _workouts[split] ?? [];
    final log = ActivityLog(
      id: const Uuid().v4(), type: 'gym',
      durationMin: exercises.length * 8.0, distanceKm: 0,
      caloriesBurned: _done.length * 45.0, loggedAt: DateTime.now(),
      notes: split);
    await ref.read(activityLogsProvider.notifier).addLog(log);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Workout saved — ${(_done.length * 45).toStringAsFixed(0)} kcal!'),
          backgroundColor: AppTheme.accent, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final split = _splits[_dayIndex];
    final exercises = _workouts[split] ?? [];
    final progress = exercises.isEmpty ? 0.0 : _done.length / exercises.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(backgroundColor: AppTheme.background, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('Gym Workout', style: TextStyle(color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700, fontSize: 20)),
        actions: [TextButton(onPressed: _saveSession,
          child: const Text('Save', style: TextStyle(color: AppTheme.accent,
              fontWeight: FontWeight.w700)))]),
      body: Stack(children: [
        Column(children: [
          // Day tabs
          SizedBox(height: 50,
            child: ListView.builder(scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: 7,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => setState(() { _dayIndex = i; _done.clear(); }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: _dayIndex == i ? AppTheme.accent : AppTheme.card,
                    borderRadius: BorderRadius.circular(20)),
                  child: Center(child: Text(_days[i], style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: _dayIndex == i ? Colors.white : AppTheme.textSecondary)))))),
          // Progress bar
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(split, style: const TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                Text('${_done.length}/${exercises.length}',
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700, color: AppTheme.accent)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: progress, minHeight: 6,
                  backgroundColor: AppTheme.card,
                  color: progress == 1.0 ? const Color(0xFF10B981) : AppTheme.accent)),
            ])),
          // Exercise list
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: exercises.length,
            itemBuilder: (_, i) {
              final ex = exercises[i];
              final key = '${_dayIndex}_$i';
              final done = _done.contains(key);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: done ? const Color(0xFF10B981).withOpacity(0.1) : AppTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: done
                      ? const Color(0xFF10B981).withOpacity(0.4)
                      : Colors.white.withOpacity(0.08))),
                child: Row(children: [
                  Text(ex[1], style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(ex[0], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: done ? const Color(0xFF10B981) : AppTheme.textPrimary,
                        decoration: done ? TextDecoration.lineThrough : null)),
                    Text('${ex[3]} sets × ${ex[4]}  •  ${ex[2]}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ])),
                  Row(children: [
                    GestureDetector(
                      onTap: () => _startTimer(int.tryParse(ex[5]) ?? 90),
                      child: Container(width: 32, height: 32,
                        decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.timer_rounded, color: Color(0xFF8B5CF6), size: 16))),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => done ? _done.remove(key) : _done.add(key)),
                      child: Container(width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: done ? const Color(0xFF10B981) : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                        child: Icon(done ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                            color: done ? Colors.white : AppTheme.textSecondary, size: 18))),
                  ]),
                ]));
            })),
        ]),
        if (_timerActive) _TimerOverlay(
          sec: _timerSec,
          onSkip: () { _timer?.cancel(); setState(() => _timerActive = false); }),
      ]),
    );
  }
}

class _TimerOverlay extends StatelessWidget {
  final int sec;
  final VoidCallback onSkip;
  const _TimerOverlay({required this.sec, required this.onSkip});
  @override
  Widget build(BuildContext context) {
    final color = sec <= 5 ? const Color(0xFFEF4444)
        : sec <= 15 ? const Color(0xFFF59E0B) : const Color(0xFF8B5CF6);
    return Positioned.fill(child: Container(
      color: Colors.black.withOpacity(0.85),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('REST TIME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
            color: Colors.white60, letterSpacing: 2)),
        const SizedBox(height: 24),
        Text('$sec', style: TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 24),
        TextButton(onPressed: onSkip,
          child: const Text('Skip', style: TextStyle(fontSize: 16, color: Colors.white54))),
      ])));
  }
}
