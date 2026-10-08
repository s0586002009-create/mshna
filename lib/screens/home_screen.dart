import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../services/calculations.dart';
import '../widgets/dedication_banner.dart';
import '../widgets/progress_card.dart';
import '../widgets/chapter_tile.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'badges_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppState state;
  const HomeScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final data = state.data!;
    final pace = state.pace();
    final start = DateTime.tryParse(state.settings['start_date'] ?? '') ?? DateTime.now();
    final expected = expectedByToday(total: state.totalSelected, start: start, today: DateTime.now(), target: state.target);
    final gap = expected - state.completedCount;
    return Scaffold(
      appBar: AppBar(
        title: const Text('משניות'),
        actions: [
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(state: state))),
            icon: const Icon(Icons.settings_outlined)),
          PopupMenuButton<String>(
            onSelected: (v) => Navigator.push(context, MaterialPageRoute(
              builder: (_) => v == 'stats' ? StatsScreen(state: state) : BadgesScreen(state: state))),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'stats', child: Text('סטטיסטיקות')),
              PopupMenuItem(value: 'badges', child: Text('תגים')),
            ],
          ),
        ],
      ),
      body: Directionality(textDirection: TextDirection.rtl, child: ListView(children: [
        DedicationBanner(text: state.dedication),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pace.remaining == 0 ? 'סיימת את כל הלימוד!'
              : gap <= 0 ? 'אתה בקצב מצוין! נותרו ${maxInt(0, pace.requiredPerDay)} פרקים להיום'
              : 'פיגור של ${gap} פרקים מהיעד'),
            const SizedBox(height: 8),
            Text('רצף נוכחי: ${state.streak()} ימים'),
            Text('קצב נדרש: ${pace.requiredPerDay} פרקים ביום'),
          ],
        ))),
        ProgressCard(completed: state.completedCount, total: state.totalSelected),
        for (final seder in data.sedarim) _seder(context, seder),
      ])),
    );
  }

  Widget _seder(BuildContext context, dynamic seder) {
    final tracts = seder.tractates.where((t) => state.selected.contains(t.id)).toList();
    if (tracts.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(title: Text(seder.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [for (final t in tracts) ExpansionTile(
        title: Text(t.name),
        subtitle: LinearProgressIndicator(value: state.completed.where((k) => k.startsWith('${t.id}:')).length / t.chapters),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            final mark = v == 'all';
            for (var chapter = 1; chapter <= t.chapters; chapter++) {
              final done = state.completed.contains('${t.id}:${chapter}');
              if (done != mark) await state.toggle(t.id, chapter, mark);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'all', child: Text('סמן הכל')),
            PopupMenuItem(value: 'none', child: Text('בטל הכל')),
          ],
        ),
        children: [for (var chapter = 1; chapter <= t.chapters; chapter++) ChapterTile(
          tractateId: t.id, chapter: chapter, done: state.completed.contains('${t.id}:${chapter}'),
          onChanged: (v) async {
            final unlocked = await state.toggle(t.id, chapter, v);
            if (unlocked.isNotEmpty && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🎉 תג נפתח: ${unlocked.map(_badgeName).join(', ')}')));
            }
          },
        )],
      )]);
  }

  String _badgeName(String id) {
    if (id == 'streak7') return '7 ימי רצף';
    if (id == 'weekly_goal') return 'יעד שבועי';
    if (id.startsWith('tractate_')) return state.data!.tractate(id.substring(10)).name;
    return id;
  }

  int maxInt(int a, int b) => a > b ? a : b;
}
