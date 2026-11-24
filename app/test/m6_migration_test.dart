@TestOn('vm')
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livebetter/data/db/database.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// v1 结构（无 `periodic_reminder_enabled` 列），与 v1 版本发布时一致。
const String _v1Schema = '''
CREATE TABLE habits (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  alias TEXT NULL,
  type TEXT NOT NULL,
  "required" INTEGER NOT NULL DEFAULT 0,
  enabled INTEGER NOT NULL DEFAULT 1,
  target_time TEXT NULL,
  goal INTEGER NULL,
  unit TEXT NULL,
  step INTEGER NULL,
  interval_days INTEGER NULL,
  bg_path TEXT NULL,
  sensitive INTEGER NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
CREATE TABLE records (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  habit_id TEXT NOT NULL REFERENCES habits (id),
  date TEXT NOT NULL,
  status TEXT NULL,
  amount INTEGER NULL,
  recorded_at TEXT NOT NULL,
  UNIQUE (habit_id, date)
);
CREATE TABLE app_settings (
  id INTEGER NOT NULL DEFAULT 1 PRIMARY KEY,
  strict_mode INTEGER NOT NULL DEFAULT 0,
  reminder_enabled INTEGER NOT NULL DEFAULT 1,
  reminder_time TEXT NOT NULL DEFAULT '22:45',
  hide_sensitive_names INTEGER NOT NULL DEFAULT 1,
  app_lock_enabled INTEGER NOT NULL DEFAULT 0,
  pin_hash TEXT NULL,
  gender TEXT NOT NULL DEFAULT 'female',
  theme TEXT NOT NULL DEFAULT 'green',
  period_enabled INTEGER NOT NULL DEFAULT 0,
  period_start TEXT NULL,
  period_length INTEGER NOT NULL DEFAULT 5,
  cycle_length INTEGER NOT NULL DEFAULT 28
);
''';

void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('livebetter_migration_');
    dbFile = File(p.join(tempDir.path, 'v1.sqlite'));
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('v1 → v2 迁移后数据完整且新增列取默认值', () async {
    final raw = sqlite3.open(dbFile.path);
    raw.execute(_v1Schema);
    raw.execute('PRAGMA user_version = 1');
    raw.execute('''
      INSERT INTO habits (id, name, type, "required", enabled, target_time,
        sensitive, sort_order, created_at, updated_at)
      VALUES ('sleep_early', '早睡', 'active', 1, 1, '23:30', 0, 1,
        '2026-01-01', '2026-01-01T00:00:00.000');
    ''');
    raw.execute('''
      INSERT INTO habits (id, name, type, "required", enabled, alias,
        sensitive, sort_order, created_at, updated_at)
      VALUES ('no_fap', '禁飞', 'passive', 0, 1, '自律项', 1, 2,
        '2026-01-01', '2026-01-01T00:00:00.000');
    ''');
    raw.execute('''
      INSERT INTO records (habit_id, date, status, recorded_at)
      VALUES ('sleep_early', '2026-11-20', 'success', '2026-11-20T23:00:00.000');
    ''');
    raw.execute('''
      INSERT INTO records (habit_id, date, amount, recorded_at)
      VALUES ('sleep_early', '2026-11-21', NULL, '2026-11-21T23:00:00.000');
    ''');
    raw.execute('''
      INSERT INTO app_settings (id, strict_mode, reminder_enabled, reminder_time,
        hide_sensitive_names, theme, period_length, cycle_length)
      VALUES (1, 1, 0, '22:30', 0, 'blue', 6, 30);
    ''');
    raw.close();

    final db = AppDatabase(NativeDatabase(dbFile));
    addTearDown(db.close);

    final habits = await db.habitDao.getAll();
    expect(habits.length, 2);
    expect(
      habits.firstWhere((row) => row.id == 'sleep_early').name,
      '早睡',
    );

    final records = await db.recordDao.all();
    expect(records.length, 2);
    expect(records.map((row) => row.date), ['2026-11-20', '2026-11-21']);

    final settings = await db.settingsDao.find();
    expect(settings, isNotNull);
    // 旧字段保留
    expect(settings!.strictMode, isTrue);
    expect(settings.reminderTime, '22:30');
    expect(settings.theme, 'blue');
    expect(settings.periodLength, 6);
    expect(settings.cycleLength, 30);
    // 新增列取默认值 true
    expect(settings.periodicReminderEnabled, isTrue);

    final version = await db
        .customSelect('PRAGMA user_version')
        .map((row) => row.read<int>('user_version'))
        .getSingle();
    expect(version, 2);
  });

  test('全新安装直接建立 v2 结构并写入默认数据', () async {
    final db = AppDatabase(NativeDatabase(dbFile));
    addTearDown(db.close);

    final habits = await db.habitDao.getAll();
    expect(habits.length, 5);
    expect(habits.first.id, 'sleep_early');

    final settings = await db.settingsDao.find();
    expect(settings, isNotNull);
    expect(settings!.periodicReminderEnabled, isTrue);
  });
}
