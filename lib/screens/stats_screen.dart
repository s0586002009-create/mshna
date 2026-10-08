import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../widgets/dedication_banner.dart';

class StatsScreen extends StatefulWidget {
  final AppState state;
  const StatsScreen({super.key, required this.state});
  @override State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  StatsRange range = StatsRange.week;

  @override
  Widget build(BuildContext context) {
    final count = widget.state.countForRange(range);
    final average = widget.state.averageForRange(range);
    final weekdays = widget.state.weekdayCounts(range);
    final maxWeek = weekdays.fold<int>(0, (a, b) => a > b ? a : b);
    final seders = widget.state.sederProgress();
    const names = ['זרעים', 'מועד', 'נשים', 'נזיקין', 'קדשים', 'טהרות'];
    final maxSeder = seders.fold<int>(0, (a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('סטטיסטיקות')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(padding: const EdgeInsets.all(12), children: [
          DedicationBanner(text: widget.state.dedication),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<StatsRange>(
              segments: const [
                ButtonSegment(value: StatsRange.today, label: Text('היום')),
                ButtonSegment(value: StatsRange.week, label: Text('שבוע')),
                ButtonSegment(value: StatsRange.month, label: Text('חודש')),
                ButtonSegment(value: StatsRange.threeMonths, label: Text('3 חודשים')),
                ButtonSegment(value: StatsRange.year, label: Text('שנה')),
                ButtonSegment(value: StatsRange.all, label: Text('הכל')),
              ],
              selected: {range},
              onSelectionChanged: (s) => setState(() => range = s.first),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _metric('נלמדו', '${count}', Icons.menu_book),
            _metric('התקדמות', '${_percent()}%', Icons.pie_chart),
            _metric('רצף נוכחי', '${widget.state.streak()}', Icons.local_fire_department),
            _metric('שיא רצף', '${widget.state.bestStreak()}', Icons.emoji_events),
            _metric('ממוצע ליום', average.toStringAsFixed(1), Icons.speed),
          ]),
          const SizedBox(height: 12),
          _chart('פרקים לפי ימי השבוע', SizedBox(height: 260, child: BarChart(
            BarChartData(
              maxY: (maxWeek + 2).toDouble(),
              barGroups: [for (var i = 0; i < 7; i++) BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: weekdays[i].toDouble(), width: 20)
              ])],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                  getTitlesWidget: (v, m) => Text(const ['א','ב','ג','ד','ה','ו','ש'][v.toInt().clamp(0,6)]))),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ))),
          _chart('התקדמות לפי סדר', SizedBox(height: 260, child: BarChart(
            BarChartData(
              maxY: (maxSeder + 2).toDouble(),
              barGroups: [for (var i = 0; i < 6; i++) BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: seders[i].toDouble(), width: 24, color: const [
                  Colors.green, Colors.blue, Colors.purple, Colors.orange, Colors.red, Colors.teal
                ][i])
              ])],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                  getTitlesWidget: (v, m) => Text(names[v.toInt().clamp(0,5)]))),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ))),
        ]),
      ),
    );
  }

  Widget _metric(String title, String value, IconData icon) => SizedBox(
    width: 150, child: Card(child: Padding(padding: const EdgeInsets.all(12),
      child: Column(children: [Icon(icon), const SizedBox(height: 5), Text(title),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]))));

  Widget _chart(String title, Widget child) => Card(child: Padding(
    padding: const EdgeInsets.all(12),
    child: Column(children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8), child])));

  int _percent() => widget.state.totalSelected == 0
      ? 0 : (widget.state.completedCount * 100 / widget.state.totalSelected).round();
}
