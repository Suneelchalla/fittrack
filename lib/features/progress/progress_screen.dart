import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/activity_log.dart';
import '../../providers/activity_provider.dart';
import '../../providers/water_provider.dart';
import '../../providers/diet_provider.dart';
import '../../providers/user_provider.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});
  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _metric = 'calories';
  String _filter = 'all';

  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(
      backgroundColor: AppTheme.background, elevation: 0,
      title: const Text('Progress', style: TextStyle(color: AppTheme.textPrimary,
          fontWeight: FontWeight.w800, fontSize: 24)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 40,
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12)),
          child: TabBar(
            controller: _tab,
            indicator: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(10)),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            dividerColor: Colors.transparent,
            tabs: const [Tab(text: 'Today'), Tab(text: 'Weekly'), Tab(text: 'History')])))),
    body: TabBarView(controller: _tab, children: [
      _TodayTab(),
      _WeeklyTab(metric: _metric, onMetric: (m) => setState(() => _metric = m)),
      _HistoryTab(filter: _filter, onFilter: (f) => setState(() => _filter = f)),
    ]),
  );
}

class _TodayTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileNotifierProvider);
    final burned = ref.watch(todayCaloriesProvider);
    final water = ref.watch(todayWaterMlProvider);
    final protein = ref.watch(todayProteinProvider);
    final foodKcal = ref.watch(todayCaloriesFromFoodProvider);
    final logs = ref.watch(activityLogsProvider);
    final now = DateTime.now();
    final todayLogs = logs.where((l) => l.loggedAt.day == now.day &&
        l.loggedAt.month == now.month && l.loggedAt.year == now.year).toList();
    final waterT = profile?.dailyWaterMl ?? 2800;
    final proteinT = profile?.dailyProteinG ?? 144;
    final kcalT = profile?.dailyCalorieTarget ?? 2000;
    final net = foodKcal - burned;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20,16,20,24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Net cal card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: net > kcalT
                  ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                  : [const Color(0xFF10B981), const Color(0xFF059669)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('NET CALORIES', style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1.4)),
            const SizedBox(height: 8),
            Text('${net.toStringAsFixed(0)} kcal', style: const TextStyle(
                fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
            Text(net > kcalT
                ? '${(net - kcalT).toStringAsFixed(0)} kcal over target'
                : '${(kcalT - net).toStringAsFixed(0)} kcal remaining',
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
            const SizedBox(height: 14),
            Row(children: [
              _Pill('🍽️', 'Eaten', '${foodKcal.toStringAsFixed(0)}'),
              const SizedBox(width: 8),
              _Pill('🔥', 'Burned', '${burned.toStringAsFixed(0)}'),
              const SizedBox(width: 8),
              _Pill('🎯', 'Target', '${kcalT.toStringAsFixed(0)}'),
            ]),
          ])),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _Ring('Water', water, waterT, 'ml', const Color(0xFF3B82F6), Icons.water_drop_rounded)),
          const SizedBox(width: 12),
          Expanded(child: _Ring('Protein', protein, proteinT, 'g', const Color(0xFF8B5CF6), Icons.egg_alt_rounded)),
          const SizedBox(width: 12),
          Expanded(child: _Ring('Burned', burned, kcalT * 0.4, 'kcal', const Color(0xFFEF4444), Icons.local_fire_department_rounded)),
        ]),
        const SizedBox(height: 20),
        if (todayLogs.isNotEmpty) ...[
          const Text('TODAY\'S ACTIVITIES', style: TextStyle(fontSize: 11,
              fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          ...todayLogs.map((l) => _LogRow(log: l)),
        ] else Container(
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
          child: const Column(children: [
            Text('😴', style: TextStyle(fontSize: 40)),
            SizedBox(height: 12),
            Text('No activities today', style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            Text('Head to Activities tab', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ])),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  final String e, l, v;
  const _Pill(this.e, this.l, this.v);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Text(e, style: const TextStyle(fontSize: 14)),
      Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
      Text(l, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.7))),
    ])));
}

class _Ring extends StatelessWidget {
  final String label, unit;
  final double current, target;
  final Color color;
  final IconData icon;
  const _Ring(this.label, this.current, this.target, this.unit, this.color, this.icon);
  @override
  Widget build(BuildContext context) {
    final p = (current / target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Column(children: [
        SizedBox(width: 64, height: 64,
          child: CustomPaint(painter: _Arc(p, color), child: Center(child: Icon(icon, color: color, size: 18)))),
        const SizedBox(height: 8),
        Text(current >= 1000 ? '${(current/1000).toStringAsFixed(1)}k' : current.toStringAsFixed(0),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        Text(unit, style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        Text('${(p*100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
      ]));
  }
}

class _Arc extends CustomPainter {
  final double p; final Color c;
  const _Arc(this.p, this.c);
  @override
  void paint(Canvas canvas, Size size) {
    final ct = Offset(size.width/2, size.height/2);
    final r = size.width/2 - 5;
    final paint = Paint()..strokeWidth = 5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    paint.color = Colors.white12;
    canvas.drawCircle(ct, r, paint);
    paint.color = c;
    canvas.drawArc(Rect.fromCircle(center: ct, radius: r), -math.pi/2, 2*math.pi*p, false, paint);
  }
  @override bool shouldRepaint(_Arc o) => o.p != p;
}

class _LogRow extends StatelessWidget {
  final ActivityLog log;
  const _LogRow({required this.log});
  static const _colors = {'run':Color(0xFFEF4444),'walk':Color(0xFF10B981),
    'cycle':Color(0xFF0EA5E9),'swim':Color(0xFF06B6D4),'gym':Color(0xFFF59E0B),'home_exercise':Color(0xFF8B5CF6)};
  static const _emojis = {'run':'🏃','walk':'🚶','cycle':'🚴','swim':'🏊','gym':'🏋️','home_exercise':'💪'};
  @override
  Widget build(BuildContext context) {
    final color = _colors[log.type] ?? AppTheme.accent;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.07))),
      child: Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(_emojis[log.type] ?? '⚡', style: const TextStyle(fontSize: 20)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(log.type[0].toUpperCase() + log.type.substring(1),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          Text('${log.durationMin.toStringAsFixed(0)} min',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${log.caloriesBurned.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          const Text('kcal', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
        ]),
      ]));
  }
}

class _WeeklyTab extends ConsumerWidget {
  final String metric;
  final void Function(String) onMetric;
  const _WeeklyTab({required this.metric, required this.onMetric});

  static const _labels = {'calories':'Cal Burned','water':'Water','protein':'Protein','distance':'Distance'};
  static const _colors = {'calories':Color(0xFFEF4444),'water':Color(0xFF3B82F6),
    'protein':Color(0xFF8B5CF6),'distance':Color(0xFF10B981)};
  static const _icons = {'calories':'🔥','water':'💧','protein':'🥚','distance':'📍'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(activityLogsProvider);
    final water = ref.watch(waterLogsProvider);
    final meals = ref.watch(mealEntriesProvider);
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6-i)));

    List<double> getData(String m) => days.map((d) {
      if (m == 'calories') return logs.where((l) => _same(l.loggedAt, d)).fold(0.0, (s,l) => s+l.caloriesBurned);
      if (m == 'water') return water.where((w) => _same(w.loggedAt, d)).fold(0.0, (s,w) => s+w.amountMl);
      if (m == 'protein') return meals.where((ml) => _same(ml.loggedAt, d)).fold(0.0, (s,ml) => s+ml.proteinG);
      return logs.where((l) => _same(l.loggedAt, d)).fold(0.0, (s,l) => s+l.distanceKm);
    }).toList();

    bool _same(DateTime a, DateTime b) => a.day==b.day && a.month==b.month && a.year==b.year;

    final data = getData(metric);
    final color = _colors[metric]!;
    final maxV = data.reduce(math.max);
    final total = data.fold(0.0, (s,v) => s+v);
    final avg = total / 7;
    final active = data.where((v) => v > 0).length;

    int streak = 0;
    final calData = getData('calories');
    for (int i = calData.length-1; i >= 0; i--) {
      if (calData[i] > 0) streak++; else if (i < calData.length-1) break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20,16,20,24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SingleChildScrollView(scrollDirection: Axis.horizontal,
          child: Row(children: ['calories','water','protein','distance'].map((m) {
            final active2 = metric == m;
            final mc = _colors[m]!;
            return GestureDetector(
              onTap: () => onMetric(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: active2 ? mc : AppTheme.card, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: active2 ? Colors.transparent : Colors.white.withOpacity(0.1))),
                child: Row(children: [
                  Text(_icons[m]!, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(_labels[m]!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: active2 ? Colors.white : AppTheme.textSecondary)),
                ])));
          }).toList())),
        const SizedBox(height: 16),
        Row(children: [
          _WBox('Week Total', _fmt(total, metric), color),
          const SizedBox(width: 10),
          _WBox('Daily Avg', _fmt(avg, metric), color),
          const SizedBox(width: 10),
          _WBox('Active Days', '$active / 7', color),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_labels[metric]!, style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const Text('Last 7 days', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ]),
            const SizedBox(height: 20),
            SizedBox(height: 160, child: _Bars(data: data, days: days, color: color, maxV: maxV > 0 ? maxV : 1)),
          ])),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: streak > 0
                ? const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight)
                : null,
            color: streak == 0 ? AppTheme.card : null,
            borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Text(streak > 0 ? '🔥' : '💤', style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(streak > 0 ? '$streak Day Streak' : 'No Streak Yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                      color: streak > 0 ? Colors.white : AppTheme.textPrimary)),
              Text(streak > 0 ? 'Keep it up! 💪' : 'Start today!',
                  style: TextStyle(fontSize: 12,
                      color: streak > 0 ? Colors.white.withOpacity(0.85) : AppTheme.textSecondary)),
            ]),
          ])),
      ]),
    );
  }

  String _fmt(double v, String m) {
    if (m == 'water') return '${(v/1000).toStringAsFixed(1)}L';
    if (m == 'distance') return '${v.toStringAsFixed(1)} km';
    if (m == 'protein') return '${v.toStringAsFixed(0)}g';
    return '${v.toStringAsFixed(0)} kcal';
  }
}

class _WBox extends StatelessWidget {
  final String label, value; final Color color;
  const _WBox(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
    ])));
}

class _Bars extends StatelessWidget {
  final List<double> data; final List<DateTime> days; final Color color; final double maxV;
  const _Bars({required this.data, required this.days, required this.color, required this.maxV});
  @override
  Widget build(BuildContext context) {
    const dl = ['M','T','W','T','F','S','S'];
    final now = DateTime.now();
    return Row(crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.length, (i) {
        final v = data[i];
        final h = v > 0 ? (v/maxV)*120 : 4.0;
        final isToday = days[i].day == now.day && days[i].month == now.month;
        final idx = (days[i].weekday - 1) % 7;
        return Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          if (v > 0) Text(v >= 1000 ? '${(v/1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0),
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700,
                  color: isToday ? color : AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 400 + i*60), curve: Curves.easeOutCubic,
              height: h,
              decoration: BoxDecoration(
                color: isToday ? color : (v > 0 ? color.withOpacity(0.45) : Colors.white12),
                borderRadius: BorderRadius.circular(6)))),
          const SizedBox(height: 8),
          Text(dl[idx], style: TextStyle(fontSize: 11,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
              color: isToday ? color : AppTheme.textSecondary)),
        ]));
      }));
  }
}

class _HistoryTab extends ConsumerWidget {
  final String filter;
  final void Function(String) onFilter;
  const _HistoryTab({required this.filter, required this.onFilter});

  static const _fl = {'all':'All','run':'🏃 Run','walk':'🚶 Walk',
    'cycle':'🚴 Cycle','swim':'🏊 Swim','gym':'🏋️ Gym','home_exercise':'💪 Home'};
  static const _colors = {'run':Color(0xFFEF4444),'walk':Color(0xFF10B981),
    'cycle':Color(0xFF0EA5E9),'swim':Color(0xFF06B6D4),'gym':Color(0xFFF59E0B),'home_exercise':Color(0xFF8B5CF6)};
  static const _emojis = {'run':'🏃','walk':'🚶','cycle':'🚴','swim':'🏊','gym':'🏋️','home_exercise':'💪'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(activityLogsProvider);
    final filtered = (filter == 'all' ? all : all.where((l) => l.type == filter).toList())
      ..sort((a,b) => b.loggedAt.compareTo(a.loggedAt));

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: Column(children: [
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal,
            child: Row(children: _fl.keys.map((f) => GestureDetector(
              onTap: () => onFilter(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: filter == f ? AppTheme.accent : AppTheme.card,
                  borderRadius: BorderRadius.circular(20)),
                child: Text(_fl[f]!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: filter == f ? Colors.white : AppTheme.textSecondary))))).toList()))),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(alignment: Alignment.centerLeft,
            child: Text('${filtered.length} sessions', style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary, letterSpacing: 1.4)))),
        const SizedBox(height: 12),
      ])),
      if (filtered.isEmpty)
        SliverToBoxAdapter(child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
          child: const Column(children: [
            Text('🔍', style: TextStyle(fontSize: 40)),
            SizedBox(height: 12),
            Text('No activities found', style: TextStyle(fontSize: 14,
                color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          ])))
      else SliverList(delegate: SliverChildBuilderDelegate((ctx, i) {
        final log = filtered[i];
        final showDate = i == 0 || !_sd(filtered[i-1].loggedAt, log.loggedAt);
        final color = _colors[log.type] ?? AppTheme.accent;
        return Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (showDate) Padding(padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(_dh(log.loggedAt), style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary))),
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.07))),
              child: Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(_emojis[log.type] ?? '⚡',
                      style: const TextStyle(fontSize: 20)))),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(log.type[0].toUpperCase() + log.type.substring(1).replaceAll('_', ' '),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  Text('${log.durationMin.toStringAsFixed(0)} min'
                      '${log.distanceKm > 0 ? " • ${log.distanceKm.toStringAsFixed(1)} km" : ""}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${log.caloriesBurned.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
                  const Text('kcal', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                ]),
              ])),
          ]));
      }, childCount: filtered.length)),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ]);
  }

  bool _sd(DateTime a, DateTime b) => a.day==b.day && a.month==b.month && a.year==b.year;
  String _dh(DateTime d) {
    final now = DateTime.now();
    if (_sd(d, now)) return 'Today';
    if (_sd(d, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }
}
