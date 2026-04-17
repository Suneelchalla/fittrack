import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  static const _activities = [
    _Activity('Run', '🏃', 'Outdoor & treadmill', Color(0xFFEF4444), '/activities/run'),
    _Activity('Walk', '🚶', 'Casual & power walk', Color(0xFF10B981), '/activities/walk'),
    _Activity('Cycle', '🚴', 'Road & indoor bike', Color(0xFF0EA5E9), '/activities/cycle'),
    _Activity('Swim', '🏊', 'Pool & open water', Color(0xFF06B6D4), '/activities/swim'),
    _Activity('Home Exercise', '💪', 'No equipment needed', Color(0xFF8B5CF6), '/activities/home-exercise'),
    _Activity('Gym Workout', '🏋️', 'Weights & machines', Color(0xFFF59E0B), '/activities/gym'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      backgroundColor: AppTheme.background, elevation: 0,
      title: const Text('Activities', style: TextStyle(
          color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 24)),
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.count(
        crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14,
        childAspectRatio: 1.05,
        children: _activities.map((a) => GestureDetector(
          onTap: () => context.push(a.route),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [a.color, a.color.withOpacity(0.7)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(a.emoji, style: const TextStyle(fontSize: 36)),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.name, style: const TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w800, color: Colors.white)),
                Text(a.subtitle, style: TextStyle(fontSize: 11,
                    color: Colors.white.withOpacity(0.8))),
              ]),
            ]),
          ),
        )).toList(),
      ),
    ),
  );
}

class _Activity {
  final String name, emoji, subtitle, route;
  final Color color;
  const _Activity(this.name, this.emoji, this.subtitle, this.color, this.route);
}
