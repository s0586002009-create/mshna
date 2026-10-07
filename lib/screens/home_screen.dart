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
        title: const Text('מעקב משנה'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen(state: state))),
            icon: const Icon(Icons.settings),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              final screen = value == 'stats' ? StatsScreen(state: state) : BadgesScreen(state: state);
              Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'stats', child: Text('סטטיסטיקות')),
              PopupMenuItem(value: 'badges', child: Text('תגים')),
            ],
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          children: [
            DedicationBanner(text: state.dedication),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pace.remaining == 0
                            ? 'סיימת את כל הלימוד!'
                            : gap <= 0
                                ? 'אתה בקצב מצוין! נותרו ${maxInt(0, pace.requiredPerDay)} פרקים להיום'
                                : 'פיגור של $gap פרקים מהיעד',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('רצף: ${state.streak()} ימים'),
                      Text('קצב נדרש: ${pace.requiredPerDay} פרקים ביום'),
                    ],
                  ),
                ),
              ),
            ),
            ProgressCard(completed: state.completedCount, total: state.totalSelected),
            for (final seder in data.sedarim) _seder(seder),
          ],
        ),
      ),
    );
  }

  Widget _seder(dynamic seder) {
    final selectedTractates = seder.tractates.where((t) => state.selected.contains(t.id)).toList();
    if (selectedTractates.isEmpty) return const SizedBox.shrink();
    return ExpansionTile(
      title: Text(seder.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        for (final tractate in selectedTractates)
          ExpansionTile(
            title: Text(tractate.name),
            subtitle: LinearProgressIndicator(
              value: state.completed.where((key) => key.startsWith('${tractate.id}:')).length / tractate.chapters,
            ),
            children: [
              for (var chapter = 1; chapter <= tractate.chapters; chapter++)
                ChapterTile(
                  tractateId: tractate.id,
                  chapter: chapter,
                  done: state.completed.contains('${tractate.id}:$chapter'),
                  onChanged: (value) => state.toggle(tractate.id, chapter, value),
                ),
            ],
          ),
      ],
    );
  }

  int maxInt(int a, int b) => a > b ? a : b;
}