import 'package:flutter/material.dart';
import '../data/database.dart';
import '../models/mishnah.dart';
import 'calculations.dart';
import 'notification_service.dart';

class AppState extends ChangeNotifier {
  final AppDatabase database;
  final NotificationService notifications;
  MishnahData? data;
  Map<String, String> settings = {};
  Set<String> selected = {};
  Set<String> completed = {};
  List<DateTime> dates = [];
  Set<String> badges = {};
  bool loading = true;

  AppState(this.database, this.notifications);

  String get dedication => settings['dedication_text'] ?? '''הלימוד לעילוי נשמת ר' מאיר משה בן ר' בן ציון הלוי ומינקה בת ר' משה שמואל ע"ה''';
  String get reminderText => settings['reminder_text'] ?? 'נותרו {remaining} פרקים להיום. זמן ללמוד!';
  int get planned => int.tryParse(settings['planned_per_day'] ?? '1') ?? 1;
  DateTime get target => DateTime.tryParse(settings['target_date'] ?? '') ?? DateTime.now();
  bool get onboardingDone => settings['onboarding_done'] == 'true';
  ThemeMode get theme => settings['theme_mode'] == 'dark' ? ThemeMode.dark : ThemeMode.light;

  Future<void> init() async {
    data = await MishnahData.load();
    settings = await database.settings();
    selected = (await database.selected()).toSet();
    completed = await database.completedKeys();
    dates = await database.completionDates();
    badges = await database.badges();
    loading = false;
    notifyListeners();
  }

  int get totalSelected => selected.fold(0, (sum, id) => sum + (data?.tractate(id).chapters ?? 0));
  int get completedCount => completed.length;

  PaceResult pace() => calculatePace(
    total: totalSelected,
    completed: completedCount,
    today: DateTime.now(),
    target: target,
    plannedPerDay: planned,
  );

  Future<void> setSetting(String key, String value) async {
    await database.setSetting(key, value);
    settings[key] = value;
    notifyListeners();
  }

  Future<void> finishOnboarding({required Set<String> ids, required DateTime targetDate, required int perDay}) async {
    final now = DateTime.now().toIso8601String();
    await database.setSelected(ids.toList());
    await database.setSetting('target_date', targetDate.toIso8601String());
    await database.setSetting('start_date', now);
    await database.setSetting('planned_per_day', perDay.toString());
    await database.setSetting('onboarding_done', 'true');
    selected = ids;
    settings['target_date'] = targetDate.toIso8601String();
    settings['start_date'] = now;
    settings['planned_per_day'] = perDay.toString();
    settings['onboarding_done'] = 'true';
    notifyListeners();
  }

  Future<void> toggle(String id, int chapter, bool value) async {
    await database.toggleProgress(id, chapter, value);
    completed = await database.completedKeys();
    dates = await database.completionDates();
    await checkBadges();
    notifyListeners();
  }

  Future<void> checkBadges() async {
    if (streak() >= 7) await database.saveBadge('streak7');
    if (weekCount() >= 7) await database.saveBadge('weekly_goal');
    final completeTracts = data!.sedarim.expand((s) => s.tractates)
        .where((t) => selected.contains(t.id))
        .where((t) => List.generate(t.chapters, (i) => t.id + ':' + (i + 1).toString()).every(completed.contains));
    for (final tractate in completeTracts) {
      await database.saveBadge('tractate_' + tractate.id);
    }
    badges = await database.badges();
  }

  int streak() => streakFromDays(dates);

  int weekCount() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday % 7));
    return dates.where((d) => !d.isBefore(start)).length;
  }

  List<int> weekly() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = List<int>.filled(7, 0);
    for (final date in dates) {
      final diff = DateTime(date.year, date.month, date.day).difference(today).inDays;
      if (diff <= 0 && diff > -7) result[date.weekday % 7]++;
    }
    return result;
  }
}