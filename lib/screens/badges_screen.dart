import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../widgets/dedication_banner.dart';

class BadgesScreen extends StatelessWidget {
  final AppState state;
  const BadgesScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final tractates = state.data!.sedarim.expand((s) => s.tractates)
        .where((t) => state.selected.contains(t.id));
    return Scaffold(
      appBar: AppBar(title: const Text('תגים')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(padding: const EdgeInsets.all(12), children: [
          DedicationBanner(text: state.dedication),
          const Card(child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(children: [
              Icon(Icons.info_outline), SizedBox(width: 10),
              Expanded(child: Text('תגים נפתחים אוטומטית כשאתה מגיע ליעד. אין צורך ללחוץ על כלום.')),
            ]),
          )),
          _badge(context, 'streak7', '7 ימי רצף', 'למדת לפחות פעם אחת במשך 7 ימים רצופים', Icons.local_fire_department),
          _badge(context, 'weekly_goal', 'יעד שבועי', 'השלמת לפחות 7 פרקים בשבוע', Icons.flag),
          for (final t in tractates)
            _badge(context, 'tractate_${t.id}', 'סיום מסכת ${t.name}',
              'השלמת את כל ${t.chapters} פרקי המסכת', Icons.menu_book),
        ]),
      ),
    );
  }

  Widget _badge(BuildContext context, String id, String title, String condition, IconData icon) {
    final earned = state.badges.contains(id);
    final date = state.badgeEarned[id];
    final color = earned ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline;
    return Card(
      color: earned ? Theme.of(context).colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: earned ? color : color.withValues(alpha: .15),
            foregroundColor: earned ? Colors.white : color,
            child: Icon(earned ? icon : Icons.lock_outline),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(condition, style: TextStyle(color: earned ? null : color)),
            if (date != null) ...[
              const SizedBox(height: 4),
              Text('נפתח בתאריך ${date.day}/${date.month}/${date.year}',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ])),
          Icon(earned ? Icons.verified : Icons.lock, color: color),
        ]),
      ),
    );
  }
}
