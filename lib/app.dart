import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/activities/activities_screen.dart';
import 'features/activities/walk_screen.dart';
import 'features/activities/run_screen.dart';
import 'features/activities/cycle_screen.dart';
import 'features/activities/swim_screen.dart';
import 'features/activities/home_exercise_screen.dart';
import 'features/activities/gym_workout_screen.dart';
import 'features/water/water_screen.dart';
import 'features/diet/diet_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/progress/progress_screen.dart';
import 'providers/user_provider.dart';

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final profile = container.read(userProfileNotifierProvider);
    final onboarded = profile != null;
    if (!onboarded && state.matchedLocation != '/onboarding') return '/onboarding';
    if (onboarded && state.matchedLocation == '/onboarding') return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/activities',
          builder: (_, __) => const ActivitiesScreen(),
          routes: [
            GoRoute(path: 'walk', builder: (_, __) => const WalkScreen()),
            GoRoute(path: 'run', builder: (_, __) => const RunScreen()),
            GoRoute(path: 'cycle', builder: (_, __) => const CycleScreen()),
            GoRoute(path: 'swim', builder: (_, __) => const SwimScreen()),
            GoRoute(path: 'home-exercise', builder: (_, __) => const HomeExerciseScreen()),
            GoRoute(path: 'gym', builder: (_, __) => const GymWorkoutScreen()),
          ],
        ),
        GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen()),
        GoRoute(path: '/water', builder: (_, __) => const WaterScreen()),
        GoRoute(path: '/diet', builder: (_, __) => const DietScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),
  ],
);

class FitTrackApp extends ConsumerWidget {
  const FitTrackApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'FitTrack',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home', path: '/'),
    _NavItem(icon: Icons.fitness_center_rounded, label: 'Activities', path: '/activities'),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Progress', path: '/progress'),
    _NavItem(icon: Icons.water_drop_rounded, label: 'Water', path: '/water'),
    _NavItem(icon: Icons.restaurant_rounded, label: 'Diet', path: '/diet'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile', path: '/profile'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: widget.child,
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: _items.asMap().entries.map((e) {
              final active = _index == e.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _index = e.key);
                    context.go(e.value.path);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: Colors.transparent,
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: active ? AppTheme.accent.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(e.value.icon,
                            color: active ? AppTheme.accent : AppTheme.textSecondary,
                            size: 22),
                      ),
                      const SizedBox(height: 2),
                      Text(e.value.label, style: TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w600,
                          color: active ? AppTheme.accent : AppTheme.textSecondary)),
                    ]),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    ),
  );
}

class _NavItem {
  final IconData icon;
  final String label, path;
  const _NavItem({required this.icon, required this.label, required this.path});
}
