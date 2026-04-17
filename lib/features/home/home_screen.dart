import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/water_provider.dart';
import '../../providers/diet_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileNotifierProvider);
    final todayCal = ref.watch(todayCaloriesProvider);
    final todayWater = ref.watch(todayWaterMlProvider);
    final todayProtein = ref.watch(todayProteinProvider);
    final allLogs = ref.watch(activityLogsProvider);

    final now = DateTime.now();
    final todayLogs = allLogs.where((l) =>
        l.loggedAt.day == now.day &&
        l.loggedAt.month == now.month &&
        l.loggedAt.year == now.year).toList();

    // Calculate streak
    int streak = 0;
    for (int i = 0; i < 30; i++) {
      final day = now.subtract(Duration(days: i));
      final hasLog = allLogs.any((l) =>
          l.loggedAt.day == day.day &&
          l.loggedAt.month == day.month &&
          l.loggedAt.year == day.year);
      if (hasLog) streak++;
      else if (i > 0) break;
    }

    final hour = now.hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final name = profile?.name ?? 'Athlete';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$greeting,', style: const TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary)),
                Text(name, style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                ),
                child: Row(children: [
                  const Text('🔥', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text('$streak day streak',
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w700, color: Color(0xFFF59E0B))),
                ]),
              ),
            ]),
            const SizedBox(height: 24),

            // Calories burned hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('CALORIES BURNED TODAY',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: Colors.white70, letterSpacing: 1.4)),
                const SizedBox(height: 8),
                Text('${todayCal.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 52,
                        fontWeight: FontWeight.w900, color: Colors.white)),
                Text('kcal from ${todayLogs.length} session${todayLogs.length == 1 ? "" : "s"}',
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
              ]),
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(children: [
              Expanded(child: _StatCard(
                icon: '💧', label: 'Water',
                value: '${(todayWater / 1000).toStringAsFixed(1)}L',
                color: AppTheme.blue,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: '🥚', label: 'Protein',
                value: '${todayProtein.toStringAsFixed(0)}g',
                color: AppTheme.purple,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: '⚡', label: 'Sessions',
                value: '${todayLogs.length}',
                color: AppTheme.orange,
              )),
            ]),
            const SizedBox(height: 24),

            // Quick start
            const Text('QUICK START', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10, mainAxisSpacing: 10,
              childAspectRatio: 1.1,
              children: [
                _QuickBtn(emoji: '🏃', label: 'Run', color: const Color(0xFFEF4444),
                    onTap: () => context.push('/activities/run')),
                _QuickBtn(emoji: '🚴', label: 'Cycle', color: const Color(0xFF0EA5E9),
                    onTap: () => context.push('/activities/cycle')),
                _QuickBtn(emoji: '🏋️', label: 'Gym', color: const Color(0xFFF59E0B),
                    onTap: () => context.push('/activities/gym')),
                _QuickBtn(emoji: '🚶', label: 'Walk', color: const Color(0xFF10B981),
                    onTap: () => context.push('/activities/walk')),
                _QuickBtn(emoji: '🏊', label: 'Swim', color: const Color(0xFF06B6D4),
                    onTap: () => context.push('/activities/swim')),
                _QuickBtn(emoji: '💪', label: 'Home', color: const Color(0xFF8B5CF6),
                    onTap: () => context.push('/activities/home-exercise')),
              ],
            ),
            const SizedBox(height: 24),

            // Recent activity
            if (todayLogs.isNotEmpty) ...[
              const Text('TODAY\'S ACTIVITY', style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              ...todayLogs.take(3).map((log) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.07)),
                ),
                child: Row(children: [
                  Text(_emoji(log.type), style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(log.type[0].toUpperCase() + log.type.substring(1),
                        style: const TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    Text('${log.durationMin.toStringAsFixed(0)} min',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ])),
                  Text('${log.caloriesBurned.toStringAsFixed(0)} kcal',
                      style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w700, color: AppTheme.accent)),
                ]),
              )),
            ],
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  String _emoji(String type) {
    const map = {'run': '🏃', 'walk': '🚶', 'cycle': '🚴',
        'swim': '🏊', 'gym': '🏋️', 'home_exercise': '💪'};
    return map[type] ?? '⚡';
  }
}

class _StatCard extends StatelessWidget {
  final String icon, label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label,
      required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withOpacity(0.08)),
    ),
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontSize: 16,
          fontWeight: FontWeight.w800, color: color)),
      Text(label, style: const TextStyle(fontSize: 10,
          color: AppTheme.textSecondary)),
    ]),
  );
}

class _QuickBtn extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;
  const _QuickBtn({required this.emoji, required this.label,
      required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11,
            fontWeight: FontWeight.w700, color: color)),
      ]),
    ),
  );
}
