import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/bmi_calculator.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _editMode = false;
  late TextEditingController _weightCtrl;
  late TextEditingController _heightCtrl;

  @override
  void initState() {
    super.initState();
    final p = ref.read(userProfileNotifierProvider);
    _weightCtrl = TextEditingController(text: p?.weight.toString() ?? '');
    _heightCtrl = TextEditingController(text: p?.height.toString() ?? '');
  }

  @override
  void dispose() { _weightCtrl.dispose(); _heightCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileNotifierProvider);
    if (profile == null) return const Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(child: Text('No profile found', style: TextStyle(color: AppTheme.textPrimary))));

    final weightKg = profile.useMetric ? profile.weight : profile.weight * 0.453592;
    final heightCm = profile.useMetric ? profile.height : profile.height * 30.48;
    final bmi = BmiCalculator.calculate(weightKg: weightKg, heightCm: heightCm);
    final bmiCat = BmiCalculator.category(bmi);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(backgroundColor: AppTheme.background, elevation: 0,
        title: const Text('Profile', style: TextStyle(color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700, fontSize: 22)),
        actions: [TextButton(
          onPressed: () async {
            if (_editMode) {
              final w = double.tryParse(_weightCtrl.text) ?? profile.weight;
              final h = double.tryParse(_heightCtrl.text) ?? profile.height;
              await ref.read(userProfileNotifierProvider.notifier).update(
                  profile.copyWith(weight: w, height: h));
            }
            setState(() => _editMode = !_editMode);
          },
          child: Text(_editMode ? 'Save' : 'Edit',
              style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700)),
        )]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.accent, AppTheme.accent.withOpacity(0.6)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              Container(width: 64, height: 64,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: Center(child: Text(
                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)))),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(profile.name, style: const TextStyle(fontSize: 22,
                    fontWeight: FontWeight.w800, color: Colors.white)),
                Text('Age ${profile.age}  •  ${profile.fitnessGoal.replaceAll('_', ' ')}',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
              ])),
            ])),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08))),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('BMI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary, letterSpacing: 1.4)),
                Text(bmi.toStringAsFixed(1), style: const TextStyle(fontSize: 32,
                    fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(bmiCat, style: const TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w700, color: Color(0xFF10B981)))),
              ])),
            ])),
          const SizedBox(height: 16),
          const Text('DAILY TARGETS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          _T(Icons.local_fire_department_rounded, const Color(0xFFEF4444),
              'Calorie Target', '${profile.dailyCalorieTarget.toStringAsFixed(0)} kcal'),
          _T(Icons.egg_alt_rounded, const Color(0xFF8B5CF6),
              'Protein Target', '${profile.dailyProteinG.toStringAsFixed(0)}g'),
          _T(Icons.water_drop_rounded, const Color(0xFF3B82F6),
              'Water Target', '${profile.dailyWaterMl.toStringAsFixed(0)} ml'),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
              backgroundColor: const Color(0xFF1C1C1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Reset App Data?', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
              content: const Text('This will delete all your data.', style: TextStyle(color: AppTheme.textSecondary)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
                TextButton(onPressed: () async {
                  await ref.read(userProfileNotifierProvider.notifier).reset();
                  if (mounted) Navigator.pop(context);
                }, child: const Text('Reset', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700))),
              ])),
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3))),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.restart_alt_rounded, color: Color(0xFFEF4444), size: 20),
                SizedBox(width: 8),
                Text('Reset App Data', style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
              ]))),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

class _T extends StatelessWidget {
  final IconData icon; final Color color; final String label, value;
  const _T(this.icon, this.color, this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07))),
    child: Row(children: [
      Container(width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 14),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14,
          fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
      Text(value, style: const TextStyle(fontSize: 14,
          fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
    ]));
}
