import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  Database? _db;
  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final p = join(await getDatabasesPath(), 'mishnah_tracker.db');
    return openDatabase(p, version: 1, onCreate: (db, _) async {
      await db.execute('CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT)');
      await db.execute('CREATE TABLE selected_tractates(order_id INTEGER, tractate_id TEXT PRIMARY KEY)');
      await db.execute('CREATE TABLE progress(tractate_id TEXT, chapter INTEGER, completed_at INTEGER NOT NULL, PRIMARY KEY(tractate_id, chapter))');
      await db.execute('CREATE TABLE badges(badge_id TEXT PRIMARY KEY, earned_at INTEGER)');
      await db.execute('CREATE INDEX idx_progress_completed_at ON progress(completed_at)');
    });
  }

  Future<Map<String, String>> settings() async {
    final r = await (await db).query('settings');
    return {for (final x in r) x['key'] as String: x['value'] as String};
  }

  Future<void> setSetting(String key, String value) async => (await db).insert(
        'settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> setSelected(List<String> ids) async {
    final d = await db;
    await d.transaction((tx) async {
      await tx.delete('selected_tractates');
      for (var i = 0; i < ids.length; i++) {
        await tx.insert('selected_tractates', {'order_id': i, 'tractate_id': ids[i]});
      }
    });
  }

  Future<List<String>> selected() async {
    final r = await (await db).query('selected_tractates', orderBy: 'order_id');
    return r.map((e) => e['tractate_id'] as String).toList();
  }

  Future<void> toggleProgress(String id, int chapter, bool complete) async {
    final d = await db;
    if (complete) {
      await d.insert('progress', {
        'tractate_id': id,
        'chapter': chapter,
        'completed_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await d.delete('progress', where: 'tractate_id=? AND chapter=?', whereArgs: [id, chapter]);
    }
  }

  Future<Set<String>> completedKeys() async {
    final r = await (await db).query('progress');
    return r.map((e) => '${e['tractate_id']}:${e['chapter']}').toSet();
  }

  Future<List<DateTime>> completionDates() async {
    final r = await (await db).query('progress');
    return r.map((e) => DateTime.fromMillisecondsSinceEpoch(e['completed_at'] as int)).toList();
  }

  Future<void> saveBadge(String id) async => (await db).insert(
        'badges', {'badge_id': id, 'earned_at': DateTime.now().millisecondsSinceEpoch},
        conflictAlgorithm: ConflictAlgorithm.ignore);

  Future<Set<String>> badges() async {
    final r = await (await db).query('badges');
    return r.map((e) => e['badge_id'] as String).toSet();
  }

  Future<Map<String, DateTime>> badgeEarnedAt() async {
    final r = await (await db).query('badges');
    return {for (final e in r)
      e['badge_id'] as String: DateTime.fromMillisecondsSinceEpoch(e['earned_at'] as int)};
  }

  Future<void> clearAll() async {
    final d = await db;
    await d.transaction((tx) async {
      await tx.delete('settings');
      await tx.delete('selected_tractates');
      await tx.delete('progress');
      await tx.delete('badges');
    });
  }

  Future<Map<String, dynamic>> exportAll() async {
    final d = await db;
    return {
      'version': 1,
      'settings': await settings(),
      'selected_tractates': await selected(),
      'progress': await d.query('progress'),
      'badges': await d.query('badges'),
    };
  }

  Future<void> importAll(Map<String, dynamic> data) async {
    final d = await db;
    await d.transaction((tx) async {
      await tx.delete('settings');
      await tx.delete('selected_tractates');
      await tx.delete('progress');
      await tx.delete('badges');
      for (final e in (data['settings'] as Map).entries) {
        await tx.insert('settings', {'key': e.key, 'value': '${e.value}'});
      }
      var i = 0;
      for (final id in (data['selected_tractates'] as List)) {
        await tx.insert('selected_tractates', {'order_id': i++, 'tractate_id': id});
      }
      for (final e in (data['progress'] as List)) {
        await tx.insert('progress', Map<String, Object?>.from(e));
      }
      for (final e in (data['badges'] as List)) {
        await tx.insert('badges', Map<String, Object?>.from(e));
      }
    });
  }

  Future<String> exportJson() async => jsonEncode(await exportAll());
}
