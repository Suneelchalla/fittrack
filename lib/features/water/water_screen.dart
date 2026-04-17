import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/water_log.dart';
import '../../providers/user_provider.dart';
import '../../providers/water_provider.dart';

class WaterScreen extends ConsumerStatefulWidget {
  const WaterScreen({super.key});
  @override
  ConsumerState<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends ConsumerState<WaterScreen> {
  Future<void> _add(double ml) async {
    final log = WaterLog(id: const Uuid().v4(), amountMl: ml, loggedAt: DateTime.now());
    await ref.read(waterLogsProvider.notifier).addLog(log);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('+${ml.toStringAsFixed(0)}ml added!'),
          backgroundColor: const Color(0xFF3B82F6), behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }

  void _showCustom() {
    double custom = 250;
    showDialog(context: context, builder: (_) => StatefulBuilder(
      builder: (ctx, setSt) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Custom Amount', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${custom.toStringAsFixed(0)} ml', style: const TextStyle(
              fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF3B82F6))),
          Slider(value: custom, min: 50, max: 1000, divisions: 19,
            activeColor: const Color(0xFF3B82F6), inactiveColor: AppTheme.card,
            onChanged: (v) => setSt(() => custom = v)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
          TextButton(onPressed: () { Navigator.pop(ctx); _add(custom); },
            child: const Text('Add', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w700))),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileNotifierProvider);
    final todayMl = ref.watch(todayWaterMlProvider);
    final logs = ref.watch(waterLogsProvider);
    final target = profile?.dailyWaterMl ?? 2800;
    final progress = (todayMl / target).clamp(0.0, 1.0);
    final now = DateTime.now();
    final todayLogs = logs.where((l) =>
        l.loggedAt.day == now.day && l.loggedAt.month == now.month).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(backgroundColor: AppTheme.background, elevation: 0,
        title: const Text('Water', style: TextStyle(color: AppTheme.textPrimary,
            fontWeight: FontWeight.w800, fontSize: 24))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(children: [
          // Ring
          SizedBox(height: 200, width: 200,
            child: CustomPaint(
              painter: _Ring(progress: progress),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('💧', style: TextStyle(fontSize: 32)),
                Text('${(todayMl / 1000).toStringAsFixed(1)}L',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary)),
                Text('of ${(target / 1000).toStringAsFixed(1)}L',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Text('${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                        color: Color(0xFF3B82F6))),
              ]),
            )),
          const SizedBox(height: 24),
          // Quick add buttons
          Row(children: [
            for (final ml in [150.0, 200.0, 250.0, 350.0])
              Expanded(child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _add(ml),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1))),
                    child: Column(children: [
                      Text('${ml.toStringAsFixed(0)}', style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const Text('ml', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                    ]),
                  ),
                ),
              )),
            GestureDetector(
              onTap: _showCustom,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3))),
                child: const Icon(Icons.add_rounded, color: Color(0xFF3B82F6), size: 22))),
          ]),
          const SizedBox(height: 24),
          // Today's log
          if (todayLogs.isNotEmpty) ...[
            const Align(alignment: Alignment.centerLeft,
              child: Text('TODAY\'S LOG', style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1.5))),
            const SizedBox(height: 12),
            ...todayLogs.take(8).map((l) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.07))),
              child: Row(children: [
                const Icon(Icons.water_drop_rounded, color: Color(0xFF3B82F6), size: 18),
                const SizedBox(width: 10),
                Text('${l.amountMl.toStringAsFixed(0)} ml',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const Spacer(),
                Text('${l.loggedAt.hour.toString().padLeft(2,'0')}:${l.loggedAt.minute.toString().padLeft(2,'0')}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ]),
            )),
          ],
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _Ring extends CustomPainter {
  final double progress;
  const _Ring({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 10;
    final p = Paint()..strokeWidth = 12..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    p.color = Colors.white12;
    canvas.drawCircle(c, r, p);
    p.color = const Color(0xFF3B82F6);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r),
        -math.pi / 2, 2 * math.pi * progress, false, p);
  }
  @override
  bool shouldRepaint(_Ring old) => old.progress != progress;
}
