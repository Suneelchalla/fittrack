import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/bmi_calculator.dart';
import '../../data/models/user_profile.dart';
import '../../providers/user_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  String _name = '';
  String _gender = 'male';
  int _age = 25;
  double _weight = 70;
  double _height = 170;
  bool _useMetric = true;
  String _goal = 'general_fitness';
  String _activityLevel = 'moderate';
  final List<String> _activities = [];

  void _next() {
    if (_page < 3) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _page++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final weightKg = _useMetric ? _weight : _weight * 0.453592;
    final heightCm = _useMetric ? _height : _height * 30.48;
    final profile = UserProfile(
      name: _name.isEmpty ? 'Athlete' : _name,
      gender: _gender, age: _age,
      weight: _weight, height: _height,
      fitnessGoal: _goal, activityLevel: _activityLevel,
      useMetric: _useMetric,
      preferredActivities: _activities,
      dailyWaterMl: BmiCalculator.dailyWaterTarget(weightKg),
      dailyProteinG: BmiCalculator.dailyProteinTarget(weightKg, _goal),
      dailyCalorieTarget: BmiCalculator.tdee(
        weightKg: weightKg, heightCm: heightCm,
        age: _age, gender: _gender, activityLevel: _activityLevel),
    );
    await ref.read(userProfileNotifierProvider.notifier).save(profile);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: SafeArea(child: Column(children: [
      // Progress bar
      Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: List.generate(4, (i) => Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: i < 3 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: i <= _page ? AppTheme.accent : Colors.white12,
              borderRadius: BorderRadius.circular(2)),
          ),
        ))),
      ),
      Expanded(child: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [_page0(), _page1(), _page2(), _page3()],
      )),
      Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(width: double.infinity, height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0),
            onPressed: _next,
            child: Text(_page == 3 ? 'Get Started 🚀' : 'Continue',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          ))),
    ])),
  );

  Widget _page0() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('👋', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      const Text("Let's get started!", style: TextStyle(fontSize: 28,
          fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
      const SizedBox(height: 8),
      const Text('Tell us about yourself', style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
      const SizedBox(height: 32),
      const Text('YOUR NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary, letterSpacing: 1.4)),
      const SizedBox(height: 8),
      TextField(
        onChanged: (v) => _name = v,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Enter your name',
          hintStyle: const TextStyle(color: AppTheme.textSecondary),
          filled: true, fillColor: AppTheme.card,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
      const SizedBox(height: 24),
      const Text('GENDER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary, letterSpacing: 1.4)),
      const SizedBox(height: 8),
      Row(children: [
        for (final g in ['male', 'female'])
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _gender = g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: g == 'male' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _gender == g ? AppTheme.accent : AppTheme.card,
                borderRadius: BorderRadius.circular(14)),
              child: Text(g == 'male' ? '♂ Male' : '♀ Female',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: _gender == g ? Colors.white : AppTheme.textSecondary))),
          )),
      ]),
      const SizedBox(height: 24),
      const Text('AGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary, letterSpacing: 1.4)),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(icon: const Icon(Icons.remove, color: AppTheme.accent),
          onPressed: () => setState(() => _age = (_age - 1).clamp(10, 100))),
        Text('$_age', style: const TextStyle(fontSize: 36,
            fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
        IconButton(icon: const Icon(Icons.add, color: AppTheme.accent),
          onPressed: () => setState(() => _age = (_age + 1).clamp(10, 100))),
      ]),
    ]),
  );

  Widget _page1() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('📏', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      const Text('Body Stats', style: TextStyle(fontSize: 28,
          fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        const Text('Imperial', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        Switch(value: _useMetric, activeColor: AppTheme.accent,
            onChanged: (v) => setState(() => _useMetric = v)),
        const Text('Metric', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      ]),
      const SizedBox(height: 16),
      Text('WEIGHT (${_useMetric ? "kg" : "lb"})', style: const TextStyle(fontSize: 11,
          fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1.4)),
      Slider(value: _weight, min: _useMetric ? 30 : 66, max: _useMetric ? 200 : 440,
        activeColor: AppTheme.accent, inactiveColor: AppTheme.card,
        label: '${_weight.toStringAsFixed(0)} ${_useMetric ? "kg" : "lb"}',
        onChanged: (v) => setState(() => _weight = v)),
      Center(child: Text('${_weight.toStringAsFixed(0)} ${_useMetric ? "kg" : "lb"}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))),
      const SizedBox(height: 24),
      Text('HEIGHT (${_useMetric ? "cm" : "ft"})', style: const TextStyle(fontSize: 11,
          fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1.4)),
      Slider(value: _height, min: _useMetric ? 100 : 3 : max: _useMetric ? 220 : 8,
        activeColor: AppTheme.accent, inactiveColor: AppTheme.card,
        label: '${_height.toStringAsFixed(0)} ${_useMetric ? "cm" : "ft"}',
        onChanged: (v) => setState(() => _height = v)),
      Center(child: Text('${_height.toStringAsFixed(0)} ${_useMetric ? "cm" : "ft"}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary))),
    ]),
  );

  Widget _page2() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('🎯', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      const Text('Your Goal', style: TextStyle(fontSize: 28,
          fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
      const SizedBox(height: 24),
      for (final g in [
        ['fat_loss', '🔥', 'Fat Loss', 'Burn calories, lose weight'],
        ['muscle_gain', '💪', 'Muscle Gain', 'Build strength and mass'],
        ['general_fitness', '⚡', 'General Fitness', 'Stay healthy and active'],
      ])
        GestureDetector(
          onTap: () => setState(() => _goal = g[0]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _goal == g[0] ? AppTheme.accent.withOpacity(0.15) : AppTheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _goal == g[0] ? AppTheme.accent : Colors.white12)),
            child: Row(children: [
              Text(g[1], style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(g[2], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                    color: _goal == g[0] ? AppTheme.accent : AppTheme.textPrimary)),
                Text(g[3], style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ]),
            ]),
          )),
      const SizedBox(height: 16),
      const Text('ACTIVITY LEVEL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary, letterSpacing: 1.4)),
      const SizedBox(height: 8),
      for (final a in [
        ['sedentary', 'Sedentary', 'Desk job, little exercise'],
        ['light', 'Light', '1-3 days/week'],
        ['moderate', 'Moderate', '3-5 days/week'],
        ['active', 'Active', '6-7 days/week'],
        ['very_active', 'Very Active', 'Physical job + training'],
      ])
        GestureDetector(
          onTap: () => setState(() => _activityLevel = a[0]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _activityLevel == a[0] ? AppTheme.accent : AppTheme.card,
              borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(a[1], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: _activityLevel == a[0] ? Colors.white : AppTheme.textPrimary)),
              Text(a[2], style: TextStyle(fontSize: 11,
                  color: _activityLevel == a[0] ? Colors.white70 : AppTheme.textSecondary)),
            ])),
        ),
    ]),
  );

  Widget _page3() => SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('🏃', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      const Text('Pick Activities', style: TextStyle(fontSize: 28,
          fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
      const SizedBox(height: 8),
      const Text('Choose what you enjoy (select all that apply)',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
      const SizedBox(height: 24),
      for (final a in [
        ['run', '🏃', 'Running'],
        ['walk', '🚶', 'Walking'],
        ['cycle', '🚴', 'Cycling'],
        ['swim', '🏊', 'Swimming'],
        ['gym', '🏋️', 'Gym Workout'],
        ['home_exercise', '💪', 'Home Exercise'],
      ])
        GestureDetector(
          onTap: () => setState(() {
            if (_activities.contains(a[0])) _activities.remove(a[0]);
            else _activities.add(a[0]);
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _activities.contains(a[0]) ? AppTheme.accent.withOpacity(0.15) : AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _activities.contains(a[0]) ? AppTheme.accent : Colors.white12)),
            child: Row(children: [
              Text(a[1], style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Text(a[2], style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: _activities.contains(a[0]) ? AppTheme.accent : AppTheme.textPrimary)),
              const Spacer(),
              if (_activities.contains(a[0]))
                const Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 22),
            ])),
        ),
    ]),
  );
}
