import 'package:flutter/material.dart';
import '../data/database.dart';
import '../models/mishnah.dart';
import 'calculations.dart';
import 'notification_service.dart';

enum StatsRange { today, week, month, threeMonths, year, all }

class AppState extends ChangeNotifier {
  final AppDatabase database;
  final NotificationService notifications;
  MishnahData? data;
  Map<String, String> settings = {};
  Set<String> selected = {};
  Set<String> completed = {};
  List<DateTime> dates = [];
  Set<String> badges = {};
  Map<String, DateTime> badgeEarned = {};
  bool loading = true;

  AppState(this.database, this.notifications);

  String get dedication => settings['dedication_text'] ??
      'הלימוד לעילוי נשמת ר\' מאיר משה בן ר\' בן ציון הלוי ומינקה בת ר\' משה שמואל ע"ה';
  String get reminderText => settings['reminder_text'] ?? 'נותרו {remaining} פרקים להיום. זמן ללמוד!';
  int get planned => int.tryParse(settings['planned_per_day'] ?? '1') ?? 1;
  DateTime get target => DateTime.tryParse(settings['target_date'] ?? '') ?? DateTime.now();
  bool get onboardingDone => settings['onboarding_done'] == 'true';

  ThemeMode get theme => switch (settings['theme_mode']) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };

  Future<void> init() async {
    data = await MishnahData.load();
    settings = await database.settings();
    selected = (await database.selected()).toSet();
    completed = await database.completedKeys();
    dates = await database.completionDates();
    badges = await database.badges();
    badgeEarned = await database.badgeEarnedAt();
    loading = false;
    await checkBadges();
    notifyListeners();
  }

  int get totalSelected => selected.fold(0, (sum, id) => sum + data!.tractate(id).chapters);
  int get completedCount => completed.length;

  PaceResult pace() => calculatePace(
        total: totalSelected, completed: completedCount,
        today: DateTime.now(), target: target, plannedPerDay: planned);

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

  Future<void> setSelectedTractates(Set<String> ids) async {
    await database.setSelected(ids.toList());
    selected = ids;
    notifyListeners();
  }

  Future<List<String>> toggle(String id, int chapter, bool value) async {
    final before = Set<String>.from(badges);
    await database.toggleProgress(id, chapter, value);
    completed = await database.completedKeys();
    dates = await database.completionDates();
    await checkBadges();
    notifyListeners();
    return badges.difference(before).toList();
  }

  Future<List<String>> checkBadges() async {
    final before = Set<String>.from(badges);
    if (streak() >= 7) await database.saveBadge('streak7');
    if (weekCount() >= 7) await database.saveBadge('weekly_goal');
    for (final t in data!.sedarim.expand((s) => s.tractates).where((t) => selected.contains(t.id))) {
      final done = List.generate(t.chapters, (i) => '${t.id}:${i + 1}').every(completed.contains);
      if (done) await database.saveBadge('tractate_${t.id}');
    }
    badges = await database.badges();
    badgeEarned = await database.badgeEarnedAt();
    return badges.difference(before).toList();
  }

  int streak() => streakFromDays(dates);

  int bestStreak() {
    final days = dates.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList()..sort();
    if (days.isEmpty) return 0;
    var best = 1, current = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        current++;
        if (current > best) best = current;
      } else {
        current = 1;
      }
    }
    return best;
  }

  int weekCount() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday % 7));
    return dates.where((d) => !d.isBefore(start)).length;
  }

  List<DateTime> datesForRange(StatsRange range) {
    if (range == StatsRange.all) return dates;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = switch (range) {
      StatsRange.today => 0,
      StatsRange.week => 6,
      StatsRange.month => 29,
      StatsRange.threeMonths => 89,
      StatsRange.year => 364,
      StatsRange.all => 0,
    };
    final start = today.subtract(Duration(days: days));
    return dates.where((d) => !DateTime(d.year, d.month, d.day).isBefore(start)).toList();
  }

  int countForRange(StatsRange range) => datesForRange(range).length;

  double averageForRange(StatsRange range) {
    final days = switch (range) {
      StatsRange.today => 1,
      StatsRange.week => 7,
      StatsRange.month => 30,
      StatsRange.threeMonths => 90,
      StatsRange.year => 365,
      StatsRange.all => ((DateTime.now().difference(
                DateTime.tryParse(settings['start_date'] ?? '') ?? DateTime.now())).inDays + 1).clamp(1, 100000),
    };
    return countForRange(range) / days;
  }

  List<int> weekdayCounts(StatsRange range) {
    final r = List<int>.filled(7, 0);
    for (final d in datesForRange(range)) r[d.weekday % 7]++;
    return r;
  }

  List<int> sederProgress() => data!.sedarim.map((s) => completed
      .where((key) => s.tractates.any((t) => key.startsWith('${t.id}:'))).length).toList();

  Future<void> resetAllData() async {
    await notifications.cancel();
    await database.clearAll();
    settings = {};
    selected = {};
    completed = {};
    dates = [];
    badges = {};
    badgeEarned = {};
    notifyListeners();
  }
}
