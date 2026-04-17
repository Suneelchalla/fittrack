import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HomeExerciseScreen extends StatefulWidget {
  const HomeExerciseScreen({super.key});
  @override
  State<HomeExerciseScreen> createState() => _HomeExerciseScreenState();
}

class _HomeExerciseScreenState extends State<HomeExerciseScreen> {
  int? _selected;

  static const _routines = [
    ['Full Body Blast','💥','Beginner','25 min',
      ['Jumping Jacks|⭐|Full Body|3|30 sec|30','Push-Ups|💪|Chest|3|12|60','Squats|🦵|Legs|3|15|60','Plank|🧱|Core|3|45s|45']],
    ['Abs Shredder','🔥','Intermediate','20 min',
      ['Crunches|🤸|Abs|3|20|45','Leg Raises|🦵|Lower Abs|3|15|60','Russian Twists|🔄|Obliques|3|20|45','Mountain Climbers|⛰️|Core|3|30s|30']],
    ['Chest at Home','💪','Intermediate','30 min',
      ['Wide Push-Ups|↔️|Outer Chest|4|12|60','Diamond Push-Ups|💎|Inner Chest|3|10|60','Decline Push-Ups|📐|Upper Chest|3|10|75']],
    ['Mobility Flow','🧘','All Levels','20 min',
      ['Hip Circles|🔵|Hips|2|10 each|20','Cat-Cow|🐱|Spine|2|10|15','World Greatest Stretch|🌍|Full Body|2|5 each|20']],
    ['Fat Loss HIIT','⚡','Beginner','30 min',
      ['High Knees|🏃|Cardio|3|30s|30','Burpees|💥|Full Body|3|8|60','Reverse Lunges|🦵|Legs|3|12 each|45']],
    ['Upper Body','🏋️','Intermediate','25 min',
      ['Pike Push-Ups|🔺|Shoulders|3|10|60','Tricep Dips|💺|Triceps|3|12|60','Superman Hold|🦸|Back|3|12|45']],
  ];

  static const _colors = [
    Color(0xFF8B5CF6),Color(0xFF06B6D4),Color(0xFFF59E0B),
    Color(0xFFEF4444),Color(0xFF10B981),Color(0xFFEC4899)];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(backgroundColor: AppTheme.background, elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded,
          color: AppTheme.textPrimary),
        onPressed: () => _selected != null
            ? setState(() => _selected = null)
            : Navigator.pop(context)),
      title: Text(_selected != null ? _routines[_selected!][0] as String : 'Home Exercise',
          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 20))),
    body: _selected == null ? _list() : _detail(_selected!),
  );

  Widget _list() => GridView.builder(
    padding: const EdgeInsets.all(20),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 0.9),
    itemCount: _routines.length,
    itemBuilder: (_, i) {
      final r = _routines[i];
      final color = _colors[i];
      return GestureDetector(
        onTap: () => setState(() => _selected = i),
        child: Container(
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(0.6)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
              child: Center(child: Text(r[1] as String, style: const TextStyle(fontSize: 40)))),
            Padding(padding: const EdgeInsets.all(12), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r[0] as String, style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              Text(r[3] as String, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              const SizedBox(height: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(r[2] as String, style: TextStyle(fontSize: 10,
                    fontWeight: FontWeight.w600, color: color))),
            ])),
          ]));
    });

  Widget _detail(int idx) {
    final exercises = (_routines[idx][4] as List).cast<String>();
    return _ExerciseList(exercises: exercises);
  }
}

class _ExerciseList extends StatefulWidget {
  final List<String> exercises;
  const _ExerciseList({required this.exercises});
  @override
  State<_ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<_ExerciseList> {
  final Set<int> _done = {};
  bool _timerOn = false;
  int _sec = 60;
  Timer? _timer;

  void _start(int s) {
    _timer?.cancel();
    setState(() { _timerOn = true; _sec = s; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _sec--);
      if (_sec <= 0) { t.cancel(); setState(() => _timerOn = false); }
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = _done.length / widget.exercises.length;
    return Stack(children: [
      SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${_done.length}/${widget.exercises.length} Done',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                Text('${(p*100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.accent)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: p, minHeight: 6,
                  backgroundColor: AppTheme.background,
                  color: p == 1.0 ? const Color(0xFF10B981) : AppTheme.accent)),
            ])),
          const SizedBox(height: 14),
          ...widget.exercises.asMap().entries.map((e) {
            final parts = e.value.split('|');
            final done = _done.contains(e.key);
            final rest = int.tryParse(parts[5]) ?? 60;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: done ? const Color(0xFF10B981).withOpacity(0.1) : AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: done
                    ? const Color(0xFF10B981).withOpacity(0.4) : Colors.white.withOpacity(0.08))),
              child: Row(children: [
                Text(parts[1], style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(parts[0], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: done ? const Color(0xFF10B981) : AppTheme.textPrimary,
                      decoration: done ? TextDecoration.lineThrough : null)),
                  Text('${parts[3]} sets × ${parts[4]}  •  ${parts[2]}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ])),
                Row(children: [
                  GestureDetector(onTap: () => _start(rest),
                    child: Container(width: 32, height: 32,
                      decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.timer_rounded, color: Color(0xFF8B5CF6), size: 16))),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => done ? _done.remove(e.key) : _done.add(e.key)),
                    child: Container(width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: done ? const Color(0xFF10B981) : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                      child: Icon(done ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                          color: done ? Colors.white : AppTheme.textSecondary, size: 18))),
                ]),
              ]));
          }),
          const SizedBox(height: 80),
        ])),
      if (_timerOn) Positioned.fill(child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('REST', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
              color: Colors.white60, letterSpacing: 2)),
          const SizedBox(height: 16),
          Text('$_sec', style: TextStyle(fontSize: 80, fontWeight: FontWeight.w900,
              color: _sec <= 5 ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6))),
          const SizedBox(height: 24),
          TextButton(onPressed: () { _timer?.cancel(); setState(() => _timerOn = false); },
            child: const Text('Skip', style: TextStyle(fontSize: 16, color: Colors.white54))),
        ]))),
    ]);
  }
}
