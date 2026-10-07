import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/app_state.dart';
import '../services/export_service.dart';
import '../widgets/dedication_banner.dart';

class SettingsScreen extends StatefulWidget {
  final AppState state;
  const SettingsScreen({super.key, required this.state});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController dedication;
  late final TextEditingController reminder;
  TimeOfDay time = const TimeOfDay(hour: 20, minute: 0);
  bool enabled = false;

  @override void initState() {
    super.initState();
    dedication = TextEditingController(text: widget.state.dedication);
    reminder = TextEditingController(text: widget.state.reminderText);
    enabled = widget.state.settings['reminder_enabled'] == 'true';
    final parts = (widget.state.settings['reminder_time'] ?? '20:00').split(':');
    if (parts.length == 2) time = TimeOfDay(hour: int.tryParse(parts[0]) ?? 20, minute: int.tryParse(parts[1]) ?? 0);
  }
  @override void dispose() { dedication.dispose(); reminder.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('הגדרות')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DedicationBanner(text: dedication.text),
            TextField(controller: dedication, maxLines: 3, decoration: const InputDecoration(labelText: 'נוסח הקדשה', border: OutlineInputBorder())),
            TextButton(
              onPressed: () => setState(() => dedication.text = '''הלימוד לעילוי נשמת ר' מאיר משה בן ר' בן ציון הלוי ומינקה בת ר' משה שמואל ע"ה'''),
              child: const Text('שחזר ברירת מחדל'),
            ),
            const Divider(),
            TextField(controller: reminder, maxLines: 2, decoration: const InputDecoration(labelText: 'נוסח תזכורת ({remaining} = מספר הפרקים להיום)', border: OutlineInputBorder())),
            SwitchListTile(title: const Text('תזכורת יומית'), value: enabled, onChanged: (v) => setState(() => enabled = v)),
            ListTile(
              title: const Text('שעת תזכורת'),
              subtitle: Text(time.format(context)),
              trailing: const Icon(Icons.schedule),
              onTap: enabled ? () async {
                final picked = await showTimePicker(context: context, initialTime: time);
                if (picked != null) setState(() => time = picked);
              } : null,
            ),
            const Divider(),
            ListTile(
              title: const Text('מצב תצוגה'),
              trailing: DropdownButton<ThemeMode>(
                value: widget.state.theme,
                items: const [
                  DropdownMenuItem(value: ThemeMode.light, child: Text('בהיר')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('כהה')),
                ],
                onChanged: (v) {
                  if (v != null) widget.state.setSetting('theme_mode', v == ThemeMode.dark ? 'dark' : 'light');
                },
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: _save, child: const Text('שמור')),
            OutlinedButton(onPressed: _backup, child: const Text('גיבוי נתונים ל‑JSON')),
            OutlinedButton(onPressed: _import, child: const Text('שחזור מגיבוי JSON')),
            OutlinedButton(onPressed: _exportPdf, child: const Text('ייצוא סיכום ל‑PDF')),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    await widget.state.setSetting('dedication_text', dedication.text.trim());
    await widget.state.setSetting('reminder_text', reminder.text.trim());
    await widget.state.setSetting('reminder_enabled', enabled.toString());
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    await widget.state.setSetting('reminder_time', hh + ':' + mm);
    if (enabled) {
      await widget.state.notifications.requestPermissions();
      final left = widget.state.pace().remaining;
      await widget.state.notifications.scheduleDaily(hour: time.hour, minute: time.minute, body: reminder.text.replaceAll('{remaining}', left.toString()));
    } else {
      await widget.state.notifications.cancel();
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _backup() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(dir.path + '/mishnah_backup.json');
    await file.writeAsString(jsonEncode(await widget.state.database.exportAll()));
    await ExportService().share(file);
  }

  Future<void> _import() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    final path = result?.files.single.path;
    if (path == null) return;
    try {
      final data = jsonDecode(await File(path).readAsString()) as Map<String, dynamic>;
      await widget.state.database.importAll(data);
      await widget.state.init();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('השחזור הושלם')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('קובץ הגיבוי אינו תקין: ' + error.toString())));
    }
  }

  Future<void> _exportPdf() async {
    final pace = widget.state.pace();
    final summary = 'הושלמו ' + widget.state.completedCount.toString() + ' מתוך ' +
        widget.state.totalSelected.toString() + ' פרקים. נותרו ' +
        pace.remaining.toString() + ' פרקים. רצף נוכחי: ' +
        widget.state.streak().toString() + ' ימים.';
    final file = await ExportService().exportPdf(
      dedication: widget.state.dedication,
      title: 'סיכום התקדמות בלימוד משנה',
      summary: summary,
    );
    await ExportService().share(file);
  }
}